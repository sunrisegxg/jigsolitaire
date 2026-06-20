import 'package:flutter/material.dart';

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
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/background.png', fit: BoxFit.cover),
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
