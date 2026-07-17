import 'entities/campaign_content.dart';
import 'entities/master_content.dart';

abstract interface class GameContentCatalog {
  List<CampaignCollectionDefinition> get campaignCollections;
  List<MasterLevelDefinition> get masterLevels;

  CampaignLevelDefinition? campaignLevel(int level);
  CampaignCollectionDefinition? collectionById(String id);
  CampaignCollectionDefinition? collectionForLevel(int level);
  MasterLevelDefinition? masterLevel(int id);
  int? get finalAvailableCampaignLevel;
}
