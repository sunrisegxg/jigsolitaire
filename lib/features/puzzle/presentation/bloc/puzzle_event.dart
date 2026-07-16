import 'dart:ui';

import 'package:jigsolitaire/features/puzzle/domain/entities/puzzle_level_config.dart';

abstract class PuzzleEvent {
  const PuzzleEvent();
}

class PuzzleStarted extends PuzzleEvent {
  final PuzzleLevelConfig config;

  const PuzzleStarted({required this.config});
}

class PuzzleResetRequested extends PuzzleEvent {
  const PuzzleResetRequested();
}

class PuzzleDragStarted extends PuzzleEvent {
  final int groupId;

  const PuzzleDragStarted(this.groupId);
}

class PuzzleDragEnded extends PuzzleEvent {
  const PuzzleDragEnded();
}

class PuzzleDropped extends PuzzleEvent {
  final int dragIndex;
  final int dropIndex;

  const PuzzleDropped({required this.dragIndex, required this.dropIndex});
}

class PuzzleSnapBackRequested extends PuzzleEvent {
  final int groupId;
  final Offset offset;

  const PuzzleSnapBackRequested({required this.groupId, required this.offset});
}

class PuzzleSnapBackFinished extends PuzzleEvent {
  final int pieceId;

  const PuzzleSnapBackFinished(this.pieceId);
}
