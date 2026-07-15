import '../entities/puzzle_board.dart';
import '../entities/puzzle_piece.dart';

class PuzzleMergeResult {
  final PuzzleBoard board;
  final Set<int> mergedGroupIds;

  const PuzzleMergeResult({
    required this.board,
    this.mergedGroupIds = const {},
  });
}

class PuzzleGroupService {
  PuzzleMergeResult updateGroups(
    PuzzleBoard board, {
    Map<int, int>? oldGroupMap,
  }) {
    final gridSize = board.gridSize;
    final parent = List.generate(gridSize * gridSize, (index) => index);

    for (int y = 0; y < gridSize; y++) {
      for (int x = 0; x < gridSize; x++) {
        final currentIndex = y * gridSize + x;
        final piece = board.pieceAt(currentIndex);

        // Check right neighbor
        if (x < gridSize - 1) {
          final rightPiece = board.pieceAt(currentIndex + 1);
          final isCorrectRightNeighbor =
              piece.origX + 1 == rightPiece.origX &&
              piece.origY == rightPiece.origY;

          if (isCorrectRightNeighbor) {
            _union(parent, piece.id, rightPiece.id);
          }
        }

        // Check bottom neighbor
        if (y < gridSize - 1) {
          final bottomPiece = board.pieceAt(currentIndex + gridSize);
          final isCorrectBottomNeighbor =
              piece.origX == bottomPiece.origX &&
              piece.origY + 1 == bottomPiece.origY;

          if (isCorrectBottomNeighbor) {
            _union(parent, piece.id, bottomPiece.id);
          }
        }
      }
    }
    // cập nhật lại groupId của các mảnh dựa trên parent mới
    final updatedPieces = board.pieces.map((piece) {
      return piece.copyWith(groupId: _find(parent, piece.id));
    }).toList();

    final updatedBoard = board.copyWith(pieces: updatedPieces);
    final mergedGroupIds = _detectMergedGroupIds(
      updatedBoard.pieces,
      oldGroupMap,
    );

    return PuzzleMergeResult(
      board: updatedBoard,
      mergedGroupIds: mergedGroupIds,
    );
  }

  // vì sửa phần tử bên trong nên parent global sẽ bị thay đổi
  int _find(List<int> parent, int index) {
    if (parent[index] == index) return index;
    parent[index] = _find(parent, parent[index]);
    return parent[index];
  }

  // vì sửa phần tử bên trong nên parent global sẽ bị thay đổi
  void _union(List<int> parent, int first, int second) {
    final rootFirst = _find(parent, first);
    final rootSecond = _find(parent, second);

    if (rootFirst != rootSecond) {
      parent[rootFirst] = rootSecond;
    }
  }

  Set<int> _detectMergedGroupIds(
    List<PuzzlePiece> pieces,
    Map<int, int>? oldGroupMap, // Map chứa {pieceId: GroupId}
  ) {
    // Nếu không có thông tin group cũ thì không thể biết group nào vừa merge.
    if (oldGroupMap == null) return {};

    /*
    Gom các mảnh theo groupId mới.

    Sau khi updateGroups chạy xong, mỗi piece đã có groupId mới.
    Ta tạo map dạng:

    {
      groupId mới: [danh sách các mảnh thuộc group đó]
    }

    Ví dụ:
    piece A -> groupId 1
    piece B -> groupId 1
    piece C -> groupId 3

    thì groups sẽ là:
    {
      1: [A, B],
      3: [C]
    }
  */
    final groups = <int, List<PuzzlePiece>>{};
    for (final piece in pieces) {
      groups.putIfAbsent(piece.groupId, () => []).add(piece);
    }

    final mergedGroupIds = <int>{};

    /*
    Duyệt từng group mới để kiểm tra nó được tạo từ bao nhiêu group cũ.

    Với mỗi group mới, ta lấy danh sách các mảnh trong group đó,
    rồi tra oldGroupMap để biết trước khi update,
    các mảnh này thuộc những group nào.

    Nếu group mới chứa các mảnh đến từ nhiều hơn 1 group cũ,
    nghĩa là đã có merge xảy ra.
  */
    for (final entry in groups.entries) {
      final oldGroupIds = entry.value
          .map((piece) => oldGroupMap[piece.id])
          .whereType<int>()
          .toSet();

      // Nếu group mới chứa mảnh từ nhiều group cũ,
      // nghĩa là các group cũ vừa được merge thành group mới này.
      // ví dụ group mới có groupId là 3 có 3 mảnh được tạo từ 2 group cũ có groupId là 2 và 3, thì group 2 và 3 vừa được merge thành group 3, khi đó oldGroupIds = {2, 3}.
      if (oldGroupIds.length > 1) {
        // Thêm groupId mới vào danh sách các group vừa được merge.
        mergedGroupIds.add(entry.key);
      }
    }

    // Trả về danh sách groupId mới vừa được tạo ra từ việc merge.
    // Nếu chỉ có 1 group thì pulse 1 group, 2 thì pulse 2 group, không có group nào thì không pulse.
    return mergedGroupIds;
  }
}
