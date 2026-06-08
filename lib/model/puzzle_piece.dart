// --- MODEL ---
class PuzzlePiece {
  final int id;
  int currentIndex;
  int groupId;

  PuzzlePiece({
    required this.id,
    required this.currentIndex,
    required this.groupId,
  });

  int get origX => id % 4;
  int get origY => id ~/ 4;
}
