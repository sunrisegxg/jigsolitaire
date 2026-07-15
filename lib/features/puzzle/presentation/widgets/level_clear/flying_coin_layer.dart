import 'dart:math' as math;

import 'package:flutter/material.dart';

class FlyingCoinLayer extends StatelessWidget {
  const FlyingCoinLayer({
    required this.animation,
    required this.start,
    required this.end,
    this.coinCount = 12,
    super.key,
  });

  final Animation<double> animation;
  final Offset start;
  final Offset end;
  final int coinCount;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Stack(
          clipBehavior: Clip.none,
          children: List.generate(coinCount, (index) => _buildCoin(index)),
        );
      },
    );
  }

  Widget _buildCoin(int index) {
    const stagger = 0.035;
    const travelDuration = 0.62;

    final startTime = index * stagger;
    final endTime = math.min(startTime + travelDuration, 1.0);

    final rawProgress = ((animation.value - startTime) / (endTime - startTime))
        .clamp(0.0, 1.0)
        .toDouble();

    if (rawProgress <= 0 || rawProgress >= 1) {
      return const SizedBox.shrink();
    }

    final progress = Curves.easeInOutCubic.transform(rawProgress);

    // Mỗi đồng có đường cong hơi khác nhau để chuyển động tự nhiên hơn.
    final controlPoint = Offset(
      start.dx + ((end.dx - start.dx) * 0.32) + ((index - 6) * 8),
      start.dy - 140 - ((index % 3) * 24),
    );

    final position = _quadraticBezier(start, controlPoint, end, progress);

    final opacity = rawProgress < 0.84
        ? 1.0
        : ((1.0 - rawProgress) / 0.16).clamp(0.0, 1.0);

    final scale = 0.78 + math.sin(rawProgress * math.pi) * 0.32;

    return Positioned(
      left: position.dx - 12,
      top: position.dy - 12,
      child: Opacity(
        opacity: opacity,
        child: Transform.rotate(
          angle: rawProgress * math.pi * (2 + index % 3),
          child: Transform.scale(
            scale: scale,
            child: const Icon(
              Icons.monetization_on,
              size: 16,
              color: Color(0xFFFFC107),
            ),
          ),
        ),
      ),
    );
  }

  Offset _quadraticBezier(Offset start, Offset control, Offset end, double t) {
    final oneMinusT = 1.0 - t;

    return start * (oneMinusT * oneMinusT) +
        control * (2.0 * oneMinusT * t) +
        end * (t * t);
  }
}
