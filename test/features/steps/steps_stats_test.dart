import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/steps/presentation/steps_stats.dart';

void main() {
  final monday = LocalDate(2026, 8, 31);

  group('buildStepsDays', () {
    test('emits one entry per calendar day, gaps included as null', () {
      final days = buildStepsDays(
        start: monday,
        end: monday.addDays(6),
        stepsByDay: {
          monday: 8000,
          monday.addDays(2): 3000,
          monday.addDays(6): 12000,
        },
      );

      expect(days, hasLength(7));
      expect(days.first.day, monday);
      expect(days.last.day, monday.addDays(6));
      expect(
        days.map((day) => day.steps),
        [8000, null, 3000, null, null, null, 12000],
      );
    });

    test('keeps a stored zero distinct from a missing day', () {
      final days = buildStepsDays(
        start: monday,
        end: monday.addDays(1),
        stepsByDay: {monday: 0},
      );

      expect(days[0].steps, 0);
      expect(days[0].hasData, isTrue);
      expect(days[1].steps, isNull);
      expect(days[1].hasData, isFalse);
    });

    test('a start after the end is an empty range, not an error', () {
      expect(
        buildStepsDays(
          start: monday.addDays(3),
          end: monday,
          stepsByDay: const {},
        ),
        isEmpty,
      );
    });
  });

  group('computeStepsRangeStats', () {
    test('averages over days WITH data, not over calendar days', () {
      // 8000 + 4000 over two recorded days inside a seven-day window. The
      // honest average is 6000; dividing by 7 would report 1714 - a number
      // she never walked, produced by counting five unsynced days as zero.
      final days = buildStepsDays(
        start: monday,
        end: monday.addDays(6),
        stepsByDay: {monday: 8000, monday.addDays(3): 4000},
      );

      final stats = computeStepsRangeStats(days, target: 7500);

      expect(stats.totalSteps, 12000);
      expect(stats.daysInRange, 7);
      expect(stats.daysWithData, 2);
      expect(stats.missingDays, 5);
      expect(stats.average, 6000);
    });

    test('counts days at or above the target, exclusive of missing days', () {
      final days = buildStepsDays(
        start: monday,
        end: monday.addDays(4),
        stepsByDay: {
          monday: 7500, // exactly the target counts
          monday.addDays(1): 7499,
          monday.addDays(2): 20000,
          // days 3 and 4 have no row - neither at target nor below it
        },
      );

      final stats = computeStepsRangeStats(days, target: 7500);

      expect(stats.daysAtTarget, 2);
      expect(stats.daysWithData, 3);
      expect(stats.missingDays, 2);
    });

    test('a range with no rows has no average rather than an average of 0', () {
      final days = buildStepsDays(
        start: monday,
        end: monday.addDays(6),
        stepsByDay: const {},
      );

      final stats = computeStepsRangeStats(days, target: 7500);

      expect(stats.hasAnyData, isFalse);
      expect(stats.average, isNull);
      expect(stats.totalSteps, 0);
      expect(stats.daysAtTarget, 0);
    });

    test('a range of recorded zeroes does have an average', () {
      final days = buildStepsDays(
        start: monday,
        end: monday.addDays(1),
        stepsByDay: {monday: 0, monday.addDays(1): 0},
      );

      final stats = computeStepsRangeStats(days, target: 7500);

      expect(stats.hasAnyData, isTrue);
      expect(stats.average, 0);
    });
  });

  group('axis helpers', () {
    test('picks a step-count interval a person reads an axis in', () {
      expect(stepsAxisInterval(3000), 1000);
      expect(stepsAxisInterval(9000), 2500);
      expect(stepsAxisInterval(18000), 5000);
      expect(stepsAxisInterval(38000), 10000);
    });

    test('rounds the axis top up to a whole number of intervals', () {
      expect(stepsAxisMax(9200, 2500), 10000);
      expect(stepsAxisMax(10000, 2500), 10000);
      // Never a zero-height axis, even for an all-zero range.
      expect(stepsAxisMax(0, 1000), 1000);
    });
  });
}
