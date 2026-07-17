import '../../../content/domain/entities/master_content.dart';
import '../../../game_progress/domain/entities/game_progress.dart';

sealed class MasterChallengeEvent {
  const MasterChallengeEvent();
}

final class MasterProgressChanged extends MasterChallengeEvent {
  const MasterProgressChanged(this.progress);
  final GameProgress progress;
}

final class MasterCardTapped extends MasterChallengeEvent {
  const MasterCardTapped(this.levelId);
  final int levelId;
}

final class MasterPurchaseConfirmed extends MasterChallengeEvent {
  const MasterPurchaseConfirmed(this.level);
  final MasterLevelDefinition level;
}

final class MasterActionHandled extends MasterChallengeEvent {
  const MasterActionHandled();
}
