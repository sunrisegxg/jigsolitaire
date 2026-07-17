import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../content/domain/game_content_catalog.dart';
import '../../../puzzle/domain/entities/puzzle_route_result.dart';
import '../../../game_progress/presentation/bloc/game_progress_bloc.dart';
import '../../../game_progress/presentation/bloc/game_progress_state.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({
    required GameContentCatalog catalog,
    required GameProgressBloc progressBloc,
  }) : _catalog = catalog,
       super(const HomeState()) {
    on<HomePuzzleReturned>(_onPuzzleReturned);
    on<HomeCollectionFlightFinished>(_onCollectionFlightFinished);
    on<HomeProgressChanged>(_onProgressChanged);
    _progressSubscription = progressBloc.stream.listen(
      (state) => add(HomeProgressChanged(state.progress)),
    );
    add(HomeProgressChanged(progressBloc.state.progress));
  }

  final GameContentCatalog _catalog;
  late final StreamSubscription<GameProgressState> _progressSubscription;

  void _onPuzzleReturned(HomePuzzleReturned event, Emitter<HomeState> emit) {
    final result = event.result;
    if (state.interactionLocked ||
        result is! PuzzleCompletedResult ||
        !result.collectionCompleted ||
        result.completedCollectionId == null) {
      return;
    }
    emit(
      state.copyWith(
        phase: HomePhase.collectionFlight,
        displayedCollectionId: result.completedCollectionId,
        dealIndex: 25,
      ),
    );
  }

  void _onProgressChanged(HomeProgressChanged event, Emitter<HomeState> emit) {
    final progress = event.progress;
    final finalLevel = _catalog.finalAvailableCampaignLevel;
    final allAvailableCompleted =
        finalLevel == null || progress.completedLevelCount >= finalLevel;
    final collection = _catalog.collectionForLevel(
      allAvailableCompleted
          ? progress.completedLevelCount
          : progress.currentLevel,
    );
    emit(
      state.copyWith(
        completedLevelCount: progress.completedLevelCount,
        currentLevel: progress.currentLevel,
        naturalCollectionId:
            collection?.id ?? _catalog.campaignCollections.first.id,
        allAvailableCompleted: allAvailableCompleted,
      ),
    );
  }

  Future<void> _onCollectionFlightFinished(
    HomeCollectionFlightFinished event,
    Emitter<HomeState> emit,
  ) async {
    if (state.phase != HomePhase.collectionFlight) return;
    final completedId = state.displayedCollectionId;
    final collections = _catalog.campaignCollections;
    final completedIndex = collections.indexWhere(
      (collection) => collection.id == completedId,
    );
    final next = completedIndex >= 0 && completedIndex + 1 < collections.length
        ? collections[completedIndex + 1]
        : null;

    if (next == null || !next.isAvailable) {
      emit(
        state.copyWith(
          phase: HomePhase.ready,
          clearDisplayedCollection: true,
          dealIndex: 25,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        phase: HomePhase.dealingNextCollection,
        displayedCollectionId: next.id,
        dealIndex: 0,
      ),
    );
    for (var index = 1; index <= 25; index++) {
      await Future<void>.delayed(const Duration(milliseconds: 70));
      if (isClosed) return;
      emit(state.copyWith(dealIndex: index));
    }
    emit(
      state.copyWith(
        phase: HomePhase.ready,
        clearDisplayedCollection: true,
        dealIndex: 25,
      ),
    );
  }

  @override
  Future<void> close() async {
    await _progressSubscription.cancel();
    return super.close();
  }
}
