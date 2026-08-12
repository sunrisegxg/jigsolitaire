import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/services/interaction_service.dart';
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

  static const int _gridSize = 5;
  static const String _backCardAsset = 'assets/images/backcard.png';

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
        final gap = 4.0 * gapFactor;
        final width = constraints.maxWidth - 24;
        final canvasHeight = constraints.maxHeight - 24;
        final cellWidth = (width - gap * (_gridSize - 1)) / _gridSize;
        final cellHeight = (canvasHeight - gap * (_gridSize - 1)) / _gridSize;

        return Center(
          child: SizedBox(
            width: width,
            height: canvasHeight,
            child: Stack(
              children: [
                for (var position = 0; position < 25; position++)
                  _buildCell(
                    context: context,
                    position: position,
                    cellWidth: cellWidth,
                    cellHeight: cellHeight,
                    gap: gap,
                    canvasWidth: cellWidth * _gridSize,
                    canvasHeight: cellHeight * _gridSize,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCell({
    required BuildContext context,
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
    final definition = collection.levels
        .where((item) => item.position == position)
        .firstOrNull;
    final isContentAvailable = definition != null;
    final isCompleted = isContentAvailable && level <= completedLevelCount;
    final isCurrent = isContentAvailable && level == completedLevelCount + 1;
    final isLocked = !isCompleted && !isCurrent;
    final isDealt = position < dealIndex;

    return Positioned(
      left: column * (cellWidth + gap),
      top: row * (cellHeight + gap),
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
            onTap: isCompleted
                ? () async {
                    await context.read<InteractionService>().tap();
                    onCompletedLevelTap(level);
                  }
                : null,
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
                    _buildBackCard(
                      level: level,
                      isCurrent: isCurrent,
                      isContentAvailable: isContentAvailable,
                    ),
                  _buildCellFrame(isCurrent: isCurrent, isLocked: isLocked),
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

  Widget _buildBackCard({
    required int level,
    required bool isCurrent,
    required bool isContentAvailable,
  }) {
    final isLocked = !isCurrent;
    const currentColor = Color(0xFF3B8F7A);
    const currentTextColor = Color(0xFFE2F5EF);
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          _backCardAsset,
          fit: BoxFit.cover,
          color: isLocked ? Colors.grey.shade700 : null,
          colorBlendMode: isLocked ? BlendMode.overlay : null,
        ),
        if (isLocked) ColoredBox(color: Colors.black.withValues(alpha: .5)),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLocked)
                Icon(
                  isContentAvailable
                      ? Icons.lock_rounded
                      : Icons.schedule_rounded,
                  size: 34,
                  color: Colors.white.withValues(alpha: .9),
                ),
              Text(
                '$level',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: isCurrent ? 22 : 16,
                  fontWeight: FontWeight.w800,
                  shadows: const [
                    Shadow(
                      color: Colors.black,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: 4,
          right: 4,
          bottom: 4,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 2),
            decoration: BoxDecoration(
              color: isCurrent
                  ? currentColor
                  : Colors.black.withValues(alpha: .72),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              isCurrent
                  ? 'CURRENT'
                  : isContentAvailable
                  ? 'LOCKED'
                  : 'COMING SOON',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: isCurrent ? currentTextColor : Colors.white,
                fontSize: isContentAvailable ? 8 : 6.5,
                fontWeight: FontWeight.w800,
                letterSpacing: .3,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCellFrame({required bool isCurrent, required bool isLocked}) {
    return IgnorePointer(
      child: Opacity(
        opacity: frameOpacity,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(
              color: isCurrent
                  ? const Color(0xFF69B7A2)
                  : isLocked
                  ? const Color(0xFF555B5E)
                  : Colors.black,
              width: isCurrent ? 3 : 1,
            ),
            borderRadius: BorderRadius.circular(5),
            boxShadow: isCurrent
                ? const [BoxShadow(color: Color(0x554A9D87), blurRadius: 5)]
                : null,
          ),
        ),
      ),
    );
  }
}
