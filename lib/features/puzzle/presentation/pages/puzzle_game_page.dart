import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../injection_container.dart';
import '../bloc/puzzle_bloc.dart';
import '../bloc/puzzle_event.dart';
import 'puzzle_game_view.dart';

class PuzzleGamePage extends StatefulWidget {
  const PuzzleGamePage({super.key});

  @override
  State<PuzzleGamePage> createState() => _PuzzleGamePageState();
}

class _PuzzleGamePageState extends State<PuzzleGamePage> {
  late final PuzzleBloc _puzzleBloc;

  @override
  void initState() {
    super.initState();

    _puzzleBloc = InjectionContainer.createPuzzleBloc()
      ..add(const PuzzleStarted());
  }

  @override
  void dispose() {
    _puzzleBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _puzzleBloc,
      child: const PuzzleGameView(),
    );
  }
}
