sealed class GameProgressEvent {
  const GameProgressEvent();
}

class GameProgressStarted extends GameProgressEvent {
  const GameProgressStarted();
}

class CampaignSessionCompleted extends GameProgressEvent {
  const CampaignSessionCompleted({
    required this.level,
    required this.rewardCoins,
    required this.isReplay,
  });
  final int level;
  final int rewardCoins;
  final bool isReplay;
}

class MasterLevelPurchaseRequested extends GameProgressEvent {
  const MasterLevelPurchaseRequested({
    required this.levelId,
    required this.unlockCost,
    required this.isAvailable,
    required this.prerequisiteCompleted,
  });
  final int levelId;
  final int unlockCost;
  final bool isAvailable;
  final bool prerequisiteCompleted;
}

class MasterSessionCompleted extends GameProgressEvent {
  const MasterSessionCompleted({required this.levelId, required this.isReplay});
  final int levelId;
  final bool isReplay;
}

class GameProgressResetRequested extends GameProgressEvent {
  const GameProgressResetRequested();
}

class DebugCoinsAdded extends GameProgressEvent {
  const DebugCoinsAdded({this.amount = 1000});
  final int amount;
}

class DebugCampaignLevelAdvanced extends GameProgressEvent {
  const DebugCampaignLevelAdvanced({required this.maximumLevel});
  final int maximumLevel;
}
