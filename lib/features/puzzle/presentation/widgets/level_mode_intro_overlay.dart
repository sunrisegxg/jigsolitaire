import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../domain/entities/puzzle_mode.dart';

class LevelModeIntroOverlay extends StatelessWidget {
  const LevelModeIntroOverlay({
    required this.mode,
    required this.visible,
    super.key,
  });

  final PuzzleMode mode;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    final style = _styleFor(mode);
    if (style == null) return const SizedBox.shrink();

    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedOpacity(
          opacity: visible ? 1 : 0,
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeOut,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(child: ColoredBox(color: style.tintColor)),
              AnimatedScale(
                scale: visible ? 1 : .85,
                duration: const Duration(milliseconds: 450),
                curve: Curves.easeOutBack,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: style.bannerColors,
                    ),
                    border: Border.symmetric(
                      horizontal: BorderSide(
                        color: style.borderColor,
                        width: 1.5,
                      ),
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black38,
                        blurRadius: 12,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Text(
                    style.label,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: style.fontSize,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                      height: 1.1,
                      shadows: const [
                        Shadow(
                          color: Colors.black38,
                          blurRadius: 3,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _LevelModeStyle? _styleFor(PuzzleMode mode) {
    return switch (mode) {
      PuzzleMode.hard => const _LevelModeStyle(
        label: 'HARD LEVEL',
        tintColor: Color(0x669B1C18),
        bannerColors: [Color(0xFFD61212), Color(0xFFA50000)],
        borderColor: Color(0xFFFF6B61),
        fontSize: 42,
      ),
      PuzzleMode.masterChallenge => const _LevelModeStyle(
        label: 'MASTER CHALLENGE',
        tintColor: Color(0x665E2585),
        bannerColors: [Color(0xFF8E44AD), Color(0xFF51206C)],
        borderColor: Color(0xFFD7A5F2),
        fontSize: 30,
      ),
      PuzzleMode.normal || PuzzleMode.dailyChallenge => null,
    };
  }
}

class _LevelModeStyle {
  const _LevelModeStyle({
    required this.label,
    required this.tintColor,
    required this.bannerColors,
    required this.borderColor,
    required this.fontSize,
  });

  final String label;
  final Color tintColor;
  final List<Color> bannerColors;
  final Color borderColor;
  final double fontSize;
}
