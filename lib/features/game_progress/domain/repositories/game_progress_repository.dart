import '../entities/game_progress.dart';

class CampaignCompletionOutcome {
  const CampaignCompletionOutcome({
    required this.progress,
    required this.firstCompletion,
  });
  final GameProgress progress;
  final bool firstCompletion;
}

enum MasterPurchaseStatus {
  purchased,
  alreadyPurchased,
  insufficientCoins,
  unavailable,
  locked,
}

class MasterPurchaseOutcome {
  const MasterPurchaseOutcome({required this.status, required this.progress});
  final MasterPurchaseStatus status;
  final GameProgress progress;
}

class MasterCompletionOutcome {
  const MasterCompletionOutcome({
    required this.progress,
    required this.firstCompletion,
  });
  final GameProgress progress;
  final bool firstCompletion;
}

abstract interface class GameProgressRepository {
  Future<GameProgress> load();

  Future<void> save(GameProgress progress);

  Future<CampaignCompletionOutcome> completeCampaignLevel({
    required int level,
    required int rewardCoins,
    required bool isReplay,
  });

  Future<MasterPurchaseOutcome> purchaseMasterLevel({
    required int levelId,
    required int unlockCost,
    required bool isAvailable,
    required bool prerequisiteCompleted,
  });

  Future<MasterCompletionOutcome> completeMasterLevel({
    required int levelId,
    required bool isReplay,
  });

  Future<void> clear();
}
