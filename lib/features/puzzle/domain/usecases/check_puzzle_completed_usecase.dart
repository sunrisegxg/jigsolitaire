import '../entities/puzzle_board.dart';
import '../services/puzzle_engine.dart';

class CheckPuzzleCompletedUseCase {
  final PuzzleEngine engine;

  const CheckPuzzleCompletedUseCase(this.engine);

  bool execute(PuzzleBoard board) {
    return engine.isCompleted(board);
  }
}
