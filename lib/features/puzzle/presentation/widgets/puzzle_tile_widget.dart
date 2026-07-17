import 'package:flutter/material.dart';

import '../../domain/entities/puzzle_piece.dart';

class PuzzleTileWidget extends StatelessWidget {
  final PuzzlePiece piece;
  final List<PuzzlePiece> board;
  final Image image;
  final int gridSize;

  const PuzzleTileWidget({
    super.key,
    required this.piece,
    required this.board,
    required this.image,
    required this.gridSize,
  });

  @override
  Widget build(BuildContext context) {
    final sameGroupTop = _checkSameGroup(0, -1);
    final sameGroupBottom = _checkSameGroup(0, 1);
    final sameGroupLeft = _checkSameGroup(-1, 0);
    final sameGroupRight = _checkSameGroup(1, 0);

    const borderWidth = 1.5;
    const radiusValue = 8.0;

    final topLeft = sameGroupLeft || sameGroupTop
        ? Radius.zero
        : const Radius.circular(radiusValue);
    final topRight = sameGroupRight || sameGroupTop
        ? Radius.zero
        : const Radius.circular(radiusValue);
    final bottomLeft = sameGroupLeft || sameGroupBottom
        ? Radius.zero
        : const Radius.circular(radiusValue);
    final bottomRight = sameGroupRight || sameGroupBottom
        ? Radius.zero
        : const Radius.circular(radiusValue);

    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: topLeft,
          topRight: topRight,
          bottomLeft: bottomLeft,
          bottomRight: bottomRight,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: -piece.origX * width,
                top: -piece.origY * height,
                width: width * gridSize,
                height: height * gridSize,
                child: SizedBox.expand(child: image),
              ),
              Positioned(
                top: sameGroupTop ? -borderWidth : 0,
                bottom: sameGroupBottom ? -borderWidth : 0,
                left: sameGroupLeft ? -borderWidth : 0,
                right: sameGroupRight ? -borderWidth : 0,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: borderWidth),
                    borderRadius: BorderRadius.only(
                      topLeft: topLeft,
                      topRight: topRight,
                      bottomLeft: bottomLeft,
                      bottomRight: bottomRight,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: sameGroupTop ? -borderWidth / 2 : 0,
                bottom: sameGroupBottom ? -borderWidth / 2 : 0,
                left: sameGroupLeft ? -borderWidth / 2 : 0,
                right: sameGroupRight ? -borderWidth / 2 : 0,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black,
                      width: borderWidth / 2,
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: topLeft,
                      topRight: topRight,
                      bottomLeft: bottomLeft,
                      bottomRight: bottomRight,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  bool _checkSameGroup(int dx, int dy) {
    final targetX = (piece.currentIndex % gridSize) + dx;
    final targetY = (piece.currentIndex ~/ gridSize) + dy;

    if (targetX < 0 ||
        targetX >= gridSize ||
        targetY < 0 ||
        targetY >= gridSize) {
      return false;
    }

    final targetIndex = targetY * gridSize + targetX;
    return board[targetIndex].groupId == piece.groupId;
  }
}
