import 'dart:ui';

import 'package:jigsolitaire/features/puzzle/domain/entities/puzzle_level_config.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/puzzle_board.dart';

const Object _unset = Object();

enum PuzzleGamePhase { loading, dealing, flipping, playing, completed }

class PuzzleState {
  final PuzzleBoard board;
  final PuzzleGamePhase phase;
  final int dealIndex;
  final int? draggingGroupId;
  final bool isProcessingDrop;
  final bool hasPlayedIntroFlip;
  final Set<int> pulsingGroups;
  final Map<int, Offset> snapBackOffsets;
  final bool isCompleted;
  final PuzzleLevelConfig? levelConfig;

  const PuzzleState({
    required this.board,
    required this.phase,
    required this.dealIndex,
    required this.draggingGroupId,
    required this.isProcessingDrop,
    required this.hasPlayedIntroFlip,
    required this.pulsingGroups,
    required this.snapBackOffsets,
    required this.isCompleted,
    this.levelConfig,
  });

  factory PuzzleState.initial() {
    return PuzzleState(
      board: PuzzleBoard.empty(gridSize: AppConstants.defaultGridSize),
      phase: PuzzleGamePhase.dealing,
      dealIndex: 0,
      draggingGroupId: null,
      isProcessingDrop: false,
      hasPlayedIntroFlip: false,
      pulsingGroups: const {},
      snapBackOffsets: const {},
      isCompleted: false,
      levelConfig: null,
    );
  }

  // Trả về true nếu người chơi có thể tương tác với trò chơi (kéo thả, sắp xếp, v.v.) trong giai đoạn chơi.
  // Tránh việc đang xử lý animation, drop, hoặc đang trong giai đoạn khác (dealing, flipping) mà vẫn cho phép tương tác.
  bool get canInteract {
    return phase == PuzzleGamePhase.playing &&
        !isProcessingDrop &&
        !isCompleted;
  }

  PuzzleState copyWith({
    PuzzleBoard? board,
    PuzzleGamePhase? phase,
    int? dealIndex,
    Object? draggingGroupId = _unset,
    bool? isProcessingDrop,
    bool? hasPlayedIntroFlip,
    Set<int>? pulsingGroups,
    Map<int, Offset>? snapBackOffsets,
    bool? isCompleted,
    PuzzleLevelConfig? levelConfig,
  }) {
    return PuzzleState(
      board: board ?? this.board,
      phase: phase ?? this.phase,
      dealIndex: dealIndex ?? this.dealIndex,
      draggingGroupId: draggingGroupId == _unset
          ? this.draggingGroupId
          : draggingGroupId as int?,
      isProcessingDrop: isProcessingDrop ?? this.isProcessingDrop,
      hasPlayedIntroFlip: hasPlayedIntroFlip ?? this.hasPlayedIntroFlip,
      pulsingGroups: pulsingGroups ?? this.pulsingGroups,
      snapBackOffsets: snapBackOffsets ?? this.snapBackOffsets,
      isCompleted: isCompleted ?? this.isCompleted,
      levelConfig: levelConfig ?? this.levelConfig,
    );
  }
}
