import 'dart:math';
import '../level/cell_pos.dart';
import '../level/level_config.dart';
import '../level/level_progression.dart';
import '../solver/backtracking_solver.dart';

class LevelGenerator {
  /// Generates a level configuration deterministically using [levelNumber]
  /// and an optional [seedOverride].
  static LevelConfig generateLevel({
    required int levelNumber,
    int? seedOverride,
  }) {
    final seed = seedOverride ?? (levelNumber * 10007 + 42);
    final n = LevelProgression.getGridSize(levelNumber);
    final targetGivensCount = LevelProgression.getGivenCount(levelNumber);

    final rng = Random(seed);

    for (int attempt = 0; attempt < 500; attempt++) {
      final queens = _generateValidQueens(n, rng);
      if (queens == null) continue;

      // Assign organic region capacities:
      // small regions (2-4 cells) create logical deduction anchors
      final capacities = List<int>.generate(n, (i) {
        if (i < 2) return rng.nextInt(2) + 2;
        return rng.nextInt(n) + 3;
      });
      capacities.shuffle(rng);

      final regionMap = _growRegions(n, queens, capacities, rng);
      if (regionMap == null) continue;

      // Level 1 explicitly requires exactly 1 given tutorial cat
      if (targetGivensCount > 0) {
        for (final q in queens) {
          final res = BacktrackingSolver.solve(
            n: n,
            regionMap: regionMap,
            givens: [q],
            maxSolutions: 2,
          );
          if (res.hasUniqueSolution) {
            return LevelConfig(
              levelNumber: levelNumber,
              n: n,
              seed: seed,
              regionMap: regionMap,
              givens: [q],
              solution: queens,
              difficulty: Difficulty.easy,
            );
          }
        }
        continue;
      }

      // Check for 0-given unique solution first
      final res0 = BacktrackingSolver.solve(
        n: n,
        regionMap: regionMap,
        maxSolutions: 2,
      );
      if (res0.hasUniqueSolution) {
        return LevelConfig(
          levelNumber: levelNumber,
          n: n,
          seed: seed,
          regionMap: regionMap,
          givens: const [],
          solution: queens,
          difficulty: res0.estimatedDifficulty,
        );
      }

      // If needed for higher N, try 1 given to ensure uniqueness
      if (attempt > (n <= 6 ? 40 : 15)) {
        for (final q in queens) {
          final res1 = BacktrackingSolver.solve(
            n: n,
            regionMap: regionMap,
            givens: [q],
            maxSolutions: 2,
          );
          if (res1.hasUniqueSolution) {
            return LevelConfig(
              levelNumber: levelNumber,
              n: n,
              seed: seed,
              regionMap: regionMap,
              givens: [q],
              solution: queens,
              difficulty: res1.estimatedDifficulty,
            );
          }
        }
      }

      // For N >= 8, if still looking after 50 attempts, test 2 givens
      if (n >= 8 && attempt > 50) {
        bool found = false;
        LevelConfig? foundLevel;
        for (int i = 0; i < n && !found; i++) {
          for (int j = i + 1; j < n; j++) {
            final givens = [queens[i], queens[j]];
            final res2 = BacktrackingSolver.solve(
              n: n,
              regionMap: regionMap,
              givens: givens,
              maxSolutions: 2,
            );
            if (res2.hasUniqueSolution) {
              foundLevel = LevelConfig(
                levelNumber: levelNumber,
                n: n,
                seed: seed,
                regionMap: regionMap,
                givens: givens,
                solution: queens,
                difficulty: res2.estimatedDifficulty,
              );
              found = true;
              break;
            }
          }
        }
        if (foundLevel != null) return foundLevel;
      }
    }

    // Deterministic fallback
    return _generateFallbackLevel(levelNumber, n, seed);
  }

  /// Places N queens on N x N grid such that:
  /// - 1 per row
  /// - 1 per col
  /// - no two queens touch in 8 directions (|r1-r2| <= 1 && |c1-c2| <= 1 forbidden)
  static List<CellPos>? _generateValidQueens(int n, Random rng) {
    final cols = List<int>.filled(n, -1);

    bool placeRow(int row, int usedColsMask) {
      if (row == n) return true;

      final candidates = <int>[];
      for (int c = 0; c < n; c++) {
        if ((usedColsMask & (1 << c)) != 0) continue;
        if (row > 0 && (cols[row - 1] - c).abs() <= 1) continue;
        candidates.add(c);
      }

      candidates.shuffle(rng);

      for (final c in candidates) {
        cols[row] = c;
        if (placeRow(row + 1, usedColsMask | (1 << c))) {
          return true;
        }
        cols[row] = -1;
      }

      return false;
    }

    if (placeRow(0, 0)) {
      return [for (int r = 0; r < n; r++) CellPos(r, cols[r])];
    }
    return null;
  }

  /// Grows N contiguous regions around each queen.
  /// Each queen is the initial seed of its region (region 0..N-1).
  /// Every cell in the grid will be assigned to exactly one region.
  static List<int>? _growRegions(
    int n,
    List<CellPos> queens,
    List<int> capacities,
    Random rng,
  ) {
    final totalCells = n * n;
    final regionMap = List<int>.filled(totalCells, -1);
    final regionSizes = List<int>.filled(n, 0);
    final frontiers = List<List<CellPos>>.generate(n, (_) => []);

    for (int i = 0; i < n; i++) {
      final q = queens[i];
      final idx = q.toIndex(n);
      regionMap[idx] = i;
      regionSizes[i] = 1;
      for (final nb in q.neighbors4(n)) {
        frontiers[i].add(nb);
      }
    }

    int assignedCount = n;

    while (assignedCount < totalCells) {
      final eligible = <int>[];
      for (int i = 0; i < n; i++) {
        frontiers[i].removeWhere((p) => regionMap[p.toIndex(n)] != -1);
        if (frontiers[i].isNotEmpty && regionSizes[i] < capacities[i]) {
          eligible.add(i);
        }
      }

      if (eligible.isEmpty) {
        for (int i = 0; i < n; i++) {
          if (frontiers[i].isNotEmpty) eligible.add(i);
        }
      }

      if (eligible.isEmpty) break;

      final chosenReg = eligible[rng.nextInt(eligible.length)];
      final frontier = frontiers[chosenReg];
      final cell = frontier.removeAt(rng.nextInt(frontier.length));
      final idx = cell.toIndex(n);

      if (regionMap[idx] == -1) {
        regionMap[idx] = chosenReg;
        regionSizes[chosenReg]++;
        assignedCount++;
        for (final nb in cell.neighbors4(n)) {
          if (regionMap[nb.toIndex(n)] == -1) {
            frontiers[chosenReg].add(nb);
          }
        }
      }
    }

    // Fill remaining cells
    for (int i = 0; i < totalCells; i++) {
      if (regionMap[i] == -1) {
        final pos = CellPos.fromIndex(i, n);
        for (final nb in pos.neighbors4(n)) {
          final r = regionMap[nb.toIndex(n)];
          if (r != -1) {
            regionMap[i] = r;
            break;
          }
        }
      }
    }

    // Verify all cells filled
    if (regionMap.contains(-1)) return null;

    // Verify contiguity of all regions
    for (int r = 0; r < n; r++) {
      final cells = <CellPos>[];
      for (int i = 0; i < totalCells; i++) {
        if (regionMap[i] == r) cells.add(CellPos.fromIndex(i, n));
      }
      if (cells.isEmpty) return null;

      final visited = <CellPos>{cells.first};
      final queue = <CellPos>[cells.first];
      while (queue.isNotEmpty) {
        final curr = queue.removeAt(0);
        for (final nb in curr.neighbors4(n)) {
          if (regionMap[nb.toIndex(n)] == r && !visited.contains(nb)) {
            visited.add(nb);
            queue.add(nb);
          }
        }
      }
      if (visited.length != cells.length) return null;
    }

    return regionMap;
  }

  /// Guaranteed fallback level
  static LevelConfig _generateFallbackLevel(int levelNumber, int n, int seed) {
    final cols = [for (int i = 0; i < n; i++) (i * 2 + (i >= n ~/ 2 ? 1 : 0)) % n];
    // Ensure adjacency check
    for (int r = 0; r < n - 1; r++) {
      if ((cols[r] - cols[r + 1]).abs() <= 1) {
        final tmp = cols[r + 1];
        cols[r + 1] = cols[n - 1];
        cols[n - 1] = tmp;
      }
    }
    final queens = [for (int r = 0; r < n; r++) CellPos(r, cols[r])];
    final regionMap = List<int>.generate(n * n, (i) => i ~/ n);

    return LevelConfig(
      levelNumber: levelNumber,
      n: n,
      seed: seed,
      regionMap: regionMap,
      givens: queens.take(n - 2).toList(),
      solution: queens,
      difficulty: Difficulty.easy,
    );
  }
}
