import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'features/splash/screens/splash_screen.dart';
import 'features/home/screens/home_screen.dart';
import 'features/game/screens/game_screen.dart';
import 'features/settings/screens/settings_screen.dart';
import 'features/profile/screens/profile_screen.dart';
import 'features/streak/screens/streak_screen.dart';
import 'features/daily/screens/daily_challenge_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/game/:level',
      name: 'game',
      builder: (context, state) {
        final levelStr = state.pathParameters['level'] ?? '1';
        final level = int.tryParse(levelStr) ?? 1;
        return GameScreen(
          initialLevel: level,
          onBackToHome: () => context.go('/home'),
        );
      },
    ),
    GoRoute(
      path: '/profile',
      name: 'profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/streak',
      name: 'streak',
      builder: (context, state) => const StreakScreen(),
    ),
    GoRoute(
      path: '/daily',
      name: 'daily',
      builder: (context, state) => const DailyChallengeScreen(),
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(child: Text(state.error?.toString() ?? 'Page not found')),
  ),
);
