sealed class HomeEvent {
  const HomeEvent();
}

/// Khởi tạo màn Home.
final class HomeStarted extends HomeEvent {
  const HomeStarted();
}

/// Được gửi khi PuzzleGamePage trả về kết quả hoàn thành màn chơi.
final class HomeLevelCompleted extends HomeEvent {
  final int level;

  const HomeLevelCompleted(this.level);
}
