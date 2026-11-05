import 'level_config.dart';

class LevelProgression {
  static const int maxGridSize = 9;
  static const int minGridSize = 4;

  static int getGridSize(int levelNumber) {
    if (levelNumber <= 5) return 4;
    if (levelNumber <= 12) return 5;
    if (levelNumber <= 25) return 6;
    if (levelNumber <= 45) return 7;
    if (levelNumber <= 70) return 8;
    return 9;
  }

  static int getGivenCount(int levelNumber) {
    if (levelNumber == 1) return 1;
    return 0;
  }

  static Difficulty getExpectedDifficulty(int levelNumber) {
    if (levelNumber <= 5) return Difficulty.easy;
    if (levelNumber <= 20) return Difficulty.medium;
    if (levelNumber <= 50) return Difficulty.hard;
    return Difficulty.expert;
  }
}

