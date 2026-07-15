class AppConstants {
  const AppConstants._();

  static const int defaultGridSize = 2;
  static const double puzzleAspectRatio = 0.7;

  static const int dealStepMs = 70;
  static const int dealAnimationMs = 500;
  static const int beforeFlipDelayMs = 300;
  static const int flipAnimationMs = 600;

  static const int swapAnimationMs = 400;
  static const int beforePulseDelayMs = 50;
  static const int pulseAnimationMs = 400;
  static const int snapBackAnimationMs = 500;

  // game image
  static const String puzzleImageAsset = 'assets/puzzle_image.jpg';
  static const String levelClearBanner = 'assets/level_clear_banner.png';

  //complete game
  static const int gameAppBarShrinkAnimationMs = 800;
  static const int completeDelayMs = 300;
}
