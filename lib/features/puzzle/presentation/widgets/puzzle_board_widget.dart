import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/puzzle_piece.dart';
import '../bloc/puzzle_bloc.dart';
import '../bloc/puzzle_event.dart';
import '../bloc/puzzle_state.dart';
import 'card_back_widget.dart';
import 'group_pulse_wrapper.dart';
import 'puzzle_drag_feedback.dart';
import 'puzzle_piece_widget.dart';

class PuzzleBoardWidget extends StatefulWidget {
  const PuzzleBoardWidget({super.key});

  @override
  State<PuzzleBoardWidget> createState() => _PuzzleBoardWidgetState();
}

class _PuzzleBoardWidgetState extends State<PuzzleBoardWidget> {
  final GlobalKey _stackKey = GlobalKey();

  late final Image _puzzleImage = Image.asset(
    AppConstants.puzzleImageAsset,
    fit: BoxFit.cover,
  );

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PuzzleBloc, PuzzleState>(
      builder: (context, state) {
        if (state.board.pieces.isEmpty) {
          return const SizedBox.shrink();
        }

        final gridSize = state.board.gridSize;

        return LayoutBuilder(
          builder: (context, constraints) {
            final tileWidth = constraints.maxWidth / gridSize;
            final tileHeight = tileWidth / AppConstants.puzzleAspectRatio;

            return SizedBox(
              width: constraints.maxWidth,
              height: tileHeight * gridSize,
              child: Stack(
                key: _stackKey,
                clipBehavior: Clip.none,
                children: state.board.pieces.map((piece) {
                  final index = piece.currentIndex;
                  final currentWidget = _buildPieceSlot(
                    context: context,
                    state: state,
                    piece: piece,
                    index: index,
                    tileWidth: tileWidth,
                    tileHeight: tileHeight,
                  );

                  return AnimatedPositioned(
                    key: ValueKey(piece.id),
                    duration: const Duration(
                      milliseconds: AppConstants.swapAnimationMs,
                    ),
                    curve: Curves.easeOutCubic,
                    left: (index % gridSize) * tileWidth,
                    top: (index ~/ gridSize) * tileHeight,
                    width: tileWidth,
                    height: tileHeight,
                    child: currentWidget,
                  );
                }).toList(),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPieceSlot({
    required BuildContext context,
    required PuzzleState state,
    required PuzzlePiece piece,
    required int index,
    required double tileWidth,
    required double tileHeight,
  }) {
    final gridSize = state.board.gridSize;
    final isPartOfDraggingGroup = state.draggingGroupId == piece.groupId;
    final isDealt =
        state.phase != PuzzleGamePhase.dealing || index < state.dealIndex;

    final baseBox = Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
    );

    if (!isDealt) {
      // đây là vị trí hiển thị lá bài đầu tiên để deal ra các vị trí khác
      final bottomRightIndex = gridSize * gridSize - 1;
      return index == bottomRightIndex ? const CardBackWidget() : baseBox;
    }

    Widget tileContent = PuzzlePieceWidget(
      piece: piece,
      board: state.board.pieces,
      image: _puzzleImage,
      gridSize: gridSize,
    );

    tileContent = _wrapSnapBackIfNeeded(
      context: context,
      state: state,
      piece: piece,
      child: tileContent,
    );

    tileContent = GroupPulseWrapper(
      trigger: state.pulsingGroups.contains(piece.groupId),
      piece: piece,
      board: state.board.pieces,
      gridSize: gridSize,
      child: tileContent,
    );

    tileContent = _wrapIntroFlipIfNeeded(
      state: state,
      piece: piece,
      child: tileContent,
    );
    tileContent = _wrapDealingAnimationIfNeeded(
      state: state,
      piece: piece,
      index: index,
      tileWidth: tileWidth,
      tileHeight: tileHeight,
      child: tileContent,
    );

    return DragTarget<int>(
      onWillAcceptWithDetails: (_) => state.canInteract,
      onAcceptWithDetails: (details) {
        context.read<PuzzleBloc>().add(
          PuzzleDropped(dragIndex: details.data, dropIndex: index),
        );
      },
      builder: (context, candidateData, rejectedData) {
        final canDrag =
            state.canInteract &&
            (state.draggingGroupId == null ||
                state.draggingGroupId == piece.groupId);

        return Draggable<int>(
          maxSimultaneousDrags: canDrag ? 1 : 0,
          data: index,
          onDragStarted: () {
            context.read<PuzzleBloc>().add(PuzzleDragStarted(piece.groupId));
          },
          onDragEnd: (details) {
            context.read<PuzzleBloc>().add(const PuzzleDragEnded());

            if (!details.wasAccepted) {
              _requestSnapBack(
                context: context,
                piece: piece,
                detailsOffset: details.offset,
                tileWidth: tileWidth,
                tileHeight: tileHeight,
              );
            }
          },
          // feedback là mảnh ảo theo tay người dùng kéo, không phải mảnh thật trên board
          feedback: PuzzleDragFeedback(
            draggedPiece: piece,
            board: state.board.pieces,
            puzzleImage: _puzzleImage,
            gridSize: gridSize,
            tileWidth: tileWidth,
            tileHeight: tileHeight,
          ),
          child: Opacity(
            opacity: isPartOfDraggingGroup ? 0.3 : 1,
            child: tileContent,
          ),
        );
      },
    );
  }

  Widget _wrapSnapBackIfNeeded({
    required BuildContext context,
    required PuzzleState state,
    required PuzzlePiece piece,
    required Widget child,
  }) {
    // nếu có snap back offset thì thực hiện animation, nếu không thì trả về child bình thường
    final snapOffset = state.snapBackOffsets[piece.id];
    if (snapOffset == null) return child;

    return TweenAnimationBuilder<Offset>(
      key: ValueKey('snap_back_${piece.id}'),
      tween: Tween<Offset>(begin: snapOffset, end: Offset.zero),
      duration: const Duration(milliseconds: AppConstants.snapBackAnimationMs),
      curve: Curves.easeOutCubic,
      onEnd: () {
        context.read<PuzzleBloc>().add(PuzzleSnapBackFinished(piece.id));
      },
      builder: (context, offset, child) {
        return Transform.translate(offset: offset, child: child);
      },
      child: child,
    );
  }

  Widget _wrapIntroFlipIfNeeded({
    required PuzzleState state,
    required PuzzlePiece piece,
    required Widget child,
  }) {
    if (state.hasPlayedIntroFlip) return child;

    final flipTarget = state.phase == PuzzleGamePhase.flipping ? 0.0 : pi;

    return TweenAnimationBuilder<double>(
      key: ValueKey('intro_flip_${piece.id}'),
      tween: Tween(begin: pi, end: flipTarget),
      duration: const Duration(milliseconds: AppConstants.flipAnimationMs),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        final isFront = value < pi / 2;

        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(value),
          child: isFront
              ? child
              // Xoay CardBackWidget thêm 180 độ để mặt sau hiển thị đúng chiều / soi gương
              // khi widget cha đang bị rotateY trong animation lật bài.
              : Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..rotateY(pi),
                  child: const CardBackWidget(),
                ),
        );
      },
      child: child,
    );
  }

  Widget _wrapDealingAnimationIfNeeded({
    required PuzzleState state,
    required PuzzlePiece piece,
    required int index,
    required double tileWidth,
    required double tileHeight,
    required Widget child,
  }) {
    if (state.phase != PuzzleGamePhase.dealing || index >= state.dealIndex) {
      return child;
    }

    // dealing từ dưới lên trên, từ phải sang trái, nên mảnh ở góc dưới phải sẽ di chuyển ít nhất, mảnh ở góc trên trái sẽ di chuyển nhiều nhất.
    final gridSize = state.board.gridSize;
    final dx = (gridSize - 1) - (index % gridSize);
    final dy = (gridSize - 1) - (index ~/ gridSize);

    return TweenAnimationBuilder<double>(
      key: ValueKey('deal_${piece.id}'),
      tween: Tween(begin: 1, end: 0),
      duration: const Duration(milliseconds: AppConstants.dealAnimationMs),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(value * dx * tileWidth, value * dy * tileHeight),
          child: child,
        );
      },
      child: child,
    );
  }

  void _requestSnapBack({
    required BuildContext context,
    required PuzzlePiece piece,
    required Offset
    detailsOffset, // Offset của mảnh với hệ quy chiếu toàn màn hình
    required double tileWidth,
    required double tileHeight,
  }) {
    // globalToLocal:
    // Màn hình -> Stack
    //
    // detailsOffset      : tọa độ theo màn hình
    // localDropPos        : tọa độ theo Stack
    // Offset(slotX,slotY) : tọa độ theo Stack
    //
    // Cần đổi cùng hệ tọa độ trước khi tính delta.
    final renderBox =
        _stackKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    // Tính tọa độ cục feedback ảo lúc thả tay so với gốc của Stack
    // Đổi offset khi drop mảnh sang hệ quy chiếu của Stack chứ không phải toàn màn hình
    final localDropPosition = renderBox.globalToLocal(detailsOffset);
    // Tính tọa độ chuẩn của ô đáng lẽ mảnh phải nằm ở đó
    final slotX = (piece.currentIndex % piece.gridSize) * tileWidth;
    final slotY = (piece.currentIndex ~/ piece.gridSize) * tileHeight;

    // đây là độ lệch của mảnh sau khi thả nhưng ko swap so với vị trí gốc của mảnh trên stack
    // lệch dx và dy so với mảnh gốc
    final deltaOffset = localDropPosition - Offset(slotX, slotY);

    context.read<PuzzleBloc>().add(
      PuzzleSnapBackRequested(groupId: piece.groupId, offset: deltaOffset),
    );
  }
}
