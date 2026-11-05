import 'package:cat_queens/core/storage/game_progress.dart';
import 'package:cat_queens/core/storage/progress_repository.dart';
import 'package:cat_queens/domain/generator/level_generator.dart';
import 'package:cat_queens/domain/level/cell_pos.dart';
import 'package:cat_queens/domain/level/level_config.dart';
import 'package:cat_queens/features/game/controllers/game_controller.dart';
import 'package:cat_queens/features/game/models/cell_mark.dart';
import 'package:cat_queens/features/game/models/game_state.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeProgressRepo implements ProgressRepository {
  GameProgress _progress = const GameProgress();

  @override
  Future<GameProgress> loadProgress() async => _progress;

  @override
  Future<void> saveProgress(GameProgress progress) async => _progress = progress;

  @override
  Future<void> recordLevelVictory({required int levelNumber, required int score, required Duration time}) async {}

  @override
  Future<void> consumeBooster({bool autoPlace = false, bool hint = false, bool undo = false}) async {
    _progress = _progress.copyWith(
      autoPlaceBoosters: _progress.autoPlaceBoosters - (autoPlace ? 1 : 0),
      hintBoosters: _progress.hintBoosters - (hint ? 1 : 0),
    );
  }

  @override
  Future<void> addBoosters({int autoPlace = 0, int hint = 0, int undo = 0}) async {}

  @override
  Future<void> setAutoX(bool enabled) async {}

  @override
  Stream<GameProgress> get progressStream => const Stream.empty();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('GameController', () {
    late LevelConfig level1;
    late FakeProgressRepo fakeRepo;

    setUp(() {
      fakeRepo = FakeProgressRepo();
      level1 = LevelGenerator.generateLevel(levelNumber: 1);
    });

    test('initializes with level 1 givens, 3 lives, score 0, and playing status', () {
      final controller = GameController(initialLevel: level1, progressRepo: fakeRepo);
      final state = controller.state;

      expect(state.level.levelNumber, 1);
      expect(state.lives, 3);
      expect(state.score, 0);
      expect(state.status, GameStatus.playing);
      expect(state.autoPlaceRemaining, 5);
      expect(state.hintsRemaining, 5);

      for (final given in level1.givens) {
        expect(state.getMarkAt(given), CellMark.queen);
        expect(state.isGiven(given), isTrue);
      }
      controller.dispose();
    });

    test('single tap cycles empty -> xMark -> empty', () {
      final controller = GameController(initialLevel: level1, progressRepo: fakeRepo);
      final target = const CellPos(0, 0) == level1.givens.first
          ? const CellPos(0, 1)
          : const CellPos(0, 0);

      expect(controller.state.getMarkAt(target), CellMark.empty);

      controller.tapCell(target);
      expect(controller.state.getMarkAt(target), CellMark.xMark);

      controller.tapCell(target);
      expect(controller.state.getMarkAt(target), CellMark.empty);

      controller.dispose();
    });

    test('double tap on correct cell places queen and auto-fills X', () {
      final controller = GameController(initialLevel: level1, progressRepo: fakeRepo);
      final solutionQueen = level1.solution.firstWhere((p) => !level1.givens.contains(p));

      controller.doubleTapCell(solutionQueen);

      expect(controller.state.getMarkAt(solutionQueen), CellMark.queen);

      // Check auto-filled X in same row
      for (int c = 0; c < level1.n; c++) {
        final p = CellPos(solutionQueen.row, c);
        if (p != solutionQueen) {
          expect(controller.state.getMarkAt(p).isX, isTrue);
        }
      }

      controller.dispose();
    });

    test('double tap on incorrect cell deducts life and sets error indication', () {
      final controller = GameController(initialLevel: level1, progressRepo: fakeRepo);
      final wrongCell = [
        for (int r = 0; r < level1.n; r++)
          for (int c = 0; c < level1.n; c++) CellPos(r, c)
      ].firstWhere((p) => !level1.solution.contains(p));

      controller.doubleTapCell(wrongCell);

      expect(controller.state.lives, 2);
      expect(controller.state.lastErrorCell, wrongCell);
      expect(controller.state.status, GameStatus.playing);

      controller.dispose();
    });

    test('restarts level after losing all lives', () {
      final controller = GameController(initialLevel: level1, progressRepo: fakeRepo);
      final wrongCell = [
        for (int r = 0; r < level1.n; r++)
          for (int c = 0; c < level1.n; c++) CellPos(r, c)
      ].firstWhere((p) => !level1.solution.contains(p));

      controller.doubleTapCell(wrongCell);
      controller.doubleTapCell(wrongCell);
      controller.doubleTapCell(wrongCell);
      expect(controller.state.status, GameStatus.lost);

      controller.restartLevel();
      expect(controller.state.lives, 3);
      expect(controller.state.status, GameStatus.playing);

      controller.dispose();
    });

    test('AutoPlace booster places remaining correct queen and decrements count', () {
      final controller = GameController(initialLevel: level1, progressRepo: fakeRepo);
      expect(controller.state.autoPlaceRemaining, 5);

      final beforeQueenCount = controller.state.queensPlacedCount;
      final used = controller.useAutoPlace();
      expect(used, isTrue);

      expect(controller.state.autoPlaceRemaining, 4);
      expect(controller.state.queensPlacedCount, beforeQueenCount + 1);

      controller.dispose();
    });

    test('Hint booster highlights an unplaced solution cell and sets explanation', () {
      final controller = GameController(initialLevel: level1, progressRepo: fakeRepo);
      expect(controller.state.hintsRemaining, 5);
      expect(controller.state.highlightedCell, isNull);

      final used = controller.useHint();
      expect(used, isTrue);

      expect(controller.state.hintsRemaining, 4);
      expect(controller.state.highlightedCell, isNotNull);
      expect(level1.solution.contains(controller.state.highlightedCell!), isTrue);
      expect(controller.state.hintExplanation, contains('Hint:'));

      controller.dispose();
    });

    test('placing all queens wins the game and computes bonus score', () {
      final controller = GameController(initialLevel: level1, progressRepo: fakeRepo);

      for (final q in level1.solution) {
        if (!level1.givens.contains(q)) {
          controller.doubleTapCell(q);
        }
      }

      expect(controller.state.status, GameStatus.won);
      expect(controller.state.score, greaterThan(300));

      controller.dispose();
    });
  });
}
