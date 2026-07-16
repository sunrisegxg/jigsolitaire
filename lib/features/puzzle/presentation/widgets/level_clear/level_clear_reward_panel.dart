import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jigsolitaire/core/services/interaction_service.dart';

class LevelClearRewardPanel extends StatelessWidget {
  const LevelClearRewardPanel({
    required this.rewardKey,
    required this.rewardCoins,
    required this.rewardOpacity,
    required this.rewardScale,
    required this.buttonOpacity,
    required this.buttonSlide,
    required this.isLocked,
    required this.onNextPressed,
    super.key,
  });

  final GlobalKey rewardKey;
  final int rewardCoins;
  final Animation<double> rewardOpacity;
  final Animation<double> rewardScale;
  final Animation<double> buttonOpacity;
  final Animation<Offset> buttonSlide;
  final bool isLocked;
  final VoidCallback onNextPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FadeTransition(
          opacity: rewardOpacity,
          child: ScaleTransition(
            scale: rewardScale,
            child: Container(
              key: rewardKey,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xB3000000),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFFFD54F), width: 1.5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.monetization_on,
                    color: Color(0xFFFFC107),
                    size: 16,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '+$rewardCoins',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        FadeTransition(
          opacity: buttonOpacity,
          child: SlideTransition(
            position: buttonSlide,
            child: SizedBox(
              width: 150,
              height: 70,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: isLocked
                        ? const [Color(0xFF8FCFE5), Color(0xFF5A9BB5)]
                        : const [Color(0xFF4FD3FF), Color(0xFF0077B6)],
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
                child: ElevatedButton(
                  onPressed: isLocked
                      ? null
                      : () async {
                          await context.read<InteractionService>().tap();
                          onNextPressed();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    disabledBackgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    disabledForegroundColor: Colors.white70,
                    elevation: 0,
                    shadowColor: Colors.transparent,

                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'NEXT',
                    maxLines: 1,
                    style: GoogleFonts.poppins(
                      textStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
