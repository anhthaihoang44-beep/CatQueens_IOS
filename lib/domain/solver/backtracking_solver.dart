import '../level/cell_pos.dart';
import '../level/level_config.dart';

class SolverResult {
  final List<List<CellPos>> solutions;
  final int branchCount;
  final Difficulty estimatedDifficulty;

  const SolverResult({
    required this.solutions,
    required this.branchCount,
    required this.estimatedDifficulty,
  });

  bool get hasUniqueSolution => solutions.length == 1;
  bool get hasNoSolution => solutions.isEmpty;
  bool get hasMultipleSolutions => solutions.length > 1;
}

class BacktrackingSolver {
  /// Solves the CatQueens puzzle for grid size [n] and [regionMap].
  /// [givens] are pre-placed queens that must be part of the solution.
  /// [maxSolutions] caps how many solutions to search for (default 2 for uniqueness testing).
  static SolverResult solve({
    required int n,
    required List<int> regionMap,
    List<CellPos> givens = const [],
    int maxSolutions = 2,
  }) {
    final solutions = <List<CellPos>>[];
    final currentQueens = List<int>.filled(n, -1); // row -> col
    int branches = 0;

    // Check if givens conflict with each other
    final givenMap = <int, int>{}; // row -> col
    int givenColsMask = 0;
    int givenRegionsMask = 0;

    for (final g in givens) {
      if (givenMap.containsKey(g.row)) return _emptyResult();
      if ((givenColsMask & (1 << g.col)) != 0) return _emptyResult();

      final reg = regionMap[g.toIndex(n)];
      if ((givenRegionsMask & (1 << reg)) != 0) return _emptyResult();

      // Check adjacency with previous givens
      for (final other in givens) {
        if (g != other && g.isAdjacent8(other)) return _emptyResult();
      }

      givenMap[g.row] = g.col;
      givenColsMask |= (1 << g.col);
      givenRegionsMask |= (1 << reg);
    }

    void search(int row, int usedColsMask, int usedRegionsMask) {
      if (solutions.length >= maxSolutions) return;

      if (row == n) {
        solutions.add([
          for (int r = 0; r < n; r++) CellPos(r, currentQueens[r]),
        ]);
        return;
      }

      // If this row has a given, only try that specific column
      if (givenMap.containsKey(row)) {
        final col = givenMap[row]!;
        final reg = regionMap[row * n + col];

        // Validate column availability
        if ((usedColsMask & (1 << col)) != 0) return;
        // Validate region availability
        if ((usedRegionsMask & (1 << reg)) != 0) return;
        // Validate adjacency with previous row
        if (row > 0 && (currentQueens[row - 1] - col).abs() <= 1) return;

        currentQueens[row] = col;
        search(
          row + 1,
          usedColsMask | (1 << col),
          usedRegionsMask | (1 << reg),
        );
        currentQueens[row] = -1;
        return;
      }

      // Find valid columns for this row
      final validCols = <int>[];
      for (int c = 0; c < n; c++) {
        if ((usedColsMask & (1 << c)) != 0) continue;
        final reg = regionMap[row * n + c];
        if ((usedRegionsMask & (1 << reg)) != 0) continue;
        if (row > 0 && (currentQueens[row - 1] - c).abs() <= 1) continue;
        validCols.add(c);
      }

      if (validCols.length > 1) {
        branches += (validCols.length - 1);
      }

      for (final col in validCols) {
        final reg = regionMap[row * n + col];
        currentQueens[row] = col;
        search(
          row + 1,
          usedColsMask | (1 << col),
          usedRegionsMask | (1 << reg),
        );
        currentQueens[row] = -1;

        if (solutions.length >= maxSolutions) return;
      }
    }

    search(0, 0, 0);

    Difficulty difficulty;
    if (branches <= 1) {
      difficulty = Difficulty.easy;
    } else if (branches <= 4) {
      difficulty = Difficulty.medium;
    } else if (branches <= 9) {
      difficulty = Difficulty.hard;
    } else {
      difficulty = Difficulty.expert;
    }

    return SolverResult(
      solutions: solutions,
      branchCount: branches,
      estimatedDifficulty: difficulty,
    );
  }

  static SolverResult _emptyResult() => const SolverResult(
        solutions: [],
        branchCount: 0,
        estimatedDifficulty: Difficulty.easy,
      );

  /// Quick check if the given board has exactly 1 solution.
  static bool hasUniqueSolution({
    required int n,
    required List<int> regionMap,
    List<CellPos> givens = const [],
  }) {
    final result = solve(
      n: n,
      regionMap: regionMap,
      givens: givens,
      maxSolutions: 2,
    );
    return result.hasUniqueSolution;
  }
}

