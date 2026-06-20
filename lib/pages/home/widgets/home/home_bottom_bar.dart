import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../dialogs/daily_challenge_dialog.dart';

class HomeBottomBar extends StatelessWidget {
  const HomeBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: MediaQuery.of(context).size.width * 0.05,
        right: MediaQuery.of(context).size.width * 0.05,
        bottom: MediaQuery.of(context).size.height * 0.04,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              showDialog(
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

          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF4FD3FF), Color(0xFF0077B6)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  offset: Offset(0, 6),
                  blurRadius: 10,
                ),
              ],
            ),
            child: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 48),
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
                      textStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        height: 1,
                      ),
                    ),
                  ),
                  Text(
                    'LEVEL 1',
                    style: GoogleFonts.poppins(
                      textStyle: TextStyle(
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
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Color(0xFF4C5B56),
              shape: BoxShape.circle,
              border: Border.all(color: Color(0xFF989C9B), width: 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(100),
                  blurRadius: 2,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Image.asset(
              'assets/crown.png',
              color: Color(0xFF989C9B),
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}
