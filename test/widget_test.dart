import 'package:cat_queens/core/storage/game_progress.dart';
import 'package:cat_queens/core/storage/progress_repository.dart';
import 'package:cat_queens/features/home/screens/home_screen.dart';
import 'package:cat_queens/features/streak/models/streak_info.dart';
import 'package:cat_queens/features/streak/providers/streak_repository_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('HomeScreen renders title, cat logo, and level button', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          progressFutureProvider.overrideWith((ref) => Stream.value(const GameProgress())),
          streakInfoProvider.overrideWith((ref) async => StreakInfo(currentStreak: 1)),
        ],
        child: const MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('CatQueens'), findsOneWidget);
    expect(find.text('Cozy Cat Puzzle'), findsOneWidget);
    expect(find.text('Level 1'), findsOneWidget);
    expect(find.text('Daily Challenge'), findsOneWidget);
  });

  testWidgets('HomeScreen displays latest passed level reached (e.g. Level 7)', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          progressFutureProvider.overrideWith(
            (ref) => Stream.value(const GameProgress(currentLevel: 7, highestLevelUnlocked: 7)),
          ),
          streakInfoProvider.overrideWith((ref) async => StreakInfo(currentStreak: 3)),
        ],
        child: const MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Level 7'), findsOneWidget);
  });
}
