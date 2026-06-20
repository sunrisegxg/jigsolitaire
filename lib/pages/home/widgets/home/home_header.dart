import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../collection/screen/collection_screen.dart';
import '../../dialogs/setting_dialog.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: MediaQuery.of(context).size.height * 0.04,
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: MediaQuery.of(context).size.width * 0.025,
          right: MediaQuery.of(context).size.width * 0.025,
          bottom: MediaQuery.of(context).size.height * 0.05,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CollectionScreen(),
                  ),
                );
              },
              child: Container(
                width: 40,
                height: 40,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  color: const Color(0xFFADAEAF),
                  border: Border.all(color: const Color(0xFFACAEAF), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(100),
                      blurRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Image.asset('assets/card.png'),
              ),
            ),

            const Spacer(),

            Stack(
              children: [
                Text(
                  'Jigsolitaire',
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      foreground: Paint()
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = 8
                        ..color = const Color(0xFF056E45),
                    ),
                  ),
                ),
                Text(
                  'Jigsolitaire',
                  style: GoogleFonts.poppins(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),

            const Spacer(),

            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => const SettingDialog(),
                );
              },
              child: Container(
                width: 40,
                height: 40,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  color: const Color(0xFFF3F3F3),
                  border: Border.all(color: const Color(0xFFACAEAF), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(100),
                      blurRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Image.asset('assets/settings.jpeg'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
