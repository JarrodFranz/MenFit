import 'package:menfit_app/features/health/domain/blood_marker_reading.dart';
import 'package:menfit_app/features/health/domain/blood_pressure_reading.dart';

/// Local-first S3 storage; deletion removes the row permanently.
abstract interface class HealthReadingsRepository {
  /// Newest measured instant first, then creation instant and id descending.
  /// [since] keeps readings measured at or after it; null keeps all.
  Stream<List<BloodPressureReading>> watchBloodPressure({DateTime? since});

  /// Upserts by id while preserving the original creation timestamp.
  Future<void> saveBloodPressure(BloodPressureReading reading);

  Future<void> deleteBloodPressure(String id);

  /// Same ordering and [since] rule as [watchBloodPressure], one [marker].
  Stream<List<BloodMarkerReading>> watchBloodMarker(
    BloodMarker marker, {
    DateTime? since,
  });

  /// Upserts by id while preserving the original creation timestamp.
  Future<void> saveBloodMarker(BloodMarkerReading reading);

  Future<void> deleteBloodMarker(String id);

  /// Empties both blood-pressure and blood-marker tables.
  Future<void> deleteAllData();
}
