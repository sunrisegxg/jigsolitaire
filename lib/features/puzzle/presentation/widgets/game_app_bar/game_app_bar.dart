import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jigsolitaire/features/game_progress/presentation/bloc/game_progress_bloc.dart';
import 'package:jigsolitaire/features/puzzle/presentation/widgets/game_app_bar/game_circle_button.dart';

class GameAppBar extends StatelessWidget {
  final bool isCompleted;
  final VoidCallback onResetPuzzle;
  const GameAppBar({
    super.key,
    required this.isCompleted,
    required this.onResetPuzzle,
  });

  @override
  Widget build(BuildContext context) {
    final currentLevel = context
        .read<GameProgressBloc>()
        .state
        .progress
        .currentLevel;

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
                    child: const Icon(Icons.lightbulb, color: Colors.grey),
                  ),
                  Text(
                    'Level $currentLevel',
                    style: Theme.of(
                      context,
                    ).textTheme.headlineSmall?.copyWith(color: Colors.white),
                  ),
                  GameCircleButton(
                    onPressed: onResetPuzzle,
                    child: const Icon(Icons.settings, color: Colors.grey),
                  ),
                ],
              ),
            ),
    );
  }
}
