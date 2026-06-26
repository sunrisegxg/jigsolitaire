class PuzzlePiece {
  final int id;
  final int currentIndex;
  final int groupId;
  final int gridSize;

  const PuzzlePiece({
    required this.id,
    required this.currentIndex,
    required this.groupId,
    required this.gridSize,
  });

  int get origX => id % gridSize;
  int get origY => id ~/ gridSize;

  PuzzlePiece copyWith({
    int? id,
    int? currentIndex,
    int? groupId,
    int? gridSize,
  }) {
    return PuzzlePiece(
      id: id ?? this.id,
      currentIndex: currentIndex ?? this.currentIndex,
      groupId: groupId ?? this.groupId,
      gridSize: gridSize ?? this.gridSize,
    );
  }
}
