import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/features/activity/domain/session_duration.dart';

void main() {
  final startedAt = DateTime.utc(2026, 9, 2, 18);

  group('sessionLooksAbandoned', () {
    test('false while still within the threshold', () {
      expect(
        sessionLooksAbandoned(
          startedAt: startedAt,
          now: startedAt.add(const Duration(minutes: 19)),
          idleThreshold: const Duration(minutes: 20),
          lastInteractionAt: startedAt,
        ),
        isFalse,
      );
    });

    test('true once nothing has been logged for longer than the threshold', () {
      expect(
        sessionLooksAbandoned(
          startedAt: startedAt,
          now: startedAt.add(const Duration(minutes: 21)),
          idleThreshold: const Duration(minutes: 20),
          lastInteractionAt: startedAt,
        ),
        isTrue,
      );
    });

    test('judges from startedAt when nothing was ever logged', () {
      expect(
        sessionLooksAbandoned(
          startedAt: startedAt,
          now: startedAt.add(const Duration(minutes: 10)),
          idleThreshold: const Duration(minutes: 20),
        ),
        isFalse,
      );
      expect(
        sessionLooksAbandoned(
          startedAt: startedAt,
          now: startedAt.add(const Duration(minutes: 21)),
          idleThreshold: const Duration(minutes: 20),
        ),
        isTrue,
      );
    });

    test('is judged against the last interaction, not the start', () {
      // Idle threshold is 20 minutes; the session is 90 minutes old but the
      // last interaction was 5 minutes ago, so it is not abandoned.
      expect(
        sessionLooksAbandoned(
          startedAt: startedAt,
          now: startedAt.add(const Duration(minutes: 90)),
          idleThreshold: const Duration(minutes: 20),
          lastInteractionAt: startedAt.add(const Duration(minutes: 85)),
        ),
        isFalse,
      );
    });
  });

  group('elapsedToLastInteraction', () {
    test('is the span from start to the last interaction', () {
      expect(
        elapsedToLastInteraction(
          startedAt: startedAt,
          lastInteractionAt: startedAt.add(const Duration(minutes: 42)),
        ),
        const Duration(minutes: 42),
      );
    });

    test('is zero when nothing was ever logged', () {
      expect(
        elapsedToLastInteraction(startedAt: startedAt),
        Duration.zero,
      );
    });

    test('never goes negative on a clock disagreement', () {
      expect(
        elapsedToLastInteraction(
          startedAt: startedAt,
          lastInteractionAt: startedAt.subtract(const Duration(minutes: 5)),
        ),
        Duration.zero,
      );
    });
  });

  // swimIdleThreshold: swimming has no inter-set rests, so 20 minutes is
  // generous - a length is roughly a minute even done slowly.
  group('swimIdleThreshold', () {
    test('is 20 minutes', () {
      expect(swimIdleThreshold, const Duration(minutes: 20));
    });

    test('a swim with laps logged every few minutes is never abandoned', () {
      expect(
        sessionLooksAbandoned(
          startedAt: startedAt,
          now: startedAt.add(const Duration(hours: 1)),
          idleThreshold: swimIdleThreshold,
          lastInteractionAt: startedAt.add(const Duration(minutes: 55)),
        ),
        isFalse,
      );
    });

    test('a swim left open at the pool after 25 idle minutes is flagged', () {
      final lastLap = startedAt.add(const Duration(minutes: 10));
      expect(
        sessionLooksAbandoned(
          startedAt: startedAt,
          now: lastLap.add(const Duration(minutes: 25)),
          idleThreshold: swimIdleThreshold,
          lastInteractionAt: lastLap,
        ),
        isTrue,
      );
    });
  });

  // mindfulIdleThreshold: a yoga/Pilates session can legitimately be still
  // for a long stretch (a yin hold, savasana, meditation), so this is
  // longer than the other trackers' thresholds to avoid interrupting a
  // real practice.
  group('mindfulIdleThreshold', () {
    test('is 45 minutes', () {
      expect(mindfulIdleThreshold, const Duration(minutes: 45));
    });

    test('a long savasana within the threshold is not flagged', () {
      expect(
        sessionLooksAbandoned(
          startedAt: startedAt,
          now: startedAt.add(const Duration(minutes: 44)),
          idleThreshold: mindfulIdleThreshold,
          lastInteractionAt: startedAt,
        ),
        isFalse,
      );
    });

    test('a session left running overnight past the threshold is flagged', () {
      final lastChange = startedAt.add(const Duration(minutes: 20));
      final finishedAt = lastChange.add(const Duration(hours: 5));
      expect(
        sessionLooksAbandoned(
          startedAt: startedAt,
          now: finishedAt,
          idleThreshold: mindfulIdleThreshold,
          lastInteractionAt: lastChange,
        ),
        isTrue,
      );
      expect(
        elapsedToLastInteraction(
          startedAt: startedAt,
          lastInteractionAt: lastChange,
        ),
        const Duration(minutes: 20),
      );
    });
  });
}
