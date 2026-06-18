import 'package:flutter/material.dart';
import 'package:test/model/puzzle_piece.dart';

// --- TILE WIDGET (Ảnh ghép giữ nguyên) ---
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
    bool sameGroupTop = _checkSameGroup(0, -1);
    bool sameGroupBottom = _checkSameGroup(0, 1);
    bool sameGroupLeft = _checkSameGroup(-1, 0);
    bool sameGroupRight = _checkSameGroup(1, 0);

    const double borderWidth = 1.5;
    const double radiusVal = 8.0;

    final tl = sameGroupLeft || sameGroupTop
        ? Radius.zero
        : const Radius.circular(radiusVal);
    final tr = sameGroupRight || sameGroupTop
        ? Radius.zero
        : const Radius.circular(radiusVal);
    final bl = sameGroupLeft || sameGroupBottom
        ? Radius.zero
        : const Radius.circular(radiusVal);
    final br = sameGroupRight || sameGroupBottom
        ? Radius.zero
        : const Radius.circular(radiusVal);

    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: tl,
          topRight: tr,
          bottomLeft: bl,
          bottomRight: br,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double w = constraints.maxWidth;
          final double h = constraints.maxHeight;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: -piece.origX * w,
                top: -piece.origY * h,
                width: w * gridSize,
                height: h * gridSize,
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
                      topLeft: tl,
                      topRight: tr,
                      bottomLeft: bl,
                      bottomRight: br,
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
                      topLeft: tl,
                      topRight: tr,
                      bottomLeft: bl,
                      bottomRight: br,
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
    int targetX = (piece.currentIndex % gridSize) + dx;
    int targetY = (piece.currentIndex ~/ gridSize) + dy;
    if (targetX < 0 ||
        targetX > (gridSize - 1) ||
        targetY < 0 ||
        targetY > (gridSize - 1)) {
      return false;
    }
    int targetIndex = targetY * gridSize + targetX;
    return board[targetIndex].groupId == piece.groupId;
  }
}
