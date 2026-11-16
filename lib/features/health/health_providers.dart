import 'package:menfit_app/core/db/app_database_provider.dart';
import 'package:menfit_app/features/health/data/drift_health_readings_repository.dart';
import 'package:menfit_app/features/health/domain/blood_marker_reading.dart';
import 'package:menfit_app/features/health/domain/blood_pressure_reading.dart';
import 'package:menfit_app/features/health/domain/health_readings_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'health_providers.g.dart';

/// Composition surface for the `health` feature (ADR 007). Not to be
/// confused with `core/platform/health/health_providers.dart` (the watch
/// adapter); import with a prefix where both are needed.
@Riverpod(keepAlive: true)
HealthReadingsRepository healthReadingsRepository(Ref ref) =>
    DriftHealthReadingsRepository(ref.watch(appDatabaseProvider));

@riverpod
Stream<List<BloodPressureReading>> bloodPressureReadings(
  Ref ref, {
  DateTime? since,
}) => ref
    .watch(healthReadingsRepositoryProvider)
    .watchBloodPressure(
      since: since,
    );

@riverpod
Stream<List<BloodMarkerReading>> bloodMarkerReadings(
  Ref ref,
  BloodMarker marker, {
  DateTime? since,
}) => ref
    .watch(healthReadingsRepositoryProvider)
    .watchBloodMarker(marker, since: since);
