import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/domain/local_date.dart';

void main() {
  group('constructor validation (S3)', () {
    test('an invalid calendar date fails its assert in debug/test mode', () {
      expect(() => LocalDate(2026, 2, 30), throwsA(isA<AssertionError>()));
      expect(() => LocalDate(2026, 13, 5), throwsA(isA<AssertionError>()));
    });

    test('a valid calendar date does not throw', () {
      expect(() => LocalDate(2026, 2, 28), returnsNormally);
    });
  });

  group('parse / toIso round-trip', () {
    test('parses and formats a plain date', () {
      final date = LocalDate.parse('2026-08-26');
      expect(date.year, 2026);
      expect(date.month, 8);
      expect(date.day, 26);
      expect(date.toIso(), '2026-08-26');
    });

    test('zero-pads month and day in toIso', () {
      final date = LocalDate(2026, 1, 5);
      expect(date.toIso(), '2026-01-05');
    });

    test('round-trips through toIso -> parse for many dates', () {
      for (final date in [
        LocalDate(2000, 1, 1),
        LocalDate(2024, 2, 29), // leap day
        LocalDate(2026, 12, 31),
        LocalDate(1999, 6, 15),
      ]) {
        expect(LocalDate.parse(date.toIso()), date);
      }
    });

    test('throws FormatException on malformed input', () {
      expect(() => LocalDate.parse('not-a-date'), throwsFormatException);
      expect(() => LocalDate.parse('2026/08/26'), throwsFormatException);
      expect(() => LocalDate.parse('26-08-2026'), throwsFormatException);
      expect(() => LocalDate.parse(''), throwsFormatException);
    });

    group('S3: rejects an ISO-shaped string naming no real calendar date', () {
      test("'2026-02-30' throws (February has no 30th)", () {
        expect(() => LocalDate.parse('2026-02-30'), throwsFormatException);
      });

      test("'2026-13-05' throws (no 13th month)", () {
        expect(() => LocalDate.parse('2026-13-05'), throwsFormatException);
      });

      test(
        "the thrown message contains none of the input value's digits "
        '(S3: cycle dates must never enter an exception string)',
        () {
          for (final value in ['2026-02-30', '2026-13-05']) {
            try {
              LocalDate.parse(value);
              fail('expected a FormatException for $value');
            } on FormatException catch (e) {
              expect(e.message, isNot(contains(RegExp(r'\d'))));
            }
          }
        },
      );
    });
  });

  group('LocalDate.today / fromDateTime', () {
    test('today() uses the injected clock', () {
      final fixed = DateTime(2026, 3, 15, 23, 59);
      final date = LocalDate.today(clock: () => fixed);
      expect(date, LocalDate(2026, 3, 15));
    });

    test('fromDateTime extracts the calendar-date fields verbatim', () {
      final dt = DateTime(2026, 7, 4, 8, 30);
      expect(LocalDate.fromDateTime(dt), LocalDate(2026, 7, 4));
    });
  });

  group('comparisons', () {
    test('isBefore / isAfter', () {
      final a = LocalDate(2026, 5, 1);
      final b = LocalDate(2026, 5, 2);
      expect(a.isBefore(b), isTrue);
      expect(b.isAfter(a), isTrue);
      expect(a.isBefore(a), isFalse);
      expect(a.isAfter(a), isFalse);
    });

    test('compareTo sorts a list correctly', () {
      final dates = [
        LocalDate(2026, 5, 2),
        LocalDate(2026, 1, 1),
        LocalDate(2025, 12, 31),
        LocalDate(2026, 5, 1),
      ]..sort();
      expect(dates, [
        LocalDate(2025, 12, 31),
        LocalDate(2026, 1, 1),
        LocalDate(2026, 5, 1),
        LocalDate(2026, 5, 2),
      ]);
    });

    test('equality and hashCode are value-based', () {
      expect(LocalDate(2026, 8, 26), LocalDate(2026, 8, 26));
      expect(
        LocalDate(2026, 8, 26).hashCode,
        LocalDate(2026, 8, 26).hashCode,
      );
      expect(LocalDate(2026, 8, 26), isNot(LocalDate(2026, 8, 27)));
    });
  });

  group('addDays', () {
    test('within a month', () {
      expect(LocalDate(2026, 8, 1).addDays(5), LocalDate(2026, 8, 6));
    });

    test('across a month end', () {
      expect(LocalDate(2026, 1, 30).addDays(3), LocalDate(2026, 2, 2));
    });

    test('across a year end', () {
      expect(LocalDate(2025, 12, 30).addDays(3), LocalDate(2026, 1, 2));
    });

    test('across a leap day', () {
      expect(LocalDate(2024, 2, 28).addDays(1), LocalDate(2024, 2, 29));
      expect(LocalDate(2024, 2, 28).addDays(2), LocalDate(2024, 3, 1));
      // 2025 is not a leap year - Feb has only 28 days.
      expect(LocalDate(2025, 2, 28).addDays(1), LocalDate(2025, 3, 1));
    });

    test('negative n goes backwards', () {
      expect(LocalDate(2026, 3, 1).addDays(-1), LocalDate(2026, 2, 28));
    });

    test('addDays(0) is a no-op', () {
      final date = LocalDate(2026, 6, 15);
      expect(date.addDays(0), date);
    });
  });

  group('difference (DST-safe)', () {
    test('difference is symmetric-negated and exact for a simple case', () {
      final a = LocalDate(2026, 8, 1);
      final b = LocalDate(2026, 8, 10);
      expect(a.difference(b), 9);
      expect(b.difference(a), -9);
    });

    test('difference to self is zero', () {
      final a = LocalDate(2026, 8, 1);
      expect(a.difference(a), 0);
    });

    // These pairs straddle a US "spring forward" DST transition
    // (2026-03-08) and a US "fall back" transition (2026-11-01), and a UK
    // one (2026-03-29 / 2026-10-25). LocalDate's UTC-noon anchor makes
    // these transitions irrelevant to the result - it's always exactly the
    // number of calendar days apart, never off by an hour or a day
    // regardless of the machine's local timezone.
    test('difference across a US spring-forward DST change', () {
      final before = LocalDate(2026, 3, 7);
      final after = LocalDate(2026, 3, 9);
      expect(before.difference(after), 2);
    });

    test('difference across a US fall-back DST change', () {
      final before = LocalDate(2026, 10, 31);
      final after = LocalDate(2026, 11, 2);
      expect(before.difference(after), 2);
    });

    test('difference across a UK/EU spring-forward DST change', () {
      final before = LocalDate(2026, 3, 28);
      final after = LocalDate(2026, 3, 30);
      expect(before.difference(after), 2);
    });

    test('difference across a UK/EU autumn DST change', () {
      final before = LocalDate(2026, 10, 24);
      final after = LocalDate(2026, 10, 26);
      expect(before.difference(after), 2);
    });

    test('difference across a leap year Feb 29', () {
      final before = LocalDate(2024, 2, 28);
      final after = LocalDate(2024, 3, 1);
      expect(before.difference(after), 2);
    });

    test('addDays and difference are inverses', () {
      final start = LocalDate(2026, 8, 26);
      for (final n in [0, 1, 7, 30, 365, -1, -30]) {
        expect(start.addDays(n).difference(start), -n);
        expect(start.difference(start.addDays(n)), n);
      }
    });
  });

  test('toString returns the ISO form', () {
    expect(LocalDate(2026, 8, 26).toString(), '2026-08-26');
  });
}
