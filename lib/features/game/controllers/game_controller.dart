import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/audio/sound_service.dart';
import '../../../core/storage/progress_repository.dart';
import '../../../domain/generator/level_generator.dart';
import '../../../domain/level/cell_pos.dart';
import '../../../domain/level/level_config.dart';
import '../../../domain/scoring/score_calculator.dart';
import '../../streak/repositories/streak_repository.dart';
import '../models/cell_mark.dart';
import '../models/game_state.dart';

/// Game controller handling game logic, timer, and persistence.
class GameController extends StateNotifier<GameState> {
  Timer? _timer;
  final ProgressRepository _progressRepo;
  final StreakRepository? _streakRepo;

  GameController({
    required LevelConfig initialLevel,
    ProgressRepository? progressRepo,
    StreakRepository? streakRepo,
  })  : _progressRepo = progressRepo ?? LocalProgressRepository(),
        _streakRepo = streakRepo,
        super(_createInitialState(initialLevel)) {
    _initFromStorage();
    _startTimer();
  }

  static GameState _createInitialState(LevelConfig level) {
    final marks = <CellPos, CellMark>{};
    for (final given in level.givens) {
      marks[given] = CellMark.queen;
    }
    return GameState(
      level: level,
      marks: marks,
      lives: 3,
      maxLives: 3,
      score: 0,
      elapsedTime: Duration.zero,
      status: GameStatus.playing,
    );
  }

  Future<void> _initFromStorage() async {
    final progress = await _progressRepo.loadProgress();
    if (!mounted) return;
    state = state.copyWith(
      autoPlaceRemaining: progress.autoPlaceBoosters,
      hintsRemaining: progress.hintBoosters,
      autoXAfterQueen: progress.autoXAfterQueen,
    );
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.status == GameStatus.playing) {
        state = state.copyWith(
          elapsedTime: state.elapsedTime + const Duration(seconds: 1),
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void loadLevel(int levelNumber) {
    final level = LevelGenerator.generateLevel(levelNumber: levelNumber);
    state = _createInitialState(level).copyWith(
      autoPlaceRemaining: state.autoPlaceRemaining,
      hintsRemaining: state.hintsRemaining,
      autoXAfterQueen: state.autoXAfterQueen,
    );
    _startTimer();
  }

  void restartLevel() {
    loadLevel(state.level.levelNumber);
  }

  /// Single tap on cell: toggles X mark or clears existing mark.
  void tapCell(CellPos pos) {
    if (state.status != GameStatus.playing) return;
    if (state.isGiven(pos)) return;

    final currentMark = state.getMarkAt(pos);
    final newMarks = Map<CellPos, CellMark>.from(state.marks);

    if (currentMark.isX) {
      newMarks.remove(pos);
    } else if (currentMark == CellMark.queen) {
      newMarks.remove(pos);
    } else {
      newMarks[pos] = CellMark.xMark;
    }

    state = state.copyWith(
      marks: newMarks,
      clearLastError: true,
      clearHighlight: true,
      clearHintExplanation: true,
    );
  }

  /// Double tap on cell: places Queen if correct, or triggers penalty if incorrect.
  void doubleTapCell(CellPos pos) {
    if (state.status != GameStatus.playing) return;
    if (state.isGiven(pos)) return;

    final currentMark = state.getMarkAt(pos);
    if (currentMark == CellMark.queen) {
      final newMarks = Map<CellPos, CellMark>.from(state.marks)..remove(pos);
      state = state.copyWith(marks: newMarks);
      return;
    }

    final isCorrect = state.level.solution.contains(pos);
    if (isCorrect) {
      _applyCorrectQueen(pos);
    } else {
      _applyIncorrectQueen(pos);
    }
  }

  /// Drag interaction: quickly paints empty cells as X.
  void dragMarkX(CellPos pos) {
    if (state.status != GameStatus.playing) return;
    if (state.isGiven(pos)) return;
    if (state.getMarkAt(pos) != CellMark.empty) return;

    final newMarks = Map<CellPos, CellMark>.from(state.marks);
    newMarks[pos] = CellMark.xMark;
    state = state.copyWith(marks: newMarks);
  }

  void _applyCorrectQueen(CellPos pos) {
    final newMarks = Map<CellPos, CellMark>.from(state.marks);
    newMarks[pos] = CellMark.queen;

    if (state.autoXAfterQueen) {
      _autoFillX(newMarks, pos);
    }

    // Check if won
    bool won = true;
    for (final solQueen in state.level.solution) {
      if (newMarks[solQueen] != CellMark.queen) {
        won = false;
        break;
      }
    }

    int newScore = state.score + 100;
    if (won) {
      SoundService.playWin();
      // Auto-fill all remaining empty cells with AutoX like in the original video
      for (int r = 0; r < state.level.n; r++) {
        for (int c = 0; c < state.level.n; c++) {
          final p = CellPos(r, c);
          if (newMarks[p] != CellMark.queen) {
            newMarks[p] = CellMark.autoXMark;
          }
        }
      }

      _timer?.cancel();
      final breakdown = ScoreCalculator.calculate(
        n: state.level.n,
        elapsed: state.elapsedTime,
        livesLeft: state.lives,
        hintsUsed: state.hintsUsedCount,
      );
      newScore = breakdown.totalScore;

      // Save victory progress
      _progressRepo.recordLevelVictory(
        levelNumber: state.level.levelNumber,
        score: newScore,
        time: state.elapsedTime,
      );

      // Record daily streak
      if (_streakRepo != null) {
        _streakRepo!.recordDayPlayed(DateTime.now());
      }
    } else {
      SoundService.playQueen();
      SoundService.playMeow();
    }

    state = state.copyWith(
      marks: newMarks,
      score: newScore,
      lastSuccessCell: pos,
      clearLastError: true,
      status: won ? GameStatus.won : GameStatus.playing,
    );
  }

  void _applyIncorrectQueen(CellPos pos) {
    SoundService.playError();
    final newLives = state.lives - 1;
    final isLost = newLives <= 0;
    if (isLost) {
      _timer?.cancel();
    }

    state = state.copyWith(
      lives: newLives,
      lastErrorCell: pos,
      errorKey: state.errorKey + 1,
      status: isLost ? GameStatus.lost : GameStatus.playing,
    );

    if (!isLost) {
      Future.delayed(const Duration(milliseconds: 900), () {
        if (mounted && state.lastErrorCell == pos) {
          state = state.copyWith(clearLastError: true);
        }
      });
    }
  }

  void _autoFillX(Map<CellPos, CellMark> marksMap, CellPos queenPos) {
    final n = state.level.n;
    final qRegion = state.level.getRegionAt(queenPos);

    for (int r = 0; r < n; r++) {
      for (int c = 0; c < n; c++) {
        final p = CellPos(r, c);
        if (p == queenPos) continue;
        if (marksMap[p] == CellMark.queen) continue;

        if (r == queenPos.row ||
            c == queenPos.col ||
            state.level.getRegionAt(p) == qRegion ||
            queenPos.isAdjacent8(p)) {
          marksMap[p] = CellMark.autoXMark;
        }
      }
    }
  }

  /// Booster 1: AutoPlace — automatically places one remaining correct queen.
  bool useAutoPlace() {
    if (state.status != GameStatus.playing) return false;
    if (state.autoPlaceRemaining <= 0) return false;

    CellPos? targetQueen;
    for (final q in state.level.solution) {
      if (state.getMarkAt(q) != CellMark.queen) {
        targetQueen = q;
        break;
      }
    }
    if (targetQueen == null) return false;

    state = state.copyWith(autoPlaceRemaining: state.autoPlaceRemaining - 1);
    _progressRepo.consumeBooster(autoPlace: true);
    _applyCorrectQueen(targetQueen);
    return true;
  }

  /// Booster 2: Hint — highlights a logical next move with explanation.
  bool useHint() {
    if (state.status != GameStatus.playing) return false;
    if (state.hintsRemaining <= 0) return false;

    CellPos? targetQueen;
    for (final q in state.level.solution) {
      if (state.getMarkAt(q) != CellMark.queen) {
        targetQueen = q;
        break;
      }
    }
    if (targetQueen == null) return false;

    final reg = state.level.getRegionAt(targetQueen);
    final explanation =
        'Hint: Color region ${reg + 1} needs 1 cat at row ${targetQueen.row + 1}, col ${targetQueen.col + 1}!';

    state = state.copyWith(
      hintsRemaining: state.hintsRemaining - 1,
      hintsUsedCount: state.hintsUsedCount + 1,
      highlightedCell: targetQueen,
      hintExplanation: explanation,
    );
    _progressRepo.consumeBooster(hint: true);
    return true;
  }

  void toggleAutoX(bool enabled) {
    state = state.copyWith(autoXAfterQueen: enabled);
    _progressRepo.setAutoX(enabled);
  }
}

final gameControllerProvider = StateNotifierProvider.family<GameController, GameState, int>((ref, levelNumber) {
  final level = LevelGenerator.generateLevel(levelNumber: levelNumber);
  final repo = ref.watch(progressRepositoryProvider);
  return GameController(initialLevel: level, progressRepo: repo, streakRepo: StreakRepository());
});
