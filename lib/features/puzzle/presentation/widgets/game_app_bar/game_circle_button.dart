import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/services/interaction_service.dart';

class GameCircleButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;

  const GameCircleButton({
    super.key,
    required this.onPressed,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color.fromARGB(95, 72, 69, 69),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: () async {
          await context.read<InteractionService>().tap();
          onPressed();
        },
        customBorder: const CircleBorder(),
        child: Padding(padding: const EdgeInsets.all(4.0), child: child),
      ),
    );
  }
}
