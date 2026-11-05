import 'package:cat_queens/features/game/screens/game_screen.dart';
import 'package:cat_queens/features/game/widgets/board_widget.dart';
import 'package:cat_queens/features/game/widgets/booster_row.dart';
import 'package:cat_queens/features/game/widgets/cat_progress_bar.dart';
import 'package:cat_queens/features/game/widgets/game_header.dart';
import 'package:cat_queens/features/game/widgets/game_over_dialog.dart';
import 'package:cat_queens/features/game/widgets/rule_cards.dart';
import 'package:cat_queens/features/game/widgets/win_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GameScreen Widgets', () {
    testWidgets('renders complete 4x4 game screen', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: GameScreen(initialLevel: 1),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Header components
      expect(find.byType(GameHeader), findsOneWidget);
      expect(find.text('Level 1'), findsOneWidget);
      expect(find.text('Score 0'), findsOneWidget);

      // Rule cards
      expect(find.byType(RuleCards), findsOneWidget);
      expect(find.text('1 cat per color'), findsOneWidget);
      expect(find.text('1 cat per row & col'), findsOneWidget);
      expect(find.text('Cats cannot touch'), findsOneWidget);

      // Cat progress bar
      expect(find.byType(CatProgressBar), findsOneWidget);

      // Board widget
      expect(find.byType(BoardWidget), findsOneWidget);

      // Booster row
      expect(find.byType(BoosterRow), findsOneWidget);
      expect(find.text('Auto Place'), findsOneWidget);
      expect(find.text('Hint'), findsOneWidget);
      expect(find.text('Undo'), findsOneWidget);
    });

    testWidgets('renders 9x9 game screen without overflowing', (tester) async {
      // Set device size to portrait mobile 360x780
      tester.view.physicalSize = const Size(360 * 3, 780 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: GameScreen(initialLevel: 75), // 9x9 tier
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Level 75'), findsOneWidget);
      expect(find.byType(BoardWidget), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders WinDialog with score and navigation buttons', (tester) async {
      bool nextPressed = false;
      bool replayPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WinDialog(
              levelNumber: 5,
              score: 850,
              elapsedTime: const Duration(seconds: 45),
              onNextLevel: () => nextPressed = true,
              onReplay: () => replayPressed = true,
            ),
          ),
        ),
      );

      expect(find.text('Awesome!'), findsOneWidget);
      expect(find.text('+850'), findsOneWidget);
      expect(find.text('0:45'), findsOneWidget);

      await tester.tap(find.text('Next Level'));
      expect(nextPressed, isTrue);

      await tester.tap(find.text('Replay'));
      expect(replayPressed, isTrue);
    });

    testWidgets('renders GameOverDialog with retry and home buttons', (tester) async {
      bool retryPressed = false;
      bool homePressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameOverDialog(
              levelNumber: 3,
              onRetry: () => retryPressed = true,
              onHome: () => homePressed = true,
            ),
          ),
        ),
      );

      expect(find.text('Out of Lives!'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
      expect(find.text('Back to Home'), findsOneWidget);

      await tester.tap(find.text('Try Again'));
      expect(retryPressed, isTrue);

      await tester.tap(find.text('Back to Home'));
      expect(homePressed, isTrue);
    });
  });
}

