import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/platform/health/health_data_snapshot.dart';
import 'package:menfit_app/core/platform/health/health_platform_stub.dart'
    if (dart.library.io) 'package:menfit_app/core/platform/health/health_platform_io.dart'
    as impl;
import 'package:menfit_app/core/platform/health/health_vitals_snapshot.dart';
import 'package:menfit_app/core/platform/health/health_workout_session.dart';

/// Abstract contract for reading health and fitness data from platform APIs
/// (Google Health Connect on Android, Apple HealthKit on iOS).
abstract class HealthPlatformAdapter {
  const HealthPlatformAdapter();

  /// Creates the default platform health adapter for the current runtime.
  factory HealthPlatformAdapter.create() => impl.createDefaultHealthAdapter();

  /// Whether the platform health API is supported on the current device.
  Future<bool> isSupported();

  /// Whether **any** of the health permissions this app asks for (steps,
  /// active calories, total calories, workouts) have been granted.
  ///
  /// An OR, deliberately: the home dashboard shows steps *or* energy and is
  /// useful with either. Anything that reads specifically one of them must
  /// ask specifically — see [hasStepsPermission].
  Future<bool> hasPermissions();

  /// Whether READ access to **steps specifically** has been granted.
  ///
  /// Separate from [hasPermissions] because that one is an OR across steps
  /// and the two energy types: a user who granted only active energy would
  /// pass it, and the step history would then show an empty chart while the
  /// app behaved as though their data were simply missing. Every steps-only
  /// read gates on this instead.
  ///
  /// **iOS can never answer this truthfully.** HealthKit deliberately does
  /// not disclose read authorization (doing so would leak whether the user
  /// has data), so the platform returns "unknown" for every read permission
  /// query, forever, even after the user has granted it. Implementations
  /// must document how they resolve that; see `health_platform_io.dart`.
  Future<bool> hasStepsPermission();

  /// Whether READ access to **completed workouts** has been granted — every
  /// type a workout read needs, not just the session record itself (on
  /// Android the plugin also reads distance per session, and a missing
  /// distance grant empties the whole read).
  ///
  /// Separate from [hasPermissions] for the same reason as
  /// [hasStepsPermission]: a user who granted steps before workout import
  /// existed passes the OR while every workout read silently returns nothing.
  /// `null` means authorization is undisclosed (iOS). An explicit sync must
  /// request authorization before reading; a background sync may attempt a
  /// read without prompting, with the OS enforcing any denial.
  Future<bool?> hasWorkoutPermission();

  /// Requests authorization from the user to read steps, energy and
  /// workouts. Types already granted are not asked for again.
  Future<bool> requestPermissions();

  /// Fetches the health data snapshot (steps, active calories) for [date].
  Future<HealthDataSnapshot?> getSnapshotForDate(LocalDate date);

  /// Fetches one step total per calendar day across `[start, end]` —
  /// **inclusive on both ends** — oldest first.
  ///
  /// Days the platform cannot answer for are **omitted**, not reported as
  /// zero: a day with no data and a day with no steps are different
  /// statements. Returns an empty list — never throws — when the platform is
  /// unsupported, permission is missing, or [start] is after [end]; callers
  /// distinguish those cases with [isSupported]/[hasPermissions] first.
  ///
  /// Implementations must not run the per-day reads concurrently. These are
  /// platform-channel calls into Health Connect / HealthKit, and firing a
  /// month of them at once buys nothing while making the failure mode
  /// (throttling, an OOM in the Health Connect process) much harder to
  /// reason about. Sequential awaits are the contract.
  Future<List<DailyStepTotal>> getDailyStepTotals(
    LocalDate start,
    LocalDate end,
  );

  /// Fetches completed workouts recorded by external wearables or fitness apps
  /// within `[start, end]` (inclusive).
  Future<List<HealthWorkoutSession>> getCompletedWorkouts({
    required DateTime start,
    required DateTime end,
  });

  /// Whether READ access to any watch vitals type has been granted.
  ///
  /// `null` = cannot be determined: iOS never reveals read authorisation
  /// (see [hasStepsPermission]), so callers attempt [getVitals] and treat an
  /// empty snapshot as "maybe not granted". False where no health platform
  /// exists (web, desktop).
  Future<bool?> hasVitalsPermission();

  /// Requests READ for the vitals types only — heart rate, resting heart
  /// rate, blood oxygen, respiratory rate, sleep and HRV (RMSSD on Android,
  /// SDNN on iOS) — in one platform sheet. Separate from
  /// [requestPermissions], which is unchanged. False on failure/unsupported.
  Future<bool> requestVitalsPermissions();

  /// Latest values in the 24 h before [now] (resting HR / HRV: 48 h; sleep:
  /// most recent session ending in the last 24 h). Null when unsupported.
  /// Never throws; a metric that cannot be read is null. Never persisted.
  Future<HealthVitalsSnapshot?> getVitals({required DateTime now});
}
