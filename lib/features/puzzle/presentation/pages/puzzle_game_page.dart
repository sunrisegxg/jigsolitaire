import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
      create: (_) => InjectionContainer.createPuzzleBloc()..add(const PuzzleStarted()),
      child: const _PuzzleGameView(),
    );
  }
}

class _PuzzleGameView extends StatelessWidget {
  const _PuzzleGameView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<PuzzleBloc, PuzzleState>(
      listenWhen: (previous, current) => previous.isCompleted != current.isCompleted,
      listener: (context, state) {
        if (!state.isCompleted) return;

        showDialog<void>(
          context: context,
          builder: (_) {
            return AlertDialog(
              title: const Text('Completed!'),
              content: const Text('You have completed the puzzle.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.read<PuzzleBloc>().add(const PuzzleResetRequested());
                  },
                  child: const Text('Play Again'),
                ),
              ],
            );
          },
        );
      },
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 6, 93, 6),
        appBar: AppBar(
          title: const Text('Cluster Puzzle Game'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                context.read<PuzzleBloc>().add(const PuzzleResetRequested());
              },
            ),
          ],
        ),
        body: const Column(
          children: [
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
            SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
