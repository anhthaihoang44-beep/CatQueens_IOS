enum CellMark {
  empty,
  queen,
  xMark,
  autoXMark,
}

extension CellMarkExt on CellMark {
  bool get isX => this == CellMark.xMark || this == CellMark.autoXMark;
  bool get isQueen => this == CellMark.queen;
  bool get isEmpty => this == CellMark.empty;
}
