import 'dart:async';
import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jigsolitaire/features/puzzle/domain/entities/puzzle_board.dart';
import 'package:jigsolitaire/features/puzzle/domain/entities/puzzle_level_config.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/usecases/check_puzzle_completed_usecase.dart';
import '../../domain/usecases/move_puzzle_group_usecase.dart';
import '../../domain/usecases/reset_puzzle_usecase.dart';
import '../../domain/usecases/start_puzzle_usecase.dart';
import 'puzzle_event.dart';
import 'puzzle_state.dart';

class PuzzleBloc extends Bloc<PuzzleEvent, PuzzleState> {
  final StartPuzzleUseCase startPuzzleUseCase;
  final MovePuzzleGroupUseCase movePuzzleGroupUseCase;
  final ResetPuzzleUseCase resetPuzzleUseCase;
  final CheckPuzzleCompletedUseCase checkPuzzleCompletedUseCase;

  PuzzleBloc({
    required this.startPuzzleUseCase,
    required this.movePuzzleGroupUseCase,
    required this.resetPuzzleUseCase,
    required this.checkPuzzleCompletedUseCase,
  }) : super(PuzzleState.initial()) {
    on<PuzzleStarted>(_onStarted);
    on<PuzzleResetRequested>(_onResetRequested);
    on<PuzzleDragStarted>(_onDragStarted);
    on<PuzzleDragEnded>(_onDragEnded);
    on<PuzzleDropped>(_onDropped);
    on<PuzzleSnapBackRequested>(_onSnapBackRequested);
    on<PuzzleSnapBackFinished>(_onSnapBackFinished);
  }

  Future<void> _onStarted(
    PuzzleStarted event,
    Emitter<PuzzleState> emit,
  ) async {
    final config = event.config;

    await _startNewGame(
      emit,
      isReset: false,
      gridSize: config.gridSize,
      levelConfig: config,
    );
  }

  Future<void> _onResetRequested(
    PuzzleResetRequested event,
    Emitter<PuzzleState> emit,
  ) async {
    final config = state.levelConfig;

    await _startNewGame(
      emit,
      isReset: true,
      gridSize: config?.gridSize ?? AppConstants.defaultGridSize,
      levelConfig: config,
    );
  }

  Future<void> _startNewGame(
    Emitter<PuzzleState> emit, {
    required bool isReset,
    required int gridSize,
    PuzzleLevelConfig? levelConfig,
  }) async {
    // Hiện loading trước khi tạo board.
    emit(
      state.copyWith(
        phase: PuzzleGamePhase.loading,
        draggingGroupId: null,
        isProcessingDrop: false,
        pulsingGroups: {},
        snapBackOffsets: {},
        isCompleted: false,

        // Khi reset không truyền config mới,
        // nên giữ lại config của level hiện tại.
        levelConfig: levelConfig ?? state.levelConfig,
      ),
    );

    // Nhường một frame để UI có thể hiển thị loading.
    await Future<void>.delayed(Duration.zero);

    if (isClosed) return;

    // Đưa việc tạo board sang một Future để không thực hiện
    // ngay trong cùng frame với lần emit loading.
    final board = await Future<PuzzleBoard>(() {
      if (isReset) {
        return resetPuzzleUseCase.execute(gridSize: gridSize);
      }

      return startPuzzleUseCase.execute(gridSize: gridSize);
    });

    if (isClosed) return;

    // Tạo board xong thì bắt đầu animation chia bài.
    emit(
      state.copyWith(
        board: board,
        phase: PuzzleGamePhase.dealing,
        dealIndex: 0,
        draggingGroupId: null,
        isProcessingDrop: false,
        hasPlayedIntroFlip: false,
        pulsingGroups: {},
        snapBackOffsets: {},
        isCompleted: false,
        levelConfig: levelConfig ?? state.levelConfig,
      ),
    );

    final dealStepMs = (AppConstants.maxDealSequenceMs ~/ board.totalPieces)
        .clamp(1, AppConstants.dealStepMs)
        .toInt();
    for (int i = 0; i < board.totalPieces; i++) {
      await Future<void>.delayed(Duration(milliseconds: dealStepMs));

      if (isClosed) return;

      emit(state.copyWith(dealIndex: i + 1));
    }

    await Future<void>.delayed(
      const Duration(milliseconds: AppConstants.beforeFlipDelayMs),
    );

    if (isClosed) return;

    emit(state.copyWith(phase: PuzzleGamePhase.flipping));

    await Future<void>.delayed(
      const Duration(milliseconds: AppConstants.flipAnimationMs),
    );

    if (isClosed) return;

    emit(
      state.copyWith(phase: PuzzleGamePhase.playing, hasPlayedIntroFlip: true),
    );
  }

  void _onDragStarted(PuzzleDragStarted event, Emitter<PuzzleState> emit) {
    emit(state.copyWith(draggingGroupId: event.groupId));
  }

  void _onDragEnded(PuzzleDragEnded event, Emitter<PuzzleState> emit) {
    emit(state.copyWith(draggingGroupId: null));
  }

  Future<void> _onDropped(
    PuzzleDropped event,
    Emitter<PuzzleState> emit,
  ) async {
    if (!state.canInteract) return;

    // swap mảnh
    final moveResult = movePuzzleGroupUseCase.execute(
      board: state.board,
      dragIndex: event.dragIndex,
      dropIndex: event.dropIndex,
    );

    if (!moveResult.isValid) return;

    emit(state.copyWith(board: moveResult.board, isProcessingDrop: true));

    await Future.delayed(
      const Duration(milliseconds: AppConstants.swapAnimationMs),
    );
    if (isClosed) return;

    // swap xong thì thực hiện merge group nếu có, và kiểm tra completed
    final mergeResult = movePuzzleGroupUseCase.updateGroupsAfterMove(
      board: state.board,
      oldGroupMap: moveResult.oldGroupMap,
    );

    emit(state.copyWith(board: mergeResult.board));

    if (mergeResult.mergedGroupIds.isEmpty) {
      emit(state.copyWith(isProcessingDrop: false));
      return;
    }

    await Future.delayed(
      const Duration(milliseconds: AppConstants.beforePulseDelayMs),
    );
    if (isClosed) return;

    // merge xong thì thực hiện pulse animation
    emit(
      state.copyWith(
        pulsingGroups: {...state.pulsingGroups, ...mergeResult.mergedGroupIds},
      ),
    );

    await Future.delayed(
      const Duration(milliseconds: AppConstants.pulseAnimationMs),
    );
    if (isClosed) return;

    final nextPulsingGroups = Set<int>.from(state.pulsingGroups)
      ..removeAll(mergeResult.mergedGroupIds);

    emit(
      state.copyWith(pulsingGroups: nextPulsingGroups, isProcessingDrop: false),
    );

    // kiểm tra completed
    final isCompleted = checkPuzzleCompletedUseCase.execute(mergeResult.board);

    if (isCompleted) {
      await Future.delayed(
        const Duration(milliseconds: AppConstants.completeDelayMs),
      );

      emit(
        state.copyWith(
          isCompleted: isCompleted,
          phase: isCompleted ? PuzzleGamePhase.completed : state.phase,
        ),
      );
    }
  }

  void _onSnapBackRequested(
    PuzzleSnapBackRequested event,
    Emitter<PuzzleState> emit,
  ) {
    final nextOffsets = Map<int, Offset>.from(state.snapBackOffsets);

    for (final piece in state.board.pieces) {
      if (piece.groupId == event.groupId) {
        nextOffsets[piece.id] = event.offset;
      }
    }

    emit(state.copyWith(snapBackOffsets: nextOffsets));
  }

  void _onSnapBackFinished(
    PuzzleSnapBackFinished event,
    Emitter<PuzzleState> emit,
  ) {
    final nextOffsets = Map.of(state.snapBackOffsets)..remove(event.pieceId);

    emit(state.copyWith(snapBackOffsets: nextOffsets));
  }
}
