import 'dart:math';

class ScoreBreakdown {
  final int baseScore;
  final int timeBonus;
  final int livesBonus;
  final int hintPenalty;
  final int totalScore;

  const ScoreBreakdown({
    required this.baseScore,
    required this.timeBonus,
    required this.livesBonus,
    required this.hintPenalty,
    required this.totalScore,
  });
}

class ScoreCalculator {
  /// Computes the score breakdown for completing a level of grid size [n].
  static ScoreBreakdown calculate({
    required int n,
    required Duration elapsed,
    required int livesLeft,
    required int hintsUsed,
  }) {
    final base = n * 100;

    final secondsRemaining = max(0, 300 - elapsed.inSeconds);
    final multiplier = (n ~/ 2) + 1;
    final time = secondsRemaining * multiplier;

    final lives = max(0, livesLeft) * 100;
    final penalty = max(0, hintsUsed) * 50;

    final total = max(100, base + time + lives - penalty);

    return ScoreBreakdown(
      baseScore: base,
      timeBonus: time,
      livesBonus: lives,
      hintPenalty: penalty,
      totalScore: total,
    );
  }
}

