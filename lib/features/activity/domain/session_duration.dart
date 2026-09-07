/// Pure rules for deciding what elapsed time a finishing workout session
/// should record, shared by every tracker that has no independent signal to
/// tell it whether the user is still active.
///
/// A GPS-tracked run can see that movement stopped and trim a forgotten end
/// automatically (`recording_session.dart`). Strength, swim, and mindful
/// sessions have no such signal - only "did the user log/adjust anything
/// recently" - so they cannot *know* that a long gap since the last
/// interaction means the session was abandoned rather than continued without
/// touching the screen (a long yin hold, a swim without touching the lap
/// counter mid-length, a heavy rest between sets). Both happen. So the rule
/// here is deliberately not "trim automatically": it is "detect the gap and
/// let the user say which it was", so a session left open can never silently
/// record the whole gap as its duration
/// (`knowledge/engineering/coding_standards.md` - numbers must not mislead).
library;

/// Whether an in-progress session has been idle long enough that its
/// wall-clock duration can no longer be trusted on its own.
///
/// [lastInteractionAt] is the last moment the user did something that counts
/// as real engagement with the session (tracker-specific - see call sites);
/// `null` means nothing has been logged since it started, which is judged
/// from [startedAt] instead. [idleThreshold] is the tracker's own tolerance
/// for a legitimate gap - see the per-tracker constants below.
bool sessionLooksAbandoned({
  required DateTime startedAt,
  required DateTime now,
  required Duration idleThreshold,
  DateTime? lastInteractionAt,
}) {
  final lastActive = lastInteractionAt ?? startedAt;
  return now.difference(lastActive) > idleThreshold;
}

/// The duration the session would have recorded had it ended at the user's
/// last interaction instead of now - the honest "time you were actually
/// engaged" answer offered alongside the full wall-clock one.
///
/// Clamped to zero rather than going negative if the clocks disagree, and
/// falls back to [Duration.zero] when nothing was ever logged (a session
/// with no interactions has no evidence of any real engagement at all).
Duration elapsedToLastInteraction({
  required DateTime startedAt,
  DateTime? lastInteractionAt,
}) {
  if (lastInteractionAt == null) return Duration.zero;
  final trimmed = lastInteractionAt.difference(startedAt);
  return trimmed.isNegative ? Duration.zero : trimmed;
}

/// How long a strength workout may sit with nothing logged before it is
/// treated as *possibly* abandoned rather than merely resting between sets.
///
/// Sized well past any plausible inter-set rest (the tracker's own rest
/// timer defaults to 90 seconds; even a heavy-single rest or a chat with a
/// training partner is minutes, not half an hour), so the finish-time
/// question this gates stays rare enough that it reads as a real question
/// rather than routine friction.
const Duration strengthIdleThreshold = Duration(minutes: 30);

/// How long a swim may sit with no lap logged, pool length changed, or
/// stroke changed before it is treated as *possibly* abandoned.
///
/// Swimming has no inter-set rests to protect against - a length is roughly
/// a minute even done slowly, and the lap counter is tapped every length -
/// so the threshold only needs to be generous enough to survive a break at
/// the wall or a chat between sets, not a genuine gap in the workout itself.
const Duration swimIdleThreshold = Duration(minutes: 20);

/// How long a mindful (yoga/Pilates) session may sit with no style, focus,
/// RPE, or notes change before it is treated as *possibly* abandoned.
///
/// Unlike strength or swimming, sitting still for a long stretch is exactly
/// what the session is often *for* - a long yin hold, a savasana, an
/// extended meditation - so this threshold is deliberately longer than the
/// other trackers' to avoid interrupting a legitimate practice with a
/// premature "still there?" question.
const Duration mindfulIdleThreshold = Duration(minutes: 45);
