import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'game_progress.dart';
import 'hive_storage_service.dart';
import 'storage_service.dart';

abstract class ProgressRepository {
  Future<GameProgress> loadProgress();
  Future<void> saveProgress(GameProgress progress);
  Future<void> recordLevelVictory({
    required int levelNumber,
    required int score,
    required Duration time,
  });
  Future<void> consumeBooster({bool autoPlace = false, bool hint = false, bool undo = false});
  Future<void> addBoosters({int autoPlace = 0, int hint = 0, int undo = 0});
  Future<void> setAutoX(bool enabled);
  Stream<GameProgress> get progressStream;
}

class LocalProgressRepository implements ProgressRepository {
  static const String boxName = 'catqueens_progress';
  static const String key = 'progress_data';

  static LocalProgressRepository? _sharedInstance;

  final StorageService _storage;
  GameProgress? _cached;
  final StreamController<GameProgress> _streamController = StreamController<GameProgress>.broadcast();

  factory LocalProgressRepository([StorageService? storage]) {
    if (storage != null) {
      return LocalProgressRepository._internal(storage);
    }
    _sharedInstance ??= LocalProgressRepository._internal(HiveStorageService());
    return _sharedInstance!;
  }

  LocalProgressRepository._internal(this._storage);

  @override
  Stream<GameProgress> get progressStream => _streamController.stream;

  @override
  Future<GameProgress> loadProgress() async {
    if (_cached != null) return _cached!;

    try {
      await _storage.init();
      final raw = _storage.get<String>(boxName, key);
      if (raw != null) {
        final Map<String, dynamic> json = jsonDecode(raw);
        _cached = GameProgress.fromJson(json);
        return _cached!;
      }
    } catch (_) {
      // In case of parsing error, return default
    }

    _cached = const GameProgress();
    return _cached!;
  }

  @override
  Future<void> saveProgress(GameProgress progress) async {
    _cached = progress;
    try {
      await _storage.init();
      final raw = jsonEncode(progress.toJson());
      await _storage.set<String>(boxName, key, raw);
    } catch (_) {
      // In-memory cache ensures continuity even if disk IO fails in tests
    }
    if (!_streamController.isClosed) {
      _streamController.add(progress);
    }
  }

  @override
  Future<void> recordLevelVictory({
    required int levelNumber,
    required int score,
    required Duration time,
  }) async {
    final current = await loadProgress();

    final nextLevel = levelNumber + 1;
    final highest = nextLevel > current.highestLevelUnlocked
        ? nextLevel
        : current.highestLevelUnlocked;

    final updatedScores = Map<int, int>.from(current.levelHighScores);
    final previousBestScore = updatedScores[levelNumber] ?? 0;
    if (score > previousBestScore) {
      updatedScores[levelNumber] = score;
    }

    final updatedTimes = Map<int, int>.from(current.levelBestTimesSeconds);
    final previousBestTime = updatedTimes[levelNumber] ?? 999999;
    if (time.inSeconds < previousBestTime) {
      updatedTimes[levelNumber] = time.inSeconds;
    }

    // Unlock Undo booster automatically if reached Level 21!
    final undoCount = highest >= 21 && current.undoBoosters == 0
        ? 3
        : current.undoBoosters;

    final updated = current.copyWith(
      currentLevel: highest,
      highestLevelUnlocked: highest,
      totalScore: current.totalScore + score,
      levelHighScores: updatedScores,
      levelBestTimesSeconds: updatedTimes,
      undoBoosters: undoCount,
    );

    await saveProgress(updated);
  }

  @override
  Future<void> consumeBooster({
    bool autoPlace = false,
    bool hint = false,
    bool undo = false,
  }) async {
    final current = await loadProgress();
    final updated = current.copyWith(
      autoPlaceBoosters: autoPlace
          ? (current.autoPlaceBoosters - 1).clamp(0, 999)
          : current.autoPlaceBoosters,
      hintBoosters: hint
          ? (current.hintBoosters - 1).clamp(0, 999)
          : current.hintBoosters,
      undoBoosters: undo
          ? (current.undoBoosters - 1).clamp(0, 999)
          : current.undoBoosters,
    );
    await saveProgress(updated);
  }

  @override
  Future<void> addBoosters({
    int autoPlace = 0,
    int hint = 0,
    int undo = 0,
  }) async {
    final current = await loadProgress();
    final updated = current.copyWith(
      autoPlaceBoosters: current.autoPlaceBoosters + autoPlace,
      hintBoosters: current.hintBoosters + hint,
      undoBoosters: current.undoBoosters + undo,
    );
    await saveProgress(updated);
  }

  @override
  Future<void> setAutoX(bool enabled) async {
    final current = await loadProgress();
    await saveProgress(current.copyWith(autoXAfterQueen: enabled));
  }
}

// Global Providers
final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  return LocalProgressRepository();
});

final progressFutureProvider = StreamProvider<GameProgress>((ref) async* {
  final repo = ref.watch(progressRepositoryProvider);
  final initial = await repo.loadProgress();
  yield initial;
  yield* repo.progressStream;
});
