import 'package:flutter/material.dart';

import '../../domain/entities/puzzle_piece.dart';
import 'puzzle_tile_widget.dart';

class PuzzleDragFeedback extends StatelessWidget {
  final PuzzlePiece draggedPiece;
  final List<PuzzlePiece> board;
  final Image puzzleImage;
  final int gridSize;
  final double tileWidth;
  final double tileHeight;

  const PuzzleDragFeedback({
    super.key,
    required this.draggedPiece,
    required this.board,
    required this.puzzleImage,
    required this.gridSize,
    required this.tileWidth,
    required this.tileHeight,
  });

  @override
  Widget build(BuildContext context) {
    final groupPieces = board
        .where((piece) => piece.groupId == draggedPiece.groupId)
        .toList();

    return Material(
      color: Colors.transparent,
      child: SizedBox(
        width: tileWidth,
        height: tileHeight,
        child: Stack(
          clipBehavior: Clip.none,
          children: groupPieces.map((piece) {
            final dx =
                (piece.currentIndex % gridSize) -
                (draggedPiece.currentIndex % gridSize);
            final dy =
                (piece.currentIndex ~/ gridSize) -
                (draggedPiece.currentIndex ~/ gridSize);

            return Positioned(
              left: dx * tileWidth,
              top: dy * tileHeight,
              width: tileWidth,
              height: tileHeight,
              child: PuzzleTileWidget(
                key: ValueKey('feedback_${piece.id}'),
                piece: piece,
                board: board,
                image: puzzleImage,
                gridSize: gridSize,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
