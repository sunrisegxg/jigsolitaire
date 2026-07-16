import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/game_progress.dart';
import '../../domain/repositories/game_progress_repository.dart';
import 'game_progress_event.dart';
import 'game_progress_state.dart';

class GameProgressBloc extends Bloc<GameProgressEvent, GameProgressState> {
  GameProgressBloc({required GameProgressRepository repository})
    : _repository = repository,
      super(const GameProgressState()) {
    on<GameProgressStarted>(_onStarted);

    on<LevelCompletedAndRewarded>(_onLevelCompletedAndRewarded);

    on<GameProgressResetRequested>(_onResetRequested);
  }

  final GameProgressRepository _repository;

  Future<void> _onStarted(
    GameProgressStarted event,
    Emitter<GameProgressState> emit,
  ) async {
    emit(state.copyWith(status: GameProgressStatus.loading));

    try {
      final progress = await _repository.load();

      emit(
        state.copyWith(status: GameProgressStatus.ready, progress: progress),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: GameProgressStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> _onLevelCompletedAndRewarded(
    LevelCompletedAndRewarded event,
    Emitter<GameProgressState> emit,
  ) async {
    final currentProgress = state.progress;

    // Không cộng lại phần thưởng cho màn đã hoàn thành.
    if (event.level <= currentProgress.completedLevelCount) {
      return;
    }

    // Chỉ cho hoàn thành đúng màn hiện tại.
    if (event.level != currentProgress.currentLevel) {
      return;
    }

    final updatedProgress = currentProgress.copyWith(
      completedLevelCount: event.level,
      coins: currentProgress.coins + max(event.rewardCoins, 0),
    );

    emit(
      state.copyWith(
        status: GameProgressStatus.ready,
        progress: updatedProgress,
      ),
    );

    await _repository.save(updatedProgress);
  }

  Future<void> _onResetRequested(
    GameProgressResetRequested event,
    Emitter<GameProgressState> emit,
  ) async {
    await _repository.clear();

    emit(
      state.copyWith(
        status: GameProgressStatus.ready,
        progress: const GameProgress(),
      ),
    );
  }
}
