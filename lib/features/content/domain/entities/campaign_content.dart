import '../../../puzzle/domain/entities/puzzle_mode.dart';
import 'content_availability.dart';

class CampaignLevelDefinition {
  const CampaignLevelDefinition({
    required this.level,
    required this.position,
    required this.puzzleImageAsset,
    required this.mode,
    this.availability = ContentAvailability.available,
  });

  final int level;
  final int position;
  final String puzzleImageAsset;
  final PuzzleMode mode;
  final ContentAvailability availability;

  bool get isAvailable => availability == ContentAvailability.available;
  int get rewardCoins => mode.rewardCoins;
}

class CampaignCollectionDefinition {
  const CampaignCollectionDefinition({
    required this.id,
    required this.ordinal,
    required this.title,
    required this.startLevel,
    required this.levelCount,
    required this.collectionImageAsset,
    required this.levels,
    this.availability = ContentAvailability.available,
  });

  final String id;
  final int ordinal;
  final String title;
  final int startLevel;
  final int levelCount;
  final String collectionImageAsset;
  final List<CampaignLevelDefinition> levels;
  final ContentAvailability availability;

  int get endLevel => startLevel + levelCount - 1;
  bool get isAvailable => availability == ContentAvailability.available;
  bool get isFullyAvailable =>
      isAvailable &&
      levels.where((level) => level.isAvailable).length == levelCount;
}
