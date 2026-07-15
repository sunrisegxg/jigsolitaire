import 'package:flutter/material.dart';

class CardBackWidget extends StatelessWidget {
  const CardBackWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade800,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      child: const Center(
        child: Icon(
          Icons.extension,
          color: Colors.white,
          size: 18,
        ),
      ),
    );
  }
}
