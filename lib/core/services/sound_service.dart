import 'package:flutter_soloud/flutter_soloud.dart';

class SoundService {
  SoundService._();

  static final SoundService instance = SoundService._();

  final SoLoud _soloud = SoLoud.instance;

  late final AudioSource _click;

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    await _soloud.init();

    _click = await _soloud.loadAsset("assets/audio/click.mp3");

    _initialized = true;
  }

  Future<void> playClick() async {
    if (!_initialized) {
      await init();
    }

    _soloud.play(_click);
  }

  Future<void> dispose() async {
    await _soloud.disposeSource(_click);
    _soloud.deinit();
  }
}
