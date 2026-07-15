import '../../domain/entities/game_progress.dart';

class GameProgressState {
  final GameProgress progress;

  const GameProgressState({
    this.progress = const GameProgress(),
  });

  GameProgressState copyWith({
    GameProgress? progress,
  }) {
    return GameProgressState(
      progress: progress ?? this.progress,
    );
  }
}