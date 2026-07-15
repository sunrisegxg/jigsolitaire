import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jigsolitaire/core/services/interaction_service.dart';

import '../utils/calendar_helper.dart';
import '../widgets/calendar/daily_calendar.dart';

class DailyChallengeDialog extends StatefulWidget {
  const DailyChallengeDialog({super.key});

  @override
  State<DailyChallengeDialog> createState() => _DailyChallengeDialogState();
}

class _DailyChallengeDialogState extends State<DailyChallengeDialog> {
  DateTime displayedMonth = DateTime.now();
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();

    selectedDate = CalendarHelper.normalize(DateTime.now());
  }

  void _onSelectDate(DateTime date) {
    final today = CalendarHelper.normalize(DateTime.now());

    if (CalendarHelper.normalize(date).isAfter(today)) return;

    setState(() {
      selectedDate = CalendarHelper.normalize(date);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            width: 320,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 37, 154, 130),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                _buildHeader(),
                const Divider(color: Colors.black, thickness: 0.5),

                const SizedBox(height: 16),

                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: const [
                          Text(
                            'SUN',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            'MON',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            'TUE',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            'WED',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            'THU',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            'FRI',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            'SAT',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      DailyCalendar(
                        displayedMonth: displayedMonth,
                        selectedDate: selectedDate,
                        onSelect: _onSelectDate,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),

          Positioned(bottom: -100, child: _buildPlayButton()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<InteractionService>().tap();
            },
            icon: const Icon(Icons.close, color: Colors.white, size: 28),
          ),
        ),
        const Text(
          'Daily Challenge',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildPlayButton() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final isToday =
        selectedDate.year == today.year &&
        selectedDate.month == today.month &&
        selectedDate.day == today.day;

    final colors = isToday
        ? [const Color(0xFF4FD3FF), const Color(0xFF0077B6)]
        : [Colors.green.shade400, Colors.green.shade700];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextButton(
        onPressed: () async {
          Navigator.pop(context);
          await context.read<InteractionService>().tap();
        },
        child: Text(
          'PLAY',
          style: GoogleFonts.poppins(
            textStyle: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
