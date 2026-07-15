import 'features/puzzle/domain/services/puzzle_engine.dart';
import 'features/puzzle/domain/services/puzzle_group_service.dart';
import 'features/puzzle/domain/services/puzzle_move_service.dart';
import 'features/puzzle/domain/services/puzzle_shuffle_service.dart';
import 'features/puzzle/domain/usecases/check_puzzle_completed_usecase.dart';
import 'features/puzzle/domain/usecases/move_puzzle_group_usecase.dart';
import 'features/puzzle/domain/usecases/reset_puzzle_usecase.dart';
import 'features/puzzle/domain/usecases/start_puzzle_usecase.dart';
import 'features/puzzle/presentation/bloc/puzzle_bloc.dart';

class InjectionContainer {
  const InjectionContainer._();

  static PuzzleBloc createPuzzleBloc() {
    final shuffleService = PuzzleShuffleService();
    final moveService = PuzzleMoveService();
    final groupService = PuzzleGroupService();

    final engine = PuzzleEngine(
      shuffleService: shuffleService,
      moveService: moveService,
      groupService: groupService,
    );

    return PuzzleBloc(
      startPuzzleUseCase: StartPuzzleUseCase(engine),
      movePuzzleGroupUseCase: MovePuzzleGroupUseCase(engine),
      resetPuzzleUseCase: ResetPuzzleUseCase(engine),
      checkPuzzleCompletedUseCase: CheckPuzzleCompletedUseCase(engine),
    );
  }
}
