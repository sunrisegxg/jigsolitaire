import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/interaction_service.dart';

class GameDialog extends StatelessWidget {
  const GameDialog({
    required this.title,
    required this.message,
    required this.actions,
    this.icon,
    super.key,
  });

  final String title;
  final String message;
  final List<Widget> actions;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 380),
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
        decoration: BoxDecoration(
          image: const DecorationImage(
            image: AssetImage('assets/images/dialog_bg.png'),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFB9F6E5), width: 2),
          boxShadow: const [
            BoxShadow(
              color: Colors.black38,
              blurRadius: 18,
              offset: Offset(0, 9),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Container(
                width: 58,
                height: 58,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.blue, size: 34),
              ),
              const SizedBox(height: 12),
            ],
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: Colors.black87,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: Colors.black87,
                fontSize: 15,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 22),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: actions),
          ],
        ),
      ),
    );
  }
}

class GameDialogButton extends StatelessWidget {
  const GameDialogButton({
    required this.label,
    required this.onPressed,
    this.primary = false,
    super.key,
  });

  final String label;
  final VoidCallback onPressed;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: SizedBox(
        height: 44,
        child: primary
            ? FilledButton(
                onPressed: () async {
                  await context.read<InteractionService>().tap();
                  onPressed();
                },
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC857),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _label,
              )
            : OutlinedButton(
                onPressed: () async {
                  await context.read<InteractionService>().tap();
                  onPressed();
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black87,
                  side: const BorderSide(color: Colors.black87),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _label,
              ),
      ),
    );
  }

  Widget get _label =>
      Text(label, style: GoogleFonts.poppins(fontWeight: FontWeight.w700));
}
