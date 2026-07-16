import '../../domain/entities/game_progress.dart';

enum GameProgressStatus { initial, loading, ready, failure }

class GameProgressState {
  const GameProgressState({
    this.status = GameProgressStatus.initial,
    this.progress = const GameProgress(),
    this.errorMessage,
  });

  final GameProgressStatus status;
  final GameProgress progress;
  final String? errorMessage;

  GameProgressState copyWith({
    GameProgressStatus? status,
    GameProgress? progress,
    String? errorMessage,
  }) {
    return GameProgressState(
      status: status ?? this.status,
      progress: progress ?? this.progress,
      errorMessage: errorMessage,
    );
  }
}
