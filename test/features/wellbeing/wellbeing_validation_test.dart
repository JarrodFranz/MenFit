import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/wellbeing/domain/daily_checkin.dart';
import 'package:menfit_app/features/wellbeing/domain/flare_event.dart';
import 'package:menfit_app/features/wellbeing/domain/wellbeing_validation.dart';

void main() {
  final today = LocalDate(2026, 8, 26);

  group('validateDailyCheckin', () {
    test('a day in the future is rejected', () {
      final result = validateDailyCheckin(day: today.addDays(1), today: today);
      expect(result.isValid, isFalse);
      expect(result.dayError, isNotNull);
    });

    test('today is a valid day', () {
      final result = validateDailyCheckin(day: today, today: today);
      expect(result.isValid, isTrue);
    });

    test('a day in the past is valid', () {
      final result = validateDailyCheckin(day: today.addDays(-3), today: today);
      expect(result.isValid, isTrue);
    });

    test('every score field 0-5 is valid', () {
      final result = validateDailyCheckin(
        day: today,
        today: today,
        energy: 0,
        sleep: 5,
        soreness: 3,
        stress: 2,
        pain: 4,
      );
      expect(result.isValid, isTrue);
    });

    test('a score of 0 is valid and accepted', () {
      final result = validateDailyCheckin(day: today, today: today, energy: 0);
      expect(result.isValid, isTrue);
      expect(result.energyError, isNull);
    });

    test('a score of 6 is out of range and rejected', () {
      final result = validateDailyCheckin(day: today, today: today, pain: 6);
      expect(result.isValid, isFalse);
      expect(result.painError, isNotNull);
    });

    test('a negative score is out of range and rejected', () {
      final result = validateDailyCheckin(day: today, today: today, stress: -1);
      expect(result.isValid, isFalse);
      expect(result.stressError, isNotNull);
    });

    test('out-of-range errors are attributed to the correct field only', () {
      final result = validateDailyCheckin(
        day: today,
        today: today,
        energy: 4,
        sleep: 9,
      );
      expect(result.sleepError, isNotNull);
      expect(result.energyError, isNull);
      expect(result.sorenessError, isNull);
      expect(result.stressError, isNull);
      expect(result.painError, isNull);
    });

    test(
      'a fully empty check-in (every score null, no day issue) validates '
      'fine - validation is separate from the empty-checkin no-op rule',
      () {
        final result = validateDailyCheckin(day: today, today: today);
        expect(result.isValid, isTrue);
      },
    );
  });

  group('DailyCheckin.isEmpty', () {
    DailyCheckin checkin({
      int? energy,
      int? sleep,
      int? soreness,
      int? stress,
      int? pain,
    }) {
      return DailyCheckin(
        id: 'id',
        day: today,
        energy: energy,
        sleep: sleep,
        soreness: soreness,
        stress: stress,
        pain: pain,
        createdAt: DateTime.utc(2026),
        updatedAt: DateTime.utc(2026),
      );
    }

    test('every field unset is empty', () {
      expect(checkin().isEmpty, isTrue);
    });

    test('any single score set makes it non-empty', () {
      expect(checkin(energy: 3).isEmpty, isFalse);
      expect(checkin(sleep: 3).isEmpty, isFalse);
      expect(checkin(soreness: 3).isEmpty, isFalse);
      expect(checkin(stress: 3).isEmpty, isFalse);
      expect(checkin(pain: 3).isEmpty, isFalse);
    });
  });

  group('validateFlareEvent', () {
    test('a day in the future is rejected', () {
      final result = validateFlareEvent(
        day: today.addDays(1),
        today: today,
        severity: FlareSeverity.mild,
        impact: FlareImpact.none,
      );
      expect(result.isValid, isFalse);
      expect(result.dayError, isNotNull);
    });

    test('missing severity is rejected', () {
      final result = validateFlareEvent(
        day: today,
        today: today,
        impact: FlareImpact.none,
      );
      expect(result.isValid, isFalse);
      expect(result.severityError, isNotNull);
    });

    test('missing impact is rejected', () {
      final result = validateFlareEvent(
        day: today,
        today: today,
        severity: FlareSeverity.mild,
      );
      expect(result.isValid, isFalse);
      expect(result.impactError, isNotNull);
    });

    test('missing both severity and impact reports both errors', () {
      final result = validateFlareEvent(day: today, today: today);
      expect(result.isValid, isFalse);
      expect(result.severityError, isNotNull);
      expect(result.impactError, isNotNull);
    });

    test('severity + impact + today is fully valid with no category', () {
      final result = validateFlareEvent(
        day: today,
        today: today,
        severity: FlareSeverity.moderate,
        impact: FlareImpact.reducedTraining,
      );
      expect(result.isValid, isTrue);
      expect(result.dayError, isNull);
      expect(result.severityError, isNull);
      expect(result.impactError, isNull);
    });
  });

  group('validateFlareEvent range rules', () {
    FlareValidation validate({required LocalDate day, LocalDate? endDay}) {
      return validateFlareEvent(
        day: day,
        today: today,
        endDay: endDay,
        severity: FlareSeverity.moderate,
        impact: FlareImpact.unableToTrain,
      );
    }

    test('a null endDay (single-day flare) is valid and reports no error', () {
      final result = validate(day: today.addDays(-3));
      expect(result.isValid, isTrue);
      expect(result.endDayError, isNull);
    });

    test('an endDay equal to day (a one-day range) is valid', () {
      final result = validate(
        day: today.addDays(-3),
        endDay: today.addDays(-3),
      );
      expect(result.isValid, isTrue);
    });

    test('an endDay before day is rejected', () {
      final result = validate(
        day: today.addDays(-3),
        endDay: today.addDays(-5),
      );
      expect(result.isValid, isFalse);
      expect(result.endDayError, isNotNull);
    });

    test('an endDay in the future is rejected', () {
      final result = validate(day: today.addDays(-1), endDay: today.addDays(1));
      expect(result.isValid, isFalse);
      expect(result.endDayError, isNotNull);
    });

    test('a range ending exactly today is valid', () {
      final result = validate(day: today.addDays(-5), endDay: today);
      expect(result.isValid, isTrue);
    });

    test('a range of exactly maxFlareRangeDays days is valid', () {
      final start = today.addDays(-(maxFlareRangeDays - 1));
      final result = validate(day: start, endDay: today);
      expect(result.isValid, isTrue);
    });

    test('a range one day longer than maxFlareRangeDays is rejected', () {
      final start = today.addDays(-maxFlareRangeDays);
      final result = validate(day: start, endDay: today);
      expect(result.isValid, isFalse);
      expect(result.endDayError, isNotNull);
    });

    test(
      'a mis-picked year (a range spanning years) is caught by the length '
      'bound - the case the bound exists for',
      () {
        final result = validate(day: LocalDate(2020, 8, 26), endDay: today);
        expect(result.isValid, isFalse);
        expect(result.endDayError, isNotNull);
      },
    );

    test(
      'S3: no range message ever interpolates a date, however the range is '
      'wrong',
      () {
        final messages = [
          validate(
            day: today.addDays(-3),
            endDay: today.addDays(-5),
          ).endDayError,
          validate(
            day: today.addDays(-1),
            endDay: today.addDays(1),
          ).endDayError,
          validate(day: LocalDate(2020, 8, 26), endDay: today).endDayError,
        ];
        for (final message in messages) {
          expect(message, isNotNull);
          expect(message, isNot(contains('2026')));
          expect(message, isNot(contains('2020')));
          expect(message, isNot(contains('-08-')));
        }
      },
    );

    test(
      'a bad range and a missing severity are reported independently',
      () {
        final result = validateFlareEvent(
          day: today.addDays(-3),
          today: today,
          endDay: today.addDays(-5),
          impact: FlareImpact.none,
        );
        expect(result.endDayError, isNotNull);
        expect(result.severityError, isNotNull);
        expect(result.impactError, isNull);
        expect(result.dayError, isNull);
      },
    );
  });
}
