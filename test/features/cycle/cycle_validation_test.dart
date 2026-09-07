import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/cycle/domain/cycle_record.dart';
import 'package:menfit_app/features/cycle/domain/cycle_validation.dart';

void main() {
  final today = LocalDate(2026, 8, 26);

  CycleRecord record({
    required String id,
    required LocalDate start,
    LocalDate? end,
  }) {
    return CycleRecord(
      id: id,
      periodStart: start,
      periodEnd: end,
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    );
  }

  group('start date', () {
    test('a start date in the future is rejected', () {
      final result = validateCycleRecord(
        periodStart: today.addDays(1),
        today: today,
        existingRecords: const [],
      );
      expect(result.isValid, isFalse);
      expect(result.startError, isNotNull);
    });

    test('today is a valid start date', () {
      final result = validateCycleRecord(
        periodStart: today,
        today: today,
        existingRecords: const [],
      );
      expect(result.isValid, isTrue);
    });

    test('a start date in the past is valid', () {
      final result = validateCycleRecord(
        periodStart: today.addDays(-10),
        today: today,
        existingRecords: const [],
      );
      expect(result.isValid, isTrue);
    });
  });

  group('end date', () {
    test('an end date before the start date is rejected', () {
      final result = validateCycleRecord(
        periodStart: today.addDays(-5),
        periodEnd: today.addDays(-6),
        today: today,
        existingRecords: const [],
      );
      expect(result.isValid, isFalse);
      expect(result.endError, isNotNull);
    });

    test('an end date equal to the start date is valid', () {
      final start = today.addDays(-5);
      final result = validateCycleRecord(
        periodStart: start,
        periodEnd: start,
        today: today,
        existingRecords: const [],
      );
      expect(result.isValid, isTrue);
    });

    test('an end date in the future is rejected', () {
      final result = validateCycleRecord(
        periodStart: today.addDays(-5),
        periodEnd: today.addDays(1),
        today: today,
        existingRecords: const [],
      );
      expect(result.isValid, isFalse);
      expect(result.endError, isNotNull);
    });

    test('an end date of today is valid', () {
      final result = validateCycleRecord(
        periodStart: today.addDays(-5),
        periodEnd: today,
        today: today,
        existingRecords: const [],
      );
      expect(result.isValid, isTrue);
    });

    test('a null end date (ongoing) is valid', () {
      final result = validateCycleRecord(
        periodStart: today,
        today: today,
        existingRecords: const [],
      );
      expect(result.isValid, isTrue);
      expect(result.endError, isNull);
    });
  });

  group('overlap', () {
    test(
      'an overlapping range against an existing ended record is rejected',
      () {
        final existing = record(
          id: 'r1',
          start: LocalDate(2026, 8, 1),
          end: LocalDate(2026, 8, 5),
        );
        final result = validateCycleRecord(
          periodStart: LocalDate(2026, 8, 3),
          periodEnd: LocalDate(2026, 8, 7),
          today: today,
          existingRecords: [existing],
        );
        expect(result.isValid, isFalse);
        expect(result.endError, isNotNull);
      },
    );

    test('a range fully containing an existing record is rejected', () {
      final existing = record(
        id: 'r1',
        start: LocalDate(2026, 8, 3),
        end: LocalDate(2026, 8, 4),
      );
      final result = validateCycleRecord(
        periodStart: LocalDate(2026, 8, 1),
        periodEnd: LocalDate(2026, 8, 10),
        today: today,
        existingRecords: [existing],
      );
      expect(result.isValid, isFalse);
    });

    test('a new period overlapping an ongoing record is rejected', () {
      final ongoing = record(id: 'r1', start: LocalDate(2026, 8, 20));
      final result = validateCycleRecord(
        periodStart: LocalDate(2026, 8, 22),
        today: today,
        existingRecords: [ongoing],
      );
      expect(result.isValid, isFalse);
      expect(result.endError, isNotNull);
    });

    test('a non-overlapping range before an existing record is valid', () {
      final existing = record(
        id: 'r1',
        start: LocalDate(2026, 8, 10),
        end: LocalDate(2026, 8, 14),
      );
      final result = validateCycleRecord(
        periodStart: LocalDate(2026, 8, 1),
        periodEnd: LocalDate(2026, 8, 5),
        today: today,
        existingRecords: [existing],
      );
      expect(result.isValid, isTrue);
    });

    test('adjacent (non-overlapping) ranges are valid', () {
      final existing = record(
        id: 'r1',
        start: LocalDate(2026, 8, 10),
        end: LocalDate(2026, 8, 14),
      );
      final result = validateCycleRecord(
        periodStart: LocalDate(2026, 8, 15),
        periodEnd: LocalDate(2026, 8, 18),
        today: today,
        existingRecords: [existing],
      );
      expect(result.isValid, isTrue);
    });

    test(
      'editing a record excludes it from the overlap check against itself',
      () {
        final existing = record(
          id: 'r1',
          start: LocalDate(2026, 8, 10),
          end: LocalDate(2026, 8, 14),
        );
        // Re-saving the exact same range for the same id must not
        // self-reject.
        final result = validateCycleRecord(
          periodStart: LocalDate(2026, 8, 10),
          periodEnd: LocalDate(2026, 8, 14),
          today: today,
          existingRecords: [existing],
          excludingId: 'r1',
        );
        expect(result.isValid, isTrue);
      },
    );

    test(
      'excludingId does not exempt an overlap against a *different* record',
      () {
        final r1 = record(
          id: 'r1',
          start: LocalDate(2026, 8, 10),
          end: LocalDate(2026, 8, 14),
        );
        final r2 = record(
          id: 'r2',
          start: LocalDate(2026, 7, 1),
          end: LocalDate(2026, 7, 5),
        );
        // Editing r2 into an overlap with r1 is still rejected.
        final result = validateCycleRecord(
          periodStart: LocalDate(2026, 8, 12),
          periodEnd: LocalDate(2026, 8, 20),
          today: today,
          existingRecords: [r1, r2],
          excludingId: 'r2',
        );
        expect(result.isValid, isFalse);
      },
    );
  });

  test(
    'a fully valid, non-overlapping save with no existing records passes',
    () {
      final result = validateCycleRecord(
        periodStart: LocalDate(2026, 8, 1),
        periodEnd: LocalDate(2026, 8, 5),
        today: today,
        existingRecords: const [],
      );
      expect(result.isValid, isTrue);
      expect(result.startError, isNull);
      expect(result.endError, isNull);
    },
  );
}
