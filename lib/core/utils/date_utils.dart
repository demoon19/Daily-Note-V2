import 'package:intl/intl.dart';

/// Helper format tanggal/waktu dipakai lintas fitur
/// (calendar, reminder, summary, expense).
class AppDateUtils {
  AppDateUtils._();

  static final DateFormat _dateFormat = DateFormat('dd MMM yyyy', 'id_ID');
  static final DateFormat _timeFormat = DateFormat('HH:mm', 'id_ID');
  static final DateFormat _dateTimeFormat =
      DateFormat('dd MMM yyyy, HH:mm', 'id_ID');
  static final DateFormat _dayNameFormat = DateFormat('EEEE', 'id_ID');

  static String formatDate(DateTime date) => _dateFormat.format(date);

  static String formatTime(DateTime date) => _timeFormat.format(date);

  static String formatDateTime(DateTime date) => _dateTimeFormat.format(date);

  static String formatDayName(DateTime date) => _dayNameFormat.format(date);

  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Rentang tanggal 7 hari ke belakang dari [reference],
  /// dipakai untuk fitur Weekly Summary.
  static DateTimeRange lastSevenDaysRange({DateTime? reference}) {
    final ref = reference ?? DateTime.now();
    final end = DateTime(ref.year, ref.month, ref.day, 23, 59, 59);
    final start = end.subtract(const Duration(days: 6));
    return DateTimeRange(start: DateTime(start.year, start.month, start.day), end: end);
  }

  static DateTime startOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static DateTime endOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day, 23, 59, 59);
}

class DateTimeRange {
  final DateTime start;
  final DateTime end;
  DateTimeRange({required this.start, required this.end});
}