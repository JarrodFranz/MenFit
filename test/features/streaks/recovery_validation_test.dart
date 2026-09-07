import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/streaks/domain/recovery_validation.dart';

void main() {
  final today = LocalDate(2026, 8, 26);

  group('validateRecoveryDay', () {
    test('a day in the future is rejected', () {
      final result = validateRecoveryDay(day: today.addDays(1), today: today);
      expect(result.isValid, isFalse);
      expect(result.dayError, isNotNull);
    });

    test('today and any past day are valid - recovery needs no proof', () {
      expect(validateRecoveryDay(day: today, today: today).isValid, isTrue);
      expect(
        validateRecoveryDay(day: today.addDays(-400), today: today).isValid,
        isTrue,
      );
    });
  });

  group('validateRecoveryDayRange', () {
    RecoveryDayRangeValidation validate(LocalDate from, LocalDate to) {
      return validateRecoveryDayRange(from: from, to: to, today: today);
    }

    test('a single-day range is valid, matching the single-day rule', () {
      final day = today.addDays(-3);
      expect(validate(day, day).isValid, isTrue);
    });

    test('a normal past range is valid', () {
      expect(validate(today.addDays(-5), today.addDays(-2)).isValid, isTrue);
    });

    test('a range ending exactly today is valid', () {
      expect(validate(today.addDays(-5), today).isValid, isTrue);
    });

    test('an end day before the start day is rejected', () {
      final result = validate(today.addDays(-2), today.addDays(-5));
      expect(result.isValid, isFalse);
      expect(result.rangeError, isNotNull);
    });

    test('a range ending in the future is rejected', () {
      final result = validate(today.addDays(-2), today.addDays(1));
      expect(result.isValid, isFalse);
      expect(result.rangeError, isNotNull);
    });

    test(
      'the future rule is the single-day rule reused: a future range '
      'reports the same message as validateRecoveryDay does',
      () {
        final range = validate(today.addDays(1), today.addDays(2));
        final single = validateRecoveryDay(day: today.addDays(2), today: today);
        expect(range.rangeError, single.dayError);
      },
    );

    test('a range of exactly maxRecoveryRangeDays days is valid', () {
      final from = today.addDays(-(maxRecoveryRangeDays - 1));
      expect(validate(from, today).isValid, isTrue);
    });

    test('a range one day longer than maxRecoveryRangeDays is rejected', () {
      final from = today.addDays(-maxRecoveryRangeDays);
      final result = validate(from, today);
      expect(result.isValid, isFalse);
      expect(result.rangeError, isNotNull);
    });

    test(
      'a mis-picked year (a range spanning years) is caught by the length '
      'bound - the case the bound exists for',
      () {
        final result = validate(LocalDate(2020, 8, 26), today);
        expect(result.isValid, isFalse);
        expect(result.rangeError, isNotNull);
      },
    );

    test(
      'S3-adjacent: no range message ever interpolates a date, however the '
      'range is wrong',
      () {
        final messages = [
          validate(today.addDays(-2), today.addDays(-5)).rangeError,
          validate(today.addDays(-2), today.addDays(1)).rangeError,
          validate(LocalDate(2020, 8, 26), today).rangeError,
        ];
        for (final message in messages) {
          expect(message, isNotNull);
          expect(message, isNot(contains('2026')));
          expect(message, isNot(contains('2020')));
          expect(message, isNot(contains('-08-')));
        }
      },
    );
  });
}
