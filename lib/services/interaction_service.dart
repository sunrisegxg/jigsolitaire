import 'sound_service.dart';
import 'vibration_service.dart';
import '../pages/home/model/setting_type.dart';

class InteractionService {
  static final InteractionService instance = InteractionService._();

  InteractionService._();

  Future<void> tap() async {
    if (settings[SettingType.vibration]!) {
      await VibrationService.instance.vibrate();
    }

    if (settings[SettingType.sound]!) {
      await SoundService.instance.playClick();
    }
  }
}
