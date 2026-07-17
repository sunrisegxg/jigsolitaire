import '../../../game_progress/domain/entities/game_progress.dart';

sealed class CollectionEvent {
  const CollectionEvent();
}

final class CollectionProgressChanged extends CollectionEvent {
  const CollectionProgressChanged(this.progress);
  final GameProgress progress;
}
