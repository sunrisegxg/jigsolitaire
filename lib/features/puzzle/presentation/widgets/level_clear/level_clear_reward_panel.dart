import 'package:flutter/material.dart';

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
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: const Color(0xB3000000),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: const Color(0xFFFFD54F),
                  width: 1.5,
                ),
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
              height: 52,
              child: ElevatedButton(
                onPressed: isLocked ? null : onNextPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00A7E1),
                  disabledBackgroundColor: const Color(0xFF00A7E1),
                  foregroundColor: Colors.white,
                  elevation: 7,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(
                      color: Color(0xFFB3E5FC),
                      width: 2,
                    ),
                  ),
                ),
                child: const Text(
                  'NEXT',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
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
