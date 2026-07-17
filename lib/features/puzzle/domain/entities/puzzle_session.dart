import '../../../content/domain/entities/campaign_content.dart';
import '../../../content/domain/entities/master_content.dart';

enum PuzzleSessionPurpose { progress, replay }

sealed class PuzzleSession {
  const PuzzleSession({required this.purpose});
  final PuzzleSessionPurpose purpose;
  bool get isReplay => purpose == PuzzleSessionPurpose.replay;
}

class CampaignPuzzleSession extends PuzzleSession {
  const CampaignPuzzleSession({required this.level, required super.purpose});
  final CampaignLevelDefinition level;
}

class MasterPuzzleSession extends PuzzleSession {
  const MasterPuzzleSession({required this.level, required super.purpose});
  final MasterLevelDefinition level;
}
