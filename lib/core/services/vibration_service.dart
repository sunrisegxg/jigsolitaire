import 'package:vibration/vibration.dart';

class VibrationService {
  static final VibrationService instance = VibrationService._();

  VibrationService._();

  Future<void> vibrate() async {
    if (await Vibration.hasVibrator()) {
      await Vibration.vibrate(duration: 50);
    }
  }
}
