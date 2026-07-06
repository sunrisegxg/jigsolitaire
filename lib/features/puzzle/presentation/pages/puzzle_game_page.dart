import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PuzzleBloc, PuzzleState>(
      listenWhen: (previous, current) =>
          previous.isCompleted != current.isCompleted,
      listener: (context, state) {
        if (!state.isCompleted) return;

        // showDialog<void>(
        //   context: context,
        //   builder: (_) {
        //     return AlertDialog(
        //       title: const Text('Completed!'),
        //       content: const Text('You have completed the puzzle.'),
        //       actions: [
        //         TextButton(
        //           onPressed: () => Navigator.of(context).pop(),
        //           child: const Text('Close'),
        //         ),
        //         FilledButton(
        //           onPressed: () {
        //             Navigator.of(context).pop();
        //             context.read<PuzzleBloc>().add(
        //               const PuzzleResetRequested(),
        //             );
        //           },
        //           child: const Text('Play Again'),
        //         ),
        //       ],
        //     );
        //   },
        // );
      },
      builder: (context, state) {
        final isCompleted = context.watch<PuzzleBloc>().state.isCompleted;

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
                    : Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 16.0,
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
                              style: Theme.of(context).textTheme.headlineSmall
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
              ),

              SizedBox(height: 10),
              Center(
                child: AspectRatio(
                  aspectRatio: AppConstants.puzzleAspectRatio,
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: PuzzleBoardWidget(),
                  ),
                ),
              ),
              ColoredBox(
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
