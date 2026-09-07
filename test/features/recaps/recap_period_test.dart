import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/recaps/domain/recap_period.dart';

void main() {
  group('RecapPeriod.forMonth', () {
    test('spans the full calendar month', () {
      final period = RecapPeriod.forMonth(LocalDate(2026, 2, 14));

      expect(period.kind, RecapPeriodKind.monthEnd);
      expect(period.start, LocalDate(2026, 2, 1));
      expect(period.end, LocalDate(2026, 2, 28));
      expect(period.label, 'Your February');
      expect(period.key, 'month:2026-02');
    });

    test('handles a leap-year February', () {
      final period = RecapPeriod.forMonth(LocalDate(2028, 2, 1));
      expect(period.end, LocalDate(2028, 2, 29));
    });
  });

  group('mostRecentCompletedMonth', () {
    test("returns the month before today's", () {
      final period = mostRecentCompletedMonth(LocalDate(2026, 8, 15));
      expect(period.start, LocalDate(2026, 7, 1));
      expect(period.end, LocalDate(2026, 7, 31));
    });

    test('rolls back across a year boundary', () {
      final period = mostRecentCompletedMonth(LocalDate(2026, 1, 5));
      expect(period.start, LocalDate(2025, 12, 1));
      expect(period.end, LocalDate(2025, 12, 31));
    });
  });
}
