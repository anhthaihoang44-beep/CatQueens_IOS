class GameProgress {
  final int currentLevel;
  final int highestLevelUnlocked;
  final int totalScore;
  final int autoPlaceBoosters;
  final int hintBoosters;
  final int undoBoosters;
  final bool autoXAfterQueen;
  final Map<int, int> levelHighScores;
  final Map<int, int> levelBestTimesSeconds;

  const GameProgress({
    this.currentLevel = 1,
    this.highestLevelUnlocked = 1,
    this.totalScore = 0,
    this.autoPlaceBoosters = 5,
    this.hintBoosters = 5,
    this.undoBoosters = 0,
    this.autoXAfterQueen = true,
    this.levelHighScores = const {},
    this.levelBestTimesSeconds = const {},
  });

  GameProgress copyWith({
    int? currentLevel,
    int? highestLevelUnlocked,
    int? totalScore,
    int? autoPlaceBoosters,
    int? hintBoosters,
    int? undoBoosters,
    bool? autoXAfterQueen,
    Map<int, int>? levelHighScores,
    Map<int, int>? levelBestTimesSeconds,
  }) {
    return GameProgress(
      currentLevel: currentLevel ?? this.currentLevel,
      highestLevelUnlocked:
          highestLevelUnlocked ?? this.highestLevelUnlocked,
      totalScore: totalScore ?? this.totalScore,
      autoPlaceBoosters: autoPlaceBoosters ?? this.autoPlaceBoosters,
      hintBoosters: hintBoosters ?? this.hintBoosters,
      undoBoosters: undoBoosters ?? this.undoBoosters,
      autoXAfterQueen: autoXAfterQueen ?? this.autoXAfterQueen,
      levelHighScores: levelHighScores ?? this.levelHighScores,
      levelBestTimesSeconds:
          levelBestTimesSeconds ?? this.levelBestTimesSeconds,
    );
  }

  Map<String, dynamic> toJson() => {
        'currentLevel': currentLevel,
        'highestLevelUnlocked': highestLevelUnlocked,
        'totalScore': totalScore,
        'autoPlaceBoosters': autoPlaceBoosters,
        'hintBoosters': hintBoosters,
        'undoBoosters': undoBoosters,
        'autoXAfterQueen': autoXAfterQueen,
        'levelHighScores': levelHighScores.map((k, v) => MapEntry(k.toString(), v)),
        'levelBestTimesSeconds':
            levelBestTimesSeconds.map((k, v) => MapEntry(k.toString(), v)),
      };

  factory GameProgress.fromJson(Map<String, dynamic> json) {
    final rawScores = json['levelHighScores'] as Map<dynamic, dynamic>? ?? {};
    final scores = rawScores.map((k, v) => MapEntry(int.parse(k.toString()), v as int));

    final rawTimes = json['levelBestTimesSeconds'] as Map<dynamic, dynamic>? ?? {};
    final times = rawTimes.map((k, v) => MapEntry(int.parse(k.toString()), v as int));

    return GameProgress(
      currentLevel: json['currentLevel'] as int? ?? 1,
      highestLevelUnlocked: json['highestLevelUnlocked'] as int? ?? 1,
      totalScore: json['totalScore'] as int? ?? 0,
      autoPlaceBoosters: json['autoPlaceBoosters'] as int? ?? 5,
      hintBoosters: json['hintBoosters'] as int? ?? 5,
      undoBoosters: json['undoBoosters'] as int? ?? 0,
      autoXAfterQueen: json['autoXAfterQueen'] as bool? ?? true,
      levelHighScores: scores,
      levelBestTimesSeconds: times,
    );
  }
}

