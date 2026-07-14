import 'package:intl/intl.dart';

class DateUtils {
  /// Format date to French format
  static String formatDate(DateTime date, {String pattern = 'dd/MM/yyyy'}) {
    return DateFormat(pattern, 'fr_FR').format(date);
  }

  /// Format date and time to French format
  static String formatDateTime(DateTime date, {String pattern = 'dd/MM/yyyy HH:mm'}) {
    return DateFormat(pattern, 'fr_FR').format(date);
  }

  /// Format time to French format
  static String formatTime(DateTime date, {String pattern = 'HH:mm'}) {
    return DateFormat(pattern, 'fr_FR').format(date);
  }

  /// Get current date
  static DateTime getCurrentDate() {
    return DateTime.now();
  }

  /// Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Check if date is tomorrow
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day;
  }

  /// Get day name in French
  static String getDayName(DateTime date) {
    return DateFormat('EEEE', 'fr_FR').format(date);
  }

  /// Get month name in French
  static String getMonthName(DateTime date) {
    return DateFormat('MMMM', 'fr_FR').format(date);
  }
}

