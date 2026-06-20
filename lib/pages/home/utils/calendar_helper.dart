class CalendarHelper {
  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static DateTime normalize(DateTime d) => DateTime(d.year, d.month, d.day);

  static bool isPast(DateTime date) =>
      normalize(date).isBefore(normalize(DateTime.now()));
}
