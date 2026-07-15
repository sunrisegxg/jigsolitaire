import '../../../../core/constants/app_constants.dart';
import '../entities/puzzle_board.dart';
import '../services/puzzle_engine.dart';

class StartPuzzleUseCase {
  final PuzzleEngine engine;

  const StartPuzzleUseCase(this.engine);

  PuzzleBoard execute({int gridSize = AppConstants.defaultGridSize}) {
    return engine.startGame(gridSize: gridSize);
  }
}
