import 'package:hive/hive.dart';
import '../models/daily_challenge.dart';

/// Repository for handling the daily challenge persistence.
class DailyChallengeRepository {
  static const String _boxName = 'daily_challenge_box';

  Future<Box<DailyChallenge>> _openBox() async => await Hive.openBox<DailyChallenge>(_boxName);

  /// Load today's challenge (by date). If none exists, create a new one.
  Future<DailyChallenge> loadTodayChallenge() async {
    final box = await _openBox();
    final todayKey = _todayKey();
    if (box.containsKey(todayKey)) {
      return box.get(todayKey)!;
    }
    // For simplicity, generate a level number based on day of year (1‑70).
    final now = DateTime.now();
    final dayOfYear = int.parse('${now.month}${now.day}');
    final levelNumber = (dayOfYear % 70) + 1; // keep within 1‑71 range
    final challenge = DailyChallenge(levelNumber: levelNumber, seed: now.toIso8601String());
    await box.put(todayKey, challenge);
    return challenge;
  }

  Future<void> recordBestTime(Duration time) async {
    final box = await _openBox();
    final todayKey = _todayKey();
    final challenge = box.get(todayKey);
    if (challenge == null) return;
    if (challenge.bestTime == null || time < challenge.bestTime!) {
      challenge.bestTime = time;
      await challenge.save();
    }
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }
}

