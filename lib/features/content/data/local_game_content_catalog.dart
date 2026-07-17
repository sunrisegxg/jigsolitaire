import 'package:flutter/services.dart';

import '../../puzzle/domain/entities/puzzle_mode.dart';
import '../domain/entities/campaign_content.dart';
import '../domain/entities/content_availability.dart';
import '../domain/entities/master_content.dart';
import '../domain/game_content_catalog.dart';

class LocalGameContentCatalog implements GameContentCatalog {
  LocalGameContentCatalog._({
    required this.campaignCollections,
    required this.masterLevels,
  });

  static Future<LocalGameContentCatalog> load() async {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final assets = manifest.listAssets();

    return LocalGameContentCatalog._(
      campaignCollections: _buildCampaignCollections(assets),
      masterLevels: _buildMasterLevels(assets),
    );
  }

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

  static List<CampaignCollectionDefinition> _buildCampaignCollections(
    List<String> assets,
  ) {
    final campaignAssets = _numberedAssets(
      assets,
      directory: 'assets/images/puzzles/campaign',
    );
    final collectionAssets = _numberedAssets(
      assets,
      directory: 'assets/images/collections',
    );

    // Campaign progression is sequential. Ignore images after the first gap so
    // the app can never advance past a missing level.
    var finalContiguousLevel = 0;
    while (campaignAssets.containsKey(finalContiguousLevel + 1)) {
      finalContiguousLevel++;
    }

    final highestCampaignCollection = finalContiguousLevel == 0
        ? 0
        : (finalContiguousLevel - 1) ~/ 25 + 1;
    final highestCollectionImage = collectionAssets.keys.isEmpty
        ? 0
        : collectionAssets.keys.reduce((a, b) => a > b ? a : b);
    final collectionCount = highestCampaignCollection > highestCollectionImage
        ? highestCampaignCollection
        : highestCollectionImage;

    return [
      for (var ordinal = 1; ordinal <= collectionCount; ordinal++)
        _buildCollection(
          ordinal: ordinal,
          finalContiguousLevel: finalContiguousLevel,
          campaignAssets: campaignAssets,
          collectionImageAsset: collectionAssets[ordinal],
        ),
    ];
  }

  static CampaignCollectionDefinition _buildCollection({
    required int ordinal,
    required int finalContiguousLevel,
    required Map<int, String> campaignAssets,
    required String? collectionImageAsset,
  }) {
    final startLevel = (ordinal - 1) * 25 + 1;
    final collectionEnd = startLevel + 24;
    final availableEnd = finalContiguousLevel < collectionEnd
        ? finalContiguousLevel
        : collectionEnd;
    final hasPlayableLevels = availableEnd >= startLevel;
    final isAvailable = collectionImageAsset != null && hasPlayableLevels;

    return CampaignCollectionDefinition(
      id: 'campaign_collection_$ordinal',
      ordinal: ordinal,
      title: '$startLevel-$collectionEnd',
      startLevel: startLevel,
      levelCount: 25,
      collectionImageAsset: collectionImageAsset ?? '',
      availability: isAvailable
          ? ContentAvailability.available
          : ContentAvailability.comingSoon,
      levels: isAvailable
          ? [
              for (var level = startLevel; level <= availableEnd; level++)
                CampaignLevelDefinition(
                  level: level,
                  position: level - startLevel,
                  puzzleImageAsset: campaignAssets[level]!,
                  mode: _campaignMode(level),
                ),
            ]
          : const [],
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

  static List<MasterLevelDefinition> _buildMasterLevels(List<String> assets) {
    final masterAssets = _numberedAssets(
      assets,
      directory: 'assets/images/puzzles/master_challenge',
    );
    final ids = masterAssets.keys.toList()..sort();
    return [
      for (final id in ids)
        MasterLevelDefinition(
          id: id,
          imageAsset: masterAssets[id]!,
          unlockCost: 1000,
        ),
    ];
  }

  static Map<int, String> _numberedAssets(
    List<String> assets, {
    required String directory,
  }) {
    final pattern = RegExp(
      '^${RegExp.escape(directory)}/([0-9]+)\\.(jpg|jpeg|png|webp)\$',
      caseSensitive: false,
    );
    final result = <int, String>{};
    for (final asset in assets) {
      final match = pattern.firstMatch(asset);
      if (match == null) continue;
      final id = int.tryParse(match.group(1)!);
      if (id != null && id > 0) result[id] = asset;
    }
    return result;
  }
}
