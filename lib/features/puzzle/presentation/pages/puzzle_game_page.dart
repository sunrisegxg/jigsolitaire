import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jigsolitaire/features/puzzle/domain/entities/puzzle_level_config.dart';
import 'package:jigsolitaire/features/puzzle/presentation/pages/puzzle_game_view.dart';

import '../../../../injection_container.dart';
import '../bloc/puzzle_bloc.dart';
import '../bloc/puzzle_event.dart';

class PuzzleGamePage extends StatefulWidget {
  final PuzzleLevelConfig config;
  const PuzzleGamePage({required this.config, super.key});

  @override
  State<PuzzleGamePage> createState() => _PuzzleGamePageState();
}

class _PuzzleGamePageState extends State<PuzzleGamePage> {
  late final PuzzleBloc _puzzleBloc;

  bool _didPrepareGame = false;

  @override
  void initState() {
    super.initState();

    _puzzleBloc = InjectionContainer.createPuzzleBloc();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_didPrepareGame) return;

    _didPrepareGame = true;
    _prepareGame();
  }

  Future<void> _prepareGame() async {
    try {
      await precacheImage(AssetImage(widget.config.imagePath), context);

      if (!mounted) return;

      _puzzleBloc.add(PuzzleStarted(config: widget.config));
    } catch (error) {
      if (!mounted) return;

      // Vẫn gửi event để Bloc xử lý.
      // Image.asset cũng sẽ hiển thị lỗi nếu asset sai.
      _puzzleBloc.add(PuzzleStarted(config: widget.config));
    }
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
      child: PuzzleGameView(config: widget.config),
    );
  }
}
