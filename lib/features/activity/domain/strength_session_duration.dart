/// Strength-tracker-specific names over the shared session-duration rules in
/// `session_duration.dart`.
///
/// Kept as thin wrappers (rather than inlined at call sites) so the existing
/// call sites and tests keep their strength-specific names; the actual rule
/// lives once, generically, in `session_duration.dart` - see its library doc
/// for why a session left open is never trimmed silently.
library;

import 'package:menfit_app/features/activity/domain/session_duration.dart';

export 'package:menfit_app/features/activity/domain/session_duration.dart'
    show strengthIdleThreshold;

/// Whether an in-progress workout has been idle long enough that its
/// wall-clock duration can no longer be trusted on its own.
///
/// [lastInteractionAt] is the last moment the user logged anything (a set
/// completed, an exercise added, a weight edited). `null` means nothing has
/// ever been logged, which is judged from [startedAt] instead.
bool strengthLooksAbandoned({
  required DateTime startedAt,
  required DateTime now,
  DateTime? lastInteractionAt,
}) {
  return sessionLooksAbandoned(
    startedAt: startedAt,
    now: now,
    idleThreshold: strengthIdleThreshold,
    lastInteractionAt: lastInteractionAt,
  );
}

/// The duration the workout would have recorded had it ended at the user's
/// last logged interaction instead of now - the honest "time you were
/// actually logging sets" answer offered alongside the full wall-clock one.
Duration strengthElapsedToLastInteraction({
  required DateTime startedAt,
  DateTime? lastInteractionAt,
}) {
  return elapsedToLastInteraction(
    startedAt: startedAt,
    lastInteractionAt: lastInteractionAt,
  );
}
