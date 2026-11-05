class CellPos {
  final int row;
  final int col;

  const CellPos(this.row, this.col);

  int toIndex(int n) => row * n + col;

  static CellPos fromIndex(int index, int n) =>
      CellPos(index ~/ n, index % n);

  bool isAdjacent8(CellPos other) {
    final dr = (row - other.row).abs();
    final dc = (col - other.col).abs();
    return dr <= 1 && dc <= 1 && !(dr == 0 && dc == 0);
  }

  List<CellPos> neighbors4(int n) {
    final list = <CellPos>[];
    if (row > 0) list.add(CellPos(row - 1, col));
    if (row < n - 1) list.add(CellPos(row + 1, col));
    if (col > 0) list.add(CellPos(row, col - 1));
    if (col < n - 1) list.add(CellPos(row, col + 1));
    return list;
  }

  List<CellPos> neighbors8(int n) {
    final list = <CellPos>[];
    for (int dr = -1; dr <= 1; dr++) {
      for (int dc = -1; dc <= 1; dc++) {
        if (dr == 0 && dc == 0) continue;
        final nr = row + dr;
        final nc = col + dc;
        if (nr >= 0 && nr < n && nc >= 0 && nc < n) {
          list.add(CellPos(nr, nc));
        }
      }
    }
    return list;
  }

  Map<String, dynamic> toJson() => {'row': row, 'col': col};

  factory CellPos.fromJson(Map<String, dynamic> json) =>
      CellPos(json['row'] as int, json['col'] as int);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CellPos &&
          runtimeType == other.runtimeType &&
          row == other.row &&
          col == other.col;

  @override
  int get hashCode => row.hashCode ^ (col.hashCode << 16);

  @override
  String toString() => '($row, $col)';
}

