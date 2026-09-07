import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/features/activity/domain/strength_session_duration.dart';

void main() {
  final startedAt = DateTime.utc(2026, 9, 2, 18);

  group('strengthLooksAbandoned', () {
    test('false while the user keeps logging sets', () {
      // Two hours in, last set logged a minute ago: a long but real
      // session, not an abandoned one.
      expect(
        strengthLooksAbandoned(
          startedAt: startedAt,
          now: startedAt.add(const Duration(hours: 2)),
          lastInteractionAt: startedAt.add(
            const Duration(hours: 1, minutes: 59),
          ),
        ),
        isFalse,
      );
    });

    test('false for a long rest that is still within the threshold', () {
      expect(
        strengthLooksAbandoned(
          startedAt: startedAt,
          now: startedAt.add(const Duration(minutes: 50)),
          lastInteractionAt: startedAt.add(const Duration(minutes: 21)),
        ),
        isFalse,
      );
    });

    test('true once nothing has been logged for longer than the threshold', () {
      expect(
        strengthLooksAbandoned(
          startedAt: startedAt,
          now: startedAt.add(const Duration(minutes: 50)),
          lastInteractionAt: startedAt.add(const Duration(minutes: 19)),
        ),
        isTrue,
      );
    });

    test('judges from startedAt when nothing was ever logged', () {
      expect(
        strengthLooksAbandoned(
          startedAt: startedAt,
          now: startedAt.add(const Duration(minutes: 10)),
        ),
        isFalse,
      );
      expect(
        strengthLooksAbandoned(
          startedAt: startedAt,
          now: startedAt.add(const Duration(minutes: 31)),
        ),
        isTrue,
      );
    });
  });

  group('strengthElapsedToLastInteraction', () {
    test('is the span from start to the last logged set', () {
      expect(
        strengthElapsedToLastInteraction(
          startedAt: startedAt,
          lastInteractionAt: startedAt.add(const Duration(minutes: 42)),
        ),
        const Duration(minutes: 42),
      );
    });

    test('is zero when nothing was ever logged', () {
      expect(
        strengthElapsedToLastInteraction(startedAt: startedAt),
        Duration.zero,
      );
    });

    test('never goes negative on a clock disagreement', () {
      expect(
        strengthElapsedToLastInteraction(
          startedAt: startedAt,
          lastInteractionAt: startedAt.subtract(const Duration(minutes: 5)),
        ),
        Duration.zero,
      );
    });
  });

  // The on-device review found an ad-hoc strength workout, left active and
  // saved later, recorded as "Elapsed time 6:16:11". The tracker's elapsed
  // duration is wall-clock since start, so the whole gap was banked as
  // training time.
  group('the 6:16:11 regression', () {
    test(
      'a workout left open for hours after the last set is detected, and '
      'offers the honest duration up to that set',
      () {
        // Started 18:00, last set logged 18:42, finished 00:16 the next
        // morning.
        final lastInteractionAt = startedAt.add(const Duration(minutes: 42));
        final finishedAt = startedAt.add(
          const Duration(hours: 6, minutes: 16, seconds: 11),
        );

        expect(
          strengthLooksAbandoned(
            startedAt: startedAt,
            now: finishedAt,
            lastInteractionAt: lastInteractionAt,
          ),
          isTrue,
          reason: 'the finish dialog must ask instead of banking 6:16:11',
        );
        expect(
          strengthElapsedToLastInteraction(
            startedAt: startedAt,
            lastInteractionAt: lastInteractionAt,
          ),
          const Duration(minutes: 42),
        );
      },
    );

    test(
      'a genuinely long session the user logged through is left alone',
      () {
        // Four hours, last set logged two minutes ago: nothing to ask about,
        // and the full duration is the honest one.
        final now = startedAt.add(const Duration(hours: 4));
        expect(
          strengthLooksAbandoned(
            startedAt: startedAt,
            now: now,
            lastInteractionAt: now.subtract(const Duration(minutes: 2)),
          ),
          isFalse,
        );
      },
    );
  });
}
