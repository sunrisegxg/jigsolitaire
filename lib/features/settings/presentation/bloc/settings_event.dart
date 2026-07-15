import '../../domain/entities/app_settings.dart';

sealed class SettingsEvent {
  const SettingsEvent();
}

class SettingsStarted extends SettingsEvent {
  const SettingsStarted();
}

class SettingToggled extends SettingsEvent {
  final SettingType type;

  const SettingToggled(this.type);
}
