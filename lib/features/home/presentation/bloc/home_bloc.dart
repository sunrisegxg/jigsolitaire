import 'dart:math' as math;

import 'package:flutter_bloc/flutter_bloc.dart';

import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(const HomeState()) {
    on<HomeStarted>(_onStarted);
    on<HomeLevelCompleted>(_onLevelCompleted);
  }

  void _onStarted(
    HomeStarted event,
    Emitter<HomeState> emit,
  ) {
    emit(state.copyWith(status: HomeStatus.ready));
  }

  void _onLevelCompleted(
    HomeLevelCompleted event,
    Emitter<HomeState> emit,
  ) {
    // Chỉ chấp nhận đúng màn hiện tại.
    // Điều này ngăn một màn bị cộng tiến trình nhiều lần.
    if (event.level != state.currentLevel || state.isAllCompleted) {
      return;
    }

    final updatedCompletedLevels = <int>{
      ...state.completedLevels,
      event.level,
    };

    final nextLevel = math.min(
      event.level + 1,
      state.totalLevels,
    );

    emit(
      state.copyWith(
        completedLevels: updatedCompletedLevels,
        currentLevel: nextLevel,
      ),
    );
  }
}
