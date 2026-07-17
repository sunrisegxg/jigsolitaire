import '../../../puzzle/domain/entities/puzzle_route_result.dart';
import '../../../game_progress/domain/entities/game_progress.dart';

sealed class HomeEvent {
  const HomeEvent();
}

final class HomePuzzleReturned extends HomeEvent {
  const HomePuzzleReturned(this.result);
  final PuzzleRouteResult? result;
}

final class HomeCollectionFlightFinished extends HomeEvent {
  const HomeCollectionFlightFinished();
}

final class HomeProgressChanged extends HomeEvent {
  const HomeProgressChanged(this.progress);
  final GameProgress progress;
}
