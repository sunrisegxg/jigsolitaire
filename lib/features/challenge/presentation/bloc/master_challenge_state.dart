import '../../../content/domain/entities/master_content.dart';
import '../../../game_progress/domain/entities/game_progress.dart';
import '../../../puzzle/domain/entities/puzzle_session.dart';

enum MasterCardState { locked, purchasable, unlocked, completed, comingSoon }

class MasterCardViewData {
  const MasterCardViewData({required this.level, required this.state});
  final MasterLevelDefinition level;
  final MasterCardState state;
}

enum MasterActionType { confirmPurchase, openPuzzle, showMessage }

class MasterAction {
  const MasterAction({
    required this.type,
    this.level,
    this.purpose,
    this.title,
    this.message,
  });
  final MasterActionType type;
  final MasterLevelDefinition? level;
  final PuzzleSessionPurpose? purpose;
  final String? title;
  final String? message;
}

class MasterChallengeState {
  const MasterChallengeState({
    this.progress = const GameProgress(),
    this.cards = const [],
    this.purchasingLevelId,
    this.action,
    this.actionId = 0,
  });

  final GameProgress progress;
  final List<MasterCardViewData> cards;
  final int? purchasingLevelId;
  final MasterAction? action;
  final int actionId;

  bool get allAvailableCompleted =>
      cards.where((card) => card.level.isAvailable).isNotEmpty &&
      cards
          .where((card) => card.level.isAvailable)
          .every((card) => card.state == MasterCardState.completed);

  MasterChallengeState copyWith({
    GameProgress? progress,
    List<MasterCardViewData>? cards,
    int? purchasingLevelId,
    bool clearPurchasing = false,
    MasterAction? action,
    bool clearAction = false,
    int? actionId,
  }) {
    return MasterChallengeState(
      progress: progress ?? this.progress,
      cards: cards ?? this.cards,
      purchasingLevelId: clearPurchasing
          ? null
          : purchasingLevelId ?? this.purchasingLevelId,
      action: clearAction ? null : action ?? this.action,
      actionId: actionId ?? this.actionId,
    );
  }
}
