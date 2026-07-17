class GameProgress {
  const GameProgress({
    this.completedLevelCount = 0,
    this.coins = 0,
    this.purchasedMasterLevelIds = const {},
    this.completedMasterLevelIds = const {},
  });

  final int completedLevelCount;
  final int coins;
  final Set<int> purchasedMasterLevelIds;
  final Set<int> completedMasterLevelIds;

  static const int levelsPerPage = 25;

  int get currentLevel => completedLevelCount + 1;

  int get currentPageIndex {
    return (currentLevel - 1) ~/ levelsPerPage;
  }

  int get currentPageNumber => currentPageIndex + 1;

  int get pageStartLevel {
    return currentPageIndex * levelsPerPage + 1;
  }

  int get pageEndLevel {
    return pageStartLevel + levelsPerPage - 1;
  }

  GameProgress copyWith({
    int? completedLevelCount,
    int? coins,
    Set<int>? purchasedMasterLevelIds,
    Set<int>? completedMasterLevelIds,
  }) {
    return GameProgress(
      completedLevelCount: completedLevelCount ?? this.completedLevelCount,
      coins: coins ?? this.coins,
      purchasedMasterLevelIds:
          purchasedMasterLevelIds ?? this.purchasedMasterLevelIds,
      completedMasterLevelIds:
          completedMasterLevelIds ?? this.completedMasterLevelIds,
    );
  }
}
