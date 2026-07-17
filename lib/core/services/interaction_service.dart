import 'package:jigsolitaire/core/services/audio_service.dart';

import '../../features/settings/domain/repositories/settings_repository.dart';
import 'sound_service.dart';
import 'vibration_service.dart';

class InteractionService {
  final SettingsRepository _settingsRepository;
  final SoundService _soundService;
  final VibrationService _vibrationService;
  final AudioService _audioService;
  const InteractionService({
    required SettingsRepository settingsRepository,
    required SoundService soundService,
    required VibrationService vibrationService,
    required AudioService audioService,
  }) : _settingsRepository = settingsRepository,
       _soundService = soundService,
       _vibrationService = vibrationService,
       _audioService = audioService;

  Future<void> tap() async {
    final settings = await _settingsRepository.loadSettings();

    final tasks = <Future<void>>[];

    if (settings.soundEnabled) {
      tasks.add(_soundService.playClick());
    }
    if (settings.vibrationEnabled) {
      tasks.add(_vibrationService.vibrate());
    }
    if (settings.musicEnabled) {
      tasks.add(_audioService.startMusic());
    }

    await Future.wait(tasks);
  }
}
