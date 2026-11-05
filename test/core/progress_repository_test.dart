import 'package:cat_queens/core/storage/progress_repository.dart';
import 'package:cat_queens/core/storage/storage_service.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeStorageService implements StorageService {
  final Map<String, Map<String, dynamic>> _data = {};

  @override
  Future<void> init() async {}

  @override
  Future<void> set<T>(String box, String key, T value) async {
    _data.putIfAbsent(box, () => {})[key] = value;
  }

  @override
  T? get<T>(String box, String key, [T? defaultValue]) {
    final val = _data[box]?[key];
    if (val is T) return val;
    return defaultValue;
  }

  @override
  Future<void> remove(String box, String key) async {
    _data[box]?.remove(key);
  }

  @override
  Future<void> clear(String box) async {
    _data[box]?.clear();
  }
}

void main() {
  group('ProgressRepository', () {
    late StorageService fakeStorage;
    late ProgressRepository repo;

    setUp(() {
      fakeStorage = FakeStorageService();
      repo = LocalProgressRepository(fakeStorage);
    });

    test('loads default progress on first launch', () async {
      final progress = await repo.loadProgress();

      expect(progress.currentLevel, 1);
      expect(progress.highestLevelUnlocked, 1);
      expect(progress.totalScore, 0);
      expect(progress.autoPlaceBoosters, 5);
      expect(progress.hintBoosters, 5);
      expect(progress.undoBoosters, 0);
      expect(progress.autoXAfterQueen, isTrue);
    });

    test('records level victory, updates unlocked level and high scores', () async {
      await repo.recordLevelVictory(
        levelNumber: 1,
        score: 1200,
        time: const Duration(seconds: 40),
      );

      var progress = await repo.loadProgress();
      expect(progress.currentLevel, 2);
      expect(progress.highestLevelUnlocked, 2);
      expect(progress.totalScore, 1200);
      expect(progress.levelHighScores[1], 1200);
      expect(progress.levelBestTimesSeconds[1], 40);

      // Replaying level 1 does not downgrade active or highest level
      await repo.recordLevelVictory(
        levelNumber: 1,
        score: 1300,
        time: const Duration(seconds: 35),
      );
      progress = await repo.loadProgress();
      expect(progress.currentLevel, 2);
      expect(progress.highestLevelUnlocked, 2);

      // Beating level 2 advances to level 3
      await repo.recordLevelVictory(
        levelNumber: 2,
        score: 1400,
        time: const Duration(seconds: 50),
      );
      progress = await repo.loadProgress();
      expect(progress.currentLevel, 3);
      expect(progress.highestLevelUnlocked, 3);
    });

    test('unlocks undo boosters upon reaching level 21', () async {
      await repo.recordLevelVictory(
        levelNumber: 20,
        score: 1500,
        time: const Duration(seconds: 90),
      );

      final progress = await repo.loadProgress();
      expect(progress.highestLevelUnlocked, 21);
      expect(progress.undoBoosters, 3); // Unlocked at level 21!
    });

    test('consumes and adds boosters accurately', () async {
      await repo.consumeBooster(autoPlace: true);
      var progress = await repo.loadProgress();
      expect(progress.autoPlaceBoosters, 4);

      await repo.consumeBooster(hint: true);
      progress = await repo.loadProgress();
      expect(progress.hintBoosters, 4);

      await repo.addBoosters(autoPlace: 3, hint: 2);
      progress = await repo.loadProgress();
      expect(progress.autoPlaceBoosters, 7);
      expect(progress.hintBoosters, 6);
    });

    test('updates autoX setting and persists it', () async {
      await repo.setAutoX(false);
      var progress = await repo.loadProgress();
      expect(progress.autoXAfterQueen, isFalse);

      await repo.setAutoX(true);
      progress = await repo.loadProgress();
      expect(progress.autoXAfterQueen, isTrue);
    });
  });
}

