import '../../../content/domain/game_content_catalog.dart';
import '../entities/puzzle_level_config.dart';
import '../entities/puzzle_mode.dart';
import '../entities/puzzle_session.dart';

class PuzzleLevelConfigService {
  const PuzzleLevelConfigService(this.catalog);
  final GameContentCatalog catalog;

  PuzzleLevelConfig campaign({
    required int level,
    PuzzleSessionPurpose purpose = PuzzleSessionPurpose.progress,
  }) {
    final definition = catalog.campaignLevel(level);
    if (definition == null || !definition.isAvailable) {
      throw StateError('Campaign level $level is not available.');
    }
    final collection = catalog.collectionForLevel(level)!;
    return PuzzleLevelConfig(
      level: level,
      mode: definition.mode,
      pageNumber: collection.ordinal,
      positionInPage: definition.position + 1,
      imagePath: definition.puzzleImageAsset,
      session: CampaignPuzzleSession(level: definition, purpose: purpose),
    );
  }

  PuzzleLevelConfig master({
    required int id,
    PuzzleSessionPurpose purpose = PuzzleSessionPurpose.progress,
  }) {
    final definition = catalog.masterLevel(id);
    if (definition == null || !definition.isAvailable) {
      throw StateError('Master level $id is not available.');
    }
    if (definition.rows != definition.columns) {
      throw StateError('The current puzzle engine requires a square grid.');
    }
    return PuzzleLevelConfig(
      level: id,
      mode: PuzzleMode.masterChallenge,
      imagePath: definition.imageAsset,
      session: MasterPuzzleSession(level: definition, purpose: purpose),
    );
  }
}
