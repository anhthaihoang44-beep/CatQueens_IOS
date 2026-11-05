import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/storage/progress_repository.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/streak_repository_provider.dart';
import '../models/streak_info.dart';

/// Screen displaying daily streak information matching video frame 18s.
class StreakScreen extends ConsumerWidget {
  const StreakScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncStreak = ref.watch(streakInfoProvider);
    final progressAsync = ref.watch(progressFutureProvider);

    final currentLevel = progressAsync.maybeWhen(
      data: (p) => p.highestLevelUnlocked > 0 ? p.highestLevelUnlocked : p.currentLevel,
      orElse: () => 1,
    );
    final highestUnlocked = progressAsync.maybeWhen(
      data: (p) => p.highestLevelUnlocked,
      orElse: () => 1,
    );
    final isDailyUnlocked = highestUnlocked > 25;

    return asyncStreak.when(
      loading: () => const Scaffold(
        backgroundColor: Color(0xFFFBF6F0),
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: const Color(0xFFFBF6F0),
        body: Center(child: Text('Error loading streak: $e')),
      ),
      data: (StreakInfo info) {
        final now = DateTime.now();
        final todayStr =
            '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
        final hasPlayedToday = info.lastPlayedDate == todayStr;

        // Current week Monday..Sunday
        final monday = now.subtract(Duration(days: now.weekday - 1));
        const dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

        return Scaffold(
          backgroundColor: const Color(0xFFFBF6F0),
          appBar: AppBar(
            title: const Text(
              'Daily Streak',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 20,
                color: Color(0xFF6D4C41),
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF6D4C41)),
              onPressed: () => context.go('/home'),
            ),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              child: Column(
                children: [
                  const Spacer(flex: 1),

                  // 3D Yarn Ball with Feathers (like video frame 18s)
                  SizedBox(
                    height: 120,
                    width: 140,
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        // Soft glow
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFFFB74D).withValues(alpha: 0.25),
                          ),
                        ),
                        // Feathers
                        const Positioned(
                          left: 12,
                          top: 15,
                          child: Text('🪶', style: TextStyle(fontSize: 44)),
                        ),
                        // Big Wool Yarn Ball
                        const Text('🧶', style: TextStyle(fontSize: 78)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Big Orange Streak Number
                  Text(
                    '${info.currentStreak}',
                    style: const TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFFF9800),
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Current Streak',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFFF9800),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Best streak pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFFFE0B2)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      'Best Streak: ${info.bestStreak}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF8D6E63),
                      ),
                    ),
                  ),

                  const Spacer(flex: 2),

                  // 7-day row container (like video frame 18s)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(7, (i) {
                        final label = dayLabels[i];
                        final dayIndexFromMonday = i; // 0..6
                        final todayWeekdayIndex = now.weekday - 1; // 0..6 (Mon..Sun)
                        final isPastOrToday = dayIndexFromMonday <= todayWeekdayIndex;
                        final isToday = dayIndexFromMonday == todayWeekdayIndex;

                        // Check if this day is marked as played
                        // If played today: today is played. If streak is active, previous days in streak are played.
                        final daysAgo = todayWeekdayIndex - dayIndexFromMonday;
                        final bool isPlayed = isPastOrToday &&
                            (hasPlayedToday
                                ? daysAgo < info.currentStreak
                                : (daysAgo > 0 && daysAgo <= info.currentStreak));

                        final bool isGiftDay = i == 6; // Sunday gift

                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              label,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isToday ? FontWeight.w900 : FontWeight.w600,
                                color: isToday ? const Color(0xFFFF9800) : const Color(0xFF8D6E63),
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Day indicator: Orange circle with white paw/tick (like video frame 18s)
                            if (isGiftDay && !isPlayed)
                              Container(
                                width: 38,
                                height: 38,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFFFFF3E0),
                                  border: isToday
                                      ? Border.all(color: const Color(0xFFFF9800), width: 1.5)
                                      : null,
                                ),
                                child: const Text('🎁', style: TextStyle(fontSize: 20)),
                              )
                            else if (isPlayed)
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFFFF9800),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFFF9800).withValues(alpha: 0.4),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.pets,
                                  size: 20,
                                  color: Colors.white,
                                ),
                              )
                            else
                              // Passed or upcoming unplayed day: greyed out paw print mark
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isToday
                                      ? const Color(0xFFF3ECE4)
                                      : const Color(0xFFE8E1DA),
                                  border: isToday
                                      ? Border.all(color: const Color(0xFFFF9800), width: 1.5)
                                      : null,
                                ),
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.pets,
                                  size: 19,
                                  color: isToday
                                      ? const Color(0xFFFFB74D).withValues(alpha: 0.85)
                                      : const Color(0xFFAFA398), // Greyed-out cat paw
                                ),
                              ),
                          ],
                        );
                      }),
                    ),
                  ),

                  const Spacer(flex: 3),

                  // Play Button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF9800),
                        foregroundColor: Colors.white,
                        elevation: 3,
                        shadowColor: const Color(0xFFFF9800).withValues(alpha: 0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () => context.go('/game/$currentLevel'),
                      child: Text(
                        hasPlayedToday ? 'Continue Level $currentLevel' : 'Play Level $currentLevel',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Daily Challenge Button (Locked until Level 25)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: isDailyUnlocked
                        ? OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF6D4C41),
                              side: const BorderSide(color: Color(0xFFFFB74D), width: 1.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            onPressed: () => context.go('/daily'),
                            icon: const Icon(Icons.calendar_month_rounded, color: Color(0xFFFF9800)),
                            label: const Text(
                              'Daily Challenge',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          )
                        : OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.grey.shade500,
                              side: BorderSide(color: Colors.grey.shade300, width: 1.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      const Text('🔒 ', style: TextStyle(fontSize: 18)),
                                      Expanded(
                                        child: Text(
                                          'Beat Level 25 to unlock Daily Challenge! (Current: Level $currentLevel/25)',
                                          style: const TextStyle(fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ],
                                  ),
                                  backgroundColor: const Color(0xFF5D4037),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                            icon: const Icon(Icons.lock_rounded, color: Colors.grey, size: 18),
                            label: const Text(
                              'Daily Challenge (Unlocks at Level 25)',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
