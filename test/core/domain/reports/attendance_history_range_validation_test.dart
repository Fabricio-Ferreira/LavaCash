import 'package:flutter_test/flutter_test.dart';
import 'package:lava_cash/core/domain/reports/attendance_history_range_validation.dart';

void main() {
  group('AttendanceHistoryRangeValidation', () {
    test('returns null for same-day range', () {
      final DateTime d = DateTime(2025, 4, 21);
      expect(AttendanceHistoryRangeValidation.validate(d, d), isNull);
    });

    test('returns message when start after end', () {
      final DateTime a = DateTime(2025, 4, 22);
      final DateTime b = DateTime(2025, 4, 21);
      expect(
        AttendanceHistoryRangeValidation.validate(a, b),
        'Data inicial após a data final',
      );
    });

    test('returns message when span exceeds max', () {
      final DateTime start = DateTime(2025, 1, 1);
      final DateTime end = start.add(
        const Duration(days: AttendanceHistoryRangeValidation.maxSpanDays),
      );
      expect(
        AttendanceHistoryRangeValidation.validate(start, end),
        isNotNull,
      );
      expect(
        AttendanceHistoryRangeValidation.validate(start, end),
        contains('366'),
      );
    });

    test('returns null for max allowed span', () {
      final DateTime start = DateTime(2025, 1, 1);
      final DateTime end = start.add(
        const Duration(days: AttendanceHistoryRangeValidation.maxSpanDays - 1),
      );
      expect(AttendanceHistoryRangeValidation.validate(start, end), isNull);
    });
  });
}
