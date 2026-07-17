import '../../domain/entities/collection_item.dart';

class CollectionState {
  const CollectionState({this.items = const []});
  final List<CollectionItem> items;
}
