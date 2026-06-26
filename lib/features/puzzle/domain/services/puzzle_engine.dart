import '../../../../core/constants/app_constants.dart';
import '../entities/puzzle_board.dart';
import 'puzzle_group_service.dart';
import 'puzzle_move_service.dart';
import 'puzzle_shuffle_service.dart';

class PuzzleEngine {
  final PuzzleShuffleService shuffleService;
  final PuzzleMoveService moveService;
  final PuzzleGroupService groupService;

  const PuzzleEngine({
    required this.shuffleService,
    required this.moveService,
    required this.groupService,
  });

  PuzzleBoard startGame({int gridSize = AppConstants.defaultGridSize}) {
    final shuffledBoard = shuffleService.generateInitialBoard(gridSize: gridSize);
    return groupService.updateGroups(shuffledBoard).board;
  }

  PuzzleBoard resetGame({int gridSize = AppConstants.defaultGridSize}) {
    return startGame(gridSize: gridSize);
  }

  PuzzleMoveResult moveGroup({
    required PuzzleBoard board,
    required int dragIndex,
    required int dropIndex,
  }) {
    return moveService.applyMove(
      board: board,
      dragIndex: dragIndex,
      dropIndex: dropIndex,
    );
  }

  PuzzleMergeResult updateGroupsAfterMove({
    required PuzzleBoard board,
    required Map<int, int> oldGroupMap,
  }) {
    return groupService.updateGroups(board, oldGroupMap: oldGroupMap);
  }

  bool isCompleted(PuzzleBoard board) {
    return board.isCompleted;
  }
}
