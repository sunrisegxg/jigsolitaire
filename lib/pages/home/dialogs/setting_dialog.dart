import 'package:flutter/material.dart';

import '../../../services/audio_service.dart';
import '../../../services/interaction_service.dart';
import '../../../services/sound_service.dart';
import '../../../services/vibration_service.dart';
import '../model/setting_type.dart';

class SettingDialog extends StatefulWidget {
  const SettingDialog({super.key});

  @override
  State<SettingDialog> createState() => _SettingDialogState();
}

class _SettingDialogState extends State<SettingDialog> {
  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setDialogState) {
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

                          await InteractionService.instance.tap();
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
                    await InteractionService.instance.tap();
                  },
                ),

                const SizedBox(height: 25),

                // Save Progress
                _buildButton(
                  icon: Icons.save,
                  text: "Save your progress",
                  onTap: () async {
                    await InteractionService.instance.tap();
                  },
                ),

                const SizedBox(height: 35),

                // Bottom Icons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildIconButton(
                      disabledIcon: Icons.music_off,
                      icon: Icons.music_note,
                      isEnabled: settings[SettingType.music]!,
                      onTap: () async {
                        setDialogState(() {
                          settings[SettingType.music] =
                              !settings[SettingType.music]!;
                        });
                        if (settings[SettingType.music]!) {
                          await AudioService.instance.startMusic();
                        } else {
                          await AudioService.instance.stopMusic();
                        }
                        await InteractionService.instance.tap();
                      },
                    ),
                    const SizedBox(width: 20),
                    _buildIconButton(
                      disabledIcon: Icons.volume_off,
                      icon: Icons.volume_up,
                      isEnabled: settings[SettingType.sound]!,
                      onTap: () async {
                        setDialogState(() {
                          settings[SettingType.sound] =
                              !settings[SettingType.sound]!;
                        });
                        await InteractionService.instance.tap();
                      },
                    ),
                    const SizedBox(width: 20),
                    _buildIconButton(
                      iconVibration: buildVibrationIcon(
                        settings[SettingType.vibration]!,
                      ),
                      isEnabled: settings[SettingType.vibration]!,
                      onTap: () async {
                        setDialogState(() {
                          settings[SettingType.vibration] =
                              !settings[SettingType.vibration]!;
                        });
                        await InteractionService.instance.tap();
                      },
                    ),
                    const SizedBox(width: 20),
                    _buildIconButton(
                      disabledIcon: Icons.notifications_off,
                      icon: Icons.notifications,
                      isEnabled: settings[SettingType.notification]!,
                      onTap: () async {
                        setDialogState(() {
                          settings[SettingType.notification] =
                              !settings[SettingType.notification]!;
                        });
                        await InteractionService.instance.tap();
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
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isEnabled ? Colors.white : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
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
              color: Colors.black.withOpacity(0.2),
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
