import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jigsolitaire/features/puzzle/domain/entities/puzzle_level_config.dart';
import 'package:jigsolitaire/features/puzzle/presentation/widgets/game_app_bar/game_circle_button.dart';

class GameAppBar extends StatelessWidget {
  final bool isCompleted;
  final VoidCallback onSettingsPressed;
  final PuzzleLevelConfig config;

  const GameAppBar({
    super.key,
    required this.isCompleted,
    required this.onSettingsPressed,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    final level = config.level;

    return AnimatedSize(
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      alignment: Alignment.topCenter,
      child: isCompleted
          ? const SizedBox.shrink()
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GameCircleButton(
                    onPressed: () {},
                    child: const Icon(Icons.lightbulb, color: Colors.white),
                  ),
                  Text(
                    'Level $level',
                    style: GoogleFonts.poppins(
                      textStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        height: 1,
                      ),
                    ),
                  ),
                  GameCircleButton(
                    onPressed: onSettingsPressed,
                    child: const Icon(Icons.settings, color: Colors.white),
                  ),
                ],
              ),
            ),
    );
  }
}
