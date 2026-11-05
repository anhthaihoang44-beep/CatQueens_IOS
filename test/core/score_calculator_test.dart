import 'package:cat_queens/domain/scoring/score_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ScoreCalculator', () {
    test('computes base score scaled by N', () {
      final res4 = ScoreCalculator.calculate(
        n: 4,
        elapsed: const Duration(seconds: 300),
        livesLeft: 0,
        hintsUsed: 0,
      );
      expect(res4.baseScore, 400);

      final res9 = ScoreCalculator.calculate(
        n: 9,
        elapsed: const Duration(seconds: 300),
        livesLeft: 0,
        hintsUsed: 0,
      );
      expect(res9.baseScore, 900);
    });

    test('adds time bonus for fast completion', () {
      final res = ScoreCalculator.calculate(
        n: 6,
        elapsed: const Duration(seconds: 100), // 200 seconds remaining
        livesLeft: 3,
        hintsUsed: 0,
      );

      // Multiplier for N=6: (6 ~/ 2) + 1 = 4
      // 200 * 4 = 800
      expect(res.timeBonus, 800);
      expect(res.livesBonus, 300);
      expect(res.hintPenalty, 0);
      expect(res.totalScore, 600 + 800 + 300);
    });

    test('deducts penalty when hints are used', () {
      final res = ScoreCalculator.calculate(
        n: 5,
        elapsed: const Duration(seconds: 300),
        livesLeft: 2,
        hintsUsed: 3, // 3 * 50 = 150 penalty
      );

      expect(res.baseScore, 500);
      expect(res.timeBonus, 0);
      expect(res.livesBonus, 200);
      expect(res.hintPenalty, 150);
      expect(res.totalScore, 500 + 200 - 150);
    });
  });
}

