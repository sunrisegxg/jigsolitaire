import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';

class SharedPreferencesSettingsRepository implements SettingsRepository {
  static const _musicKey = 'settings_musicEnabled';
  static const _soundKey = 'settings_soundEnabled';
  static const _vibrationKey = 'settings_vibrationEnabled';
  static const _notificationKey = 'settings_notificationEnabled';

  Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  @override
  Future<AppSettings> loadSettings() async {
    final prefs = await _prefs;

    return AppSettings(
      musicEnabled: prefs.getBool(_musicKey) ?? true,
      soundEnabled: prefs.getBool(_soundKey) ?? true,
      vibrationEnabled: prefs.getBool(_vibrationKey) ?? true,
      notificationEnabled: prefs.getBool(_notificationKey) ?? true,
    );
  }

  @override
  Future<void> saveSettings(AppSettings settings) async {
    final prefs = await _prefs;

    await Future.wait([
      prefs.setBool(_musicKey, settings.musicEnabled),
      prefs.setBool(_soundKey, settings.soundEnabled),
      prefs.setBool(_vibrationKey, settings.vibrationEnabled),
      prefs.setBool(_notificationKey, settings.notificationEnabled),
    ]);
  }
}
