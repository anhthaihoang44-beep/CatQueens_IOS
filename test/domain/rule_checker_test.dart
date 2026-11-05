import 'package:cat_queens/domain/level/cell_pos.dart';
import 'package:cat_queens/domain/rules/rule_checker.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RuleChecker', () {
    const n = 4;
    // 4 regions, each 4 cells
    final regionMap = <int>[
      0, 0, 1, 1,
      0, 0, 1, 1,
      2, 2, 3, 3,
      2, 2, 3, 3,
    ];

    // Canonical 4x4 solution: (0, 1), (1, 3), (2, 0), (3, 2)
    // Regions: (0, 1)->0, (1, 3)->1, (2, 0)->2, (3, 2)->3 -> All distinct!
    final validSolution = const [
      CellPos(0, 1),
      CellPos(1, 3),
      CellPos(2, 0),
      CellPos(3, 2),
    ];

    test('valid placement passes isSolved', () {
      expect(
        RuleChecker.isSolved(
          n: n,
          regionMap: regionMap,
          queens: validSolution,
        ),
        isTrue,
      );
      final violations = RuleChecker.findAllViolations(
        n: n,
        regionMap: regionMap,
        queens: validSolution,
      );
      expect(violations, isEmpty);
    });

    test('row collision is detected', () {
      final invalid = const [
        CellPos(0, 1),
        CellPos(0, 3), // Same row 0!
        CellPos(2, 0),
        CellPos(3, 2),
      ];
      final violations = RuleChecker.findAllViolations(
        n: n,
        regionMap: regionMap,
        queens: invalid,
      );
      expect(
        violations.any((v) => v.type == RuleViolationType.row),
        isTrue,
      );
      expect(
        RuleChecker.isSolved(n: n, regionMap: regionMap, queens: invalid),
        isFalse,
      );
    });

    test('column collision is detected', () {
      final invalid = const [
        CellPos(0, 1),
        CellPos(1, 1), // Same col 1!
        CellPos(2, 0),
        CellPos(3, 2),
      ];
      final violations = RuleChecker.findAllViolations(
        n: n,
        regionMap: regionMap,
        queens: invalid,
      );
      expect(
        violations.any((v) => v.type == RuleViolationType.column),
        isTrue,
      );
    });

    test('region collision is detected', () {
      // CellPos(0, 0) and CellPos(0, 1) are both in region 0
      final invalid = const [
        CellPos(0, 0),
        CellPos(1, 1), // in region 0 too!
        CellPos(2, 2),
        CellPos(3, 3),
      ];
      final violations = RuleChecker.findAllViolations(
        n: n,
        regionMap: regionMap,
        queens: invalid,
      );
      expect(
        violations.any((v) => v.type == RuleViolationType.region),
        isTrue,
      );
    });

    test('8-way diagonal collision is detected', () {
      final invalid = const [
        CellPos(0, 1),
        CellPos(1, 2), // Diagonally touching (0, 1)!
        CellPos(2, 0),
        CellPos(3, 3),
      ];
      final violations = RuleChecker.findAllViolations(
        n: n,
        regionMap: regionMap,
        queens: invalid,
      );
      expect(
        violations.any((v) => v.type == RuleViolationType.adjacency),
        isTrue,
      );
    });

    test('candidate conflict detects upcoming violations', () {
      final current = [const CellPos(0, 1)];

      // Diagonally touching cell (row 1, col 2 is adjacent to row 0, col 1, but in region 1)
      final adjConflict = RuleChecker.checkCandidateConflict(
        n: n,
        regionMap: regionMap,
        existingQueens: current,
        candidate: const CellPos(1, 2),
      );
      expect(adjConflict, isNotNull);
      expect(adjConflict!.type, RuleViolationType.adjacency);

      // Same row cell
      final rowConflict = RuleChecker.checkCandidateConflict(
        n: n,
        regionMap: regionMap,
        existingQueens: current,
        candidate: const CellPos(0, 3),
      );
      expect(rowConflict, isNotNull);
      expect(rowConflict!.type, RuleViolationType.row);

      // Same col cell
      final colConflict = RuleChecker.checkCandidateConflict(
        n: n,
        regionMap: regionMap,
        existingQueens: current,
        candidate: const CellPos(3, 1),
      );
      expect(colConflict, isNotNull);
      expect(colConflict!.type, RuleViolationType.column);

      // Valid candidate
      final validCand = RuleChecker.checkCandidateConflict(
        n: n,
        regionMap: regionMap,
        existingQueens: current,
        candidate: const CellPos(2, 0),
      );
      expect(validCand, isNull);
    });
  });
}

