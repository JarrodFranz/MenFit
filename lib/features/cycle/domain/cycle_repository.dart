import 'package:menfit_app/features/cycle/domain/cycle_record.dart';

/// Persistence for user-logged cycle (period) records and the
/// streak-pausing preference.
///
/// S3-tier data (`knowledge/engineering/security_and_privacy.md`): never
/// logged, never denormalised into other tables.
abstract interface class CycleRepository {
  /// Emits every non-deleted [CycleRecord], newest [CycleRecord.periodStart]
  /// first, on every change.
  Stream<List<CycleRecord>> watchRecords();

  /// One-shot fetch of every non-deleted [CycleRecord], newest
  /// [CycleRecord.periodStart] first — the snapshot [watchRecords] would
  /// emit, read exactly once.
  ///
  /// For the recap/insight aggregations that derive cycle phases from a
  /// fixed snapshot and then stop — see
  /// `features/activity/domain/activity_repository.dart#getActivities` for
  /// why those must not be written as `watchRecords().first`.
  Future<List<CycleRecord>> getRecords();

  /// Upserts [record] by id. Always stamps the persisted `updatedAt` to
  /// UTC-now, regardless of the value carried on [record]. The persisted
  /// `createdAt` is always the value of the first-ever save for that id -
  /// a later call with a different [CycleRecord.createdAt] does not move
  /// it (same convention as `features/profile/domain/profile_repository.dart`
  /// and `features/activity/domain/activity_repository.dart`).
  Future<void> saveRecord(CycleRecord record);

  /// Atomically upserts multiple [records] in a single transaction.
  Future<void> saveRecords(List<CycleRecord> records);

  /// Permanently (hard-)deletes the record with [id] - not a soft delete.
  /// See `data/drift_cycle_repository.dart`'s `deleteRecord` dartdoc for why
  /// this diverges from ADR 004's soft-delete convention for this table.
  Future<void> deleteRecord(String id);

  /// Emits whether logged period days are treated as protected recovery
  /// (`domain/streak_assembly.dart`'s protection source c), on every
  /// change.
  ///
  /// **Defaults to `false`** (S1-2, `knowledge/product/stage1_audit.md`'s
  /// accepted §5.8 resolution) until the user changes it — a change from
  /// this preference's pre-S1-2 default of `true`. Rationale: period-day
  /// protection used to be the *only* protection mechanism the streak
  /// engine had, so defaulting it on made sense; now that explicit
  /// recovery days and flare-impact protection both exist as independent,
  /// symptom-driven sources (`streak_assembly.dart`), auto-protecting every
  /// period day regardless of how the user actually feels re-introduces
  /// exactly the "cycle-phase folklore over the individual's reported
  /// state" pattern `knowledge/product/product_vision.md` rules against.
  /// It remains fully opt-in and one tap away
  /// (`features/cycle/presentation/cycle_screen.dart`'s toggle) for anyone
  /// who wants it. Existing installs that already set this preference keep
  /// their saved value — this default only applies when nothing has been
  /// persisted yet (a fresh install, or a pre-S1-2 install that never
  /// touched the toggle).
  Stream<bool> watchStreakPausingEnabled();

  /// Persists the streak-pausing preference.
  Future<void> setStreakPausingEnabled({required bool enabled});

  /// Permanently deletes every cycle record on this device (part of the
  /// "Delete my data" flow — S3 data is deleted first per
  /// security_and_privacy.md). Does not touch the streak-pausing
  /// preference; callers that want it reset too clear it separately via
  /// [clearStreakPausingPreference].
  Future<void> deleteAllData();

  /// Clears the persisted streak-pausing preference entirely (removes the
  /// key, rather than setting it to `false`) — part of the "Delete my
  /// data" flow (`features/settings/presentation/settings_screen.dart`),
  /// called alongside [deleteAllData]. This repository owns the
  /// `cycle_pause_streaks` `SharedPreferences` key (see
  /// `data/drift_cycle_repository.dart`), so it's the seam that clears it,
  /// rather than the settings screen reaching into a SharedPreferences
  /// instance directly. Removing the key (not writing `false`) matters:
  /// [watchStreakPausingEnabled]'s default-`false`-when-absent behaviour
  /// only applies to an absent key, and the B1-adjacent grandfathering
  /// seed (F4, [watchStreakPausingEnabled]'s dartdoc) re-derives from
  /// "is the key absent" too — leaving a stray persisted `false` behind
  /// would be indistinguishable from an explicit user choice and would
  /// permanently block that re-derivation for an account that starts fresh
  /// after a wipe but still has (re-imported or re-seeded) cycle records.
  Future<void> clearStreakPausingPreference();
}
