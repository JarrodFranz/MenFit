import 'dart:async';

import 'package:drift/drift.dart';
import 'package:menfit_app/core/db/app_database.dart' as db;
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/errors/app_exception.dart';
import 'package:menfit_app/features/cycle/domain/cycle_record.dart';
import 'package:menfit_app/features/cycle/domain/cycle_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// [CycleRepository] backed by the `cycle_records` Drift table for period
/// records, and by [SharedPreferences] for the streak-pausing preference
/// (same split of concerns as `features/settings/data/settings_repository.dart`
/// - a lightweight boolean preference doesn't need its own table).
///
/// The generated Drift row class for the table is also named `CycleRecord`,
/// so this file imports `app_database.dart` with the `db` prefix throughout
/// to keep it distinct from the freezed domain entity of the same name
/// (same convention as `features/profile/data/drift_profile_repository.dart`).
///
/// The provider for this repository lives in `../cycle_providers.dart`
/// (ADR 007), not here.
///
/// S3-tier data (`knowledge/engineering/security_and_privacy.md`): no
/// period dates ever appear in a thrown [AppException]'s `message` - those
/// stay static strings, same as every other repository in this codebase.
class DriftCycleRepository implements CycleRepository {
  DriftCycleRepository(this._db, this._preferences)
    : _streakPausingEnabled = _preferences.getBool(_streakPausingKey) ?? false;

  final db.AppDatabase _db;
  final SharedPreferences _preferences;

  static const String _streakPausingKey = 'cycle_pause_streaks';

  bool _streakPausingEnabled;

  /// Broadcasts changes to the streak-pausing preference.
  /// [watchStreakPausingEnabled] seeds each new subscription with the
  /// current cached value before forwarding this stream, so it behaves
  /// like a small hand-rolled `BehaviorSubject<bool>` without adding a new
  /// package (SharedPreferences itself has no stream API to wrap). The F4
  /// grandfathering seed (below) also pushes its correction through this
  /// same controller, exactly like [setStreakPausingEnabled] does — one
  /// broadcast path for every way this preference's value can change.
  final StreamController<bool> _streakPausingController =
      StreamController<bool>.broadcast();

  /// Single-flight guard for the F4 grandfathering seed (see
  /// [watchStreakPausingEnabled]'s dartdoc) — `null` until the first call
  /// to [_ensureGrandfatheredDefault] starts it, then holds that same
  /// in-flight (or already-completed) [Future] for every subsequent
  /// caller. Without this, a burst of concurrent `watchStreakPausingEnabled()`
  /// subscriptions (e.g. several widgets rebuilding at once) could each
  /// independently query `cycle_records` and independently call
  /// `setBool`, redundantly (idempotently, but wastefully) racing each
  /// other instead of sharing one check.
  Future<void>? _grandfatherSeedFuture;

  Selectable<db.CycleRecord> _activeRecordsQuery() {
    return _db.select(_db.cycleRecords)
      ..where((t) => t.deletedAt.isNull())
      ..orderBy([(t) => OrderingTerm.desc(t.periodStartDay)]);
  }

  @override
  Stream<List<CycleRecord>> watchRecords() {
    return _activeRecordsQuery()
        .watch()
        .map((rows) => rows.map(_toEntity).toList())
        .handleError((Object error, StackTrace stackTrace) {
          // Rethrowing from an error handler replaces the stream's error
          // event with this one - a raw platform exception must never
          // cross the repository boundary (error_handling.md).
          throw StorageException(
            message: 'Failed to watch cycle records',
            cause: error,
            stackTrace: stackTrace,
          );
        });
  }

  @override
  Future<List<CycleRecord>> getRecords() async {
    try {
      final rows = await _activeRecordsQuery().get();
      return rows.map(_toEntity).toList();
    } catch (e, st) {
      throw StorageException(
        message: 'Failed to get cycle records',
        cause: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<void> saveRecord(CycleRecord record) async {
    final now = DateTime.now().toUtc();
    try {
      await _db.transaction(() async {
        // Read-then-write so `createdAt` is preserved across an update
        // regardless of what the caller passed in (same reasoning as
        // `DriftProfileRepository.saveProfile`/`DriftActivityRepository.saveActivity`).
        final existing = await (_db.select(
          _db.cycleRecords,
        )..where((t) => t.id.equals(record.id))).getSingleOrNull();
        final createdAtMillis =
            existing?.createdAt ??
            record.createdAt.toUtc().millisecondsSinceEpoch;

        await _db
            .into(_db.cycleRecords)
            .insertOnConflictUpdate(
              db.CycleRecordsCompanion.insert(
                id: record.id,
                periodStartDay: record.periodStart.toIso(),
                // Explicit Value(...) so clearing the end date back to null
                // (re-opening a period) is actually applied -
                // insertOnConflictUpdate leaves columns absent from the
                // companion untouched on the existing row.
                periodEndDay: Value(record.periodEnd?.toIso()),
                createdAt: createdAtMillis,
                updatedAt: now.millisecondsSinceEpoch,
              ),
            );
      });
    } catch (e, st) {
      throw StorageException(
        message: 'Failed to save cycle record',
        cause: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<void> saveRecords(List<CycleRecord> records) async {
    final now = DateTime.now().toUtc();
    try {
      await _db.transaction(() async {
        for (final record in records) {
          final existing = await (_db.select(
            _db.cycleRecords,
          )..where((t) => t.id.equals(record.id))).getSingleOrNull();
          final createdAtMillis =
              existing?.createdAt ??
              record.createdAt.toUtc().millisecondsSinceEpoch;

          await _db
              .into(_db.cycleRecords)
              .insertOnConflictUpdate(
                db.CycleRecordsCompanion.insert(
                  id: record.id,
                  periodStartDay: record.periodStart.toIso(),
                  periodEndDay: Value(record.periodEnd?.toIso()),
                  createdAt: createdAtMillis,
                  updatedAt: now.millisecondsSinceEpoch,
                ),
              );
        }
      });
    } catch (e, st) {
      throw StorageException(
        message: 'Failed to save cycle records in batch',
        cause: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<void> deleteRecord(String id) async {
    // soft-delete convention - see `domain/cycle_repository.dart`'s
    // dartdoc). That convention exists to support multi-device sync, which
    // this app doesn't have. For S3-tier cycle data
    // (`knowledge/engineering/security_and_privacy.md`), a "deleted" period
    // that's still forensically recoverable on-device contradicts both the
    // delete-confirmation dialog's "This can't be undone" promise
    // (`presentation/widgets/cycle_history_list.dart`) and
    // `knowledge/domain/womens_health.md`'s strongest-protection rule for
    // this data class. Revisit only alongside an actual cycle-sync E2E
    // design that needs tombstones for this table.
    try {
      await _db.transaction(() async {
        await (_db.delete(
          _db.cycleRecords,
        )..where((t) => t.id.equals(id))).go();
      });
    } catch (e, st) {
      throw StorageException(
        message: 'Failed to delete cycle record',
        cause: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<void> deleteAllData() async {
    try {
      await _db.transaction(() async {
        await _db.delete(_db.cycleRecords).go();
      });
    } catch (e, st) {
      throw StorageException(
        message: 'Failed to delete cycle data',
        cause: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<void> clearStreakPausingPreference() async {
    // `remove`, not `setBool(..., false)` — see
    // `domain/cycle_repository.dart#clearStreakPausingPreference`'s
    // dartdoc for why an absent key (not a persisted `false`) is the
    // correct post-wipe state.
    final ok = await _preferences.remove(_streakPausingKey);
    if (!ok) {
      throw const StorageException(
        message: 'Failed to clear streak-pausing preference',
      );
    }
    _streakPausingEnabled = false;
    _streakPausingController.add(false);
  }

  /// F4 (`knowledge/product/stage1_audit.md`'s "new users" scoping,
  /// accepted resolution): a pre-S1-2 install already has period-day
  /// protection baked into its habits — back then it was the *only*
  /// protection source the streak engine had (see
  /// `features/streaks/domain/streak_assembly.dart`'s dartdoc), so using
  /// the app at all was an implicit opt-in. Rather than silently
  /// re-interpreting that history as "opted out" the moment this
  /// preference's default flipped to `false` for *new* installs, this
  /// one-time seed grandfathers such an install's preference to `true` -
  /// but only when [_streakPausingKey] has genuinely never been set
  /// (never overwrites an explicit choice, `true` or `false`) AND
  /// `cycle_records` already has at least one non-deleted row at the time
  /// of the check. A genuinely new install (absent key, no records) is
  /// left alone: the key stays absent and [watchStreakPausingEnabled]'s
  /// plain `false` default continues to apply, ready to grandfather later
  /// if a record does eventually show up before this repository's next
  /// process restart.
  ///
  /// Single-flight via [_grandfatherSeedFuture] - safe to call from every
  /// [watchStreakPausingEnabled] subscription without duplicating the
  /// check or double-persisting.
  Future<void> _ensureGrandfatheredDefault() {
    return _grandfatherSeedFuture ??= _seedGrandfatheredDefault();
  }

  Future<void> _seedGrandfatheredDefault() async {
    if (_preferences.containsKey(_streakPausingKey)) return;

    final existingRecords = await _activeRecordsQuery().get();
    if (existingRecords.isEmpty) return;

    final ok = await _preferences.setBool(_streakPausingKey, true);
    // Best-effort: a failed persist here leaves the key absent, which is a
    // safe (if unlucky) fallback - `watchStreakPausingEnabled` still
    // behaves correctly (defaults `false`), and the seed will simply be
    // retried from scratch on the next process start.
    if (!ok) return;
    _streakPausingEnabled = true;
    _streakPausingController.add(true);
  }

  @override
  Stream<bool> watchStreakPausingEnabled() {
    // Deliberately NOT an `async*` generator (`yield seed; yield*
    // _streakPausingController.stream;`): an async* generator's body only
    // starts running - and only subscribes to the inner stream - on a
    // microtask *after* `.listen()` returns, so a caller that awaits
    // something (even a fast SharedPreferences write) before the next
    // event could fire `setStreakPausingEnabled` before that subscription
    // exists, silently dropping the event on this broadcast controller.
    // A plain `StreamController` subscribes to the inner stream
    // synchronously inside `onListen` - which itself runs synchronously as
    // part of the `.listen()` call - closing that race.
    //
    // The F4 grandfathering check ([_ensureGrandfatheredDefault]) is
    // deliberately NOT awaited before this synchronous initial emission,
    // for the exact same race-safety reason: it needs a real (async)
    // `cycle_records` query, and delaying the first emission behind that
    // would reopen the same "a write lands before the subscription is
    // ready" hazard this comment already guards against (a
    // `setStreakPausingEnabled` call racing the initial emission would be
    // able to land first, then get clobbered by a stale "current value"
    // emitted after it). Instead: emit the constructor-time value
    // immediately as always, subscribe to the raw stream, THEN kick off
    // the seed - if it determines a flip is warranted, it pushes that
    // correction through `_streakPausingController` exactly like
    // `setStreakPausingEnabled` does, which this subscription is already
    // listening to by the time that resolves. Every existing subscriber
    // (this one included) simply sees it as a second, later emission -
    // the same "eventual" pattern this codebase already uses for any
    // Drift-backed stream (see `streaks_providers_test.dart`'s `waitFor`).
    late final StreamController<bool> controller;
    StreamSubscription<bool>? subscription;
    controller = StreamController<bool>(
      onListen: () {
        controller.add(_streakPausingEnabled);
        subscription = _streakPausingController.stream.listen(
          controller.add,
          onError: controller.addError,
        );
        unawaited(_ensureGrandfatheredDefault());
      },
      onCancel: () => subscription?.cancel(),
    );
    return controller.stream;
  }

  @override
  Future<void> setStreakPausingEnabled({required bool enabled}) async {
    // SharedPreferences read/write methods return `false` (rather than
    // throwing) on platform-level failure - a raw `false` must not be
    // treated as silent success (see error_handling.md and
    // `features/settings/data/settings_repository.dart`).
    final ok = await _preferences.setBool(_streakPausingKey, enabled);
    if (!ok) {
      throw const StorageException(
        message: 'Failed to persist streak-pausing preference',
      );
    }
    _streakPausingEnabled = enabled;
    _streakPausingController.add(enabled);
  }

  CycleRecord _toEntity(db.CycleRecord row) {
    return CycleRecord(
      id: row.id,
      periodStart: LocalDate.parse(row.periodStartDay),
      periodEnd: row.periodEndDay == null
          ? null
          : LocalDate.parse(row.periodEndDay!),
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        row.createdAt,
        isUtc: true,
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        row.updatedAt,
        isUtc: true,
      ),
    );
  }
}
