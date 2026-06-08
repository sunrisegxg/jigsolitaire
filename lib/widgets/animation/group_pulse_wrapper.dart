import 'package:flutter/material.dart';
import 'package:test/model/puzzle_piece.dart';

// --- WIDGET HIỆU ỨNG NHỊP TIM CHO CỤM MẢNH GHÉP VỪA GỘP (PULSE GROUP) ---
class GroupPulseWrapper extends StatefulWidget {
  final Widget child;
  final bool trigger;
  final PuzzlePiece piece;
  final List<PuzzlePiece> board;
  final int gridSize;

  const GroupPulseWrapper({
    super.key,
    required this.child,
    required this.trigger,
    required this.piece,
    required this.board,
    required this.gridSize,
  });

  @override
  State<GroupPulseWrapper> createState() => _GroupPulseWrapperState();
}

class _GroupPulseWrapperState extends State<GroupPulseWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.08), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.08, end: 1.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(covariant GroupPulseWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger && !oldWidget.trigger) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final groupPieces = widget.board
        .where((p) => p.groupId == widget.piece.groupId)
        .toList();

    final xs = groupPieces
        .map((p) => p.currentIndex % widget.gridSize)
        .toList();
    final ys = groupPieces
        .map((p) => p.currentIndex ~/ widget.gridSize)
        .toList();

    final minX = xs.reduce((a, b) => a < b ? a : b).toDouble();
    final maxX = xs.reduce((a, b) => a > b ? a : b).toDouble();
    final minY = ys.reduce((a, b) => a < b ? a : b).toDouble();
    final maxY = ys.reduce((a, b) => a > b ? a : b).toDouble();

    final centerX = (minX + maxX) / 2.0;
    final centerY = (minY + maxY) / 2.0;

    final pieceX = (widget.piece.currentIndex % widget.gridSize).toDouble();
    final pieceY = (widget.piece.currentIndex ~/ widget.gridSize).toDouble();

    return LayoutBuilder(
      builder: (context, constraints) {
        final tileW = constraints.maxWidth;
        final tileH = constraints.maxHeight;

        return AnimatedBuilder(
          animation: _scale,
          child: widget.child,
          builder: (context, child) {
            final s = _scale.value;

            final dx = (pieceX - centerX) * (s - 1) * tileW;
            final dy = (pieceY - centerY) * (s - 1) * tileH;

            return Transform.translate(
              offset: Offset(dx, dy),
              child: Transform.scale(scale: s, child: child),
            );
          },
        );
      },
    );
  }
}
