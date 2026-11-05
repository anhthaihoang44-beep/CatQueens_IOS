import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/audio/sound_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/storage/progress_repository.dart';
import '../../streak/providers/streak_repository_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(progressFutureProvider);
    final streakAsync = ref.watch(streakInfoProvider);

    final currentLevel = progressAsync.maybeWhen(
      data: (p) => p.highestLevelUnlocked > 0 ? p.highestLevelUnlocked : p.currentLevel,
      orElse: () => 1,
    );

    final highestUnlocked = progressAsync.maybeWhen(
      data: (p) => p.highestLevelUnlocked,
      orElse: () => 1,
    );
    final bool isDailyUnlocked = highestUnlocked > 25;

    final streakCount = streakAsync.maybeWhen(
      data: (s) => s.currentStreak,
      orElse: () => 0,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              // Top Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Profile Button
                  InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () {
                      SoundService.playClick();
                      context.go('/profile');
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.person_rounded, size: 28, color: AppColors.primary),
                    ),
                  ),

                  // Streak Pill
                  InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      SoundService.playClick();
                      context.go('/streak');
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Text('🧶', style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 6),
                          Text(
                            '$streakCount',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Settings Button
                  InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () {
                      SoundService.playClick();
                      context.go('/settings');
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.settings_rounded, size: 28, color: AppColors.textPrimary),
                    ),
                  ),
                ],
              ),

              const Spacer(flex: 2),

              // Game Title & Cat Logo
              const Text('👑', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 8),
              const Text(
                'CatQueens',
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Cozy Cat Puzzle',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 24),
              const Text('🐱', style: TextStyle(fontSize: 90)),

              const Spacer(flex: 3),

              // Primary Play Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    elevation: 3,
                  ),
                  onPressed: () {
                    SoundService.playClick();
                    context.go('/game/$currentLevel');
                  },
                  child: Text(
                    'Level $currentLevel',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Daily Challenge Button (Locked until Level 25)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: isDailyUnlocked
                    ? ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.textPrimary,
                          side: BorderSide(color: Colors.grey.shade300, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          elevation: 1,
                        ),
                        onPressed: () {
                          SoundService.playClick();
                          context.go('/daily');
                        },
                        icon: const Icon(Icons.calendar_month_rounded, color: AppColors.primary),
                        label: const Text(
                          'Daily Challenge',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                      )
                    : ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEBE5DF),
                          foregroundColor: Colors.grey.shade600,
                          side: BorderSide(color: Colors.grey.shade300, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          SoundService.playError();
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
                        icon: const Icon(Icons.lock_rounded, color: Colors.grey, size: 20),
                        label: const Text(
                          'Daily Challenge',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey,
                          ),
                        ),
                      ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
