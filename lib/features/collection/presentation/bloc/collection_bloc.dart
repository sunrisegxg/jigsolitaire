import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../content/domain/entities/campaign_content.dart';
import '../../../content/domain/game_content_catalog.dart';
import '../../../game_progress/domain/entities/game_progress.dart';
import '../../../game_progress/presentation/bloc/game_progress_bloc.dart';
import '../../../game_progress/presentation/bloc/game_progress_state.dart';
import '../../domain/entities/collection_item.dart';
import 'collection_event.dart';
import 'collection_state.dart';

class CollectionBloc extends Bloc<CollectionEvent, CollectionState> {
  CollectionBloc({
    required GameContentCatalog catalog,
    required GameProgressBloc progressBloc,
  }) : _catalog = catalog,
       super(const CollectionState()) {
    on<CollectionProgressChanged>(_onProgressChanged);
    _progressSubscription = progressBloc.stream.listen(
      (state) => add(CollectionProgressChanged(state.progress)),
    );
    add(CollectionProgressChanged(progressBloc.state.progress));
  }

  final GameContentCatalog _catalog;
  late final StreamSubscription<GameProgressState> _progressSubscription;

  void _onProgressChanged(
    CollectionProgressChanged event,
    Emitter<CollectionState> emit,
  ) {
    emit(CollectionState(items: _buildItems(event.progress)));
  }

  List<CollectionItem> _buildItems(GameProgress progress) {
    return [
      for (final definition in _catalog.campaignCollections)
        CollectionItem(
          definition: definition,
          completedCount: definition.levels
              .where((level) => level.level <= progress.completedLevelCount)
              .length,
          state: _stateFor(definition, progress),
        ),
    ];
  }

  CollectionProgressState _stateFor(
    CampaignCollectionDefinition definition,
    GameProgress progress,
  ) {
    if (!definition.isAvailable || definition.levels.isEmpty) {
      return CollectionProgressState.comingSoon;
    }
    final completedCount = definition.levels
        .where((level) => level.level <= progress.completedLevelCount)
        .length;
    if (definition.isFullyAvailable &&
        completedCount == definition.levelCount) {
      return CollectionProgressState.completed;
    }
    if (progress.completedLevelCount >= definition.startLevel - 1) {
      return CollectionProgressState.inProgress;
    }
    return CollectionProgressState.locked;
  }

  @override
  Future<void> close() async {
    await _progressSubscription.cancel();
    return super.close();
  }
}
