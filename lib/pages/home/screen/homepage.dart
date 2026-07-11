import 'package:flutter/material.dart';

import '../../../services/audio_service.dart';
import '../model/setting_type.dart';
import '../widgets/home/home_bottom_bar.dart';
import '../widgets/home/home_grid.dart';
import '../widgets/home/home_header.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    debugPrint("HOME INIT");
    _initMusic();
  }

  @override
  void dispose() {
    debugPrint("HOME DISPOSE");
    super.dispose();
  }

  Future<void> _initMusic() async {
    if (settings[SettingType.music]!) {
      await AudioService.instance.startMusic();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Column(
              children: const [
                HomeHeader(),
                Expanded(child: HomeGrid()),
                HomeBottomBar(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
