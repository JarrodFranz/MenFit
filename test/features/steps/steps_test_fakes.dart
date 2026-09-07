import 'dart:async';

import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/platform/health/health_providers.dart';
import 'package:menfit_app/features/profile/profile_providers.dart';
import 'package:menfit_app/features/settings/presentation/settings_controller.dart';
import 'package:menfit_app/features/steps/steps_providers.dart';

/// In-memory [StepsRepository] that also records which windows were asked
/// for, so a test can assert what the screen requested (the Week/Month
/// switch is only observable that way).
class FakeStepsRepository implements StepsRepository {
  FakeStepsRepository([List<DailySteps> rows = const []])
    : _rows = [...rows],
      pending = false;

  /// A repository whose reads never emit, so the provider stays in
  /// `AsyncLoading`. `Stream.empty()` closes without an event, which leaves
  /// the stream provider loading forever and - unlike a delayed stream -
  /// leaves no timer pending at the end of a test.
  FakeStepsRepository.pendingReads() : _rows = [], pending = true;

  final List<DailySteps> _rows;
  final bool pending;

  /// Every `[start, end]` handed to [watchRange], in call order.
  final List<({LocalDate start, LocalDate end})> watchedRanges = [];

  List<DailySteps> _inRange(LocalDate start, LocalDate end) {
    final rows =
        _rows
            .where((row) => !row.day.isBefore(start) && !row.day.isAfter(end))
            .toList()
          ..sort((a, b) => a.day.compareTo(b.day));
    return rows;
  }

  @override
  Stream<List<DailySteps>> watchRange(LocalDate start, LocalDate end) {
    watchedRanges.add((start: start, end: end));
    if (pending) return const Stream<List<DailySteps>>.empty();
    return Stream<List<DailySteps>>.value(_inRange(start, end));
  }

  @override
  Future<List<DailySteps>> getRange(LocalDate start, LocalDate end) async =>
      _inRange(start, end);

  @override
  Future<void> upsertMany(List<DailySteps> rows) async {
    for (final row in rows) {
      _rows.removeWhere((existing) => existing.day == row.day);
      _rows.add(row);
    }
  }

  @override
  Future<void> deleteAllData() async => _rows.clear();
}

/// Records sync requests instead of touching a health platform.
class FakeStepsSync extends StepsSync {
  FakeStepsSync({this.initialState = const StepsSyncState()});

  final StepsSyncState initialState;

  final List<({int days, bool force})> recentCalls = [];
  final List<({LocalDate start, LocalDate end})> rangeCalls = [];

  @override
  StepsSyncState build() => initialState;

  @override
  Future<void> syncRecent({int days = 35, bool force = false}) async {
    recentCalls.add((days: days, force: force));
  }

  @override
  Future<void> syncRange(LocalDate start, LocalDate end) async {
    rangeCalls.add((start: start, end: end));
  }

  /// Puts the notifier into the state where the real one drops incoming
  /// `syncRange` calls, so the screen's "remember it and re-issue" path can
  /// be exercised without a real platform read.
  void beginSync() => state = state.copyWith(syncing: true);

  void endSync() => state = const StepsSyncState();
}

/// Answers the permission request without an OS prompt.
class FakeHealthSync extends HealthSync {
  FakeHealthSync({this.grant = true});

  final bool grant;
  int requestCount = 0;

  @override
  HealthSyncState build() => const HealthSyncState(
    isSupported: true,
    hasPermissions: false,
    isSyncing: false,
  );

  @override
  Future<bool> requestPermissions() async {
    requestCount++;
    return grant;
  }
}

/// The fitness-device sync toggle, without a settings repository behind it.
class FakeFitnessDeviceSyncController extends FitnessDeviceSyncController {
  FakeFitnessDeviceSyncController({this.enabled = true});

  final bool enabled;

  @override
  bool build() => enabled;

  @override
  Future<void> toggle({required bool enabled}) async {
    state = enabled;
  }
}

/// A stored day. `syncedAt` is fixed so equality in tests is stable.
DailySteps stepsRow(LocalDate day, int steps) => DailySteps(
  day: day,
  steps: steps,
  source: 'Test',
  syncedAt: DateTime.utc(2026, 9, 3, 6),
);

/// The full provider-override set the steps surfaces need, with no database
/// and no platform adapter anywhere in it.
List<Override> stepsOverrides({
  required FakeStepsRepository repository,
  required FakeStepsSync sync,
  StepsAvailability availability = StepsAvailability.available,
  int target = 7500,
  FakeHealthSync? healthSync,
  bool deviceSyncEnabled = true,
  bool permissionPending = false,
}) {
  return [
    stepsRepositoryProvider.overrideWithValue(repository),
    stepsSyncProvider.overrideWith(() => sync),
    stepsAvailabilityProvider.overrideWithValue(availability),
    stepsTargetProvider.overrideWithValue(target),
    // Always overridden, never left to the real adapter: the screen asks
    // this one whether `permissionNeeded` means "still asking" or "denied".
    // `permissionPending` hands it a future that never completes, which is
    // exactly the first-frame state the checking panel exists for.
    stepsPermissionProvider.overrideWith(
      (ref) => permissionPending
          ? Completer<bool>().future
          : Future<bool>.value(true),
    ),
    if (healthSync != null) healthSyncProvider.overrideWith(() => healthSync),
    fitnessDeviceSyncControllerProvider.overrideWith(
      () => FakeFitnessDeviceSyncController(enabled: deviceSyncEnabled),
    ),
    userProfileProvider.overrideWith((ref) => Stream.value(null)),
  ];
}
