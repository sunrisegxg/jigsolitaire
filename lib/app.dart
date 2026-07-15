import 'package:flutter/material.dart';

import 'features/puzzle/presentation/pages/puzzle_game_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cluster Puzzle Game',
      theme: ThemeData(useMaterial3: true),
      home: const PuzzleGamePage(),
    );
  }
}
