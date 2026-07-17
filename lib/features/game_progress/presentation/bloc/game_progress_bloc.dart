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
    on<CampaignSessionCompleted>(_onCampaignCompleted);
    on<MasterLevelPurchaseRequested>(_onMasterPurchaseRequested);
    on<MasterSessionCompleted>(_onMasterCompleted);
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

  Future<void> _onCampaignCompleted(
    CampaignSessionCompleted event,
    Emitter<GameProgressState> emit,
  ) => _completeCampaign(event.level, event.rewardCoins, event.isReplay, emit);

  Future<void> _completeCampaign(
    int level,
    int rewardCoins,
    bool isReplay,
    Emitter<GameProgressState> emit,
  ) async {
    emit(
      state.copyWith(
        operationStatus: ProgressOperationStatus.saving,
        clearOperationResult: true,
      ),
    );
    try {
      final outcome = await _repository.completeCampaignLevel(
        level: level,
        rewardCoins: rewardCoins,
        isReplay: isReplay,
      );
      emit(
        state.copyWith(
          status: GameProgressStatus.ready,
          progress: outcome.progress,
          operationStatus: ProgressOperationStatus.success,
          operationResult: outcome,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          operationStatus: ProgressOperationStatus.failure,
          errorMessage: error.toString(),
          clearOperationResult: true,
        ),
      );
    }
  }

  Future<void> _onMasterPurchaseRequested(
    MasterLevelPurchaseRequested event,
    Emitter<GameProgressState> emit,
  ) async {
    if (state.operationStatus == ProgressOperationStatus.saving) return;
    emit(
      state.copyWith(
        operationStatus: ProgressOperationStatus.saving,
        clearOperationResult: true,
      ),
    );
    try {
      final outcome = await _repository.purchaseMasterLevel(
        levelId: event.levelId,
        unlockCost: event.unlockCost,
        isAvailable: event.isAvailable,
        prerequisiteCompleted: event.prerequisiteCompleted,
      );
      emit(
        state.copyWith(
          progress: outcome.progress,
          operationStatus: ProgressOperationStatus.success,
          operationResult: outcome,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          operationStatus: ProgressOperationStatus.failure,
          errorMessage: error.toString(),
          clearOperationResult: true,
        ),
      );
    }
  }

  Future<void> _onMasterCompleted(
    MasterSessionCompleted event,
    Emitter<GameProgressState> emit,
  ) async {
    emit(
      state.copyWith(
        operationStatus: ProgressOperationStatus.saving,
        clearOperationResult: true,
      ),
    );
    try {
      final outcome = await _repository.completeMasterLevel(
        levelId: event.levelId,
        isReplay: event.isReplay,
      );
      emit(
        state.copyWith(
          progress: outcome.progress,
          operationStatus: ProgressOperationStatus.success,
          operationResult: outcome,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          operationStatus: ProgressOperationStatus.failure,
          errorMessage: error.toString(),
          clearOperationResult: true,
        ),
      );
    }
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
        operationStatus: ProgressOperationStatus.idle,
        clearOperationResult: true,
      ),
    );
  }
}
