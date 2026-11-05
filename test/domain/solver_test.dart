import 'package:cat_queens/domain/level/cell_pos.dart';
import 'package:cat_queens/domain/solver/backtracking_solver.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BacktrackingSolver', () {
    test('solves 4x4 with canonical regions and unique solution', () {
      const n = 4;
      final regionMap = <int>[
        0, 0, 1, 1,
        0, 0, 1, 1,
        2, 2, 3, 3,
        2, 2, 3, 3,
      ];

      // Givens: (0, 1) forces the unique solution
      final result = BacktrackingSolver.solve(
        n: n,
        regionMap: regionMap,
        givens: const [CellPos(0, 1)],
      );

      expect(result.hasUniqueSolution, isTrue);
      expect(result.solutions.length, 1);
      final sol = result.solutions.first;
      expect(sol, contains(const CellPos(0, 1)));
      expect(sol, contains(const CellPos(1, 3)));
      expect(sol, contains(const CellPos(2, 0)));
      expect(sol, contains(const CellPos(3, 2)));
    });

    test('detects multiple solutions when ambiguous without givens', () {
      const n = 4;
      // All rows are regions -> any 4-queens solution is accepted by region rule
      final regionMap = <int>[
        0, 0, 0, 0,
        1, 1, 1, 1,
        2, 2, 2, 2,
        3, 3, 3, 3,
      ];

      final result = BacktrackingSolver.solve(
        n: n,
        regionMap: regionMap,
        maxSolutions: 2,
      );

      // 4x4 has 2 non-touching solutions: (1, 3, 0, 2) and (2, 0, 3, 1)
      expect(result.solutions.length, 2);
      expect(result.hasUniqueSolution, isFalse);
    });

    test('detects impossible boards with 0 solutions', () {
      const n = 4;
      // All cells in region 0 except 1 cell
      final regionMap = <int>[
        0, 0, 0, 0,
        0, 0, 0, 0,
        0, 0, 0, 0,
        0, 0, 1, 2,
      ]; // Region 3 does not even exist -> impossible to place 4 queens in 4 regions

      final result = BacktrackingSolver.solve(
        n: n,
        regionMap: regionMap,
      );

      expect(result.hasNoSolution, isTrue);
    });

    test('solves sizes from N=4 up to N=9', () {
      for (int n = 4; n <= 9; n++) {
        // Construct a simple deterministic board that has a solution
        // Row i -> region i, with canonical given
        final regionMap = List<int>.generate(n * n, (i) => i ~/ n);

        final result = BacktrackingSolver.solve(
          n: n,
          regionMap: regionMap,
          maxSolutions: 1,
        );

        expect(
          result.solutions.isNotEmpty,
          isTrue,
          reason: 'Expected at least 1 solution for N=$n',
        );
        expect(result.solutions.first.length, n);
      }
    });
  });
}

