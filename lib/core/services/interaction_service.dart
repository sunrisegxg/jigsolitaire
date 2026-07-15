import '../../features/settings/domain/repositories/settings_repository.dart';
import 'sound_service.dart';
import 'vibration_service.dart';

class InteractionService {
  final SettingsRepository _settingsRepository;
  final SoundService _soundService;
  final VibrationService _vibrationService;

  const InteractionService({
    required SettingsRepository settingsRepository,
    required SoundService soundService,
    required VibrationService vibrationService,
  }) : _settingsRepository = settingsRepository,
       _soundService = soundService,
       _vibrationService = vibrationService;

  Future<void> tap() async {
    final settings = await _settingsRepository.loadSettings();

    final tasks = <Future<void>>[];

    if (settings.vibrationEnabled) {
      tasks.add(_vibrationService.vibrate());
    }

    if (settings.soundEnabled) {
      tasks.add(_soundService.playClick());
    }

    await Future.wait(tasks);
  }
}
