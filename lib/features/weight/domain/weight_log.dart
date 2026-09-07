import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:menfit_app/core/domain/local_date.dart';

part 'weight_log.freezed.dart';

/// Where a [WeightLog] came from.
///
/// A closed vocabulary persisted as the storage keys below (see
/// `core/db/tables/weight_logs.dart`'s `source` column). It exists so the
/// history can be honest about provenance — a value the user typed, a
/// value carried over from their profile at migration time, and (later) a
/// value a health platform supplied are not the same claim.
enum WeightLogSource {
  /// The user entered this weight themselves — including via the profile's
  /// weight field, which writes through to a log.
  manual,

  /// Seeded by the schema v18 migration from the single `weight_kg` the
  /// profile already held, so an upgrading install starts with a history
  /// rather than nothing. At most one such row exists per install.
  profileMigration,

  /// Imported from a connected health platform. Nothing writes this yet —
  /// reserved so the vocabulary doesn't have to change when Health
  /// Connect/HealthKit sync arrives (TASKS_TO_DO.md task 6.1).
  healthSync;

  /// Decodes the persisted storage key.
  ///
  /// An unrecognised key falls back to [manual] rather than throwing or
  /// dropping the row: a reading the app can't classify is still a real
  /// weigh-in the user is entitled to see, and provenance is metadata, not
  /// the measurement. (Same "never lose the user's data over a vocabulary
  /// mismatch" instinct as `SymptomType`'s catch-all.)
  static WeightLogSource fromStorage(String? value) => switch (value) {
    'manual' => WeightLogSource.manual,
    'profile-migration' => WeightLogSource.profileMigration,
    'health-sync' => WeightLogSource.healthSync,
    _ => WeightLogSource.manual,
  };

  /// The persisted storage key. Hyphenated for the multi-word values, and
  /// stable — changing one is a migration, not an edit.
  String toStorage() => switch (this) {
    WeightLogSource.manual => 'manual',
    WeightLogSource.profileMigration => 'profile-migration',
    WeightLogSource.healthSync => 'health-sync',
  };
}

/// A single body-weight measurement recorded on a calendar day.
///
/// Mirrors `core/db/tables/weight_logs.dart` one field at a time; mapping
/// to/from the Drift row happens in `data/drift_weight_repository.dart` so
/// the Drift type never leaks above the data layer (coding_standards.md).
///
/// [day] is a [LocalDate] (a user-local calendar day), never a [DateTime]
/// instant — see `core/domain/local_date.dart`. [weightKg] is canonical
/// metric; presentation converts for imperial users
/// (`core/domain/units.dart`).
///
/// **Several logs may share a [day]** — see
/// `core/db/tables/weight_logs.dart` for why, and
/// `domain/weight_repository.dart` for the ordering that makes "the
/// latest reading of a day" well defined.
///
/// S2-tier data (`knowledge/engineering/security_and_privacy.md`):
/// [weightKg] and [notes] never enter logs, analytics, or exception
/// messages. Anything built on top of this entity is also ED-sensitive
/// territory — `knowledge/domain/mens_health.md` gates the copy: report
/// what was measured, never judge it, and never imply a target.
@freezed
abstract class WeightLog with _$WeightLog {
  const factory WeightLog({
    required String id,
    required LocalDate day,

    /// Canonical metric (kilograms).
    required double weightKg,

    /// UTC.
    required DateTime createdAt,

    /// UTC.
    required DateTime updatedAt,

    /// Free-text note. `null` when the user attached none — never an
    /// empty string standing in for absence.
    String? notes,

    /// Provenance. Defaults to [WeightLogSource.manual], which is what a
    /// value the user typed is.
    @Default(WeightLogSource.manual) WeightLogSource source,
  }) = _WeightLog;
}
