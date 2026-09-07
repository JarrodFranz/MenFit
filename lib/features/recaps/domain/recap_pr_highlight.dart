import 'package:menfit_app/features/cycle/domain/cycle_prediction_engine.dart';

/// The kind of personal record a [RecapPrHighlight] celebrates.
enum RecapPrType {
  /// Fastest time over a standard effort distance (e.g. 5 km).
  bestEffort,

  /// New all-time longest single-activity distance.
  longestDistance,

  /// New all-time highest single-activity elevation gain.
  mostElevation,

  /// New heaviest completed set for a named strength exercise.
  strengthWeight,
}

/// One personal record set **during** a `RecapPeriod`
/// (`domain/recap_period.dart`), with the menstrual cycle phase it was set
/// in, when known — the recap's "top 3 PRs with phase context"
/// (`TASKS_TO_DO.md` Task 1.3, e.g. *"You set your 5k PR during your
/// Follicular phase"*).
///
/// [phase] is deliberately nullable rather than defaulting to
/// [CyclePhase.none]: the exported share card's phase pill is opt-in
/// (mirrors Wave 2's `WorkoutShareDialog` phase toggle), and "no phase
/// known" must stay distinguishable from "phase is None" for that toggle
/// to have anything meaningful to hide.
class RecapPrHighlight {
  const RecapPrHighlight({
    required this.type,
    required this.label,
    required this.valueLabel,
    required this.achievedAt,
    this.phase,
  });

  final RecapPrType type;

  /// What the record is of (e.g. "5 km best effort", "Longest distance",
  /// "Highest climb", "Barbell Squat").
  final String label;

  /// The record's formatted value (e.g. "24:12", "12.40 km", "620 m",
  /// "65.0 kg").
  final String valueLabel;

  /// UTC — the activity's `startedAt`.
  final DateTime achievedAt;

  /// The cycle phase this was set in, or `null` when no cycle data covers
  /// that day.
  final CyclePhase? phase;

  /// The phase worth *showing*, or `null` when there is none.
  ///
  /// Collapses [CyclePhase.none] into `null`. `none` is
  /// `CyclePredictionEngine.getDayStatus`'s "no phase known for this day",
  /// not a fifth phase, and rendering it produces the meaningless "None
  /// phase". `recaps_providers.dart` already keeps `none` days out of the
  /// phase map it hands [phase] from; this getter is the defence in depth
  /// that keeps any other producer from putting "None phase" on a slide,
  /// a share card, or shared text.
  ///
  /// Every presentation surface reads this, never [phase] directly.
  CyclePhase? get displayPhase => phase == CyclePhase.none ? null : phase;

  @override
  // Immutable in substance (every field final, no setters) but not
  // `@immutable`-annotated - same `domain/` dependency-free reasoning as
  // `core/domain/local_date.dart`'s identical suppression.
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecapPrHighlight &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          label == other.label &&
          valueLabel == other.valueLabel &&
          achievedAt == other.achievedAt &&
          phase == other.phase;

  @override
  // Same reasoning as operator== above.
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  int get hashCode => Object.hash(type, label, valueLabel, achievedAt, phase);

  /// Deliberately opaque: type only, never [phase], [achievedAt], [label]
  /// or [valueLabel].
  ///
  /// A highlight carries the cycle phase a record was set in — S3 data
  /// under `knowledge/engineering/security_and_privacy.md`, which forbids
  /// it from reaching logs or crash reports — alongside the exact instant
  /// and value of a workout (S2). This object is reachable from a
  /// `CycleRecap` held as a Riverpod provider value, and provider errors
  /// interpolate their value into a description that
  /// `app/bootstrap.dart`'s error hooks pass to `developer.log`. Same
  /// reasoning as `features/insights/domain/personal_insight.dart`, which
  /// omits `toString()` entirely for the same class of data.
  @override
  String toString() => 'RecapPrHighlight(${type.name})';
}
