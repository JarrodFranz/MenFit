import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/cycle/domain/cycle_prediction_engine.dart';
import 'package:menfit_app/features/cycle/domain/cycle_record.dart';
import 'package:menfit_app/features/cycle/domain/period_days.dart';

void main() {
  final today = LocalDate(2026, 8, 26);

  CycleRecord record({
    required LocalDate start,
    LocalDate? end,
    String id = 'r1',
  }) {
    return CycleRecord(
      id: id,
      periodStart: start,
      periodEnd: end,
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    );
  }

  group('isPeriodDay', () {
    test('empty records: every day is false', () {
      expect(isPeriodDay(today, const [], today), isFalse);
    });

    test('inclusive lower boundary: the start day is a period day', () {
      final r = record(
        start: LocalDate(2026, 8, 10),
        end: LocalDate(2026, 8, 14),
      );
      expect(isPeriodDay(LocalDate(2026, 8, 10), [r], today), isTrue);
    });

    test('inclusive upper boundary: the end day is a period day', () {
      final r = record(
        start: LocalDate(2026, 8, 10),
        end: LocalDate(2026, 8, 14),
      );
      expect(isPeriodDay(LocalDate(2026, 8, 14), [r], today), isTrue);
    });

    test('the day before start is not a period day', () {
      final r = record(
        start: LocalDate(2026, 8, 10),
        end: LocalDate(2026, 8, 14),
      );
      expect(isPeriodDay(LocalDate(2026, 8, 9), [r], today), isFalse);
    });

    test('the day after end is not a period day', () {
      final r = record(
        start: LocalDate(2026, 8, 10),
        end: LocalDate(2026, 8, 14),
      );
      expect(isPeriodDay(LocalDate(2026, 8, 15), [r], today), isFalse);
    });

    test('a single-day period covers only that day', () {
      final r = record(
        start: LocalDate(2026, 8, 10),
        end: LocalDate(2026, 8, 10),
      );
      expect(isPeriodDay(LocalDate(2026, 8, 10), [r], today), isTrue);
      expect(isPeriodDay(LocalDate(2026, 8, 9), [r], today), isFalse);
      expect(isPeriodDay(LocalDate(2026, 8, 11), [r], today), isFalse);
    });

    group('ongoing records (null end)', () {
      test('covers start..today inclusive', () {
        final r = record(start: LocalDate(2026, 8, 24));
        expect(isPeriodDay(LocalDate(2026, 8, 24), [r], today), isTrue);
        expect(isPeriodDay(LocalDate(2026, 8, 25), [r], today), isTrue);
        expect(isPeriodDay(today, [r], today), isTrue);
      });

      test('never covers a day after today - predictions must not pause', () {
        final r = record(start: LocalDate(2026, 8, 24));
        expect(isPeriodDay(today.addDays(1), [r], today), isFalse);
      });

      test('an ongoing record starting today covers only today', () {
        final r = record(start: today);
        expect(isPeriodDay(today, [r], today), isTrue);
        expect(isPeriodDay(today.addDays(-1), [r], today), isFalse);
        expect(isPeriodDay(today.addDays(1), [r], today), isFalse);
      });

      group('the plausible-duration cap', () {
        // A record left open is a record she forgot to close. Uncapped it
        // marked every day since as a period day - pausing her streak
        // forever and auto-qualifying every all-protected consistency week
        // permanently, since awards are never revoked.
        const maxDuration = CyclePredictionEngine.maxPlausiblePeriodDuration;

        test('behaves exactly as before within a plausible duration', () {
          final start = today.addDays(-(maxDuration - 1));
          final r = record(start: start);
          for (var offset = 0; offset < maxDuration; offset++) {
            expect(
              isPeriodDay(start.addDays(offset), [r], today),
              isTrue,
              reason: 'day ${offset + 1} of an ongoing period',
            );
          }
          expect(isPeriodDay(today, [r], today), isTrue);
        });

        test('stops after the last plausible day, however stale', () {
          final start = today.addDays(-90);
          final r = record(start: start);
          expect(
            isPeriodDay(start.addDays(maxDuration - 1), [r], today),
            isTrue,
            reason: 'the last plausible day is still covered',
          );
          expect(
            isPeriodDay(start.addDays(maxDuration), [r], today),
            isFalse,
            reason: 'day ${maxDuration + 1} of an un-ended record is not one',
          );
          expect(isPeriodDay(today, [r], today), isFalse);
        });

        test('a logged end longer than the cap is respected as logged', () {
          // The cap applies to the null-end fallback only. A 30-day end she
          // typed in is a fact she entered, not a guess to be trimmed.
          final start = today.addDays(-40);
          final r = record(start: start, end: start.addDays(29));
          expect(isPeriodDay(start.addDays(29), [r], today), isTrue);
          expect(isPeriodDay(start.addDays(30), [r], today), isFalse);
        });
      });
    });

    test('overlap union: a day covered by either of two records is true', () {
      final r1 = record(
        start: LocalDate(2026, 1, 1),
        end: LocalDate(2026, 1, 5),
      );
      final r2 = record(
        id: 'r2',
        start: LocalDate(2026, 8, 1),
        end: LocalDate(2026, 8, 5),
      );
      expect(isPeriodDay(LocalDate(2026, 1, 3), [r1, r2], today), isTrue);
      expect(isPeriodDay(LocalDate(2026, 8, 3), [r1, r2], today), isTrue);
      expect(isPeriodDay(LocalDate(2026, 4, 1), [r1, r2], today), isFalse);
    });
  });

  group('periodDaysInRange', () {
    test('empty records returns an empty set', () {
      expect(
        periodDaysInRange(
          LocalDate(2026, 8, 1),
          LocalDate(2026, 8, 31),
          const [],
          today,
        ),
        isEmpty,
      );
    });

    test('from after to returns an empty set', () {
      final r = record(
        start: LocalDate(2026, 8, 1),
        end: LocalDate(2026, 8, 5),
      );
      expect(
        periodDaysInRange(LocalDate(2026, 8, 10), LocalDate(2026, 8, 1), [
          r,
        ], today),
        isEmpty,
      );
    });

    test('returns every inclusive day of a fully-contained record', () {
      final r = record(
        start: LocalDate(2026, 8, 10),
        end: LocalDate(2026, 8, 12),
      );
      final result = periodDaysInRange(
        LocalDate(2026, 8, 1),
        LocalDate(2026, 8, 31),
        [r],
        today,
      );
      expect(result, {
        LocalDate(2026, 8, 10),
        LocalDate(2026, 8, 11),
        LocalDate(2026, 8, 12),
      });
    });

    test('clamps a record that extends outside the query range', () {
      final r = record(
        start: LocalDate(2026, 7, 28),
        end: LocalDate(2026, 8, 3),
      );
      final result = periodDaysInRange(
        LocalDate(2026, 8, 1),
        LocalDate(2026, 8, 31),
        [r],
        today,
      );
      expect(result, {
        LocalDate(2026, 8, 1),
        LocalDate(2026, 8, 2),
        LocalDate(2026, 8, 3),
      });
    });

    test('caps an ongoing record at today, not beyond', () {
      final r = record(start: LocalDate(2026, 8, 20));
      final result = periodDaysInRange(
        LocalDate(2026, 8, 1),
        LocalDate(2026, 8, 31),
        [r],
        today,
      );
      expect(
        result,
        {
          for (
            var d = LocalDate(2026, 8, 20);
            !d.isAfter(today);
            d = d.addDays(1)
          )
            d,
        },
      );
      expect(result.contains(today.addDays(1)), isFalse);
    });

    test('a stale ongoing record covers a plausible period, not a month', () {
      const maxDuration = CyclePredictionEngine.maxPlausiblePeriodDuration;
      final start = LocalDate(2026, 7, 1);
      final result = periodDaysInRange(
        LocalDate(2026, 7, 1),
        LocalDate(2026, 8, 31),
        [record(start: start)],
        today,
      );
      expect(result, hasLength(maxDuration));
      expect(result, contains(start.addDays(maxDuration - 1)));
      expect(result, isNot(contains(start.addDays(maxDuration))));
    });

    test('unions overlapping/adjacent records without duplicates', () {
      final r1 = record(
        start: LocalDate(2026, 8, 1),
        end: LocalDate(2026, 8, 5),
      );
      final r2 = record(
        id: 'r2',
        start: LocalDate(2026, 8, 3),
        end: LocalDate(2026, 8, 8),
      );
      final result = periodDaysInRange(
        LocalDate(2026, 8, 1),
        LocalDate(2026, 8, 31),
        [r1, r2],
        today,
      );
      expect(result.length, 8); // Aug 1-8 inclusive, union, no duplicates.
      expect(result, {
        for (
          var d = LocalDate(2026, 8, 1);
          !d.isAfter(LocalDate(2026, 8, 8));
          d = d.addDays(1)
        )
          d,
      });
    });

    test('a record entirely outside the range contributes nothing', () {
      final r = record(
        start: LocalDate(2025, 1, 1),
        end: LocalDate(2025, 1, 5),
      );
      final result = periodDaysInRange(
        LocalDate(2026, 8, 1),
        LocalDate(2026, 8, 31),
        [r],
        today,
      );
      expect(result, isEmpty);
    });
  });
}
