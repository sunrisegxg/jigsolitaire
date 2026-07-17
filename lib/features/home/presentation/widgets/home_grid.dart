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

  Widget _buildCell({
    required int position,
    required double cellWidth,
    required double cellHeight,
    required double gap,
    required double canvasWidth,
    required double canvasHeight,
  }) {
    final row = position ~/ 5;
    final column = position % 5;
    final level = collection.startLevel + position;
    final definition = collection.levels
        .where((item) => item.position == position)
        .firstOrNull;
    final completed = definition != null && level <= completedLevelCount;
    final dealt = position < dealIndex;

    return Positioned(
      left: column * (cellWidth + gap),
      top: row * (cellHeight + gap),
      width: cellWidth,
      height: cellHeight,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 250),
        opacity: dealt ? 1 : 0,
        child: AnimatedSlide(
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeOutCubic,
          offset: dealt
              ? Offset.zero
              : Offset(4 - column.toDouble(), 4 - row.toDouble()),
          child: GestureDetector(
            onTap: completed ? () => onCompletedLevelTap(level) : null,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5 * frameOpacity),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (completed)
                    ClipRect(
                      child: OverflowBox(
                        alignment: Alignment.topLeft,
                        minWidth: canvasWidth,
                        maxWidth: canvasWidth,
                        minHeight: canvasHeight,
                        maxHeight: canvasHeight,
                        child: Transform.translate(
                          offset: Offset(
                            -column * cellWidth,
                            -row * cellHeight,
                          ),
                          child: Image.asset(
                            collection.collectionImageAsset,
                            width: canvasWidth,
                            height: canvasHeight,
                            fit: BoxFit.cover,
                            alignment: Alignment.center,
                          ),
                        ),
                      ),
                    )
                  else
                    Image.asset(
                      'assets/images/backcard.jpeg',
                      fit: BoxFit.cover,
                    ),
                  if (!completed)
                    Center(
                      child: Text(
                        '$level',
                        style: GoogleFonts.poppins(
                          color: definition == null
                              ? Colors.white54
                              : Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          shadows: const [
                            Shadow(blurRadius: 4, color: Colors.black),
                          ],
                        ),
                      ),
                    ),
                  IgnorePointer(
                    child: Opacity(
                      opacity: frameOpacity,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 1),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
