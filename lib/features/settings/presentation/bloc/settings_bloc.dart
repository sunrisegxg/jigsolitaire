import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jigsolitaire/features/settings/domain/entities/app_settings.dart';

import '../../../../core/services/audio_service.dart';
import '../../domain/repositories/settings_repository.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsRepository _repository;
  final AudioService _audioService;

  SettingsBloc({
    required SettingsRepository repository,
    required AudioService audioService,
  }) : _repository = repository,
       _audioService = audioService,
       super(const SettingsState()) {
    on<SettingsStarted>(_onStarted);
    on<SettingToggled>(_onSettingToggled);
  }

  Future<void> _onStarted(
    SettingsStarted event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(status: SettingsStatus.loading));

    try {
      final settings = await _repository.loadSettings();

      emit(state.copyWith(status: SettingsStatus.ready, settings: settings));

      print(
        'Music is enabled, starting music...======================${settings.musicEnabled}',
      );
      if (settings.musicEnabled) {
        await _audioService.startMusic();
      }
    } catch (error) {
      emit(
        state.copyWith(
          status: SettingsStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> _onSettingToggled(
    SettingToggled event,
    Emitter<SettingsState> emit,
  ) async {
    final updatedSettings = state.settings.toggle(event.type);

    emit(
      state.copyWith(status: SettingsStatus.ready, settings: updatedSettings),
    );

    await _repository.saveSettings(updatedSettings);

    switch (event.type) {
      case SettingType.music:
        if (updatedSettings.musicEnabled) {
          await _audioService.startMusic();
        } else {
          await _audioService.stopMusic();
        }

      case SettingType.sound:
      case SettingType.vibration:
      case SettingType.notification:
        break;
    }
  }
}
