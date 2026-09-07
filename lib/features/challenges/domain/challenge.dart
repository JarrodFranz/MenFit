import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';

part 'challenge.freezed.dart';

/// What a challenge asks for. v1 has exactly two kinds.
///
/// Water and check-in kinds are deliberately **not** here: a hydration or
/// mood-logging race between two people turns self-care into compliance
/// scoring, which is the same objection that keeps nutrition-adherence
/// badges permanently out of the achievements catalogue
/// (`knowledge/product/feature_ideas.md`). They are registered as a later
/// question, not a v1 omission.
enum ChallengeKind {
  /// Total distance across the chosen activity types, in metres.
  /// `ChallengeBlueprint.targetUnits` counts **hundreds of metres**.
  totalDistance,

  /// Number of sessions of the chosen activity types.
  /// `ChallengeBlueprint.targetUnits` counts sessions.
  sessionCount;

  /// Parses the persisted string form, defaulting to [totalDistance] for
  /// any unrecognised value (an old build meeting a newer row reads it as
  /// the commonest kind rather than throwing on their challenge list).
  static ChallengeKind fromStorage(String value) {
    return switch (value) {
      'session_count' => ChallengeKind.sessionCount,
      _ => ChallengeKind.totalDistance,
    };
  }

  /// The persisted string form of this value.
  String toStorage() => switch (this) {
    ChallengeKind.totalDistance => 'total_distance',
    ChallengeKind.sessionCount => 'session_count',
  };
}

/// Whether this device started the challenge or joined one.
///
/// Carried for copy only ("you started this", "you joined Sam's"). It
/// confers nothing: the initiator has no privileged role, no editing
/// rights the joiner lacks, and no standing in the outcome.
enum ChallengeOrigin {
  created,
  joined;

  static ChallengeOrigin fromStorage(String value) {
    return switch (value) {
      'joined' => ChallengeOrigin.joined,
      _ => ChallengeOrigin.created,
    };
  }

  String toStorage() => switch (this) {
    ChallengeOrigin.created => 'created',
    ChallengeOrigin.joined => 'joined',
  };
}

/// The half of a challenge that both devices must agree on, byte for byte.
///
/// This is exactly what a challenge code encodes, and nothing else: the
/// kind, which activity types count, the target, the calendar window, and
/// a salt. No names, no progress, nothing derived from anybody's body.
/// [id] is a pure function of the other fields (see
/// `challenge_codes.dart#challengeBlueprintFrom`), which is what lets two
/// people who have only exchanged a short string agree on which challenge
/// they are in without a server ever being involved.
///
/// **The window is a calendar date range, always.** Never "this cycle",
/// never "the next 30 days from when you join": two people's cycles are
/// their own, and a cycle-relative window would either leak one person's
/// cycle into the other's app or silently give them different windows.
@freezed
abstract class ChallengeBlueprint with _$ChallengeBlueprint {
  const factory ChallengeBlueprint({
    /// Deterministic id — see the class doc. Build blueprints through
    /// `challenge_codes.dart#challengeBlueprintFrom` so this stays true.
    required String id,
    required ChallengeKind kind,

    /// Which activity types count. **Empty means every type counts** —
    /// that is a real, useful choice ("12 sessions of anything"), not a
    /// missing value.
    required Set<ActivityType> activityTypes,

    /// The target in [kind]'s own units: hundreds of metres for
    /// [ChallengeKind.totalDistance], sessions for
    /// [ChallengeKind.sessionCount]. Stored in coarse units because that
    /// is what the code encodes, and a shared target nobody can express
    /// exactly is worse than one both sides read identically.
    required int targetUnits,

    /// Inclusive first day of the window.
    required LocalDate windowStart,

    /// Inclusive last day of the window.
    required LocalDate windowEnd,

    /// 32-bit salt, so two challenges created with identical parameters
    /// are still two challenges.
    required int salt,
  }) = _ChallengeBlueprint;

  const ChallengeBlueprint._();

  /// The target expressed in the unit the progress engine works in:
  /// metres for [ChallengeKind.totalDistance], a session count for
  /// [ChallengeKind.sessionCount].
  double get target => switch (kind) {
    ChallengeKind.totalDistance => targetUnits * 100.0,
    ChallengeKind.sessionCount => targetUnits.toDouble(),
  };

  /// Number of days in the window, both endpoints included. Always >= 1
  /// for a blueprint that passed validation.
  int get windowDays => windowStart.difference(windowEnd) + 1;

  /// Whether [day] falls inside the window (both endpoints included).
  bool containsDay(LocalDate day) =>
      !day.isBefore(windowStart) && !day.isAfter(windowEnd);

  /// Whether an activity of [type] counts towards this challenge. An empty
  /// [activityTypes] counts everything — see its own doc.
  bool countsType(ActivityType type) =>
      activityTypes.isEmpty || activityTypes.contains(type);
}

/// A challenge as this device holds it: the shared [blueprint] plus the
/// purely local things — what the user calls themselves here, when they picked
/// it up, and the last thing their buddy told them.
///
/// Their own progress is deliberately **not** a field: it is recomputed from
/// their activity log every time it is asked for
/// (`challenge_progress_engine.dart`), so it cannot go stale, and — more
/// to the point — their privately-adjusted target never has to be written
/// down anywhere it could be read out of.
@freezed
abstract class Challenge with _$Challenge {
  const factory Challenge({
    required ChallengeBlueprint blueprint,

    /// The name they chose to show their buddy for this challenge. Per
    /// challenge, not per account: the same person may be "Ana" to a
    /// running club and something else to a sister.
    required String selfDisplayName,
    required ChallengeOrigin origin,

    /// This device's 32-bit tag for this challenge, drawn at random when
    /// they created or joined it and stamped into every progress code they
    /// export for it.
    ///
    /// Local, not shared identity: the two devices in a challenge hold
    /// **different** tags for the same challenge, which is the entire
    /// point — a pasted code whose tag equals this one is their own code
    /// coming back, and importing it would overwrite their buddy's snapshot
    /// with their own figure
    /// (`application/challenge_code_service.dart#importProgressCode`).
    ///
    /// It is random noise: not derived from their name, their device or
    /// anything they have logged. See the privacy invariant on
    /// `challenge_codes.dart`.
    required int authorTag,

    /// UTC. When this device created or joined the challenge — local
    /// metadata, not part of the shared identity.
    required DateTime createdAt,

    /// The buddy's last pasted progress, or null if they have not pasted
    /// one yet. Null is a completely normal, permanent-if-they-likes state:
    /// a challenge works perfectly well with nobody exchanging progress at
    /// all.
    ChallengeBuddySnapshot? buddy,
  }) = _Challenge;

  const Challenge._();

  String get id => blueprint.id;

  /// Whether the window is still open on [today] (inclusive).
  bool isActiveOn(LocalDate today) => !today.isAfter(blueprint.windowEnd);
}

/// What one pasted progress code said, and when it said it.
///
/// Three fields, and there is no fourth: a progress code carries a name, a
/// percentage and a date, and this type is the whole of what the app knows
/// about the other person. It cannot say how far they ran, what their target
/// was, or which of their days were protected — see the privacy invariant on
/// `challenge_codes.dart`.
@freezed
abstract class ChallengeBuddySnapshot with _$ChallengeBuddySnapshot {
  const factory ChallengeBuddySnapshot({
    /// The name they chose for themselves.
    required String displayName,

    /// Their progress against their own privately-adjusted target, as a
    /// percentage. May exceed 100 — going past your own goal is a thing
    /// that happens, and clamping it would quietly delete the best part.
    required double progressPercent,

    /// The day the code was exported for.
    required LocalDate asOf,
  }) = _ChallengeBuddySnapshot;

  const ChallengeBuddySnapshot._();

  /// Whether they reached their own goal as of [asOf].
  bool get reachedGoal => progressPercent >= 100;
}
