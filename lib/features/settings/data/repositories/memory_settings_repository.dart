import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';

class MemorySettingsRepository implements SettingsRepository {
  AppSettings _settings = const AppSettings();

  @override
  Future<AppSettings> loadSettings() async {
    return _settings;
  }

  @override
  Future<void> saveSettings(AppSettings settings) async {
    _settings = settings;
  }
}
