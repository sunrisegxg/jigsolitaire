import 'puzzle_session.dart';

sealed class PuzzleRouteResult {
  const PuzzleRouteResult();
}

class PuzzleCompletedResult extends PuzzleRouteResult {
  const PuzzleCompletedResult({
    required this.session,
    this.firstCompletion = false,
    this.collectionCompleted = false,
    this.completedCollectionId,
  });

  final PuzzleSession session;
  final bool firstCompletion;
  final bool collectionCompleted;
  final String? completedCollectionId;
}
