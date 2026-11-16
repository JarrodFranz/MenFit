import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/platform/health/health_data_snapshot.dart';
import 'package:menfit_app/core/platform/health/health_platform_adapter.dart';
import 'package:menfit_app/core/platform/health/health_vitals_snapshot.dart';
import 'package:menfit_app/core/platform/health/health_workout_session.dart';

HealthPlatformAdapter createDefaultHealthAdapter() =>
    const StubHealthPlatformAdapter();

/// Fallback stub for environments where Health Connect / HealthKit is not
/// available (e.g. Web, Windows Desktop, headless unit tests).
class StubHealthPlatformAdapter implements HealthPlatformAdapter {
  const StubHealthPlatformAdapter();

  @override
  Future<bool> isSupported() async => false;

  @override
  Future<bool> hasPermissions() async => false;

  @override
  Future<bool> hasStepsPermission() async => false;

  @override
  Future<bool> hasWorkoutPermission() async => false;

  @override
  Future<bool> requestPermissions() async => false;

  @override
  Future<HealthDataSnapshot?> getSnapshotForDate(LocalDate date) async => null;

  @override
  Future<List<DailyStepTotal>> getDailyStepTotals(
    LocalDate start,
    LocalDate end,
  ) async => const [];

  @override
  Future<List<HealthWorkoutSession>> getCompletedWorkouts({
    required DateTime start,
    required DateTime end,
  }) async => const [];

  @override
  Future<bool?> hasVitalsPermission() async => false;

  @override
  Future<bool> requestVitalsPermissions() async => false;

  @override
  Future<HealthVitalsSnapshot?> getVitals({required DateTime now}) async =>
      null;
}
