import 'package:flutter/material.dart';
import 'package:test/screen/puzzle_game_screen.dart';

void main() {
  runApp(const PuzzleApp());
}

class PuzzleApp extends StatelessWidget {
  const PuzzleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const PuzzleGameScreen(),
    );
  }
}
