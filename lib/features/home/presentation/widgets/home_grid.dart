import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../content/domain/entities/campaign_content.dart';

class HomeGrid extends StatelessWidget {
  const HomeGrid({
    required this.collection,
    required this.completedLevelCount,
    required this.onCompletedLevelTap,
    this.gapFactor = 1,
    this.frameOpacity = 1,
    this.dealIndex = 25,
    super.key,
  });

  final CampaignCollectionDefinition collection;
  final int completedLevelCount;
  final ValueChanged<int> onCompletedLevelTap;
  final double gapFactor;
  final double frameOpacity;
  final int dealIndex;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const columns = 5;
        const rows = 5;
        final gap = 4.0 * gapFactor;
        final width = constraints.maxWidth - 24;
        final availableHeight = constraints.maxHeight - 24;
        final canvasHeight = availableHeight;
        final cellWidth = (width - gap * (columns - 1)) / columns;
        final cellHeight = (canvasHeight - gap * (rows - 1)) / rows;

        return Center(
          child: SizedBox(
            width: width,
            height: canvasHeight,
            child: Stack(
              children: [
                for (var position = 0; position < 25; position++)
                  _buildCell(
                    position: position,
                    cellWidth: cellWidth,
                    cellHeight: cellHeight,
                    gap: gap,
                    canvasWidth: cellWidth * columns,
                    canvasHeight: cellHeight * rows,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  static const int _gridSize = 5;
  static const String _backCardAsset = 'assets/images/backcard.jpeg';

  Widget _buildCell({
    required int position,
    required double cellWidth,
    required double cellHeight,
    required double gap,
    required double canvasWidth,
    required double canvasHeight,
  }) {
    final row = position ~/ _gridSize;
    final column = position % _gridSize;
    final level = collection.startLevel + position;

    final levelDefinition = collection.levels
        .where((item) => item.position == position)
        .firstOrNull;

    final isAvailable = levelDefinition != null;
    final isCompleted = isAvailable && level <= completedLevelCount;
    final isDealt = position < dealIndex;

    final left = column * (cellWidth + gap);
    final top = row * (cellHeight + gap);

    return Positioned(
      left: left,
      top: top,
      width: cellWidth,
      height: cellHeight,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 250),
        opacity: isDealt ? 1 : 0,
        child: AnimatedSlide(
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeOutCubic,
          offset: isDealt
              ? Offset.zero
              : Offset(
                  (_gridSize - 1 - column).toDouble(),
                  (_gridSize - 1 - row).toDouble(),
                ),
          child: GestureDetector(
            onTap: isCompleted ? () => onCompletedLevelTap(level) : null,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5 * frameOpacity),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (isCompleted)
                    _buildCompletedImageSlice(
                      row: row,
                      column: column,
                      canvasWidth: canvasWidth,
                      canvasHeight: canvasHeight,
                    )
                  else
                    _buildBackCard(level: level, isAvailable: isAvailable),
                  _buildCellFrame(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompletedImageSlice({
    required int row,
    required int column,
    required double canvasWidth,
    required double canvasHeight,
  }) {
    final sliceWidth = canvasWidth / _gridSize;
    final sliceHeight = canvasHeight / _gridSize;

    return ClipRect(
      child: OverflowBox(
        alignment: Alignment.topLeft,
        minWidth: canvasWidth,
        maxWidth: canvasWidth,
        minHeight: canvasHeight,
        maxHeight: canvasHeight,
        child: Transform.translate(
          offset: Offset(-column * sliceWidth, -row * sliceHeight),
          child: Image.asset(
            collection.collectionImageAsset,
            width: canvasWidth,
            height: canvasHeight,
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
        ),
      ),
    );
  }

  Widget _buildBackCard({required int level, required bool isAvailable}) {
    final text = '$level';

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          _backCardAsset,
          fit: BoxFit.cover,
          color: isAvailable ? null : Colors.black.withValues(alpha: 0.25),
          colorBlendMode: isAvailable ? null : BlendMode.darken,
        ),
        Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Viền tối giúp số rõ trên họa tiết.
              Text(
                text,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  height: 1,
                  foreground: Paint()
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = 4
                    ..color = Colors.black.withValues(alpha: 0.8),
                ),
              ),
              Text(
                text,
                style: GoogleFonts.poppins(
                  color: isAvailable
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.45),
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  height: 1,
                  shadows: const [
                    Shadow(
                      color: Colors.black54,
                      blurRadius: 3,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCellFrame() {
    return IgnorePointer(
      child: Opacity(
        opacity: frameOpacity,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 1),
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ),
    );
  }
}
