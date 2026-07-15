import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';

class AudioService {
  static final AudioService instance = AudioService._();

  AudioService._();

  final AudioPlayer _player = AudioPlayer();

  bool _initialized = false;

  Future<void> _init() async {
    if (_initialized) return;

    _initialized = true;

    final session = await AudioSession.instance;

    await session.configure(const AudioSessionConfiguration.music());

    await _player.setLoopMode(LoopMode.one);

    await _player.setAsset("assets/audio/background.mp3");
  }

  Future<void> startMusic() async {
    await _init();

    if (_player.playing) return;

    await _player.play();
  }

  Future<void> stopMusic() async {
    await _player.stop();
  }

  Future<void> pauseMusic() async {
    await _player.pause();
  }

  Future<void> resumeMusic() async {
    if (!_player.playing) {
      await _player.play();
    }
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}
