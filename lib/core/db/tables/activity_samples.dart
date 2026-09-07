import 'package:drift/drift.dart';
import 'package:menfit_app/core/db/tables/activities.dart';

/// A single GPS/HR sample belonging to a recorded [Activities] row (wave
/// C3 adds recording; manually-logged activities have no samples). Raw
/// samples are kept — not downsampled — so splits/PRs can be recomputed
/// later; see `knowledge/architecture/data_architecture.md`'s "GPS tracks"
/// section.
@TableIndex(
  name: 'idx_activity_samples_activity_id_timestamp_ms',
  columns: {#activityId, #timestampMs},
)
class ActivitySamples extends Table {
  /// Client-generated UUIDv7.
  TextColumn get id => text()();

  TextColumn get activityId => text().references(Activities, #id)();

  /// UTC milliseconds since epoch.
  IntColumn get timestampMs => integer()();

  RealColumn get latitude => real()();

  RealColumn get longitude => real()();

  RealColumn get elevationMeters => real().nullable()();

  RealColumn get horizontalAccuracyMeters => real().nullable()();

  IntColumn get heartRate => integer().nullable()();

  /// Whether this sample was accepted while the recording was paused
  /// (manually or automatically) — see
  /// `features/activity/domain/recording_session.dart`'s `RecordedFix`.
  /// Added in schema v4; every sample persisted before that migration has
  /// this default (`false`), which is the correct value for pre-v4 data —
  /// wave C3/D recordings predate pause-aware sample tagging entirely, so
  /// there is nothing to backfill (see `domain/track_analysis.dart`'s "old
  /// data" doc note).
  BoolColumn get isPaused => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
