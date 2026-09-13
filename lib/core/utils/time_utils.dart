import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppTimeUtils {
  /// Formats TimeOfDay to a 12-hour format string, e.g. "06:30 AM" or "6:30 AM"
  static String formatTimeOfDay(BuildContext? context, TimeOfDay time) {
    if (context != null) {
      return time.format(context);
    }
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('hh:mm a').format(dt);
  }

  /// Converts TimeOfDay to a string storage representation "HH:mm" (24h)
  static String toStorageString(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Parses "HH:mm" to TimeOfDay
  static TimeOfDay? fromStorageString(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final parts = raw.split(':');
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return TimeOfDay(hour: hour, minute: minute);
  }

  /// Compares two TimeOfDay instances. Returns negative if a < b, 0 if equal, positive if a > b.
  static int compareTimeOfDay(TimeOfDay a, TimeOfDay b) {
    if (a.hour != b.hour) {
      return a.hour.compareTo(b.hour);
    }
    return a.minute.compareTo(b.minute);
  }
}
