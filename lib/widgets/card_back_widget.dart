import 'package:flutter/material.dart';

// --- WIDGET MẶT SAU LÁ BÀI ---
class CardBackWidget extends StatelessWidget {
  const CardBackWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blueGrey[800],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white70, width: 1),
        //   image: const DecorationImage(
        //     image: NetworkImage('https://picsum.photos/id/1060/200/200'),
        //     fit: BoxFit.cover,
        //     colorFilter: ColorFilter.mode(Colors.black54, BlendMode.darken),
        //   ),
      ),
      child: const Center(
        child: Icon(Icons.star, color: Colors.white54, size: 32),
      ),
    );
  }
}