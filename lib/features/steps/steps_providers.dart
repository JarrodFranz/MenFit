import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:menfit_app/core/db/app_database_provider.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/platform/health/health_platform_support.dart';
import 'package:menfit_app/core/platform/health/health_providers.dart';
import 'package:menfit_app/features/settings/presentation/settings_controller.dart';
import 'package:menfit_app/features/steps/data/drift_steps_repository.dart';
import 'package:menfit_app/features/steps/domain/daily_steps.dart';
import 'package:menfit_app/features/steps/domain/steps_repository.dart';
import 'package:menfit_app/features/steps/domain/steps_sync_state.dart';
import 'package:menfit_app/features/steps/domain/steps_target.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

/// Composition surface for the `steps` feature (ADR 007).
///
/// The only legal way for another feature (or the composition root's "Delete
/// my data" flow) to reach this feature: other features import this file,
/// never `data/` or `presentation/` directly. Everything this feature's own
/// presentation layer needs is re-exported here, so a single import of this
/// file is enough.
///
/// The exports sit above the `part` directive because Dart requires it
/// (`Export directives must precede part directives`).
export 'package:menfit_app/features/steps/domain/daily_steps.dart';
export 'package:menfit_app/features/steps/domain/steps_repository.dart';
export 'package:menfit_app/features/steps/domain/steps_sync_state.dart';
export 'package:menfit_app/features/steps/domain/steps_target.dart';

part 'steps_providers.g.dart';

/// Persistence for the daily step history, typed as the domain interface so
/// nothing above `data/` knows Drift is behind it.
@Riverpod(keepAlive: true)
StepsRepository stepsRepository(Ref ref) {
  final database = ref.watch(appDatabaseProvider);
  return DriftStepsRepository(database);
}

/// Every stored step total in `[start, end]` — inclusive both ends, oldest
/// first, only days that have a row — re-emitted on every change.
@riverpod
Stream<List<DailySteps>> dailyStepsRange(
  Ref ref,
  LocalDate start,
  LocalDate end,
) {
  return ref.watch(stepsRepositoryProvider).watchRange(start, end);
}

/// The daily step target the UI draws its ring and progress against.
///
/// A provider rather than a bare constant so the eventual per-user target
/// (stored alongside the other goals) is a change in one place. Today it
/// always answers [defaultDailyStepTarget]; see that constant for why the
/// number is a display default and not health advice.
@riverpod
int stepsTarget(Ref ref) => defaultDailyStepTarget;

/// Whether the health platform has granted this app read access to steps.
///
/// Its own provider, rather than an `await` inside [stepsAvailability],
/// because this is the only asynchronous part of that question and keeping
/// it separate lets availability stay a plain synchronous value the UI can
/// switch on. A throwing `hasPermissions()` answers `false`: if the app
/// cannot establish that it has been granted access to their health data, it
/// must not behave as though it has.
@riverpod
Future<bool> stepsPermission(Ref ref) async {
  final adapter = ref.watch(healthPlatformAdapterProvider);
  try {
    // `hasStepsPermission`, never `hasPermissions`: the latter is an OR
    // across steps and the two energy types, so a user who granted only
    // active energy would read as `available` here and then be shown an
    // empty chart that blames their data rather than the missing grant.
    return await adapter.hasStepsPermission();
  } on Object catch (_) {
    return false;
  }
}

/// Whether steps can be synced on this device right now, and if not, why —
/// the four cases the UI shows different, honest empty states for.
///
/// The two cheap questions are asked first and **short-circuit** the third,
/// so on web and Windows — and whenever the user's sync toggle is off —
/// [stepsPermission] is never even subscribed to and nothing touches the
/// health platform.
///
/// While [stepsPermission] is still resolving this reads
/// [StepsAvailability.permissionNeeded], and settles to
/// [StepsAvailability.available] when the platform answers. That direction
/// is deliberate: a moment of "we need permission" that resolves itself is
/// harmless, whereas defaulting to "available" would have the UI ask for
/// step data the app may have no right to.
@riverpod
StepsAvailability stepsAvailability(Ref ref) {
  if (!healthPlatformSupported) {
    return StepsAvailability.unsupportedPlatform;
  }
  // Their stated preference is checked before any permission is, so a user
  // with the toggle off is never prompted about health access they have
  // already declined at the app level.
  if (!ref.watch(fitnessDeviceSyncControllerProvider)) {
    return StepsAvailability.syncOff;
  }
  final granted = ref.watch(stepsPermissionProvider).value ?? false;
  return granted
      ? StepsAvailability.available
      : StepsAvailability.permissionNeeded;
}

/// Reads step totals from the platform health source and stores them.
///
/// `keepAlive` because [StepsSyncState.lastSyncedAt] is what the throttle in
/// [StepsSync.syncRecent] measures against — an autoDispose notifier would
/// forget it every time the steps screen popped, and the throttle would stop
/// existing.
///
/// S2 (`knowledge/engineering/security_and_privacy.md`: health-platform
/// data). Three rules hold throughout:
///
/// * **Nothing is read unless they asked for it.** Every entry point returns
///   without touching the adapter while the fitness-device sync toggle is
///   off, which is their explicit per-source permission for this app.
/// * **No step value is ever logged**, and no platform exception is either —
///   a health platform's error text can carry the values themselves.
/// * **Outcomes are honest.** A missing permission is reported as
///   [StepsSyncOutcome.noPermission], never as a failure; an absent platform
///   as [StepsSyncOutcome.unsupported]; and [StepsSyncOutcome.synced] is
///   only ever claimed for a window that was actually read.
@Riverpod(keepAlive: true)
class StepsSync extends _$StepsSync {
  /// How recently a successful sync makes [syncRecent] a no-op.
  ///
  /// An hour, because the only row that can change within one is today's
  /// (past days are settled), and re-reading a month of days to refresh one
  /// accruing number is a poor trade for the battery and for Health
  /// Connect's rate limits. `force: true` is the escape hatch for an
  /// explicit pull-to-refresh, where the user is entitled to have asked.
  static const Duration throttle = Duration(hours: 1);

  /// Time source for the throttle, for `syncedAt`, and for resolving
  /// "today".
  ///
  /// Injectable so the throttle's *expiry* is testable at all: with
  /// `DateTime.now` hard-coded, a test can only ever prove that a second
  /// sync a millisecond later is suppressed, never that an hour later it is
  /// allowed — and "the throttle never lets go" would pass that test.
  /// Same pattern as `LocalDate.today({clock})`, which this passes it to.
  @visibleForTesting
  DateTime Function() clock = DateTime.now;

  @override
  StepsSyncState build() => const StepsSyncState();

  /// Syncs the last [days] calendar days, ending with today.
  ///
  /// **A no-op if a sync succeeded less than [throttle] ago**, unless
  /// [force] is set. A *failed* attempt never blocks the next one — the
  /// throttle measures from the last success, not the last try.
  ///
  /// Today's row is written on every non-throttled call: the day is still
  /// accruing, so its stored total is always the reading as of the last
  /// sync, never a final figure.
  Future<void> syncRecent({int days = 35, bool force = false}) async {
    final lastSyncedAt = state.lastSyncedAt;
    if (!force &&
        lastSyncedAt != null &&
        clock().toUtc().difference(lastSyncedAt) < throttle) {
      return;
    }
    final span = days < 1 ? 1 : days;
    final today = LocalDate.today(clock: clock);
    await syncRange(today.addDays(-(span - 1)), today);
  }

  /// Syncs exactly `[start, end]` — inclusive both ends — with no throttle.
  ///
  /// An explicit range is always a deliberate request (a chart scrolled back
  /// past what has been synced), so it is honoured immediately. Concurrent
  /// calls are dropped rather than queued: the second one would read the
  /// same platform data the first is already reading.
  ///
  /// **[end] is clamped to today, and a window starting after today is a
  /// no-op.** Calendar windows routinely end in the future ("this week",
  /// "this month"), and the platform must never be asked about a day that
  /// has not happened - see the comment in the body.
  Future<void> syncRange(LocalDate start, LocalDate end) async {
    if (state.syncing) return;
    // Their stated preference, checked before the adapter is even read.
    if (!ref.read(fitnessDeviceSyncControllerProvider)) return;

    // Never ask the platform about a day that has not happened. Callers
    // pass calendar windows ("this week", "this month") whose end is
    // routinely in the future, and a health platform asked for a future
    // interval may answer 0 rather than refusing - which would store "they
    // took no steps" for days that have not occurred. That is the one thing
    // ADR 013 forbids outright, and clamping here is what makes it
    // impossible rather than merely unlikely.
    final today = LocalDate.today(clock: clock);
    if (start.isAfter(today)) return;
    final effectiveEnd = end.isAfter(today) ? today : end;

    state = state.copyWith(syncing: true);
    final adapter = ref.read(healthPlatformAdapterProvider);
    try {
      if (!await adapter.isSupported()) {
        _finish(StepsSyncOutcome.unsupported);
        return;
      }
      // Steps-specific: see `stepsPermissionProvider` for why the OR in
      // `hasPermissions` is the wrong question here.
      if (!await adapter.hasStepsPermission()) {
        _finish(StepsSyncOutcome.noPermission);
        return;
      }

      final totals = await adapter.getDailyStepTotals(start, effectiveEnd);
      final syncedAt = clock().toUtc();
      await ref.read(stepsRepositoryProvider).upsertMany([
        // The `total.date.isAfter(today)` filter is belt-and-braces beside
        // the clamp above: the clamp fixes what is *asked for*, this fixes
        // what is *stored*. A platform (or a future adapter) that returned
        // a day outside the requested window would otherwise put a step
        // count against a day that has not happened, and no clamp on the
        // request side can prevent that.
        for (final total in totals)
          if (!total.date.isAfter(today))
            DailySteps(
              day: total.date,
              steps: total.steps,
              source: total.source,
              syncedAt: syncedAt,
            ),
      ]);
      _finish(StepsSyncOutcome.synced, syncedAt: syncedAt);
    } on Object catch (_) {
      // Deliberately swallowed and deliberately unlogged: a background sync
      // must not take the app down, and a health platform's exception text
      // can carry the very values that must never be written anywhere.
      _finish(StepsSyncOutcome.failed);
    }
  }

  void _finish(StepsSyncOutcome outcome, {DateTime? syncedAt}) {
    state = StepsSyncState(
      lastSyncedAt: syncedAt ?? state.lastSyncedAt,
      lastOutcome: outcome,
    );
  }
}
