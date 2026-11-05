import 'package:cat_queens/domain/generator/level_generator.dart';
import 'package:cat_queens/domain/level/cell_pos.dart';
import 'package:cat_queens/domain/level/level_progression.dart';
import 'package:cat_queens/domain/rules/rule_checker.dart';
import 'package:cat_queens/domain/solver/backtracking_solver.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LevelGenerator', () {
    test('Level 1 generation produces valid 4x4 board with 1 given and unique solution', () {
      final level = LevelGenerator.generateLevel(levelNumber: 1);

      expect(level.n, 4);
      expect(level.levelNumber, 1);
      expect(level.givens.length, 1);
      expect(level.solution.length, 4);

      // Given must be part of solution
      expect(level.solution.contains(level.givens.first), isTrue);

      // Verify rule satisfaction
      expect(
        RuleChecker.isSolved(
          n: level.n,
          regionMap: level.regionMap,
          queens: level.solution,
        ),
        isTrue,
      );

      // Verify uniqueness with solver
      final solverCheck = BacktrackingSolver.solve(
        n: level.n,
        regionMap: level.regionMap,
        givens: level.givens,
        maxSolutions: 2,
      );
      expect(solverCheck.hasUniqueSolution, isTrue);
    });

    test('generates valid levels for different grid sizes (4x4 to 9x9)', () {
      // Test sample level numbers representing each grid size tier
      final testLevels = [1, 7, 15, 28, 50, 75];

      for (final lvlNum in testLevels) {
        final expectedN = LevelProgression.getGridSize(lvlNum);
        final level = LevelGenerator.generateLevel(levelNumber: lvlNum);

        expect(level.n, expectedN, reason: 'Level $lvlNum should have grid size $expectedN');
        expect(level.solution.length, expectedN);
        expect(level.regionMap.length, expectedN * expectedN);

        // Every region 0..N-1 should exist
        final uniqueRegions = level.regionMap.toSet();
        expect(uniqueRegions.length, expectedN);

        // Solution must be valid
        expect(
          RuleChecker.isSolved(
            n: level.n,
            regionMap: level.regionMap,
            queens: level.solution,
          ),
          isTrue,
        );

        // Solution must be unique
        final solverCheck = BacktrackingSolver.solve(
          n: level.n,
          regionMap: level.regionMap,
          givens: level.givens,
          maxSolutions: 2,
        );
        expect(
          solverCheck.hasUniqueSolution,
          isTrue,
          reason: 'Level $lvlNum must have exactly 1 unique solution',
        );

        // Verify contiguity of each region
        for (int r = 0; r < expectedN; r++) {
          final regionCells = <CellPos>[];
          for (int i = 0; i < level.regionMap.length; i++) {
            if (level.regionMap[i] == r) {
              regionCells.add(CellPos.fromIndex(i, expectedN));
            }
          }
          expect(regionCells.isNotEmpty, isTrue);

          // BFS to verify connectivity
          final visited = <CellPos>{regionCells.first};
          final queue = <CellPos>[regionCells.first];
          while (queue.isNotEmpty) {
            final curr = queue.removeAt(0);
            for (final nb in curr.neighbors4(expectedN)) {
              if (level.regionMap[nb.toIndex(expectedN)] == r && !visited.contains(nb)) {
                visited.add(nb);
                queue.add(nb);
              }
            }
          }
          expect(
            visited.length,
            regionCells.length,
            reason: 'Region $r in level $lvlNum must be contiguous',
          );
        }
      }
    });

    test('seed reproducibility: same levelNumber and seed produce identical config', () {
      final levelA = LevelGenerator.generateLevel(levelNumber: 42, seedOverride: 12345);
      final levelB = LevelGenerator.generateLevel(levelNumber: 42, seedOverride: 12345);

      expect(levelA.n, levelB.n);
      expect(levelA.regionMap, equals(levelB.regionMap));
      expect(levelA.solution, equals(levelB.solution));
      expect(levelA.givens, equals(levelB.givens));
    });
  });
}

