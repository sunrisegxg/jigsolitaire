import 'dart:math';

import '../../../../core/constants/app_constants.dart';
import '../entities/puzzle_board.dart';
import '../entities/puzzle_piece.dart';

class PuzzleShuffleService {
  final Random _random;

  PuzzleShuffleService({Random? random}) : _random = random ?? Random();

  // Generates a shuffled puzzle board with the specified grid size.
  PuzzleBoard generateInitialBoard({
    int gridSize = AppConstants.defaultGridSize,
  }) {
    final pieces = List.generate(gridSize * gridSize, (index) {
      return PuzzlePiece(
        id: index,
        currentIndex: index,
        groupId: index,
        gridSize: gridSize,
      );
    });

    pieces.shuffle(_random);

    final reindexedPieces = List.generate(
      pieces.length,
      (index) => pieces[index].copyWith(currentIndex: index),
    );

    return PuzzleBoard(gridSize: gridSize, pieces: reindexedPieces);
  }
}
