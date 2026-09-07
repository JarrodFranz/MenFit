import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/challenges/domain/challenge.dart';

part 'challenge_progress.freezed.dart';

/// The user's own standing in a challenge, recomputed from their logs.
///
/// **This type is local-only and stays that way.** [adjustedTarget] and
/// [protectedDaysInWindow] are derived from their cycle, flare and recovery
/// days; [rawValue] is exactly how far they ran. None of the three is
/// persisted and none of them may be encoded into a progress code — the
/// only field of this object that ever leaves the device is [percent], and
/// the encoder's signature is what enforces that
/// (`challenge_codes.dart#encodeProgressCode` takes a percentage and no
/// object at all). See that file's privacy invariant.
@freezed
abstract class ChallengeSelfProgress with _$ChallengeSelfProgress {
  const factory ChallengeSelfProgress({
    /// What they actually did inside the window, in the challenge kind's
    /// working unit: metres for a distance challenge, a session count for
    /// a session challenge.
    required double rawValue,

    /// What the challenge asks of a person with no protected days —
    /// identical on both devices, because it is part of the shared
    /// blueprint.
    required double nominalTarget,

    /// What it asks of *them*, after pro-rating by their protected days. Less
    /// than or equal to [nominalTarget], always. Zero when every day of
    /// the window was protected.
    required double adjustedTarget,

    /// How many days of the window were protected recovery for them. Never
    /// leaves this object.
    required int protectedDaysInWindow,

    /// Days in the window, both endpoints included.
    required int windowDays,

    /// [rawValue] against [adjustedTarget], as a percentage. Not capped:
    /// 140% is a real and good answer. Zero-target windows (every day
    /// protected) read as 100 — there was nothing to fall short of.
    required double percent,
  }) = _ChallengeSelfProgress;

  const ChallengeSelfProgress._();

  /// Whether they reached their own goal.
  bool get reachedGoal => percent >= 100;
}

/// One side of a challenge, as the UI renders it.
///
/// ## What this type cannot express
///
/// There is no comparison here. No `leader`, no `isAhead`, no ordering
/// between two participants, no difference between two percentages, and
/// no notion of a result for the pair beyond "did each person reach their
/// own goal". That is the same structural stance
/// `features/insights/domain/personal_insight.dart` takes against
/// causation: the cheapest way to guarantee the app never tells one person
/// they are losing to their friend is to make "losing" unrepresentable in the
/// layer the copy is built from.
///
/// Each participant's percentage is measured against **their own** target,
/// privately adjusted for their own protected days. The two numbers are not
/// on a common scale by construction, so ranking them would not even be
/// meaningful — which is a happy accident, but the rule stands regardless
/// of the arithmetic.
sealed class ChallengeParticipant {
  const ChallengeParticipant();

  /// The name shown for this participant.
  String get displayName;

  /// Progress against this participant's own target, as a percentage.
  double get progressPercent;

  /// Whether this participant reached their own goal.
  bool get reachedGoal;
}

/// The user themselves — computed live, never stored, never shared beyond
/// [ChallengeSelfProgress.percent].
final class SelfParticipant extends ChallengeParticipant {
  const SelfParticipant({required this.displayName, required this.progress});

  @override
  final String displayName;

  final ChallengeSelfProgress progress;

  @override
  double get progressPercent => progress.percent;

  @override
  bool get reachedGoal => progress.reachedGoal;
}

/// The buddy — everything known about their comes from one pasted code, so
/// this carries the day that code was for.
final class BuddyParticipant extends ChallengeParticipant {
  const BuddyParticipant(this.snapshot);

  final ChallengeBuddySnapshot snapshot;

  @override
  String get displayName => snapshot.displayName;

  @override
  double get progressPercent => snapshot.progressPercent;

  @override
  bool get reachedGoal => snapshot.reachedGoal;

  /// The day the buddy's code was exported for — the UI says so plainly,
  /// because a number from last Tuesday presented as today's would be a
  /// small lie in a feature whose whole point is trust.
  LocalDate get asOf => snapshot.asOf;
}

/// Both sides of one challenge, ready for rendering.
///
/// [buddy] is null until a progress code has been pasted, which is a
/// normal state and not a degraded one.
class ChallengePair {
  const ChallengePair({
    required this.challenge,
    required this.self,
    this.buddy,
  });

  final Challenge challenge;
  final SelfParticipant self;
  final BuddyParticipant? buddy;

  /// The celebrated outcome: both people reached their own goals.
  ///
  /// Note what is absent — there is no `oneReached`, no `firstToFinish`,
  /// and nothing that answers "who is further along". Each participant's
  /// own [ChallengeParticipant.reachedGoal] is available on their own
  /// object, which is where a sentence about their belongs.
  bool get bothReachedGoal => self.reachedGoal && (buddy?.reachedGoal ?? false);
}
