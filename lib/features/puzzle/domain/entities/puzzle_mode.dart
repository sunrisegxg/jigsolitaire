enum PuzzleMode { normal, hard, dailyChallenge, masterChallenge }

extension PuzzleModeExtension on PuzzleMode {
  int get gridSize {
    return switch (this) {
      PuzzleMode.normal => 2,
      PuzzleMode.hard => 2,
      PuzzleMode.dailyChallenge => 8,
      PuzzleMode.masterChallenge => 9,
    };
  }

  int get pieceCount => gridSize * gridSize;

  int get rewardCoins {
    return switch (this) {
      PuzzleMode.normal => 16,
      PuzzleMode.hard => 36,
      PuzzleMode.dailyChallenge => 64,
      PuzzleMode.masterChallenge => 0,
    };
  }

  String get displayName {
    return switch (this) {
      PuzzleMode.normal => 'NORMAL',
      PuzzleMode.hard => 'HARD',
      PuzzleMode.dailyChallenge => 'DAILY CHALLENGE',
      PuzzleMode.masterChallenge => 'MASTER CHALLENGE',
    };
  }
}
