class GameProgress {
  final int coins;
  final int currentLevel;
  final Set<int> unlockedLevels;

  const GameProgress({
    this.coins = 0,
    this.currentLevel = 1,
    this.unlockedLevels = const {1},
  });

  GameProgress copyWith({
    int? coins,
    int? currentLevel,
    Set<int>? unlockedLevels,
  }) {
    return GameProgress(
      coins: coins ?? this.coins,
      currentLevel:
          currentLevel ?? this.currentLevel,
      unlockedLevels:
          unlockedLevels ?? this.unlockedLevels,
    );
  }
}