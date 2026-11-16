import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/platform/health/health_data_snapshot.dart';
import 'package:menfit_app/core/platform/health/health_platform_adapter.dart';
import 'package:menfit_app/core/platform/health/health_workout_session.dart';

/// A [HealthPlatformAdapter] test double with no platform behind it.
///
/// Records how many times each call was made, so a test can assert that a
/// throttled or gated sync genuinely did not reach the platform — "nothing
/// was written" alone would also pass if the read happened and the write
/// silently failed.
class FakeHealthPlatformAdapter implements HealthPlatformAdapter {
  FakeHealthPlatformAdapter({
    this.supported = true,
    this.stepsPermissionGranted = true,
    this.energyPermissionGranted = false,
    this.stepsPerDay = 8000,
    this.sourceLabel = 'Health Connect',
    this.throwOnRange = false,
    this.throwOnPermissions = false,
    this.workoutsToReturn = const [],
    this.workoutPermissionGranted = true,
  });

  /// The energy-only grant, which is the case the split exists for: the
  /// real adapter's `hasPermissions` is an OR, so this configuration passes
  /// it while `hasStepsPermission` correctly refuses.
  factory FakeHealthPlatformAdapter.energyOnly() => FakeHealthPlatformAdapter(
    stepsPermissionGranted: false,
    energyPermissionGranted: true,
  );

  bool supported;

  /// READ access to steps specifically.
  bool stepsPermissionGranted;

  /// READ access to one of the energy types, and nothing else.
  bool energyPermissionGranted;

  /// READ access to workouts (exercise + distance on Android).
  bool? workoutPermissionGranted;

  /// When set, [requestPermissions] leaves workout access denied — the
  /// user dismissed or refused the platform sheet.
  bool denyWorkoutOnRequest = false;

  /// Whether the platform authorization flow itself completes successfully.
  bool permissionRequestSucceeds = true;

  int requestPermissionsCallCount = 0;

  /// Steps reported for every day in a requested window.
  int stepsPerDay;
  String? sourceLabel;

  /// When set, [getDailyStepTotals] throws — the "platform blew up" path.
  bool throwOnRange;

  /// When set, [hasPermissions] throws.
  bool throwOnPermissions;

  /// Extra totals appended to whatever the requested window produces, so a
  /// test can simulate a platform answering outside the window it was asked
  /// about.
  List<DailyStepTotal> extraTotals = const [];

  int rangeCallCount = 0;

  /// Counts calls to **either** permission query, so a test can assert that
  /// a gated path did not touch the platform at all.
  int permissionCallCount = 0;
  int stepsPermissionCallCount = 0;
  final List<(LocalDate, LocalDate)> requestedWindows = [];

  @override
  Future<bool> isSupported() async => supported;

  @override
  Future<bool> hasPermissions() async {
    permissionCallCount++;
    if (throwOnPermissions) throw StateError('platform unavailable');
    // The OR the real adapter performs, reproduced faithfully - it is what
    // makes the energy-only case pass here and fail `hasStepsPermission`.
    return stepsPermissionGranted || energyPermissionGranted;
  }

  @override
  Future<bool> hasStepsPermission() async {
    permissionCallCount++;
    stepsPermissionCallCount++;
    if (throwOnPermissions) throw StateError('platform unavailable');
    return stepsPermissionGranted;
  }

  @override
  Future<bool?> hasWorkoutPermission() async => workoutPermissionGranted;

  @override
  Future<bool> requestPermissions() async {
    requestPermissionsCallCount++;
    if (!permissionRequestSucceeds) return false;
    if (!denyWorkoutOnRequest && workoutPermissionGranted != null) {
      workoutPermissionGranted = true;
    }
    stepsPermissionGranted = true;
    energyPermissionGranted = true;
    return true;
  }

  @override
  Future<HealthDataSnapshot?> getSnapshotForDate(LocalDate date) async {
    if (!stepsPermissionGranted && !energyPermissionGranted) return null;
    return HealthDataSnapshot(
      date: date,
      steps: stepsPerDay,
      lastSyncedAt: DateTime.utc(2026, 9, 3),
      source: sourceLabel ?? 'Fitness Tracker',
    );
  }

  @override
  Future<List<DailyStepTotal>> getDailyStepTotals(
    LocalDate start,
    LocalDate end,
  ) async {
    rangeCallCount++;
    requestedWindows.add((start, end));
    if (throwOnRange) throw StateError('platform read failed');
    if (!stepsPermissionGranted) return const [];
    if (start.compareTo(end) > 0) return const [];

    final totals = <DailyStepTotal>[];
    var day = start;
    while (day.compareTo(end) <= 0) {
      totals.add(
        DailyStepTotal(date: day, steps: stepsPerDay, source: sourceLabel),
      );
      day = day.addDays(1);
    }
    return [...totals, ...extraTotals];
  }

  List<HealthWorkoutSession> workoutsToReturn;
  int workoutReadCallCount = 0;

  @override
  Future<List<HealthWorkoutSession>> getCompletedWorkouts({
    required DateTime start,
    required DateTime end,
  }) async {
    workoutReadCallCount++;
    return workoutsToReturn;
  }
}
