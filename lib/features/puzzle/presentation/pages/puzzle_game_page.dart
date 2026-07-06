import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_confetti/flutter_confetti.dart';
import 'package:test/features/puzzle/presentation/widgets/game_app_bar/game_circle_button.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../injection_container.dart';
import '../bloc/puzzle_bloc.dart';
import '../bloc/puzzle_event.dart';
import '../bloc/puzzle_state.dart';
import '../widgets/puzzle_board_widget.dart';

class PuzzleGamePage extends StatelessWidget {
  const PuzzleGamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          InjectionContainer.createPuzzleBloc()..add(const PuzzleStarted()),
      child: const _PuzzleGameView(),
    );
  }
}

class _PuzzleGameView extends StatelessWidget {
  const _PuzzleGameView();

  void _launchConfetti(BuildContext context) {
    Confetti.launch(
      context,
      options: const ConfettiOptions(
        particleCount: 120,
        spread: 40,
        startVelocity: 40,
        gravity: -0.5,
        ticks: 300,
        x: 0.25,
        y: 0.75,
        colors: [
          Colors.green,
          Colors.blue,
          Colors.pink,
          Colors.orange,
          Colors.purple,
          Colors.yellow,
        ],
      ),
    );
    Confetti.launch(
      context,
      options: const ConfettiOptions(
        particleCount: 120,
        spread: 40,
        startVelocity: 40,
        gravity: -1.0,
        ticks: 300,
        x: 0.75,
        y: 0.75,
        colors: [
          Colors.green,
          Colors.blue,
          Colors.pink,
          Colors.orange,
          Colors.purple,
          Colors.yellow,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PuzzleBloc, PuzzleState>(
      listenWhen: (previous, current) {
        return !previous.isCompleted && current.isCompleted;
      },
      listener: (context, state) {
        _launchConfetti(context);
      },
      builder: (context, state) {
        final isCompleted = state.isCompleted;

        return Scaffold(
          backgroundColor: const Color.fromARGB(255, 6, 93, 6),
          body: Column(
            children: [
              AnimatedSize(
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeInOut,
                alignment: Alignment.topCenter,
                child: isCompleted
                    ? const SizedBox.shrink()
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 24),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                              vertical: 4.0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GameCircleButton(
                                  onPressed: () {},
                                  child: const Icon(
                                    Icons.lightbulb,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  'Level 1',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(color: Colors.white),
                                ),
                                GameCircleButton(
                                  onPressed: () {
                                    context.read<PuzzleBloc>().add(
                                      const PuzzleResetRequested(),
                                    );
                                  },
                                  child: const Icon(
                                    Icons.settings,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
              ),

              const SizedBox(height: 32),

              Center(
                child: AspectRatio(
                  aspectRatio: AppConstants.puzzleAspectRatio,
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: PuzzleBoardWidget(),
                  ),
                ),
              ),

              const ColoredBox(
                color: Colors.black,
                child: SizedBox(height: 80, width: 300),
              ),
            ],
          ),
        );
      },
    );
  }
}
