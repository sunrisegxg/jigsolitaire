import '../entities/puzzle_level_config.dart';
import '../entities/puzzle_mode.dart';

class PuzzleLevelConfigService {
  PuzzleLevelConfigService._();

  static const int levelsPerPage = 25;

  /// Trang đầu ít màn Hard hơn để người chơi làm quen.
  static const Set<int> _firstPageHardPositions = {10, 20, 25};

  /// Trang thứ hai tăng nhẹ số màn Hard.
  static const Set<int> _secondPageHardPositions = {8, 16, 24, 25};

  /// Từ trang thứ ba trở đi:
  /// mỗi 5 màn có một màn Hard.
  static const Set<int> _regularHardPositions = {5, 10, 15, 20, 25};

  static PuzzleLevelConfig campaign({required int level}) {
    if (level < 1) {
      throw ArgumentError.value(
        level,
        'level',
        'Campaign level must be greater than or equal to 1.',
      );
    }

    final pageIndex = (level - 1) ~/ levelsPerPage;
    final pageNumber = pageIndex + 1;

    final positionInPage = ((level - 1) % levelsPerPage) + 1;

    final hardPositions = _hardPositionsForPage(pageNumber);

    final mode = hardPositions.contains(positionInPage)
        ? PuzzleMode.hard
        : PuzzleMode.normal;

    return PuzzleLevelConfig(
      level: level,
      mode: mode,
      pageNumber: pageNumber,
      positionInPage: positionInPage,
      imagePath: _campaignImagePath(level),
    );
  }

  static PuzzleLevelConfig dailyChallenge({
    required DateTime date,
    required String imagePath,
  }) {
    return PuzzleLevelConfig(
      level: 0,
      mode: PuzzleMode.dailyChallenge,
      imagePath: imagePath,
    );
  }

  static PuzzleLevelConfig masterChallenge({required String imagePath}) {
    return PuzzleLevelConfig(
      level: 0,
      mode: PuzzleMode.masterChallenge,
      imagePath: imagePath,
    );
  }

  // hàm kiểm tra nếu còn trong 25 màn thì có 3 hard level, 50 thì 4, 50 trở lên thì auto 5
  static Set<int> _hardPositionsForPage(int pageNumber) {
    if (pageNumber == 1) {
      return _firstPageHardPositions;
    }

    if (pageNumber == 2) {
      return _secondPageHardPositions;
    }

    return _regularHardPositions;
  }

  static String _campaignImagePath(int level) {
    // final formattedLevel = level.toString().padLeft(3, '0');
    final formattedLevel = level.toString();

    return 'assets/images/puzzles/campaign/'
        // 'level_$formattedLevel.webp';
        '$formattedLevel.jpg';
  }
}
