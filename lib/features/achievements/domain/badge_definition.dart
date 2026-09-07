import 'package:freezed_annotation/freezed_annotation.dart' show immutable;
import 'package:menfit_app/features/achievements/domain/badge_tier.dart';

/// Whether a badge has a ladder of tiers or is awarded exactly once.
enum BadgeKind {
  /// Bronze → Silver → Gold → Platinum → Diamond → Diamond II → …
  /// Only ever attached to a behaviour the user can keep progressing at.
  tiered,

  /// A single award. No ladder, no progress bar beyond earned/not.
  oneOff,
}

/// The trophy-case section a badge belongs to.
enum BadgeCategory {
  movement,
  strength,
  cycling,
  swimming,
  intervals,
  mindfulness,
  hydration,
  consistency,
  fun;

  /// Section heading shown above the badges in this category.
  String get label => switch (this) {
    BadgeCategory.movement => 'Movement',
    BadgeCategory.strength => 'Strength',
    BadgeCategory.cycling => 'Cycling',
    BadgeCategory.swimming => 'Swimming',
    BadgeCategory.intervals => 'Intervals',
    BadgeCategory.mindfulness => 'Mindfulness',
    BadgeCategory.hydration => 'Hydration',
    BadgeCategory.consistency => 'Consistency',
    BadgeCategory.fun => 'Just for fun',
  };
}

/// The quantity a tiered badge's ladder is measured in.
///
/// Every metric value the engine produces is in **canonical units**
/// (metres, kilograms, whole counts, minutes) — presentation converts
/// (metres → km, minutes → hours) exactly as it does everywhere else in
/// this codebase.
enum BadgeMetricUnit {
  metres,
  kilograms,
  sessions,
  days,
  weeks,
  minutes,
  months,

  /// Metres of climbing, shown as whole metres rather than converted to
  /// kilometres. Climbing is read in metres everywhere in this app and
  /// everywhere outside it — "75 km climbed" is arithmetically true and
  /// means nothing to anybody, so this unit exists purely so the ascent
  /// ladder reads the way the number is actually spoken.
  ascentMetres,
}

/// A quantity that accumulates over the user's whole history, and that a
/// tiered ladder can be hung on.
///
/// Every member here must be **monotonically non-decreasing** as more is
/// logged: a ladder over something that can fall would mean a badge could
/// be un-earned, which this app does not do. (Deleting logged data can of
/// course lower a value — awards already recorded still stand; see
/// `domain/award_repository.dart`.)
enum BadgeMetric {
  /// Completed Monday-start weeks that met the walking target, cycle-aware
  /// — see `domain/badge_metrics.dart#countWeeklyWalkingTargetWeeks`.
  weeklyWalkingTargetWeeks,

  /// Number of logged sessions of any kind.
  lifetimeSessionCount,

  /// Lifetime `ActivityType.run` distance, in metres.
  lifetimeRunDistanceMetres,

  /// Lifetime `ActivityType.ride` distance, in metres.
  lifetimeRideDistanceMetres,

  /// Lifetime `ActivityType.walk` distance, in metres.
  lifetimeWalkDistanceMetres,

  /// Lifetime `ActivityType.hike` distance, in metres.
  lifetimeHikeDistanceMetres,

  /// Lifetime `ActivityType.swim` distance, in metres — the logged
  /// distance, falling back to laps × pool length when only the lap count
  /// was entered. See `domain/badge_metrics.dart#swimDistanceMetres`.
  lifetimeSwimDistanceMetres,

  /// Lifetime climbing, in metres, summed across every activity that
  /// recorded any. An activity with no elevation contributes `0` rather
  /// than breaking the sum — most manually-logged sessions have none, and
  /// this ladder is a bonus for the ones that do, never the only ladder a
  /// given activity type has.
  lifetimeAscentMetres,

  /// Number of logged interval (HIIT) sessions.
  hiitSessionCount,

  /// Number of logged `ActivityType.yoga` sessions.
  yogaSessionCount,

  /// Number of logged `ActivityType.pilates` sessions.
  pilatesSessionCount,

  /// Lifetime completed strength tonnage, in kilograms.
  lifetimeStrengthVolumeKg,

  /// Number of logged strength sessions.
  strengthSessionCount,

  /// Number of days with a logged wellbeing check-in.
  checkinDayCount,

  /// Number of days whose logged water reached the hydration target.
  waterTargetDayCount,

  /// Total minutes of yoga/pilates/mindful sessions.
  mindfulMinutes,

  /// Sessions started before 07:00 local time.
  earlyBirdSessionCount,

  /// Sessions started at or after 20:00 local time.
  nightOwlSessionCount,
}

/// A yes/no fact about the user's history that a one-off badge hangs on.
///
/// Every member must be computable from data the app **already stores**.
/// No badge may motivate collecting something new, and none may reach for
/// an outside service (that is why there is no rainy-day badge — see
/// `domain/badge_catalogue.dart`'s "Ideas deliberately not shipped").
enum BadgeCondition {
  firstActivityLogged,
  firstFiveKilometreEffort,
  firstStrengthSession,
  firstMindfulSession,
  firstWaterTargetDay,
  fullCheckinWeek,
  seasonalTurnSession,
  everySeasonActive,
  fiveMovementKinds,
  palindromeDistance,
  firstWalkSession,
  tenKilometreWalk,
  firstHikeSession,
  fifteenKilometreHike,
  fiveHundredMetreClimb,
  firstRideSession,
  twentyFiveKilometreRide,
  firstHiitSession,
  twentyIntervalRounds,
  firstSwimSession,
  oneKilometreSwim,
  hourLongYogaSession,
  hourLongPilatesSession,
}

/// How a badge's Diamond thresholds continue past Diamond I.
///
/// A tiered badge's ladder gives explicit thresholds only for the five
/// named tiers; everything above Diamond I comes from this rule, which is
/// what makes the ladder open-ended without a table of a hundred numbers.
sealed class DiamondProgression {
  const DiamondProgression();

  /// The threshold for Diamond [level] (1-based), given the Diamond I
  /// threshold as [base]. `level == 1` always returns [base] exactly.
  double thresholdForLevel({required double base, required int level});
}

/// Diamond II = base + step, Diamond III = base + 2·step, …
///
/// The right shape for count-like metrics, where "another 250 sessions"
/// stays a comprehensible ask forever and a doubling would not.
@immutable
final class ArithmeticDiamondProgression extends DiamondProgression {
  const ArithmeticDiamondProgression(this.step) : assert(step > 0, 'step > 0');

  final double step;

  @override
  double thresholdForLevel({required double base, required int level}) {
    assert(level >= 1, 'Diamond levels are 1-based.');
    return base + step * (level - 1);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ArithmeticDiamondProgression && other.step == step);

  @override
  int get hashCode => Object.hash(ArithmeticDiamondProgression, step);
}

/// Diamond II = base × factor, Diamond III = base × factor², …
///
/// The right shape for a metric that itself accumulates multiplicatively,
/// where a fixed step would be crossed again within weeks of the last one.
@immutable
final class GeometricDiamondProgression extends DiamondProgression {
  const GeometricDiamondProgression(this.factor)
    : assert(factor > 1, 'factor > 1');

  final double factor;

  @override
  double thresholdForLevel({required double base, required int level}) {
    assert(level >= 1, 'Diamond levels are 1-based.');
    // Repeated multiplication rather than `pow`, so the result is exactly
    // the same sequence of floating-point operations every time on every
    // platform (web included) — a threshold that differs in its last bit
    // between platforms would award a tier on one and not the other.
    var value = base;
    for (var i = 1; i < level; i++) {
      value *= factor;
    }
    return value;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GeometricDiamondProgression && other.factor == factor);

  @override
  int get hashCode => Object.hash(GeometricDiamondProgression, factor);
}

/// The threshold ladder of a tiered badge: five explicit named thresholds
/// plus the rule that continues them past Diamond I.
@immutable
class BadgeLadder {
  const BadgeLadder({
    required this.bronze,
    required this.silver,
    required this.gold,
    required this.platinum,
    required this.diamond,
    required this.diamondProgression,
  }) : assert(
         bronze > 0 &&
             silver > bronze &&
             gold > silver &&
             platinum > gold &&
             diamond > platinum,
         'Ladder thresholds must be strictly increasing and positive.',
       );

  /// Thresholds in the metric's canonical unit (see [BadgeMetricUnit]).
  final double bronze;
  final double silver;
  final double gold;
  final double platinum;

  /// The Diamond I threshold. Higher Diamond levels come from
  /// [diamondProgression].
  final double diamond;

  final DiamondProgression diamondProgression;

  /// The five explicitly listed thresholds, in [BadgeTier.namedTiers]
  /// order.
  List<double> get namedThresholds => [bronze, silver, gold, platinum, diamond];

  /// The metric value [tier] is reached at.
  double thresholdFor(BadgeTier tier) {
    if (!tier.isDiamond) return namedThresholds[tier.rank];
    return diamondProgression.thresholdForLevel(
      base: diamond,
      level: tier.diamondLevel,
    );
  }
}

/// One badge in the catalogue.
///
/// ## The id contract
///
/// [id] is a **stable string that is never renamed once shipped**. Awards
/// persist as `(badgeId, tierKey)` rows (`core/db/tables/badge_awards.dart`),
/// so renaming an id silently takes a badge away from everyone who had
/// earned it, and there is no migration that can put it back — the old id
/// is the only record that they earned anything at all. Retiring a badge
/// means leaving its definition in the catalogue (so earned awards still
/// resolve to a title) and, if it must stop being offered, hiding it in
/// presentation. Ids are lower_snake_case and describe the achievement,
/// not the copy, so the title can be rewritten freely.
///
/// ## The copy contract
///
/// [title] and [description] are user-facing and are written to the same
/// standard as recap and insight copy: celebration only, never obligation.
/// No badge tells them what they should do, implies they are behind, or refers
/// to body weight or appearance. A shared vocabulary test
/// (`test/features/achievements/achievements_test_vocabulary.dart`) fails
/// the build over every string here.
@immutable
class BadgeDefinition {
  /// A badge with a progression ladder.
  const BadgeDefinition.tiered({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required BadgeMetric this.metric,
    required BadgeMetricUnit this.unit,
    required BadgeLadder this.ladder,
  }) : kind = BadgeKind.tiered,
       condition = null;

  /// A badge awarded exactly once.
  const BadgeDefinition.oneOff({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required BadgeCondition this.condition,
  }) : kind = BadgeKind.oneOff,
       metric = null,
       unit = null,
       ladder = null;

  /// Stable forever — see the class doc.
  final String id;
  final String title;
  final String description;
  final BadgeKind kind;
  final BadgeCategory category;

  /// Non-null iff [kind] is [BadgeKind.tiered].
  final BadgeMetric? metric;

  /// Non-null iff [kind] is [BadgeKind.tiered].
  final BadgeMetricUnit? unit;

  /// Non-null iff [kind] is [BadgeKind.tiered].
  final BadgeLadder? ladder;

  /// Non-null iff [kind] is [BadgeKind.oneOff].
  final BadgeCondition? condition;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is BadgeDefinition && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'BadgeDefinition($id)';
}
