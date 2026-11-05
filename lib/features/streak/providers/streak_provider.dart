import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/streak_repository.dart';
import '../models/streak_info.dart';

final streakRepositoryProvider = Provider<StreakRepository>((ref) => StreakRepository());

final streakInfoProvider = FutureProvider<StreakInfo>((ref) async {
  final repo = ref.watch(streakRepositoryProvider);
  return await repo.loadStreak();
});

