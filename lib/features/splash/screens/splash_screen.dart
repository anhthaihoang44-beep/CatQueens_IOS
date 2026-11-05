import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';

/// Splash screen displayed on app start.
/// Shows a random encouraging quote (hard‑coded list) and a logo.
/// After a short delay it navigates to the home screen.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  static const _quotes = [
    "You will win!",
    "Patience brings victory.",
    "Cats always lead the way.",
    "Keep trying, success will come.",
    "Every move is a discovery."
  ];

  late final String _quote;

  @override
  void initState() {
    super.initState();
    _quote = (List.of(_quotes)..shuffle()).first;
    // Navigate after 2 seconds.
    Timer(const Duration(seconds: 2), () {
      if (mounted) context.go('/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    _quote,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.start,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // "- CatQueens" aligned right.
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  "- CatQueens",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Progress bar with a cat head.
            SizedBox(
              height: 8,
              child: LinearProgressIndicator(
                value: 0.6,
                backgroundColor: AppColors.progressBg,
                valueColor: const AlwaysStoppedAnimation(AppColors.progressFill),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 8),
            // Cat head placeholder.
            Icon(Icons.pets, size: 48, color: AppColors.catHead),
            const SizedBox(height: 24),
            // Logo placeholder.
            Icon(Icons.gamepad, size: 96, color: AppColors.logo),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}

