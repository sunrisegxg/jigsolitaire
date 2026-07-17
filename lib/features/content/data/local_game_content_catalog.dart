import '../../puzzle/domain/entities/puzzle_mode.dart';
import '../domain/entities/campaign_content.dart';
import '../domain/entities/content_availability.dart';
import '../domain/entities/master_content.dart';
import '../domain/game_content_catalog.dart';

class LocalGameContentCatalog implements GameContentCatalog {
  LocalGameContentCatalog()
    : campaignCollections = _buildCampaignCollections(),
      masterLevels = _buildMasterLevels();

  @override
  final List<CampaignCollectionDefinition> campaignCollections;

  @override
  final List<MasterLevelDefinition> masterLevels;

  @override
  CampaignLevelDefinition? campaignLevel(int level) {
    for (final collection in campaignCollections) {
      for (final definition in collection.levels) {
        if (definition.level == level) return definition;
      }
    }
    return null;
  }

  @override
  CampaignCollectionDefinition? collectionById(String id) {
    for (final collection in campaignCollections) {
      if (collection.id == id) return collection;
    }
    return null;
  }

  @override
  CampaignCollectionDefinition? collectionForLevel(int level) {
    for (final collection in campaignCollections) {
      if (level >= collection.startLevel && level <= collection.endLevel) {
        return collection;
      }
    }
    return null;
  }

  @override
  MasterLevelDefinition? masterLevel(int id) {
    for (final level in masterLevels) {
      if (level.id == id) return level;
    }
    return null;
  }

  @override
  int? get finalAvailableCampaignLevel {
    final levels = campaignCollections
        .expand((collection) => collection.levels)
        .where((level) => level.isAvailable)
        .map((level) => level.level);
    return levels.isEmpty ? null : levels.reduce((a, b) => a > b ? a : b);
  }

  static List<CampaignCollectionDefinition> _buildCampaignCollections() {
    return [
      _collection(ordinal: 1, availableEndLevel: 25),
      _collection(ordinal: 2, availableEndLevel: 34),
      for (var ordinal = 3; ordinal <= 10; ordinal++)
        CampaignCollectionDefinition(
          id: 'campaign_collection_$ordinal',
          ordinal: ordinal,
          title: '${(ordinal - 1) * 25 + 1}-${ordinal * 25}',
          startLevel: (ordinal - 1) * 25 + 1,
          levelCount: 25,
          collectionImageAsset: 'assets/images/collections/$ordinal.jpg',
          levels: const [],
          availability: ContentAvailability.comingSoon,
        ),
    ];
  }

  static CampaignCollectionDefinition _collection({
    required int ordinal,
    required int availableEndLevel,
  }) {
    final start = (ordinal - 1) * 25 + 1;
    return CampaignCollectionDefinition(
      id: 'campaign_collection_$ordinal',
      ordinal: ordinal,
      title: '$start-${start + 24}',
      startLevel: start,
      levelCount: 25,
      collectionImageAsset: 'assets/images/collections/$ordinal.jpg',
      levels: [
        for (var level = start; level <= availableEndLevel; level++)
          CampaignLevelDefinition(
            level: level,
            position: level - start,
            puzzleImageAsset: 'assets/images/puzzles/campaign/$level.jpg',
            mode: _campaignMode(level),
          ),
      ],
    );
  }

  static PuzzleMode _campaignMode(int level) {
    final page = (level - 1) ~/ 25 + 1;
    final position = (level - 1) % 25 + 1;
    final hardPositions = switch (page) {
      1 => const {10, 20, 25},
      2 => const {8, 16, 24, 25},
      _ => const {5, 10, 15, 20, 25},
    };
    return hardPositions.contains(position)
        ? PuzzleMode.hard
        : PuzzleMode.normal;
  }

  static List<MasterLevelDefinition> _buildMasterLevels() {
    return [
      for (var id = 1; id <= 12; id++)
        MasterLevelDefinition(
          id: id,
          imageAsset: 'assets/images/puzzles/master_challenge/$id.jpg',
          unlockCost: 1000,
          rows: 9,
          columns: 9,
        ),
    ];
  }
}
