enum SettingType { music, sound, vibration, notification }

class AppSettings {
  final bool musicEnabled;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final bool notificationEnabled;

  const AppSettings({
    this.musicEnabled = true,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.notificationEnabled = true,
  });

  bool isEnabled(SettingType type) {
    return switch (type) {
      SettingType.music => musicEnabled,
      SettingType.sound => soundEnabled,
      SettingType.vibration => vibrationEnabled,
      SettingType.notification => notificationEnabled,
    };
  }

  AppSettings toggle(SettingType type) {
    return switch (type) {
      SettingType.music => copyWith(musicEnabled: !musicEnabled),
      SettingType.sound => copyWith(soundEnabled: !soundEnabled),
      SettingType.vibration => copyWith(vibrationEnabled: !vibrationEnabled),
      SettingType.notification => copyWith(
        notificationEnabled: !notificationEnabled,
      ),
    };
  }

  AppSettings copyWith({
    bool? musicEnabled,
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? notificationEnabled,
  }) {
    return AppSettings(
      musicEnabled: musicEnabled ?? this.musicEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
    );
  }
}
