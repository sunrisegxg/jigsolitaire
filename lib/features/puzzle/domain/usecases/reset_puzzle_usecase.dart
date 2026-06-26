import '../../../../core/constants/app_constants.dart';
import '../entities/puzzle_board.dart';
import '../services/puzzle_engine.dart';

class ResetPuzzleUseCase {
  final PuzzleEngine engine;

  const ResetPuzzleUseCase(this.engine);

  PuzzleBoard execute({int gridSize = AppConstants.defaultGridSize}) {
    return engine.resetGame(gridSize: gridSize);
  }
}
