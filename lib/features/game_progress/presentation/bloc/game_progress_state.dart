import '../../domain/entities/game_progress.dart';

enum GameProgressStatus { initial, loading, ready, failure }

enum ProgressOperationStatus { idle, saving, success, failure }

class GameProgressState {
  const GameProgressState({
    this.status = GameProgressStatus.initial,
    this.progress = const GameProgress(),
    this.errorMessage,
    this.operationStatus = ProgressOperationStatus.idle,
    this.operationResult,
  });

  final GameProgressStatus status;
  final GameProgress progress;
  final String? errorMessage;
  final ProgressOperationStatus operationStatus;
  final Object? operationResult;

  GameProgressState copyWith({
    GameProgressStatus? status,
    GameProgress? progress,
    String? errorMessage,
    ProgressOperationStatus? operationStatus,
    Object? operationResult,
    bool clearOperationResult = false,
  }) {
    return GameProgressState(
      status: status ?? this.status,
      progress: progress ?? this.progress,
      errorMessage: errorMessage,
      operationStatus: operationStatus ?? this.operationStatus,
      operationResult: clearOperationResult
          ? null
          : operationResult ?? this.operationResult,
    );
  }
}
