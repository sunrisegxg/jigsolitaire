import '../../../content/domain/entities/campaign_content.dart';

enum CollectionProgressState { locked, inProgress, completed, comingSoon }

class CollectionItem {
  const CollectionItem({
    required this.definition,
    required this.state,
    required this.completedCount,
  });
  final CampaignCollectionDefinition definition;
  final CollectionProgressState state;
  final int completedCount;
}
