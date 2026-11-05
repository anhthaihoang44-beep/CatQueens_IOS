import 'cell_pos.dart';

enum Difficulty {
  easy,
  medium,
  hard,
  expert;

  String get displayName {
    switch (this) {
      case Difficulty.easy:
        return 'Easy';
      case Difficulty.medium:
        return 'Medium';
      case Difficulty.hard:
        return 'Hard';
      case Difficulty.expert:
        return 'Expert';
    }
  }
}

class LevelConfig {
  final int levelNumber;
  final int n;
  final int seed;
  final List<int> regionMap; // length n * n, values 0..n-1
  final List<CellPos> givens;
  final List<CellPos> solution;
  final Difficulty difficulty;

  const LevelConfig({
    required this.levelNumber,
    required this.n,
    required this.seed,
    required this.regionMap,
    required this.givens,
    required this.solution,
    required this.difficulty,
  });

  int getRegion(int row, int col) => regionMap[row * n + col];
  int getRegionAt(CellPos pos) => regionMap[pos.toIndex(n)];

  Map<String, dynamic> toJson() => {
        'levelNumber': levelNumber,
        'n': n,
        'seed': seed,
        'regionMap': regionMap,
        'givens': givens.map((p) => p.toJson()).toList(),
        'solution': solution.map((p) => p.toJson()).toList(),
        'difficulty': difficulty.name,
      };

  factory LevelConfig.fromJson(Map<String, dynamic> json) {
    return LevelConfig(
      levelNumber: json['levelNumber'] as int,
      n: json['n'] as int,
      seed: json['seed'] as int,
      regionMap: List<int>.from(json['regionMap'] as List),
      givens: (json['givens'] as List)
          .map((p) => CellPos.fromJson(p as Map<String, dynamic>))
          .toList(),
      solution: (json['solution'] as List)
          .map((p) => CellPos.fromJson(p as Map<String, dynamic>))
          .toList(),
      difficulty: Difficulty.values.byName(json['difficulty'] as String),
    );
  }
}

