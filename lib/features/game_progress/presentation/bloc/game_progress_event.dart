sealed class GameProgressEvent {
  const GameProgressEvent();
}

class GameProgressStarted extends GameProgressEvent {
  const GameProgressStarted();
}

class LevelCompletedAndRewarded extends GameProgressEvent {
  const LevelCompletedAndRewarded({
    required this.level,
    required this.rewardCoins,
  });

  final int level;
  final int rewardCoins;
}

class GameProgressResetRequested extends GameProgressEvent {
  const GameProgressResetRequested();
}
