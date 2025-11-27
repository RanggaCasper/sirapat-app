import 'package:intl/intl.dart';

/// Utility class for consistent date formatting across the app
class DateFormatter {
  DateFormatter._();

  /// Format date to Indonesian long format (e.g., "Senin, 27 November 2025")
  static String formatToLongDate(DateTime date) {
    try {
      return DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(date);
    } catch (e) {
      return date.toString();
    }
  }

  /// Format date string to Indonesian long format
  static String formatStringToLongDate(String dateStr) {
    try {
      final DateTime dateTime = DateTime.parse(dateStr);
      return formatToLongDate(dateTime);
    } catch (e) {
      return dateStr;
    }
  }

  /// Format date to short format (e.g., "27 Nov 2025")
  static String formatToShortDate(DateTime date) {
    try {
      return DateFormat('dd MMM yyyy', 'id_ID').format(date);
    } catch (e) {
      return date.toString();
    }
  }

  /// Format date with time (e.g., "27 November 2025, 14:30")
  static String formatToDateTime(DateTime date) {
    try {
      return DateFormat('dd MMMM yyyy, HH:mm', 'id_ID').format(date);
    } catch (e) {
      return date.toString();
    }
  }

  /// Format time only (e.g., "14:30")
  static String formatToTimeOnly(DateTime date) {
    try {
      return DateFormat('HH:mm').format(date);
    } catch (e) {
      return date.toString();
    }
  }

  /// Format date string to short format (e.g., "27 Nov 2025")
  static String formatStringToShortDate(String dateStr) {
    try {
      final DateTime dateTime = DateTime.parse(dateStr);
      return formatToShortDate(dateTime);
    } catch (e) {
      return dateStr;
    }
  }

  /// Format date string with time (e.g., "27 November 2025, 14:30")
  static String formatStringToDateTime(String dateStr) {
    try {
      final DateTime dateTime = DateTime.parse(dateStr);
      return formatToDateTime(dateTime);
    } catch (e) {
      return dateStr;
    }
  }
}
