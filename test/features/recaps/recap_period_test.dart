import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/cycle/domain/cycle_record.dart';
import 'package:menfit_app/features/recaps/domain/recap_period.dart';

CycleRecord _record(String id, LocalDate start, {LocalDate? end}) {
  return CycleRecord(
    id: id,
    periodStart: start,
    periodEnd: end,
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
  );
}

void main() {
  group('RecapPeriod.forCompletedCycle', () {
    test('spans from cycleStart to the day before the next cycle starts', () {
      final period = RecapPeriod.forCompletedCycle(
        cycleStart: _record('a', LocalDate(2026, 7, 1)),
        nextCycleStart: _record('b', LocalDate(2026, 7, 29)),
      );

      expect(period.kind, RecapPeriodKind.cycleEnd);
      expect(period.start, LocalDate(2026, 7, 1));
      expect(period.end, LocalDate(2026, 7, 28));
      expect(period.label, 'Cycle ending 28 Jul');
      expect(period.key, 'cycle:a');
      expect(period.totalDays, 28);
    });
  });

  group('RecapPeriod.forMonth', () {
    test('spans the full calendar month', () {
      final period = RecapPeriod.forMonth(LocalDate(2026, 2, 14));

      expect(period.kind, RecapPeriodKind.month);
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

  group('completedCyclePeriods', () {
    test('returns nothing for fewer than 2 records', () {
      expect(completedCyclePeriods(const []), isEmpty);
      expect(
        completedCyclePeriods([_record('a', LocalDate(2026, 1, 1))]),
        isEmpty,
      );
    });

    test('the most recent logged period never yields a completed cycle', () {
      final periods = completedCyclePeriods([
        _record('a', LocalDate(2026, 1, 1)),
        _record('b', LocalDate(2026, 1, 29)),
      ]);

      expect(periods, hasLength(1));
      expect(periods.single.key, 'cycle:a');
    });

    test('returns one period per consecutive pair, oldest first', () {
      final periods = completedCyclePeriods([
        // Out of order on purpose - the function must sort internally.
        _record('c', LocalDate(2026, 3, 25)),
        _record('a', LocalDate(2026, 1, 1)),
        _record('b', LocalDate(2026, 1, 29)),
      ]);

      expect(periods, hasLength(2));
      expect(periods[0].key, 'cycle:a');
      expect(periods[1].key, 'cycle:b');
      expect(periods[0].start.isBefore(periods[1].start), isTrue);
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
