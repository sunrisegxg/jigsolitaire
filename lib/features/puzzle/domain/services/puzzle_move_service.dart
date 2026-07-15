import '../entities/board_position.dart';
import '../entities/puzzle_board.dart';
import '../entities/puzzle_piece.dart';

class PuzzleMoveResult {
  final bool isValid;
  final PuzzleBoard board;
  final Map<int, int> oldGroupMap;
  final String? reason;

  const PuzzleMoveResult._({
    required this.isValid,
    required this.board,
    required this.oldGroupMap,
    this.reason,
  });

  factory PuzzleMoveResult.valid({
    required PuzzleBoard board,
    required Map<int, int> oldGroupMap,
  }) {
    return PuzzleMoveResult._(
      isValid: true,
      board: board,
      oldGroupMap: oldGroupMap,
    );
  }

  factory PuzzleMoveResult.invalid({
    required PuzzleBoard board,
    String? reason,
  }) {
    return PuzzleMoveResult._(
      isValid: false,
      board: board,
      oldGroupMap: const {},
      reason: reason,
    );
  }
}

class PuzzleMoveService {
  PuzzleMoveResult applyMove({
    required PuzzleBoard board,
    required int dragIndex,
    required int dropIndex,
  }) {
    if (dragIndex == dropIndex) {
      return PuzzleMoveResult.invalid(
        board: board,
        reason: 'Drag index and drop index are the same.',
      );
    }

    if (dragIndex < 0 || dragIndex >= board.totalPieces) {
      return PuzzleMoveResult.invalid(
        board: board,
        reason: 'Invalid drag index.',
      );
    }

    if (dropIndex < 0 || dropIndex >= board.totalPieces) {
      return PuzzleMoveResult.invalid(
        board: board,
        reason: 'Invalid drop index.',
      );
    }

    // Calculate offset between drag and drop positions
    final gridSize = board.gridSize;
    final draggedPiece = board.pieceAt(dragIndex);
    final dragPosition = BoardPosition.fromIndex(dragIndex, gridSize);
    final dropPosition = BoardPosition.fromIndex(dropIndex, gridSize);
    final dx = dropPosition.x - dragPosition.x;
    final dy = dropPosition.y - dragPosition.y;

    // Get all pieces in the dragged group and check if they can be moved to the new position
    final groupPieces = board.piecesInGroup(draggedPiece.groupId);

    for (final piece in groupPieces) {
      final position = BoardPosition.fromIndex(piece.currentIndex, gridSize);
      final nextPosition = position.translate(dx, dy);

      if (!nextPosition.isInside(gridSize)) {
        return PuzzleMoveResult.invalid(
          board: board,
          reason: 'The dragged group is out of bounds.',
        );
      }
    }

    // Tạo map cũ của groupId để so sánh sau khi di chuyển
    final oldGroupMap = {
      for (final piece in board.pieces) piece.id: piece.groupId,
    };
    final oldIndices = groupPieces.map((piece) => piece.currentIndex).toSet();

    //
    final newIndices = groupPieces.map((piece) {
      final position = BoardPosition.fromIndex(piece.currentIndex, gridSize);
      return position.translate(dx, dy).toIndex(gridSize);
    }).toSet();

    // gaps là các vị trí trống sau khi group di chuyển
    final gaps = oldIndices.difference(newIndices).toList();
    // displacedIndices là các vị trí mà các mảnh sẽ bị đẩy ra khỏi vị trí của chúng khi group di chuyển vào
    final displacedIndices = newIndices.difference(oldIndices).toList();

    if (gaps.length != displacedIndices.length) {
      return PuzzleMoveResult.invalid(
        board: board,
        reason: 'Invalid move calculation.',
      );
    }

    // lấp các vị trí trống gaps bằng các mảnh bị đẩy ra displacedIndices khỏi vị trí của chúng
    final displacedPieces = displacedIndices.map(board.pieceAt).toList();
    final nextPieces = List<PuzzlePiece>.from(board.pieces);

    // Di chuyển các mảnh trong group đến vị trí mới
    for (final piece in groupPieces) {
      final position = BoardPosition.fromIndex(piece.currentIndex, gridSize);
      final nextIndex = position.translate(dx, dy).toIndex(gridSize);
      nextPieces[nextIndex] = piece;
    }

    // Lấp các vị trí trống gaps bằng các mảnh bị đẩy ra
    for (int i = 0; i < displacedPieces.length; i++) {
      nextPieces[gaps[i]] = displacedPieces[i];
    }

    final movedBoard = board.copyWith(pieces: nextPieces).withReindexedPieces();

    return PuzzleMoveResult.valid(board: movedBoard, oldGroupMap: oldGroupMap);
  }
}
