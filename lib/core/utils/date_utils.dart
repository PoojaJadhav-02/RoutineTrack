import 'package:intl/intl.dart';

class AppDateUtils {
  static final DateFormat _keyFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat _fullDisplayFormat = DateFormat('EEEE, d MMMM yyyy');
  static final DateFormat _mediumDisplayFormat = DateFormat('d MMMM yyyy');
  static final DateFormat _shortDisplayFormat = DateFormat('d MMM yyyy');
  static final DateFormat _dayNameFormat = DateFormat('EEEE');

  /// Normalizes a DateTime by stripping hours, minutes, seconds, milliseconds, microseconds.
  static DateTime normalize(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  /// Returns 'yyyy-MM-dd' formatted key
  static String toKey(DateTime dateTime) {
    return _keyFormat.format(dateTime);
  }

  /// Parses 'yyyy-MM-dd' to normalized DateTime
  static DateTime fromKey(String key) {
    final parsed = _keyFormat.parse(key);
    return normalize(parsed);
  }

  /// Full date display: 'Sunday, 13 September 2026'
  static String formatFull(DateTime dateTime) {
    return _fullDisplayFormat.format(dateTime);
  }

  /// Medium date display: '13 September 2026'
  static String formatMedium(DateTime dateTime) {
    return _mediumDisplayFormat.format(dateTime);
  }

  /// Short date display: '13 Sep 2026'
  static String formatShort(DateTime dateTime) {
    return _shortDisplayFormat.format(dateTime);
  }

  /// Day name display: 'Sunday'
  static String formatDayName(DateTime dateTime) {
    return _dayNameFormat.format(dateTime);
  }

  /// Check if a date is today
  static bool isToday(DateTime dateTime) {
    final now = DateTime.now();
    return normalize(dateTime) == normalize(now);
  }

  /// Check if a date is yesterday
  static bool isYesterday(DateTime dateTime) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return normalize(dateTime) == normalize(yesterday);
  }

  /// Check if a date is tomorrow
  static bool isTomorrow(DateTime dateTime) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return normalize(dateTime) == normalize(tomorrow);
  }

  /// Returns friendly relative date label, e.g. "Today", "Yesterday", "Tomorrow", or formatted date
  static String getRelativeLabel(DateTime dateTime) {
    if (isToday(dateTime)) return 'Today';
    if (isYesterday(dateTime)) return 'Yesterday';
    if (isTomorrow(dateTime)) return 'Tomorrow';
    return formatShort(dateTime);
  }
}
