import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/storage/progress_repository.dart';
import '../../../core/theme/app_theme.dart';
import '../repositories/daily_challenge_repository.dart';
import '../models/daily_challenge.dart';

final dailyChallengeRepoProvider = Provider<DailyChallengeRepository>(
  (ref) => DailyChallengeRepository(),
);

final todayChallengeProvider = FutureProvider<DailyChallenge>((ref) async {
  final repo = ref.watch(dailyChallengeRepoProvider);
  return await repo.loadTodayChallenge();
});

class DailyChallengeScreen extends ConsumerWidget {
  const DailyChallengeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(progressFutureProvider);
    final challengeAsync = ref.watch(todayChallengeProvider);

    final currentLevel = progressAsync.maybeWhen(
      data: (p) => p.highestLevelUnlocked > 0 ? p.highestLevelUnlocked : p.currentLevel,
      orElse: () => 1,
    );
    final highestUnlocked = progressAsync.maybeWhen(
      data: (p) => p.highestLevelUnlocked,
      orElse: () => 1,
    );
    final isUnlocked = highestUnlocked > 25;

    return Scaffold(
      backgroundColor: const Color(0xFFFBF6F0),
      appBar: AppBar(
        title: const Text(
          'Daily Challenge',
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
        child: !isUnlocked
            ? _buildLockedView(context, currentLevel)
            : challengeAsync.when(
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                error: (err, _) => Center(child: Text('Error: $err')),
                data: (challenge) {
                  final bestTimeText = challenge.bestTime != null
                      ? '${challenge.bestTime!.inMinutes}:${(challenge.bestTime!.inSeconds % 60).toString().padLeft(2, '0')}'
                      : 'None yet';

                  return Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('🗓️', style: TextStyle(fontSize: 64)),
                        const SizedBox(height: 16),
                        Text(
                          'Today\'s Challenge',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Special daily puzzle. Sharpen your mind every day!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                        ),
                        const SizedBox(height: 32),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Level:', style: TextStyle(fontWeight: FontWeight.w600)),
                                  Text(
                                    'Level ${challenge.levelNumber}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                                  ),
                                ],
                              ),
                              const Divider(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Best Record:', style: TextStyle(fontWeight: FontWeight.w600)),
                                  Text(
                                    bestTimeText,
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              elevation: 2,
                            ),
                            onPressed: () {
                              context.go('/game/${challenge.levelNumber}');
                            },
                            child: const Text(
                              'Start Challenge',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildLockedView(BuildContext context, int currentLevel) {
    final progressVal = (currentLevel / 25.0).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),

          // Big Lock Icon with soft circle
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFFECB3).withValues(alpha: 0.5),
            ),
            child: const Center(
              child: Text('🔒', style: TextStyle(fontSize: 54)),
            ),
          ),
          const SizedBox(height: 24),

          const Text(
            'Unlocks After Level 25',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Color(0xFF5D4037),
            ),
          ),
          const SizedBox(height: 10),

          const Text(
            'You need to beat Level 25 in the main mode to unlock Daily Challenge!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Color(0xFF8D6E63),
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 32),

          // Progress indicator
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Unlock Progress',
                      style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF6D4C41)),
                    ),
                    Text(
                      'Level $currentLevel / 25',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFFF9800),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progressVal,
                    minHeight: 10,
                    backgroundColor: const Color(0xFFEFEBE9),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF9800)),
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Play Main Game Button
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
                'Continue Level $currentLevel',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Back to home
          TextButton(
            onPressed: () => context.go('/home'),
            child: const Text(
              'Back to Home',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF8D6E63),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
