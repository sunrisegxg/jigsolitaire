import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jigsolitaire/core/services/interaction_service.dart';

import '../dialogs/daily_challenge_dialog.dart';

class HomeBottomBar extends StatelessWidget {
  final int currentLevel;
  final bool isAllCompleted;
  final VoidCallback onPlayPressed;

  const HomeBottomBar({
    required this.currentLevel,
    required this.isAllCompleted,
    required this.onPlayPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: MediaQuery.sizeOf(context).width * 0.05,
        right: MediaQuery.sizeOf(context).width * 0.05,
        bottom: MediaQuery.sizeOf(context).height * 0.04,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () async {
              await context.read<InteractionService>().tap();

              if (!context.mounted) return;

              await showDialog<void>(
                context: context,
                builder: (_) => const DailyChallengeDialog(),
              );
            },
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF4C5B56),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF989C9B), width: 4),
              ),
              child: const Icon(Icons.calendar_month, color: Color(0xFF989C9B)),
            ),
          ),
          const Spacer(),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF4FD3FF), Color(0xFF0077B6)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  offset: Offset(0, 6),
                  blurRadius: 10,
                ),
              ],
            ),
            child: TextButton(
              onPressed: () async {
                await context.read<InteractionService>().tap();
                onPlayPressed();
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 48,
                ),
                disabledForegroundColor: Colors.white70,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'PLAY',
                    style: GoogleFonts.poppins(
                      textStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        height: 1,
                      ),
                    ),
                  ),
                  Text(
                    'LEVEL $currentLevel',
                    style: GoogleFonts.poppins(
                      textStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          Container(
            width: 50,
            height: 50,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF4C5B56),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF989C9B), width: 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(100),
                  blurRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Image.asset(
              'assets/images/crown.png',
              color: const Color(0xFF989C9B),
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}
