import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/challenges/domain/challenge.dart';
import 'package:menfit_app/features/challenges/domain/challenge_validation.dart';

void main() {
  final today = LocalDate(2026, 9, 1);

  ChallengeValidation validate({
    ChallengeKind kind = ChallengeKind.totalDistance,
    int targetUnits = 300,
    LocalDate? windowStart,
    LocalDate? windowEnd,
    String displayName = 'Alex',
  }) {
    return validateChallenge(
      kind: kind,
      targetUnits: targetUnits,
      windowStart: windowStart ?? LocalDate(2026, 9, 1),
      windowEnd: windowEnd ?? LocalDate(2026, 9, 30),
      displayName: displayName,
      today: today,
    );
  }

  group('window', () {
    test('a realistic month passes', () {
      expect(validate().isValid, isTrue);
    });

    test('a single-day window passes', () {
      expect(
        validate(
          windowStart: LocalDate(2026, 9, 7),
          windowEnd: LocalDate(2026, 9, 7),
        ).isValid,
        isTrue,
      );
    });

    test('an end before the start is rejected', () {
      expect(
        validate(
          windowStart: LocalDate(2026, 9, 10),
          windowEnd: LocalDate(2026, 9, 9),
        ).windowError,
        isNotNull,
      );
    });

    test('the maximum length is inclusive and the day after is not', () {
      final start = LocalDate(2026, 9, 1);
      expect(
        validate(
          windowStart: start,
          windowEnd: start.addDays(maxChallengeWindowDays - 1),
        ).windowError,
        isNull,
      );
      expect(
        validate(
          windowStart: start,
          windowEnd: start.addDays(maxChallengeWindowDays),
        ).windowError,
        isNotNull,
      );
    });

    test('a start more than a year away in either direction is rejected', () {
      expect(
        validate(
          windowStart: today.addDays(-maxChallengeStartPastDays - 1),
          windowEnd: today.addDays(-maxChallengeStartPastDays),
        ).windowError,
        isNotNull,
      );
      expect(
        validate(
          windowStart: today.addDays(maxChallengeStartFutureDays + 1),
          windowEnd: today.addDays(maxChallengeStartFutureDays + 2),
        ).windowError,
        isNotNull,
      );
    });

    test('a challenge that has already finished still validates', () {
      // Joining late, or looking at an archived one, must not fail
      // validation - the window is in the past, not absurd.
      expect(
        validate(
          windowStart: LocalDate(2026, 6, 1),
          windowEnd: LocalDate(2026, 6, 30),
        ).windowError,
        isNull,
      );
    });
  });

  group('target', () {
    test('distance bounds are inclusive at both ends', () {
      expect(validate(targetUnits: minDistanceTargetUnits).targetError, isNull);
      expect(validate(targetUnits: maxDistanceTargetUnits).targetError, isNull);
      expect(
        validate(targetUnits: minDistanceTargetUnits - 1).targetError,
        isNotNull,
      );
      expect(
        validate(targetUnits: maxDistanceTargetUnits + 1).targetError,
        isNotNull,
      );
    });

    test('session bounds are checked against the session range', () {
      expect(
        validate(
          kind: ChallengeKind.sessionCount,
          targetUnits: minSessionTargetUnits,
        ).targetError,
        isNull,
      );
      expect(
        validate(
          kind: ChallengeKind.sessionCount,
          targetUnits: maxSessionTargetUnits + 1,
        ).targetError,
        isNotNull,
      );
      expect(
        validate(kind: ChallengeKind.sessionCount, targetUnits: 0).targetError,
        isNotNull,
      );
    });

    test('a distance target is judged by distance rules, not session ones', () {
      // 1,000 hundred-metre units is 100 km - fine as a distance, absurd as
      // a session count. The bound has to know which kind it is looking at.
      expect(validate(targetUnits: 1000).targetError, isNull);
      expect(
        validate(
          kind: ChallengeKind.sessionCount,
          targetUnits: 1000,
        ).targetError,
        isNotNull,
      );
    });
  });

  group('display name', () {
    test('an empty or whitespace-only name is rejected', () {
      expect(validateDisplayName(''), isNotNull);
      expect(validateDisplayName('   '), isNotNull);
    });

    test('the bound counts UTF-8 bytes, not characters', () {
      // 24 single-byte characters fit; six four-byte emoji fit exactly;
      // seven do not.
      expect(validateDisplayName('W' * 24), isNull);
      expect(validateDisplayName('W' * 25), isNotNull);
      expect(validateDisplayName('🏃' * 6), isNull);
      expect(
        validateDisplayName('🏃' * 7),
        isNotNull,
        reason:
            'a name that would be silently truncated in the code is better '
            'rejected where she can see it',
      );
    });

    test('surrounding whitespace does not count towards the bound', () {
      expect(validateDisplayName('  ${'W' * 24}  '), isNull);
    });
  });

  test('errors are reported per field, all at once', () {
    final result = validate(
      targetUnits: 0,
      windowStart: LocalDate(2026, 9, 10),
      windowEnd: LocalDate(2026, 9, 1),
      displayName: '',
    );

    expect(result.isValid, isFalse);
    expect(result.windowError, isNotNull);
    expect(result.targetError, isNotNull);
    expect(result.displayNameError, isNotNull);
  });

  test('no message names a date, a body metric, or anything cycle-derived', () {
    // Same S3 habit as `core/domain/local_date.dart#parse`: a validation
    // string can end up in a log or a screenshot.
    final messages = [
      validate(
        windowStart: LocalDate(2026, 9, 10),
        windowEnd: LocalDate(2026, 9, 1),
      ).windowError!,
      validate(
        windowStart: LocalDate(2026, 9, 1),
        windowEnd: LocalDate(2027, 9, 1),
      ).windowError!,
      validate(targetUnits: 0).targetError!,
      validate(kind: ChallengeKind.sessionCount, targetUnits: 0).targetError!,
      validateDisplayName('')!,
      validateDisplayName('W' * 40)!,
    ];

    for (final message in messages) {
      expect(
        message,
        isNot(contains('2026')),
        reason: 'no validation message may interpolate a date',
      );
      expect(
        message,
        isNot(contains('2027')),
        reason: 'no validation message may interpolate a date',
      );
      for (final word in ['period', 'cycle', 'recovery', 'weight']) {
        expect(message.toLowerCase(), isNot(contains(word)));
      }
    }
  });
}
