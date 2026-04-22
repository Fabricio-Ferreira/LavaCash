/// Shared rules for attendance history / interval-style date ranges (local days).
abstract class AttendanceHistoryRangeValidation {
  static const int maxSpanDays = 366;

  /// `null` if valid; otherwise a user-facing validation message.
  static String? validate(DateTime startInclusive, DateTime endInclusive) {
    final DateTime start = DateTime(
      startInclusive.year,
      startInclusive.month,
      startInclusive.day,
    );
    final DateTime end = DateTime(
      endInclusive.year,
      endInclusive.month,
      endInclusive.day,
    );
    if (start.isAfter(end)) {
      return 'Data inicial após a data final';
    }
    final int spanDays = end.difference(start).inDays + 1;
    if (spanDays > maxSpanDays) {
      return 'Período máximo: $maxSpanDays dias';
    }
    return null;
  }
}
