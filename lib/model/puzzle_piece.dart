// --- MODEL ---
class PuzzlePiece {
  final int id;
  int currentIndex;
  int groupId;
  int gridSize;

  PuzzlePiece({
    required this.id,
    required this.currentIndex,
    required this.groupId,
    required this.gridSize,
  });

  int get origX => id % gridSize;
  int get origY => id ~/ gridSize;
}
