import 'package:hive/hive.dart';
import '../models/streak_info.dart';

/// Repository handling daily streak persistence.
class StreakRepository {
  static const String _boxName = 'streak_box';

  Future<Box<StreakInfo>?> _openBox() async {
    try {
      return await Hive.openBox<StreakInfo>(_boxName);
    } catch (_) {
      return null;
    }
  }

  /// Load streak info, or create a new one if none exists.
  Future<StreakInfo> loadStreak() async {
    try {
      final box = await _openBox();
      if (box == null || box.isEmpty) {
        final info = StreakInfo();
        await box?.put('streak', info);
        return info;
      }
      return box.get('streak') ?? StreakInfo();
    } catch (_) {
      return StreakInfo();
    }
  }

  Future<void> saveStreak(StreakInfo info) async {
    try {
      final box = await _openBox();
      await box?.put('streak', info);
    } catch (_) {}
  }

  /// Call when a day is successfully played.
  Future<void> recordDayPlayed(DateTime today) async {
    try {
      final info = await loadStreak();
      final todayStr = _formatDate(today);
      if (info.lastPlayedDate == todayStr) return; // already recorded today

      // If previous day was yesterday, increase streak, otherwise reset.
      final yesterday = today.subtract(const Duration(days: 1));
      if (info.lastPlayedDate == _formatDate(yesterday)) {
        info.currentStreak += 1;
      } else {
        info.currentStreak = 1;
      }
      if (info.currentStreak > info.bestStreak) {
        info.bestStreak = info.currentStreak;
      }
      info.lastPlayedDate = todayStr;
      await saveStreak(info);
    } catch (_) {}
  }

  /// Call when a day is missed.
  Future<void> resetStreakIfMissed(DateTime today) async {
    try {
      final info = await loadStreak();
      final todayStr = _formatDate(today);
      if (info.lastPlayedDate == todayStr) return; // already updated today
      final yesterday = today.subtract(const Duration(days: 1));
      if (info.lastPlayedDate != _formatDate(yesterday)) {
        info.currentStreak = 0;
        await saveStreak(info);
      }
    } catch (_) {}
  }

  String _formatDate(DateTime dt) =>
      '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
}
