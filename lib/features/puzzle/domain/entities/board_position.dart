class BoardPosition {
  final int x;
  final int y;

  const BoardPosition({
    required this.x,
    required this.y,
  });

  int toIndex(int gridSize) => y * gridSize + x;

  bool isInside(int gridSize) {
    return x >= 0 && x < gridSize && y >= 0 && y < gridSize;
  }

  //
  BoardPosition translate(int dx, int dy) {
    return BoardPosition(x: x + dx, y: y + dy);
  }
  //
  static BoardPosition fromIndex(int index, int gridSize) {
    return BoardPosition(
      x: index % gridSize,
      y: index ~/ gridSize,
    );
  }
}
