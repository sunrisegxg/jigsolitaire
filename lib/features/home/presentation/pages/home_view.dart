import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jigsolitaire/features/game_progress/presentation/bloc/game_progress_bloc.dart';
import 'package:jigsolitaire/features/game_progress/presentation/bloc/game_progress_state.dart';
import 'package:jigsolitaire/features/puzzle/domain/services/puzzle_level_config_service.dart';

import '../../../puzzle/presentation/pages/puzzle_game_page.dart';
import '../widgets/home_bottom_bar.dart';
import '../widgets/home_grid.dart';
import '../widgets/home_header.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  Future<void> _openCurrentLevel(BuildContext context, int currentLevel) async {
    final config = PuzzleLevelConfigService.campaign(level: currentLevel);

    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => PuzzleGamePage(config: config)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameProgressBloc, GameProgressState>(
      builder: (context, state) {
        final progress = state.progress;

        final currentLevel = progress.currentLevel;
        final pageIndex = (currentLevel - 1) ~/ 25;

        return Scaffold(
          body: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/images/background.png',
                  fit: BoxFit.cover,
                ),
              ),

              SafeArea(
                child: Column(
                  children: [
                    const HomeHeader(),

                    Expanded(
                      child: HomeGrid(
                        completedLevelCount: progress.completedLevelCount,
                        pageIndex: pageIndex,
                      ),
                    ),

                    HomeBottomBar(
                      currentLevel: currentLevel,

                      // Nếu game chưa có giới hạn level,
                      // tạm thời luôn là false.
                      isAllCompleted: false,

                      onPlayPressed: () {
                        _openCurrentLevel(context, currentLevel);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
