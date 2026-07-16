import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeGrid extends StatelessWidget {
  const HomeGrid({
    required this.completedLevelCount,
    required this.pageIndex,
    super.key,
  });

  final int completedLevelCount;
  final int pageIndex;

  static const int levelsPerPage = 25;

  @override
  Widget build(BuildContext context) {
    final pageStartLevel = pageIndex * levelsPerPage + 1;

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(12),
      itemCount: levelsPerPage,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
        childAspectRatio: 0.72,
      ),
      itemBuilder: (context, index) {
        final level = pageStartLevel + index;

        final isCompleted = level <= completedLevelCount;

        final isCurrent = level == completedLevelCount + 1;

        return _LevelProgressCard(
          level: level,
          isCompleted: isCompleted,
          isCurrent: isCurrent,
        );
      },
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
            ? const [BoxShadow(color: Color(0x99FFD54F), blurRadius: 7)]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: isCompleted
            ? _CompletedLevelCard(level: level)
            : _UncompletedLevelCard(level: level, isCurrent: isCurrent),
      ),
    );
  }
}

class _UncompletedLevelCard extends StatelessWidget {
  final int level;
  final bool isCurrent;

  const _UncompletedLevelCard({required this.level, required this.isCurrent});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      alignment: Alignment.center,
      children: [
        Image.asset('assets/images/backcard.jpeg', fit: BoxFit.cover),
        if (!isCurrent) ColoredBox(color: Colors.black.withValues(alpha: 0.15)),
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
          colors: [Color(0xFF56C596), Color(0xFF087F5B)],
        ),
      ),
      child: Stack(
        children: [
          const Center(
            child: Icon(Icons.check_rounded, color: Colors.white, size: 32),
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
