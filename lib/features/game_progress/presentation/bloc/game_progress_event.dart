sealed class GameProgressEvent {
  const GameProgressEvent();
}

class GameProgressStarted
    extends GameProgressEvent {
  const GameProgressStarted();
}

class CoinsEarned extends GameProgressEvent {
  final int amount;

  const CoinsEarned(this.amount);
}

class LevelCompleted extends GameProgressEvent {
  final int level;

  const LevelCompleted(this.level);
}