import 'puzzle_mode.dart';

class PuzzleLevelConfig {
  const PuzzleLevelConfig({
    required this.level,
    required this.mode,
    required this.imagePath,
    this.pageNumber,
    this.positionInPage,
  });

  /// Số màn trong campaign.
  ///
  /// Daily hoặc Master có thể dùng level = 0.
  final int level;

  final PuzzleMode mode;

  final String imagePath;

  /// Trang Home, bắt đầu từ 1.
  ///
  /// Trang 1: level 1–25.
  /// Trang 2: level 26–50.
  final int? pageNumber;

  /// Vị trí của màn trong trang, từ 1–25.
  final int? positionInPage;

  int get gridSize => mode.gridSize;

  int get pieceCount => mode.pieceCount;

  int get rewardCoins => mode.rewardCoins;

  bool get isNormal => mode == PuzzleMode.normal;

  bool get isHard => mode == PuzzleMode.hard;

  bool get isDailyChallenge => mode == PuzzleMode.dailyChallenge;

  bool get isMasterChallenge => mode == PuzzleMode.masterChallenge;
}
