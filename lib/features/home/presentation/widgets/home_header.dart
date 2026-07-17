import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jigsolitaire/features/collection/presentation/pages/collection_page.dart';
import 'package:jigsolitaire/features/settings/presentation/widgets/setting_dialog.dart';

import '../../../../core/services/interaction_service.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({this.collectionButtonKey, super.key});
  final GlobalKey? collectionButtonKey;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: MediaQuery.sizeOf(context).height * 0.04,
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: MediaQuery.sizeOf(context).width * 0.025,
          right: MediaQuery.sizeOf(context).width * 0.025,
          bottom: MediaQuery.sizeOf(context).height * 0.025,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              key: collectionButtonKey,
              onTap: () async {
                await context.read<InteractionService>().tap();

                if (!context.mounted) return;

                await Navigator.of(context).push<void>(
                  MaterialPageRoute(builder: (_) => const CollectionPage()),
                );
              },
              child: Container(
                width: 40,
                height: 40,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: const Color(0xFFF3F3F3),
                  border: Border.all(color: const Color(0xFFACAEAF)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(100),
                      blurRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Image.asset('assets/images/card.jpg'),
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
              onTap: () async {
                await context.read<InteractionService>().tap();

                if (!context.mounted) return;

                await showDialog<void>(
                  context: context,
                  builder: (_) => const SettingDialog(),
                );
              },
              child: Container(
                width: 40,
                height: 40,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: const Color(0xFFF3F3F3),
                  border: Border.all(color: const Color(0xFFACAEAF)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(100),
                      blurRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Image.asset('assets/images/settings.jpeg'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
