import '../level/cell_pos.dart';

enum RuleViolationType {
  row,
  column,
  region,
  adjacency,
}

class RuleViolation {
  final RuleViolationType type;
  final String message;
  final List<CellPos> involvedCells;

  const RuleViolation({
    required this.type,
    required this.message,
    required this.involvedCells,
  });
}

class RuleChecker {
  /// Checks if placing a queen at [candidate] conflicts with any of the [existingQueens]
  /// with respect to row, column, region, or 8-way adjacency.
  static RuleViolation? checkCandidateConflict({
    required int n,
    required List<int> regionMap,
    required List<CellPos> existingQueens,
    required CellPos candidate,
  }) {
    final candidateRegion = regionMap[candidate.toIndex(n)];

    for (final q in existingQueens) {
      if (q == candidate) continue;

      if (q.row == candidate.row) {
        return RuleViolation(
          type: RuleViolationType.row,
          message: 'Row ${candidate.row + 1} already has a cat.',
          involvedCells: [q, candidate],
        );
      }

      if (q.col == candidate.col) {
        return RuleViolation(
          type: RuleViolationType.column,
          message: 'Col ${candidate.col + 1} already has a cat.',
          involvedCells: [q, candidate],
        );
      }

      final qRegion = regionMap[q.toIndex(n)];
      if (qRegion == candidateRegion) {
        return RuleViolation(
          type: RuleViolationType.region,
          message: 'This color region already has a cat.',
          involvedCells: [q, candidate],
        );
      }

      if (candidate.isAdjacent8(q)) {
        return RuleViolation(
          type: RuleViolationType.adjacency,
          message: 'Cats cannot touch each other (including diagonals).',
          involvedCells: [q, candidate],
        );
      }
    }

    return null;
  }

  /// Finds all rule violations among the given list of queens.
  static List<RuleViolation> findAllViolations({
    required int n,
    required List<int> regionMap,
    required List<CellPos> queens,
  }) {
    final violations = <RuleViolation>[];

    // Check rows
    final rowMap = <int, List<CellPos>>{};
    for (final q in queens) {
      rowMap.putIfAbsent(q.row, () => []).add(q);
    }
    for (final entry in rowMap.entries) {
      if (entry.value.length > 1) {
        violations.add(RuleViolation(
          type: RuleViolationType.row,
          message: 'Row ${entry.key + 1} has more than 1 cat.',
          involvedCells: entry.value,
        ));
      }
    }

    // Check columns
    final colMap = <int, List<CellPos>>{};
    for (final q in queens) {
      colMap.putIfAbsent(q.col, () => []).add(q);
    }
    for (final entry in colMap.entries) {
      if (entry.value.length > 1) {
        violations.add(RuleViolation(
          type: RuleViolationType.column,
          message: 'Col ${entry.key + 1} has more than 1 cat.',
          involvedCells: entry.value,
        ));
      }
    }

    // Check regions
    final regMap = <int, List<CellPos>>{};
    for (final q in queens) {
      final rId = regionMap[q.toIndex(n)];
      regMap.putIfAbsent(rId, () => []).add(q);
    }
    for (final entry in regMap.entries) {
      if (entry.value.length > 1) {
        violations.add(RuleViolation(
          type: RuleViolationType.region,
          message: 'Color region ${entry.key + 1} has more than 1 cat.',
          involvedCells: entry.value,
        ));
      }
    }

    // Check 8-way adjacency
    for (int i = 0; i < queens.length; i++) {
      for (int j = i + 1; j < queens.length; j++) {
        if (queens[i].isAdjacent8(queens[j])) {
          violations.add(RuleViolation(
            type: RuleViolationType.adjacency,
            message: 'Two cats touch each other at ${queens[i]} and ${queens[j]}.',
            involvedCells: [queens[i], queens[j]],
          ));
        }
      }
    }

    return violations;
  }

  /// Checks if the board is completely and correctly solved:
  /// - Exactly N queens placed
  /// - No violations
  /// - Exactly 1 queen per row, column, and region
  static bool isSolved({
    required int n,
    required List<int> regionMap,
    required List<CellPos> queens,
  }) {
    if (queens.length != n) return false;
    final violations = findAllViolations(
      n: n,
      regionMap: regionMap,
      queens: queens,
    );
    return violations.isEmpty;
  }
}

