import 'package:cat_queens/domain/level/level_config.dart';
import 'package:cat_queens/domain/level/level_progression.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LevelProgression', () {
    test('grid size matches specification exactly', () {
      // 1-5: 4x4
      for (int l = 1; l <= 5; l++) {
        expect(LevelProgression.getGridSize(l), 4);
      }
      // 6-12: 5x5
      for (int l = 6; l <= 12; l++) {
        expect(LevelProgression.getGridSize(l), 5);
      }
      // 13-25: 6x6
      for (int l = 13; l <= 25; l++) {
        expect(LevelProgression.getGridSize(l), 6);
      }
      // 26-45: 7x7
      for (int l = 26; l <= 45; l++) {
        expect(LevelProgression.getGridSize(l), 7);
      }
      // 46-70: 8x8
      for (int l = 46; l <= 70; l++) {
        expect(LevelProgression.getGridSize(l), 8);
      }
      // 71+: 9x9 (capped at MAX_GRID_SIZE = 9)
      for (int l = 71; l <= 150; l += 20) {
        expect(LevelProgression.getGridSize(l), 9);
      }
    });

    test('level 1 has 1 given cat, subsequent levels have 0 givens', () {
      expect(LevelProgression.getGivenCount(1), 1);
      expect(LevelProgression.getGivenCount(2), 0);
      expect(LevelProgression.getGivenCount(5), 0);
      expect(LevelProgression.getGivenCount(25), 0);
    });

    test('expected difficulty progresses logically', () {
      expect(LevelProgression.getExpectedDifficulty(1), Difficulty.easy);
      expect(LevelProgression.getExpectedDifficulty(10), Difficulty.medium);
      expect(LevelProgression.getExpectedDifficulty(30), Difficulty.hard);
      expect(LevelProgression.getExpectedDifficulty(60), Difficulty.expert);
    });
  });
}

