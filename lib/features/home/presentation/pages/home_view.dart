import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../puzzle/presentation/pages/puzzle_game_page.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../widgets/home_bottom_bar.dart';
import '../widgets/home_grid.dart';
import '../widgets/home_header.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  Future<void> _openCurrentLevel(
    BuildContext context,
    int currentLevel,
  ) async {
    // HomeBloc vẫn tồn tại bên dưới route Puzzle.
    // Puzzle trả true khi người chơi hoàn thành màn và quay về Home.
    final isCompleted = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => const PuzzleGamePage(),
      ),
    );

    if (!context.mounted || isCompleted != true) {
      return;
    }

    context.read<HomeBloc>().add(
      HomeLevelCompleted(currentLevel),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
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
                    // Bạn có thể giữ nguyên HomeHeader cũ.
                    const HomeHeader(),
                    Expanded(
                      child: HomeGrid(
                        totalLevels: state.totalLevels,
                        currentLevel: state.currentLevel,
                        completedLevels: state.completedLevels,
                      ),
                    ),
                    HomeBottomBar(
                      currentLevel: state.currentLevel,
                      isAllCompleted: state.isAllCompleted,
                      onPlayPressed: () {
                        _openCurrentLevel(
                          context,
                          state.currentLevel,
                        );
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
