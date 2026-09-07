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
/// (`domain/recap_period.dart`) — part of the recap's "top 3 PRs"
/// (`TASKS_TO_DO.md` Task 1.3).
class RecapPrHighlight {
  const RecapPrHighlight({
    required this.type,
    required this.label,
    required this.valueLabel,
    required this.achievedAt,
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
          achievedAt == other.achievedAt;

  @override
  // Same reasoning as operator== above.
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  int get hashCode => Object.hash(type, label, valueLabel, achievedAt);

  /// Deliberately opaque: type only, never [achievedAt], [label] or
  /// [valueLabel].
  ///
  /// A highlight carries the exact instant and value of a workout (S2 -
  /// `knowledge/engineering/security_and_privacy.md`). This object is
  /// reachable from a `MonthRecap` held as a Riverpod provider value, and
  /// provider errors interpolate their value into a description that
  /// `app/bootstrap.dart`'s error hooks pass to `developer.log`. Same
  /// reasoning as `features/insights/domain/personal_insight.dart`, which
  /// omits `toString()` entirely for the same class of data.
  @override
  String toString() => 'RecapPrHighlight(${type.name})';
}
