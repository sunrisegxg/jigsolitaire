import 'package:flutter/material.dart';

import '../../utils/calendar_helper.dart';
import 'day_cell.dart';

class DailyCalendar extends StatelessWidget {
  final DateTime displayedMonth;
  final DateTime selectedDate;
  final Function(DateTime date) onSelect;

  const DailyCalendar({
    super.key,
    required this.displayedMonth,
    required this.selectedDate,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final firstWeekday =
        DateTime(displayedMonth.year, displayedMonth.month, 1).weekday % 7;

    final daysInMonth = DateTime(
      displayedMonth.year,
      displayedMonth.month + 1,
      0,
    ).day;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 42,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
      ),
      itemBuilder: (context, index) {
        if (index < firstWeekday) return const SizedBox();

        final day = index - firstWeekday + 1;
        if (day > daysInMonth) return const SizedBox();

        final date = CalendarHelper.normalize(
          DateTime(displayedMonth.year, displayedMonth.month, day),
        );

        return DayCell(
          date: date,
          selectedDate: selectedDate,
          onTap: () => onSelect(date),
        );
      },
    );
  }
}
