import 'package:flutter/material.dart';

class LevelClearBanner extends StatelessWidget {
  const LevelClearBanner({
    required this.assetPath,
    required this.controller,
    required this.opacity,
    required this.slide,
    required this.widthScale,
    required this.heightScale,
    required this.textReveal,
    super.key,
  });

  final String assetPath;
  final Animation<double> controller;
  final Animation<double> opacity;
  final Animation<Offset> slide;
  final Animation<double> widthScale;
  final Animation<double> heightScale;
  final Animation<double> textReveal;

  static const _textStyle = TextStyle(
    color: Color.fromARGB(255, 228, 189, 91),
    fontSize: 30,
    fontWeight: FontWeight.w900,
    letterSpacing: 1.5,
    shadows: [
      Shadow(color: Color(0x99000000), offset: Offset(0, 3), blurRadius: 0),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, child) {
            return SlideTransition(
              position: slide,
              child: Opacity(
                opacity: opacity.value,
                child: Transform.scale(
                  scaleX: widthScale.value,
                  scaleY: heightScale.value,
                  child: child,
                ),
              ),
            );
          },
          child: Image.asset(assetPath, fit: BoxFit.fitHeight, height: 150),
        ),
      ),
    );
  }
}

class _RevealText extends StatelessWidget {
  const _RevealText({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.centerLeft,
          children: [
            const Opacity(
              opacity: 0,
              child: Text(
                'LEVEL CLEAR!',
                maxLines: 1,
                style: LevelClearBanner._textStyle,
              ),
            ),
            ClipRect(
              child: Align(
                alignment: Alignment.centerLeft,
                widthFactor: animation.value,
                child: const Text(
                  'LEVEL CLEAR!',
                  maxLines: 1,
                  style: LevelClearBanner._textStyle,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
