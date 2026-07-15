import 'package:flutter_bloc/flutter_bloc.dart';

import 'game_progress_event.dart';
import 'game_progress_state.dart';

class GameProgressBloc extends Bloc<GameProgressEvent, GameProgressState> {
  GameProgressBloc() : super(const GameProgressState()) {
    on<CoinsEarned>(_onCoinsEarned);
    on<LevelCompleted>(_onLevelCompleted);
  }

  void _onCoinsEarned(CoinsEarned event, Emitter<GameProgressState> emit) {
    final progress = state.progress;

    emit(
      state.copyWith(
        progress: progress.copyWith(coins: progress.coins + event.amount),
      ),
    );
  }

  void _onLevelCompleted(
    LevelCompleted event,
    Emitter<GameProgressState> emit,
  ) {
    final nextLevel = event.level + 1;

    final unlockedLevels = {...state.progress.unlockedLevels, nextLevel};

    emit(
      state.copyWith(
        progress: state.progress.copyWith(
          currentLevel: nextLevel,
          unlockedLevels: unlockedLevels,
        ),
      ),
    );
  }
}
