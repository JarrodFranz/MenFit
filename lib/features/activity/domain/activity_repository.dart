import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/activity/domain/activity_sample.dart';

/// Persistence for logged activities and their GPS/HR samples.
abstract interface class ActivityRepository {
  /// Emits every non-deleted activity, newest [Activity.startedAt] first,
  /// on every change.
  Stream<List<Activity>> watchActivities();

  /// One-shot fetch of every non-deleted activity, newest
  /// [Activity.startedAt] first — the snapshot [watchActivities] would
  /// emit, read exactly once.
  ///
  /// For aggregations that consume a whole-history snapshot and then stop
  /// (`features/recaps/recaps_providers.dart`,
  /// `features/insights/insights_providers.dart`), the same reasoning that
  /// gives [getSamples] a one-shot counterpart to [watchSamples].
  ///
  /// **Never express those as `watchActivities().first`.** `Stream.first`
  /// only completes its future *after* the subscription it opened has been
  /// cancelled, and cancelling a Drift query stream resolves through a
  /// future owned by the SDK's root zone — which escapes `flutter_test`'s
  /// `FakeAsync`. Inside a widget test such an await never completes while
  /// the test pumps, and the half-run provider then strands Drift's
  /// database-opening lock, hanging `AppDatabase.close()` in `tearDown`
  /// forever. Guard test:
  /// `test/features/insights/insight_observations_provider_test.dart`.
  Future<List<Activity>> getActivities();

  /// Emits the non-deleted activity with [id], or `null` if it doesn't
  /// exist (or has been deleted), on every change.
  Stream<Activity?> watchActivity(String id);

  /// One-shot fetch of the non-deleted activity with [id], or `null` if it
  /// doesn't exist (or has been deleted).
  Future<Activity?> getActivity(String id);

  /// Upserts [activity] by id. Always stamps the persisted `updatedAt` to
  /// UTC-now, regardless of the value carried on [activity]. The persisted
  /// `createdAt` is always the value of the first-ever save for that id -
  /// a later call with a different [Activity.createdAt] does not move it,
  /// so callers never need to read-before-write themselves (same
  /// convention as `features/profile/domain/profile_repository.dart`).
  Future<void> saveActivity(Activity activity);

  /// Soft-deletes the activity with [id]: sets `deletedAt`, doesn't remove
  /// the row (ADR 004 convention - unlike profile's documented hard-delete
  /// exception, activities preserve the row for sync/undo).
  Future<void> deleteActivity(String id);

  /// Batch-inserts [samples]. No-ops for an empty list.
  Future<void> insertSamples(List<ActivitySample> samples);

  /// Persists a freshly recorded [activity] together with its [samples] as
  /// a **single atomic unit** — either both land or neither does.
  ///
  /// [saveActivity] followed by [insertSamples] is not equivalent: those
  /// commit separately, so a process death in between (crash, OOM, force
  /// quit — all plausible right after a long background recording) leaves
  /// a `source: recorded` activity with an empty GPS track, permanently.
  /// The pending data lives only in controller memory, so nothing can
  /// retry it after a restart. Use this for anything coming out of the
  /// recording flow; the separate methods remain for manual entry and
  /// edits, where there is no second write to tear.
  Future<void> saveRecordedActivity(
    Activity activity,
    List<ActivitySample> samples,
  );

  /// Emits every sample belonging to [activityId], ordered by
  /// [ActivitySample.timestamp] ascending, on every change.
  Stream<List<ActivitySample>> watchSamples(String activityId);

  /// One-shot fetch of every sample belonging to [activityId], ordered by
  /// [ActivitySample.timestamp] ascending. Returns an empty list when the
  /// activity has none (or doesn't exist).
  ///
  /// For analytics scans (splits, best efforts/PRs - `domain/track_analysis.dart`,
  /// `domain/personal_records.dart`) that need a snapshot for many
  /// activities at once, where subscribing to [watchSamples] per activity
  /// would mean plumbing and disposing a stream per activity for no benefit
  /// (those scans already re-run in full on the next `watchActivities`
  /// emission).
  Future<List<ActivitySample>> getSamples(String activityId);

  /// One-shot fetch of the samples belonging to **many** activities at
  /// once, keyed by [ActivitySample.activityId]. Each entry is ordered by
  /// [ActivitySample.timestamp] ascending — byte-for-byte what [getSamples]
  /// returns for that id, just gathered without a round trip per activity.
  ///
  /// An id with no samples (a manual activity, an id that doesn't exist) is
  /// **absent** from the result rather than present with an empty list, so
  /// callers read it as `result[id] ?? const []` — the same shape
  /// `domain/personal_records.dart#computePersonalRecords` already expects
  /// of its `samplesByActivityId`. Duplicate [ids] are collapsed. An empty
  /// [ids] returns an empty map without touching storage at all.
  ///
  /// Exists for the whole-history aggregations
  /// (`features/recaps/recaps_providers.dart#recapForPeriod`) that fold
  /// every past activity's track into a records snapshot: awaiting
  /// [getSamples] once per activity put hundreds of serialised queries on
  /// the app-launch path for a user with a year of recorded runs. Callers
  /// still choose their own batch size — this is a round-trip fix, not a
  /// licence to hold every recorded activity's full sample list in memory
  /// at once (see [getSamples]' callers and `computePersonalRecords`'s
  /// memory note for why that matters).
  Future<Map<String, List<ActivitySample>>> getSamplesForActivities(
    List<String> ids,
  );

  /// Permanently (hard-)deletes every activity AND every activity sample on
  /// this device, transactionally — part of the "Delete my data" flow (see
  /// `features/settings/presentation/settings_screen.dart`). Unlike
  /// [deleteActivity], this is a hard delete even though normal single-
  /// activity deletion is soft (ADR 004): "Delete my data" must leave
  /// nothing forensically recoverable, the same reasoning
  /// every other feature's `deleteAllData` already applies. Activities carry
  /// GPS routes — location data is S3-tier
  /// (`knowledge/engineering/security_and_privacy.md`) even though this
  /// repository's day-to-day deletes are soft; the full-wipe flow doesn't
  /// get to leave that behind.
  Future<void> deleteAllData();
}
