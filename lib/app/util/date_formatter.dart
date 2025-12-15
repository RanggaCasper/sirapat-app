import 'package:intl/intl.dart';

/// Utility class for consistent date formatting across the app
class DateFormatter {
  DateFormatter._();

  /// INTERNAL: ensure DateTime always local
  static DateTime _local(DateTime date) {
    return date.isUtc ? date.toLocal() : date;
  }

  /// "Senin, 27 November 2025"
  static String formatToLongDate(DateTime date) {
    final local = _local(date);
    return DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(local);
  }

  /// "27 Nov 2025"
  static String formatToShortDate(DateTime date) {
    final local = _local(date);
    return DateFormat('dd MMM yyyy', 'id_ID').format(local);
  }

  /// "27 November 2025, 14:30"
  static String formatToDateTime(DateTime date) {
    final local = _local(date);
    return DateFormat('dd MMMM yyyy, HH:mm', 'id_ID').format(local);
  }

  /// "14:30"
  static String formatToTimeOnly(DateTime date) {
    final local = _local(date);
    return DateFormat('HH:mm').format(local);
  }

  static String formatStringToLongDate(String dateStr) {
    try {
      return formatToLongDate(DateTime.parse(dateStr));
    } catch (_) {
      return '-';
    }
  }

  static String formatStringToShortDate(String dateStr) {
    try {
      return formatToShortDate(DateTime.parse(dateStr));
    } catch (_) {
      return '-';
    }
  }

  static String formatStringToDateTime(String dateStr) {
    try {
      return formatToDateTime(DateTime.parse(dateStr));
    } catch (_) {
      return '-';
    }
  }
}
