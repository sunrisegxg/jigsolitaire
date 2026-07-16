import 'package:flutter/material.dart';

class PuzzleLoadingView extends StatelessWidget {
  const PuzzleLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 46,
            height: 46,
            child: CircularProgressIndicator(
              strokeWidth: 5,
              color: Colors.amber,
              backgroundColor: Colors.white24,
            ),
          ),
          SizedBox(height: 18),
          Text(
            'ĐANG CHUẨN BỊ PUZZLE...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}
