import 'package:menfit_app/core/domain/local_date.dart';

/// One calendar day's step total, as synced from the platform health source.
///
/// S2-tier data (`knowledge/engineering/security_and_privacy.md`:
/// health-platform data). [steps] never enters a log line, an analytics
/// payload, or an exception message — which is also why [toString] here
/// names the day and nothing else.
///
/// Hand-written rather than freezed (ADR 005's default) for one reason: this
/// is the shape the steps feature's data contract is specified in, and the
/// class is four fields with no unions, no JSON and no nested rebuilds — the
/// generator would produce exactly this and a `toString` that prints the
/// step count. Value equality and [copyWith] are the whole of the API, and
/// both are covered by tests. `core/platform/health/health_data_snapshot.dart`
/// is hand-written for the same reason.
class DailySteps {
  const DailySteps({
    required this.day,
    required this.steps,
    required this.syncedAt,
    this.source,
  });

  /// The user-local calendar day these steps were accrued on.
  final LocalDate day;

  /// Steps accrued on [day]. Zero is a real value — a day they did not carry
  /// their phone — and is stored as such; a day that was never synced has no
  /// [DailySteps] at all rather than a zero one.
  final int steps;

  /// The health platform's human-readable label for where the count came
  /// from (`'Health Connect'`, `'Apple Health'`, …), or null when the
  /// platform did not name one. Never a device identifier.
  final String? source;

  /// UTC instant at which this total was last read from the platform — not
  /// when the steps were taken. Today's total is re-read repeatedly while
  /// the day is still accruing.
  final DateTime syncedAt;

  /// Returns a copy with the given fields replaced.
  ///
  /// [source] follows the usual "omitted means unchanged" rule, so it cannot
  /// be cleared back to null here; construct a new [DailySteps] for that.
  /// Nothing in this feature needs to un-name a source it once knew.
  DailySteps copyWith({
    LocalDate? day,
    int? steps,
    String? source,
    DateTime? syncedAt,
  }) {
    return DailySteps(
      day: day ?? this.day,
      steps: steps ?? this.steps,
      source: source ?? this.source,
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }

  @override
  // Immutable in substance — every field is final and there are no setters.
  // `package:meta`'s @immutable is unavailable here: domain/ code stays
  // dependency-free (architecture_overview.md's layer rules), same as
  // `core/domain/local_date.dart`.
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  bool operator ==(Object other) {
    return other is DailySteps &&
        other.day == day &&
        other.steps == steps &&
        other.source == source &&
        other.syncedAt == syncedAt;
  }

  @override
  // Same reasoning as operator== above.
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  int get hashCode => Object.hash(day, steps, source, syncedAt);

  @override
  // S2: the step count is deliberately absent. `toString` is what ends up in
  // a debugger, an assertion message or a crash breadcrumb, and a health
  // value must not travel that way.
  String toString() => 'DailySteps(${day.toIso()})';
}
