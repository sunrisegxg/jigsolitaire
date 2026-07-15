import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jigsolitaire/core/services/interaction_service.dart';
import 'package:jigsolitaire/features/settings/domain/entities/app_settings.dart';
import 'package:jigsolitaire/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:jigsolitaire/features/settings/presentation/bloc/settings_event.dart';
import 'package:jigsolitaire/features/settings/presentation/bloc/settings_state.dart';

class SettingDialog extends StatefulWidget {
  const SettingDialog({super.key});

  @override
  State<SettingDialog> createState() => _SettingDialogState();
}

class _SettingDialogState extends State<SettingDialog> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        final settings = state.settings;

        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Container(
            width: 320,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 37, 154, 130),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 10),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: () async {
                          Navigator.pop(context);

                          await context.read<InteractionService>().tap();
                        },
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),

                    const Text(
                      'Settings',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Divider(color: Colors.black, thickness: 0.5),
                SizedBox(height: 40),
                // Help Center
                _buildButton(
                  icon: Icons.help,
                  text: "Help Center",
                  onTap: () async {
                    await context.read<InteractionService>().tap();
                  },
                ),

                const SizedBox(height: 25),

                // Save Progress
                _buildButton(
                  icon: Icons.save,
                  text: "Save your progress",
                  onTap: () async {
                    await context.read<InteractionService>().tap();
                  },
                ),

                const SizedBox(height: 35),

                // Bottom Icons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildIconButton(
                      icon: Icons.music_note,
                      disabledIcon: Icons.music_off,
                      isEnabled: settings.musicEnabled,
                      onPressed: () {
                        context.read<SettingsBloc>().add(
                          const SettingToggled(SettingType.music),
                        );
                      },
                    ),
                    const SizedBox(width: 20),
                    _buildIconButton(
                      disabledIcon: Icons.volume_off,
                      icon: Icons.volume_up,
                      isEnabled: settings.soundEnabled,
                      onPressed: () async {
                        context.read<SettingsBloc>().add(
                          const SettingToggled(SettingType.sound),
                        );
                        await context.read<InteractionService>().tap();
                      },
                    ),
                    const SizedBox(width: 20),
                    _buildIconButton(
                      iconVibration: buildVibrationIcon(
                        settings.vibrationEnabled,
                      ),
                      isEnabled: settings.vibrationEnabled,
                      onPressed: () async {
                        context.read<SettingsBloc>().add(
                          const SettingToggled(SettingType.vibration),
                        );
                        await context.read<InteractionService>().tap();
                      },
                    ),
                    const SizedBox(width: 20),
                    _buildIconButton(
                      disabledIcon: Icons.notifications_off,
                      icon: Icons.notifications,
                      isEnabled: settings.notificationEnabled,
                      onPressed: () async {
                        context.read<SettingsBloc>().add(
                          const SettingToggled(SettingType.notification),
                        );
                        await context.read<InteractionService>().tap();
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildIconButton({
    IconData? icon,
    IconData? disabledIcon,
    Widget? iconVibration,
    required bool isEnabled,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isEnabled ? Colors.white : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 4,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child:
              iconVibration ??
              Icon(
                isEnabled ? icon : disabledIcon,
                size: 30,
                color: Colors.green.shade900,
              ),
        ),
      ),
    );
  }

  Widget _buildButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 240,
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 4,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 26, color: Colors.green.shade900),
            Text(
              text,
              style: TextStyle(
                fontSize: 16,
                color: Colors.green.shade900,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildVibrationIcon(bool isEnabled) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(Icons.vibration, size: 30, color: Colors.green.shade900),
        if (!isEnabled)
          Transform.rotate(
            angle: -0.8,
            child: Container(
              width: 2.5,
              height: 28,
              decoration: BoxDecoration(color: Colors.green.shade900),
            ),
          ),
      ],
    );
  }
}
