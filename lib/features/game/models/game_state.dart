import '../../../domain/level/cell_pos.dart';
import '../../../domain/level/level_config.dart';
import 'cell_mark.dart';

enum GameStatus {
  playing,
  won,
  lost,
}

class GameState {
  final LevelConfig level;
  final Map<CellPos, CellMark> marks;
  final int lives;
  final int maxLives;
  final int score;
  final Duration elapsedTime;
  final GameStatus status;
  final CellPos? lastErrorCell;
  final CellPos? lastSuccessCell;
  final int errorKey; // increments to trigger shake animation
  final bool autoXAfterQueen;
  final int autoPlaceRemaining;
  final int hintsRemaining;
  final int hintsUsedCount;
  final CellPos? highlightedCell;
  final String? hintExplanation;

  const GameState({
    required this.level,
    required this.marks,
    this.lives = 3,
    this.maxLives = 3,
    this.score = 0,
    this.elapsedTime = Duration.zero,
    this.status = GameStatus.playing,
    this.lastErrorCell,
    this.lastSuccessCell,
    this.errorKey = 0,
    this.autoXAfterQueen = true,
    this.autoPlaceRemaining = 5,
    this.hintsRemaining = 5,
    this.hintsUsedCount = 0,
    this.highlightedCell,
    this.hintExplanation,
  });

  CellMark getMarkAt(CellPos pos) => marks[pos] ?? CellMark.empty;

  bool isGiven(CellPos pos) => level.givens.contains(pos);

  int get queensPlacedCount {
    int count = 0;
    marks.forEach((_, mark) {
      if (mark == CellMark.queen) count++;
    });
    return count;
  }

  Set<int> get completedRegions {
    final set = <int>{};
    marks.forEach((pos, mark) {
      if (mark == CellMark.queen) {
        set.add(level.getRegionAt(pos));
      }
    });
    return set;
  }

  GameState copyWith({
    LevelConfig? level,
    Map<CellPos, CellMark>? marks,
    int? lives,
    int? maxLives,
    int? score,
    Duration? elapsedTime,
    GameStatus? status,
    CellPos? lastErrorCell,
    bool clearLastError = false,
    CellPos? lastSuccessCell,
    bool clearLastSuccess = false,
    int? errorKey,
    bool? autoXAfterQueen,
    int? autoPlaceRemaining,
    int? hintsRemaining,
    int? hintsUsedCount,
    CellPos? highlightedCell,
    bool clearHighlight = false,
    String? hintExplanation,
    bool clearHintExplanation = false,
  }) {
    return GameState(
      level: level ?? this.level,
      marks: marks ?? this.marks,
      lives: lives ?? this.lives,
      maxLives: maxLives ?? this.maxLives,
      score: score ?? this.score,
      elapsedTime: elapsedTime ?? this.elapsedTime,
      status: status ?? this.status,
      lastErrorCell: clearLastError ? null : (lastErrorCell ?? this.lastErrorCell),
      lastSuccessCell: clearLastSuccess ? null : (lastSuccessCell ?? this.lastSuccessCell),
      errorKey: errorKey ?? this.errorKey,
      autoXAfterQueen: autoXAfterQueen ?? this.autoXAfterQueen,
      autoPlaceRemaining: autoPlaceRemaining ?? this.autoPlaceRemaining,
      hintsRemaining: hintsRemaining ?? this.hintsRemaining,
      hintsUsedCount: hintsUsedCount ?? this.hintsUsedCount,
      highlightedCell: clearHighlight ? null : (highlightedCell ?? this.highlightedCell),
      hintExplanation: clearHintExplanation ? null : (hintExplanation ?? this.hintExplanation),
    );
  }
}

