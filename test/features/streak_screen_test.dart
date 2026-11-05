import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cat_queens/core/storage/game_progress.dart';
import 'package:cat_queens/core/storage/progress_repository.dart';
import 'package:cat_queens/features/streak/models/streak_info.dart';
import 'package:cat_queens/features/streak/providers/streak_repository_provider.dart';
import 'package:cat_queens/features/streak/screens/streak_screen.dart';

void main() {
  testWidgets('StreakScreen displays pets paw icon for both played and greyed-out unplayed days',
      (WidgetTester tester) async {
    final mockStreak = StreakInfo(
      currentStreak: 2,
      bestStreak: 5,
      lastPlayedDate: '2026-11-05',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          streakInfoProvider.overrideWith((ref) async => mockStreak),
          progressFutureProvider.overrideWith((ref) => Stream.value(const GameProgress())),
        ],
        child: const MaterialApp(
          home: StreakScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify streak screen elements
    expect(find.text('Daily Streak'), findsOneWidget);
    expect(find.text('Current Streak'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('Best Streak: 5'), findsOneWidget);

    // Verify that Icons.pets is rendered for the 6 weekday circles (both played and greyed-out unplayed)
    final petIcons = find.byIcon(Icons.pets);
    expect(petIcons, findsNWidgets(6));
  });
}
