import 'package:jigsolitaire/core/services/audio_service.dart';
import 'package:jigsolitaire/core/services/interaction_service.dart';
import 'package:jigsolitaire/core/services/sound_service.dart';
import 'package:jigsolitaire/core/services/vibration_service.dart';
import 'package:jigsolitaire/features/game_progress/data/local_game_progress_repository.dart';
import 'package:jigsolitaire/features/game_progress/domain/repositories/game_progress_repository.dart';
import 'package:jigsolitaire/features/game_progress/presentation/bloc/game_progress_bloc.dart';
import 'package:jigsolitaire/features/home/presentation/bloc/home_bloc.dart';
import 'package:jigsolitaire/features/settings/data/repositories/memory_settings_repository.dart';
import 'package:jigsolitaire/features/settings/domain/repositories/settings_repository.dart';
import 'package:jigsolitaire/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'features/puzzle/domain/services/puzzle_engine.dart';
import 'features/puzzle/domain/services/puzzle_group_service.dart';
import 'features/puzzle/domain/services/puzzle_move_service.dart';
import 'features/puzzle/domain/services/puzzle_shuffle_service.dart';
import 'features/puzzle/domain/usecases/check_puzzle_completed_usecase.dart';
import 'features/puzzle/domain/usecases/move_puzzle_group_usecase.dart';
import 'features/puzzle/domain/usecases/reset_puzzle_usecase.dart';
import 'features/puzzle/domain/usecases/start_puzzle_usecase.dart';
import 'features/puzzle/presentation/bloc/puzzle_bloc.dart';

class InjectionContainer {
  const InjectionContainer._();

  static final AudioService audioService = AudioService.instance;
  static final SoundService soundService = SoundService.instance;
  static final VibrationService vibrationService = VibrationService.instance;

  static final SettingsRepository settingsRepository =
      MemorySettingsRepository();

  static final SharedPreferencesAsync _sharedPreferences =
      SharedPreferencesAsync();

  static final GameProgressRepository gameProgressRepository =
      LocalGameProgressRepository(preferences: _sharedPreferences);

  static late final InteractionService interactionService;

  static Future<void> initialize() async {
    await soundService.init();

    interactionService = InteractionService(
      settingsRepository: settingsRepository,
      soundService: soundService,
      vibrationService: vibrationService,
      audioService: audioService,
    );
  }

  // settings bloc
  static SettingsBloc createSettingsBloc() {
    return SettingsBloc(
      repository: settingsRepository,
      audioService: audioService,
    );
  }

  // game progress bloc
  static GameProgressBloc createGameProgressBloc() {
    return GameProgressBloc(repository: gameProgressRepository);
  }

  // home bloc
  static HomeBloc createHomeBloc() {
    return HomeBloc();
  }

  // game puzzle bloc
  static PuzzleBloc createPuzzleBloc() {
    final shuffleService = PuzzleShuffleService();
    final moveService = PuzzleMoveService();
    final groupService = PuzzleGroupService();

    final engine = PuzzleEngine(
      shuffleService: shuffleService,
      moveService: moveService,
      groupService: groupService,
    );

    return PuzzleBloc(
      startPuzzleUseCase: StartPuzzleUseCase(engine),
      movePuzzleGroupUseCase: MovePuzzleGroupUseCase(engine),
      resetPuzzleUseCase: ResetPuzzleUseCase(engine),
      checkPuzzleCompletedUseCase: CheckPuzzleCompletedUseCase(engine),
    );
  }
}
