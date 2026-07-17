import '../entities/puzzle_board.dart';
import '../services/puzzle_engine.dart';
import '../services/puzzle_group_service.dart';
import '../services/puzzle_move_service.dart';

class MovePuzzleGroupUseCase {
  final PuzzleEngine engine;

  const MovePuzzleGroupUseCase(this.engine);

  PuzzleMoveResult execute({
    required PuzzleBoard board,
    required int dragIndex,
    required int dropIndex,
  }) {
    return engine.moveGroup(
      board: board,
      dragIndex: dragIndex,
      dropIndex: dropIndex,
    );
  }

  PuzzleMergeResult updateGroupsAfterMove({
    required PuzzleBoard board,
    required Map<int, int> oldGroupMap,
  }) {
    return engine.updateGroupsAfterMove(board: board, oldGroupMap: oldGroupMap);
  }
}
