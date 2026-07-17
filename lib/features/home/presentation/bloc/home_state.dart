enum HomeStatus { initial, ready }

class HomeState {
  static const int defaultTotalLevels = 25;

  final HomeStatus status;
  final int totalLevels;
  final int currentLevel;
  final Set<int> completedLevels;

  const HomeState({
    this.status = HomeStatus.initial,
    this.totalLevels = defaultTotalLevels,
    this.currentLevel = 1,
    this.completedLevels = const <int>{},
  });

  bool isLevelCompleted(int level) => completedLevels.contains(level);

  bool get isAllCompleted => completedLevels.length >= totalLevels;

  HomeState copyWith({
    HomeStatus? status,
    int? totalLevels,
    int? currentLevel,
    Set<int>? completedLevels,
  }) {
    return HomeState(
      status: status ?? this.status,
      totalLevels: totalLevels ?? this.totalLevels,
      currentLevel: currentLevel ?? this.currentLevel,
      completedLevels: completedLevels ?? this.completedLevels,
    );
  }
}
