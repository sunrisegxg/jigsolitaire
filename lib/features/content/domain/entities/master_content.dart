import 'content_availability.dart';

class MasterLevelDefinition {
  const MasterLevelDefinition({
    required this.id,
    required this.imageAsset,
    required this.unlockCost,
    this.availability = ContentAvailability.available,
  });

  final int id;
  final String imageAsset;
  final int unlockCost;
  final ContentAvailability availability;

  bool get isAvailable =>
      availability == ContentAvailability.available && imageAsset.isNotEmpty;
}
