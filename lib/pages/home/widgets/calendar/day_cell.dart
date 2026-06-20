import 'package:flutter/material.dart';
import '../../utils/calendar_helper.dart';

class DayCell extends StatelessWidget {
  final DateTime date;
  final DateTime selectedDate;
  final VoidCallback? onTap;

  const DayCell({
    super.key,
    required this.date,
    required this.selectedDate,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final today = CalendarHelper.normalize(DateTime.now());
    final current = CalendarHelper.normalize(date);

    final isSelected = CalendarHelper.isSameDay(date, selectedDate);

    Color color;

    if (isSelected) {
      color = Colors.amber;
    } else if (CalendarHelper.isSameDay(date, today)) {
      color = Colors.teal;
    } else if (CalendarHelper.isPast(date)) {
      color = Colors.blue;
    } else {
      color = Colors.grey.shade300;
    }

    final isFuture = current.isAfter(today);

    return GestureDetector(
      onTap: isFuture ? null : onTap,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          '${date.day}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
