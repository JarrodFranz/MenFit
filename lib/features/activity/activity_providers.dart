import 'dart:async';

import 'package:flutter_riverpod/misc.dart';
import 'package:menfit_app/core/config/shared_preferences_provider.dart';
import 'package:menfit_app/core/db/app_database_provider.dart';
import 'package:menfit_app/core/domain/units.dart';
import 'package:menfit_app/features/activity/data/drift_activity_repository.dart';
import 'package:menfit_app/features/activity/data/drift_strength_routine_repository.dart';
import 'package:menfit_app/features/activity/data/drift_yoga_sequence_repository.dart';
import 'package:menfit_app/features/activity/data/screen_awake_preference_store.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/activity/domain/activity_repository.dart';
import 'package:menfit_app/features/activity/domain/activity_sample.dart';
import 'package:menfit_app/features/activity/domain/personal_records.dart';
import 'package:menfit_app/features/activity/domain/strength_routine.dart';
import 'package:menfit_app/features/activity/domain/strength_routine_repository.dart';
import 'package:menfit_app/features/activity/domain/yoga_sequence.dart';
import 'package:menfit_app/features/activity/domain/yoga_sequence_repository.dart';
import 'package:menfit_app/features/profile/profile_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'activity_providers.g.dart';

/// Composition surface for the `activity` feature (ADR 007).
///
/// The only legal way for another feature (or the composition root) to
/// reach this feature's persistence: other features may import this file,
/// never `data/` or `presentation/` directly.
@Riverpod(keepAlive: true)
ActivityRepository activityRepository(Ref ref) {
  final database = ref.watch(appDatabaseProvider);
  return DriftActivityRepository(database);
}

/// Watches every non-deleted activity, newest first.
@riverpod
Stream<List<Activity>> activities(Ref ref) {
  final repository = ref.watch(activityRepositoryProvider);
  return repository.watchActivities();
}

@Riverpod(keepAlive: true)
StrengthRoutineRepository strengthRoutineRepository(Ref ref) {
  final database = ref.watch(appDatabaseProvider);
  return DriftStrengthRoutineRepository(database);
}

@riverpod
Stream<List<StrengthCycle>> strengthCycles(Ref ref) {
  final repository = ref.watch(strengthRoutineRepositoryProvider);
  return repository.watchCycles();
}

@riverpod
Stream<List<StrengthDayRoutine>> strengthRoutines(Ref ref) {
  final repository = ref.watch(strengthRoutineRepositoryProvider);
  return repository.watchRoutines();
}

/// The active training cycle, live.
///
/// A stream over [StrengthRoutineRepository.watchCycles] rather than a
/// one-shot `getActiveCycle()`: as a Future this provider was never
/// invalidated after `setActiveCycle`, so "Set Active" wrote to the database
/// and neither the launcher sheet nor the Strength Hub ever showed it
/// (found on device 2026-09-02).
@riverpod
Stream<StrengthCycle?> activeStrengthCycle(Ref ref) {
  final repository = ref.watch(strengthRoutineRepositoryProvider);
  return repository.watchCycles().map(
    (cycles) => cycles.where((cycle) => cycle.isActive).firstOrNull,
  );
}

@Riverpod(keepAlive: true)
YogaSequenceRepository yogaSequenceRepository(Ref ref) {
  final database = ref.watch(appDatabaseProvider);
  return DriftYogaSequenceRepository(database);
}

/// Every saved yoga sequence, most recently updated first.
///
/// Stored rows only. `YogaSequenceStarters.starters` is a domain constant
/// and is deliberately **not** merged in here - an empty list means she has
/// saved nothing, and the UI offers a starter separately, saving
/// `starter.copyAsNew()` if she takes it.
@riverpod
Stream<List<YogaSequence>> yogaSequences(Ref ref) {
  final repository = ref.watch(yogaSequenceRepositoryProvider);
  return repository.watchSequences();
}

/// One saved sequence, live.
///
/// Derived from `watchSequences()` rather than a one-shot `getSequence` so
/// an editor or runner watching it sees an edit land - the same reason
/// `activeStrengthCycle` is a stream (see its doc for what a Future cost us
/// there).
@riverpod
Stream<YogaSequence?> yogaSequence(Ref ref, String id) {
  final repository = ref.watch(yogaSequenceRepositoryProvider);
  return repository.watchSequences().map(
    (sequences) => sequences.where((s) => s.id == id).firstOrNull,
  );
}

/// Remembers, per activity type, whether a running session holds the
/// screen on.
///
/// **Known departure from ADR 007**, recorded rather than quietly left, and
/// the same one `nutrition_providers.dart`'s `onlineLookupNoticeStore`
/// documents: the other providers on this surface are typed as `domain/`
/// interfaces, and this one is typed as the concrete `data/` class. It is a
/// handful of device booleans with no second implementation in prospect,
/// and a port for them would be ceremony.
///
/// Degrades to a store with no backing when `sharedPreferencesProvider` was
/// never overridden, the same way `accessibilityRepositoryProvider` does:
/// every tracker reaches this on start, so a widget test that pumps one
/// without wiring preferences would otherwise die on that provider's
/// deliberate `UnimplementedError`. Unreachable in the app — `bootstrap.dart`
/// always overrides it before `runApp`.
///
/// **Only that one case degrades.** Riverpod 3 wraps an error thrown by a
/// dependency in a `ProviderException` before `ref.watch` rethrows it, so
/// `on UnimplementedError` would catch nothing here and `on Object` would
/// swallow every real failure as a silently preference-less app. Unwrap,
/// check, and rethrow anything else.
@Riverpod(keepAlive: true)
ScreenAwakePreferenceStore screenAwakePreferenceStore(Ref ref) {
  try {
    return ScreenAwakePreferenceStore(ref.watch(sharedPreferencesProvider));
  } on ProviderException catch (error) {
    if (error.exception is! UnimplementedError) rethrow;
    return const ScreenAwakePreferenceStore(null);
  }
}

/// Whether [type]'s tracker should keep the screen awake — the value the
/// hub switch renders and the trackers obey.
///
/// `keepAlive` because a tracker holds onto this for the whole of a
/// session, and that outlives the hub screen the switch lives on: an
/// autoDispose family would drop the listener the moment she left the hub,
/// which is exactly when a running workout still needs to hear about a
/// change.
@Riverpod(keepAlive: true)
class ScreenAwakePreference extends _$ScreenAwakePreference {
  @override
  bool build(ActivityType type) {
    return ref.watch(screenAwakePreferenceStoreProvider).isEnabled(type);
  }

  /// Applies [enabled] optimistically, then persists it.
  ///
  /// The switch has to move under her finger, so state goes first; a failed
  /// write puts it back and rethrows, so the caller can say why rather than
  /// leaving a switch that looks set and is not.
  Future<void> set({required bool enabled}) async {
    final previous = state;
    if (previous == enabled) return;
    state = enabled;
    try {
      await ref
          .read(screenAwakePreferenceStoreProvider)
          .setEnabled(type, enabled: enabled);
    } on Object {
      state = previous;
      rethrow;
    }
  }
}

/// The current user's preferred unit system, for converting activity (and,
/// via this same composition-surface provider, progress) stats at the
/// presentation boundary. Reads through `profile`'s composition surface
/// (`profile_providers.dart`) - legal per ADR 007 since it's that feature's
/// public provider, not its `data/`/`presentation/`. Defaults to
/// [UnitSystem.metric] until a profile exists (mirrors
/// `OnboardingController`'s default).
///
/// Promoted here from `activity/presentation/activity_list_controller.dart`
/// (F8, review-recommended): this is a composition-surface concern, not
/// screen-specific state, and living here is what let `progress_providers.dart`
/// consume it directly instead of maintaining its own byte-for-byte
/// duplicate (`progressUnitSystemProvider`, now deleted) - ADR 007 only
/// blocked that reuse while this provider lived in `activity`'s
/// `presentation/`, never its `domain/`/composition surface.
@riverpod
Stream<UnitSystem> activityUnitSystem(Ref ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return repository.watchProfile().map(
    (profile) => profile?.unitSystem ?? UnitSystem.metric,
  );
}

/// Recomputes [PersonalRecords] (`domain/personal_records.dart`) every time
/// the activity list changes.
///
/// ## Fold, don't batch (F7)
/// On each `watchActivities()` emission, this fetches (via one-shot
/// [ActivityRepository.getSamples], not a per-activity stream subscription)
/// one `recorded` activity's samples at a time and immediately folds them
/// into a running [PersonalRecords] via
/// [foldActivityIntoRecords] - unlike `computePersonalRecords`'s batch
/// form, this never holds more than one activity's sample list in memory
/// at once (the previous activity's samples become unreachable, and
/// GC-eligible, the moment the loop moves on).
///
/// ## Stale-drop (F7)
/// A rescan is a chain of awaits (one `getSamples` per recorded activity),
/// so a burst of rapid `watchActivities()` emissions (e.g. several
/// activities saved in quick succession) can leave more than one rescan
/// in flight at once. Each rescan is tagged with the epoch it started at;
/// `latestEpoch` is bumped synchronously the moment a new emission
/// arrives (*not* when its rescan happens to finish), and a rescan checks
/// its own epoch against it both before starting the next activity's fetch
/// and again right after that fetch resolves - if it's been superseded
/// either time, it abandons silently (adds nothing to `controller`)
/// rather than letting a slow, now-stale rescan's result overwrite a
/// faster, newer one that already landed. This is what keeps the two
/// `getSamples` await points genuinely cheap to abandon at, rather than
/// discovering staleness only once a full rescan has already finished.
///
/// ## The offstage-IndexedStack reality (F7)
/// This provider has no `keepAlive: true` of its own, but that doesn't
/// mean it's cheaply disposed in practice: `app/router` keeps every shell
/// branch's navigator (Home, Activity, Progress, ...) mounted offstage
/// inside an `IndexedStack` rather than tearing it down on tab switch (see
/// `flutter_patterns.md`), so a screen that watches this provider keeps it
/// alive - and rescanning on every activity change - for as long as the
/// app runs, even while its tab is offstage and nothing is visibly
/// listening. The stale-drop above bounds the *cost* of that (an offstage
/// rescan still gets abandoned the instant a newer one supersedes it), but
/// it doesn't stop the rescans from happening at all. A real fix (e.g. a
/// shared activities stream, or genuinely disposing offstage branches) is
/// tracked in `knowledge/product/deferred.md`'s "Offstage IndexedStack
/// keeps Progress providers live" and "Shared activities stream" entries -
/// this wave only closes the "wasted work while superseded" half of that
/// gap, not the "runs at all while offstage" half.
///
/// Exposed here (rather than in a wave-2 `progress` feature) per ADR 007:
/// this feature owns the data the computation is derived from, and another
/// feature may only reach it through this composition surface.
@riverpod
Stream<PersonalRecords> personalRecords(Ref ref) {
  final repository = ref.watch(activityRepositoryProvider);
  final controller = StreamController<PersonalRecords>();
  var latestEpoch = 0;

  Future<void> rescan(List<Activity> activities, int epoch) async {
    var result = const PersonalRecords(bestEfforts: {});
    for (final activity in activities) {
      if (epoch != latestEpoch) return; // Superseded - abandon before the
      // next await rather than finishing a rescan nobody wants anymore.
      final samples = activity.source == ActivitySource.recorded
          ? await repository.getSamples(activity.id)
          : const <ActivitySample>[];
      if (epoch != latestEpoch) return; // Superseded while awaiting.
      result = foldActivityIntoRecords(
        current: result,
        activity: activity,
        samples: samples,
      );
    }
    if (epoch == latestEpoch && !controller.isClosed) {
      controller.add(result);
    }
  }

  final subscription = repository.watchActivities().listen(
    (activities) {
      final epoch = ++latestEpoch;
      unawaited(rescan(activities, epoch));
    },
    onError: controller.addError,
    onDone: controller.close,
  );

  ref.onDispose(() {
    unawaited(subscription.cancel());
    if (!controller.isClosed) unawaited(controller.close());
  });

  return controller.stream;
}
