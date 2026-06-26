import 'package:flutter/material.dart';

import '../../domain/entities/puzzle_piece.dart';
import 'puzzle_tile_widget.dart';

class PuzzlePieceWidget extends StatelessWidget {
  final PuzzlePiece piece;
  final List<PuzzlePiece> board;
  final Image image;
  final int gridSize;

  const PuzzlePieceWidget({
    super.key,
    required this.piece,
    required this.board,
    required this.image,
    required this.gridSize,
  });

  @override
  Widget build(BuildContext context) {
    return PuzzleTileWidget(
      key: ValueKey('tile_${piece.id}'),
      piece: piece,
      board: board,
      image: image,
      gridSize: gridSize,
    );
  }
}
