import 'package:cat_queens/domain/level/cell_pos.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CellPos', () {
    test('index conversion works correctly for 5x5', () {
      final pos = CellPos(2, 3);
      expect(pos.toIndex(5), 13);
      final fromIdx = CellPos.fromIndex(13, 5);
      expect(fromIdx.row, 2);
      expect(fromIdx.col, 3);
      expect(fromIdx, equals(pos));
    });

    test('isAdjacent8 detects 8-direction neighbors and self correctly', () {
      final center = CellPos(2, 2);
      // Self is not adjacent to self
      expect(center.isAdjacent8(CellPos(2, 2)), isFalse);

      // Orthogonal neighbors
      expect(center.isAdjacent8(CellPos(1, 2)), isTrue);
      expect(center.isAdjacent8(CellPos(3, 2)), isTrue);
      expect(center.isAdjacent8(CellPos(2, 1)), isTrue);
      expect(center.isAdjacent8(CellPos(2, 3)), isTrue);

      // Diagonal neighbors
      expect(center.isAdjacent8(CellPos(1, 1)), isTrue);
      expect(center.isAdjacent8(CellPos(1, 3)), isTrue);
      expect(center.isAdjacent8(CellPos(3, 1)), isTrue);
      expect(center.isAdjacent8(CellPos(3, 3)), isTrue);

      // Further cells
      expect(center.isAdjacent8(CellPos(0, 0)), isFalse);
      expect(center.isAdjacent8(CellPos(2, 4)), isFalse);
    });

    test('neighbors4 returns correct count at corners, edges, and center', () {
      final corner = CellPos(0, 0);
      expect(corner.neighbors4(5).length, 2);

      final edge = CellPos(0, 2);
      expect(edge.neighbors4(5).length, 3);

      final center = CellPos(2, 2);
      expect(center.neighbors4(5).length, 4);
    });

    test('neighbors8 returns correct count at corners, edges, and center', () {
      final corner = CellPos(0, 0);
      expect(corner.neighbors8(5).length, 3);

      final edge = CellPos(0, 2);
      expect(edge.neighbors8(5).length, 5);

      final center = CellPos(2, 2);
      expect(center.neighbors8(5).length, 8);
    });
  });
}

