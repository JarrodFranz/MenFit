import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/streaks/domain/streak_engine.dart';
import 'package:menfit_app/features/wellbeing/domain/daily_checkin.dart';
import 'package:menfit_app/features/wellbeing/domain/flare_event.dart';
import 'package:menfit_app/features/wellbeing/domain/recovery_prompt.dart';

void main() {
  final day = LocalDate(2026, 8, 20);
  final now = DateTime.utc(2026);

  DailyCheckin checkin({int? pain, int? energy}) {
    return DailyCheckin(
      id: 'c1',
      day: day,
      pain: pain,
      energy: energy,
      createdAt: now,
      updatedAt: now,
    );
  }

  FlareEvent flare({required FlareImpact impact}) {
    return FlareEvent(
      id: 'f1',
      day: day,
      severity: FlareSeverity.mild,
      impact: impact,
      createdAt: now,
      updatedAt: now,
    );
  }

  group('no checkin, no flares', () {
    test('null checkin and no flares -> false', () {
      expect(hasSignificantSymptoms(null, const []), isFalse);
    });
  });

  group('pain threshold', () {
    test('pain 3 -> false', () {
      expect(hasSignificantSymptoms(checkin(pain: 3), const []), isFalse);
    });

    test('pain 4 -> true', () {
      expect(hasSignificantSymptoms(checkin(pain: 4), const []), isTrue);
    });

    test('pain 5 -> true', () {
      expect(hasSignificantSymptoms(checkin(pain: 5), const []), isTrue);
    });

    test('pain unset -> false (with no other signal)', () {
      expect(hasSignificantSymptoms(checkin(), const []), isFalse);
    });
  });

  group('energy threshold', () {
    test('energy 3 -> false', () {
      expect(hasSignificantSymptoms(checkin(energy: 3), const []), isFalse);
    });

    test('energy 2 -> true', () {
      expect(hasSignificantSymptoms(checkin(energy: 2), const []), isTrue);
    });

    test('energy 1 -> true', () {
      expect(hasSignificantSymptoms(checkin(energy: 1), const []), isTrue);
    });

    test('energy unset -> false (with no other signal)', () {
      expect(hasSignificantSymptoms(checkin(), const []), isFalse);
    });
  });

  group('flare impact', () {
    test('a flare with impact none -> false', () {
      expect(
        hasSignificantSymptoms(null, [flare(impact: FlareImpact.none)]),
        isFalse,
      );
    });

    test('a flare with impact reducedTraining -> true', () {
      expect(
        hasSignificantSymptoms(
          null,
          [flare(impact: FlareImpact.reducedTraining)],
        ),
        isTrue,
      );
    });

    test('a flare with impact unableToTrain -> true', () {
      expect(
        hasSignificantSymptoms(
          null,
          [flare(impact: FlareImpact.unableToTrain)],
        ),
        isTrue,
      );
    });
  });

  group('combinations', () {
    test('mild checkin plus a none-impact flare -> false', () {
      expect(
        hasSignificantSymptoms(checkin(pain: 2, energy: 4), [
          flare(impact: FlareImpact.none),
        ]),
        isFalse,
      );
    });

    test('any single significant signal is enough, even amid mild ones', () {
      expect(
        hasSignificantSymptoms(checkin(pain: 2, energy: 2), const []),
        isTrue,
      );
    });
  });

  group('evaluateRecoveryPromptEligibility (F2)', () {
    RecoveryPromptDecision evaluate({
      DailyCheckin? checkin,
      List<FlareEvent> todaysFlares = const [],
      DayStatus todayStatus = DayStatus.unscheduled,
      bool alreadyDismissed = false,
      bool isToday = true,
    }) {
      return evaluateRecoveryPromptEligibility(
        checkin: checkin,
        todaysFlares: todaysFlares,
        todayStatus: todayStatus,
        alreadyDismissed: alreadyDismissed,
        isToday: isToday,
      );
    }

    test(
      'every condition met -> offer',
      () {
        expect(
          evaluate(checkin: checkin(pain: 5)),
          RecoveryPromptDecision.offer,
        );
      },
    );

    test('not today -> notToday, even with a significant check-in', () {
      expect(
        evaluate(checkin: checkin(pain: 5), isToday: false),
        RecoveryPromptDecision.notToday,
      );
    });

    test(
      'not today wins over every other reason it could also fail for '
      '(checked first)',
      () {
        expect(
          evaluate(
            isToday: false,
            todayStatus: DayStatus.completedActivity,
            alreadyDismissed: true,
          ),
          RecoveryPromptDecision.notToday,
        );
      },
    );

    for (final status in [
      DayStatus.completedActivity,
      DayStatus.protectedRecovery,
    ]) {
      test(
        'todayStatus == $status -> alreadyCovered, even with a significant '
        'check-in (today is already active or already protected)',
        () {
          expect(
            evaluate(checkin: checkin(pain: 5), todayStatus: status),
            RecoveryPromptDecision.alreadyCovered,
          );
        },
      );
    }

    test('todayStatus == unscheduled does not itself block the prompt', () {
      expect(
        evaluate(checkin: checkin(pain: 5)),
        isNot(RecoveryPromptDecision.alreadyCovered),
      );
    });

    test(
      'already dismissed this session -> alreadyDismissed, even with a '
      'significant check-in',
      () {
        expect(
          evaluate(checkin: checkin(pain: 5), alreadyDismissed: true),
          RecoveryPromptDecision.alreadyDismissed,
        );
      },
    );

    test('nothing significant logged -> notSignificant', () {
      expect(
        evaluate(checkin: checkin(pain: 2, energy: 4)),
        RecoveryPromptDecision.notSignificant,
      );
    });

    test('null checkin with no flares -> notSignificant', () {
      expect(evaluate(), RecoveryPromptDecision.notSignificant);
    });

    test(
      'a flare-only trigger (no checkin scores at all) still -> offer - '
      'the F2 flare-only regression',
      () {
        expect(
          evaluate(
            todaysFlares: [flare(impact: FlareImpact.unableToTrain)],
          ),
          RecoveryPromptDecision.offer,
        );
      },
    );
  });
}
