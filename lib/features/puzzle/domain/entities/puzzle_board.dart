import 'puzzle_piece.dart';

class PuzzleBoard {
  final int gridSize;
  final List<PuzzlePiece> pieces;

  const PuzzleBoard({
    required this.gridSize,
    required this.pieces,
  });

  int get totalPieces => gridSize * gridSize;

  PuzzlePiece pieceAt(int index) => pieces[index];


  // Returns a list of pieces that belong to the specified group ID.
  List<PuzzlePiece> piecesInGroup(int groupId) {
    return pieces.where((piece) => piece.groupId == groupId).toList();
  }

  bool get isCompleted {
    return pieces.every((piece) => piece.id == piece.currentIndex);
  }

  PuzzleBoard copyWith({
    int? gridSize,
    List<PuzzlePiece>? pieces,
  }) {
    return PuzzleBoard(
      gridSize: gridSize ?? this.gridSize,
      pieces: pieces ?? this.pieces,
    );
  }

  PuzzleBoard withReindexedPieces() {
    return copyWith(
      pieces: List.generate(
        pieces.length,
        (index) => pieces[index].copyWith(currentIndex: index),
      ),
    );
  }

  static PuzzleBoard empty({int gridSize = 0}) {
    return PuzzleBoard(gridSize: gridSize, pieces: const []);
  }
}
