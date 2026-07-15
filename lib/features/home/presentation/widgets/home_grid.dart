import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeGrid extends StatelessWidget {
  final int totalLevels;
  final int currentLevel;
  final Set<int> completedLevels;

  const HomeGrid({
    required this.totalLevels,
    required this.currentLevel,
    required this.completedLevels,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.sizeOf(context).width * 0.05,
      ),
      child: GridView.builder(
        padding: EdgeInsets.zero,
        physics: const BouncingScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
          childAspectRatio: 0.7,
        ),
        itemCount: totalLevels,
        itemBuilder: (context, index) {
          final level = index + 1;
          final isCompleted = completedLevels.contains(level);
          final isCurrent = level == currentLevel && !isCompleted;

          // Không có GestureDetector/InkWell:
          // người chơi không thể chọn màn trong grid.
          return _LevelProgressCard(
            level: level,
            isCompleted: isCompleted,
            isCurrent: isCurrent,
          );
        },
      ),
    );
  }
}

class _LevelProgressCard extends StatelessWidget {
  final int level;
  final bool isCompleted;
  final bool isCurrent;

  const _LevelProgressCard({
    required this.level,
    required this.isCompleted,
    required this.isCurrent,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(
          color: isCurrent ? const Color(0xFFFFD54F) : Colors.black,
          width: isCurrent ? 3 : 1,
        ),
        borderRadius: BorderRadius.circular(5),
        boxShadow: isCurrent
            ? const [
                BoxShadow(
                  color: Color(0x99FFD54F),
                  blurRadius: 7,
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: isCompleted
            ? _CompletedLevelCard(level: level)
            : _UncompletedLevelCard(
                level: level,
                isCurrent: isCurrent,
              ),
      ),
    );
  }
}

class _UncompletedLevelCard extends StatelessWidget {
  final int level;
  final bool isCurrent;

  const _UncompletedLevelCard({
    required this.level,
    required this.isCurrent,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      alignment: Alignment.center,
      children: [
        Image.asset(
          'assets/images/backcard.jpeg',
          fit: BoxFit.cover,
        ),
        if (!isCurrent)
          ColoredBox(
            color: Colors.black.withOpacity(0.15),
          ),
        Center(
          child: Text(
            '$level',
            style: GoogleFonts.poppins(
              textStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    blurRadius: 4,
                    color: Colors.black,
                    offset: Offset(1, 1),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CompletedLevelCard extends StatelessWidget {
  final int level;

  const _CompletedLevelCard({required this.level});

  @override
  Widget build(BuildContext context) {
    // Đây là mặt trước tạm thời.
    // Sau này thay bằng một phần của bức tranh và thêm animation lật thẻ.
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF56C596),
            Color(0xFF087F5B),
          ],
        ),
      ),
      child: Stack(
        children: [
          const Center(
            child: Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          Positioned(
            right: 5,
            bottom: 3,
            child: Text(
              '$level',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
