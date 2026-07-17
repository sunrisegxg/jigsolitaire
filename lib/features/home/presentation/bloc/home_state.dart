enum HomePhase { ready, collectionFlight, dealingNextCollection }

class HomeState {
  const HomeState({
    this.phase = HomePhase.ready,
    this.displayedCollectionId,
    this.dealIndex = 25,
    this.completedLevelCount = 0,
    this.currentLevel = 1,
    this.naturalCollectionId,
    this.allAvailableCompleted = false,
  });

  final HomePhase phase;
  final String? displayedCollectionId;
  final int dealIndex;
  final int completedLevelCount;
  final int currentLevel;
  final String? naturalCollectionId;
  final bool allAvailableCompleted;

  bool get interactionLocked => phase != HomePhase.ready;

  HomeState copyWith({
    HomePhase? phase,
    String? displayedCollectionId,
    bool clearDisplayedCollection = false,
    int? dealIndex,
    int? completedLevelCount,
    int? currentLevel,
    String? naturalCollectionId,
    bool? allAvailableCompleted,
  }) {
    return HomeState(
      phase: phase ?? this.phase,
      displayedCollectionId: clearDisplayedCollection
          ? null
          : displayedCollectionId ?? this.displayedCollectionId,
      dealIndex: dealIndex ?? this.dealIndex,
      completedLevelCount: completedLevelCount ?? this.completedLevelCount,
      currentLevel: currentLevel ?? this.currentLevel,
      naturalCollectionId: naturalCollectionId ?? this.naturalCollectionId,
      allAvailableCompleted:
          allAvailableCompleted ?? this.allAvailableCompleted,
    );
  }
}
