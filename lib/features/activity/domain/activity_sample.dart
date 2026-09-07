import 'package:freezed_annotation/freezed_annotation.dart';

part 'activity_sample.freezed.dart';

/// A single GPS/HR sample belonging to a recorded `Activity` (see
/// `activity.dart`). Mirrors `core/db/tables/activity_samples.dart` one
/// field at a time; mapping to/from the Drift row happens in
/// `data/drift_activity_repository.dart`.
@freezed
abstract class ActivitySample with _$ActivitySample {
  const factory ActivitySample({
    required String id,
    required String activityId,

    /// UTC.
    required DateTime timestamp,
    required double latitude,
    required double longitude,
    double? elevationMeters,
    double? horizontalAccuracyMeters,
    int? heartRate,

    /// Whether this sample was accepted while the recording was paused
    /// (manually or automatically) — see
    /// `domain/recording_session.dart`'s `RecordedFix`. Schema v4; every
    /// sample persisted before that migration defaults to `false` (there is
    /// no pause data to backfill for pre-v4 recordings — see
    /// `domain/track_analysis.dart`'s "old data" doc note).
    @Default(false) bool isPaused,
  }) = _ActivitySample;
}
