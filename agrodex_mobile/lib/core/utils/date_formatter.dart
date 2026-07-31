import 'package:agrodex_mobile/core/error/failures.dart';
import 'package:intl/intl.dart';

/// Date formatting and normalization utilities matching React src/lib/api.ts.
class DateFormatter {
  DateFormatter._();

  /// Normalize date from DD-MM-YYYY to YYYY-MM-DD (ISO date-only format).
  /// Also accepts YYYY-MM-DD and returns it unchanged.
  /// Rejects ambiguous US format (MM-DD-YYYY) or out-of-range dates.
  static String normalizeDate(String input) {
    final trimmed = input.trim();

    // If already YYYY-MM-DD format, return as-is
    final ymdRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    if (ymdRegex.hasMatch(trimmed)) {
      return trimmed;
    }

    // Handle DD-MM-YYYY format (e.g., "28-10-2025")
    final dmyRegex = RegExp(r'^(\d{2})-(\d{2})-(\d{4})$');
    final match = dmyRegex.firstMatch(trimmed);
    if (match != null) {
      final dd = match.group(1)!;
      final mm = match.group(2)!;
      final yyyy = match.group(3)!;

      final dayNum = int.tryParse(dd) ?? 0;
      final monthNum = int.tryParse(mm) ?? 0;

      if (dayNum < 1 || dayNum > 31) {
        throw ValidationException(
          'Invalid date format: Invalid day: $dd. Expected DD-MM-YYYY or YYYY-MM-DD',
        );
      }

      if (monthNum < 1 || monthNum > 12) {
        throw ValidationException(
          'Invalid date format: Invalid month: $mm. Expected DD-MM-YYYY or YYYY-MM-DD',
        );
      }

      return '$yyyy-$mm-$dd';
    }

    throw ValidationException(
      'Invalid date format: $input. Expected DD-MM-YYYY or YYYY-MM-DD',
    );
  }

  /// Formats an ISO-8601 timestamp string into a human-readable format.
  /// Example: "Oct 28, 2025" or "Oct 28, 2025 14:30"
  static String formatDisplayDate(
    String isoString, {
    bool includeTime = false,
  }) {
    try {
      final date = DateTime.parse(isoString).toLocal();
      if (includeTime) {
        return DateFormat('MMM dd, yyyy HH:mm').format(date);
      }
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (_) {
      return isoString;
    }
  }

  /// Returns today's date in YYYY-MM-DD format.
  static String todayIso() {
    final now = DateTime.now();
    return DateFormat('yyyy-MM-dd').format(now);
  }
}
