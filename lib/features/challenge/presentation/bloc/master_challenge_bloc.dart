import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../content/domain/entities/master_content.dart';
import '../../../content/domain/game_content_catalog.dart';
import '../../../game_progress/domain/entities/game_progress.dart';
import '../../../game_progress/domain/repositories/game_progress_repository.dart';
import '../../../game_progress/presentation/bloc/game_progress_bloc.dart';
import '../../../game_progress/presentation/bloc/game_progress_event.dart';
import '../../../game_progress/presentation/bloc/game_progress_state.dart';
import '../../../puzzle/domain/entities/puzzle_session.dart';
import 'master_challenge_event.dart';
import 'master_challenge_state.dart';

class MasterChallengeBloc
    extends Bloc<MasterChallengeEvent, MasterChallengeState> {
  MasterChallengeBloc({
    required GameContentCatalog catalog,
    required GameProgressBloc progressBloc,
  }) : _catalog = catalog,
       _progressBloc = progressBloc,
       super(const MasterChallengeState()) {
    on<MasterProgressChanged>(_onProgressChanged);
    on<MasterCardTapped>(_onCardTapped);
    on<MasterPurchaseConfirmed>(_onPurchaseConfirmed);
    on<MasterActionHandled>(_onActionHandled);
    _progressSubscription = progressBloc.stream.listen(
      (state) => add(MasterProgressChanged(state.progress)),
    );
    add(MasterProgressChanged(progressBloc.state.progress));
  }

  final GameContentCatalog _catalog;
  final GameProgressBloc _progressBloc;
  late final StreamSubscription<GameProgressState> _progressSubscription;

  void _onProgressChanged(
    MasterProgressChanged event,
    Emitter<MasterChallengeState> emit,
  ) {
    emit(
      state.copyWith(
        progress: event.progress,
        cards: _buildCards(event.progress),
      ),
    );
  }

  void _onCardTapped(
    MasterCardTapped event,
    Emitter<MasterChallengeState> emit,
  ) {
    if (state.purchasingLevelId != null || state.action != null) return;
    final card = state.cards
        .where((item) => item.level.id == event.levelId)
        .firstOrNull;
    if (card == null) return;
    final action = switch (card.state) {
      MasterCardState.purchasable => MasterAction(
        type: MasterActionType.confirmPurchase,
        level: card.level,
      ),
      MasterCardState.unlocked => MasterAction(
        type: MasterActionType.openPuzzle,
        level: card.level,
        purpose: PuzzleSessionPurpose.progress,
      ),
      MasterCardState.completed => MasterAction(
        type: MasterActionType.openPuzzle,
        level: card.level,
        purpose: PuzzleSessionPurpose.replay,
      ),
      MasterCardState.locked || MasterCardState.comingSoon => null,
    };
    if (action != null) {
      emit(state.copyWith(action: action, actionId: state.actionId + 1));
    }
  }

  Future<void> _onPurchaseConfirmed(
    MasterPurchaseConfirmed event,
    Emitter<MasterChallengeState> emit,
  ) async {
    if (state.purchasingLevelId != null) return;
    final level = event.level;
    emit(state.copyWith(purchasingLevelId: level.id, clearAction: true));
    final prerequisiteCompleted =
        level.id == 1 ||
        state.progress.completedMasterLevelIds.contains(level.id - 1);
    _progressBloc.add(
      MasterLevelPurchaseRequested(
        levelId: level.id,
        unlockCost: level.unlockCost,
        isAvailable: level.isAvailable,
        prerequisiteCompleted: prerequisiteCompleted,
      ),
    );
    final result = await _progressBloc.stream.firstWhere(
      (progressState) =>
          progressState.operationStatus == ProgressOperationStatus.success ||
          progressState.operationStatus == ProgressOperationStatus.failure,
    );
    if (isClosed) return;
    MasterAction? action;
    if (result.operationStatus == ProgressOperationStatus.failure) {
      action = MasterAction(
        type: MasterActionType.showMessage,
        title: 'Purchase failed',
        message: result.errorMessage ?? 'Please try again.',
      );
    } else if (result.operationResult case MasterPurchaseOutcome outcome) {
      if (outcome.status == MasterPurchaseStatus.insufficientCoins) {
        action = const MasterAction(
          type: MasterActionType.showMessage,
          title: 'Not Enough Coins',
          message:
              'You do not have enough coins to unlock this Master Challenge.',
        );
      }
    }
    emit(
      state.copyWith(
        clearPurchasing: true,
        action: action,
        clearAction: action == null,
        actionId: action == null ? state.actionId : state.actionId + 1,
      ),
    );
  }

  void _onActionHandled(
    MasterActionHandled event,
    Emitter<MasterChallengeState> emit,
  ) {
    emit(state.copyWith(clearAction: true));
  }

  List<MasterCardViewData> _buildCards(GameProgress progress) {
    return [
      for (final level in _catalog.masterLevels)
        MasterCardViewData(level: level, state: _stateFor(level, progress)),
    ];
  }

  MasterCardState _stateFor(
    MasterLevelDefinition level,
    GameProgress progress,
  ) {
    if (!level.isAvailable) return MasterCardState.comingSoon;
    if (progress.completedMasterLevelIds.contains(level.id)) {
      return MasterCardState.completed;
    }
    if (progress.purchasedMasterLevelIds.contains(level.id)) {
      return MasterCardState.unlocked;
    }
    if (level.id == 1 ||
        progress.completedMasterLevelIds.contains(level.id - 1)) {
      return MasterCardState.purchasable;
    }
    return MasterCardState.locked;
  }

  @override
  Future<void> close() async {
    await _progressSubscription.cancel();
    return super.close();
  }
}
