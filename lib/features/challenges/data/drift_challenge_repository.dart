import 'package:drift/drift.dart';
import 'package:menfit_app/core/db/app_database.dart' as db;
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/errors/app_exception.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/challenges/domain/challenge.dart';
import 'package:menfit_app/features/challenges/domain/challenge_repository.dart';

/// [ChallengeRepository] backed by the `challenges` Drift table.
///
/// The `watch`/`get` twins share one query builder each, so a stream and
/// its one-shot sibling can never drift apart in filter or ordering — the
/// one-shot variants exist because `await watchX().first` deadlocks widget
/// tests (central `testing-pitfalls.md`, 2026-09-01), and a second
/// hand-written query would reintroduce exactly the divergence the pattern
/// avoids.
///
/// The provider lives in `../challenges_providers.dart` (ADR 007), not
/// here.
class DriftChallengeRepository implements ChallengeRepository {
  const DriftChallengeRepository(this._db);

  final db.AppDatabase _db;

  Selectable<db.ChallengeRow> _allQuery() {
    return _db.select(_db.challenges)..orderBy([
      (t) => OrderingTerm.desc(t.windowStart),
      (t) => OrderingTerm.desc(t.id),
    ]);
  }

  Selectable<db.ChallengeRow> _byIdQuery(String id) {
    return _db.select(_db.challenges)..where((t) => t.id.equals(id));
  }

  @override
  Stream<List<Challenge>> watchChallenges() {
    return _allQuery()
        .watch()
        .map((rows) => rows.map(_toEntity).toList())
        .handleError((Object error, StackTrace stackTrace) {
          // Rethrowing from an error handler replaces the stream's error
          // event with this one - a raw platform exception must never
          // cross the repository boundary (error_handling.md).
          throw StorageException(
            message: 'Failed to watch challenges',
            cause: error,
            stackTrace: stackTrace,
          );
        });
  }

  @override
  Future<List<Challenge>> getChallenges() async {
    try {
      final rows = await _allQuery().get();
      return rows.map(_toEntity).toList();
    } catch (e, st) {
      throw StorageException(
        message: 'Failed to read challenges',
        cause: e,
        stackTrace: st,
      );
    }
  }

  @override
  Stream<Challenge?> watchChallenge(String id) {
    return _byIdQuery(id)
        .watchSingleOrNull()
        .map((row) => row == null ? null : _toEntity(row))
        .handleError((Object error, StackTrace stackTrace) {
          throw StorageException(
            message: 'Failed to watch a challenge',
            cause: error,
            stackTrace: stackTrace,
          );
        });
  }

  @override
  Future<Challenge?> getChallenge(String id) async {
    try {
      final row = await _byIdQuery(id).getSingleOrNull();
      return row == null ? null : _toEntity(row);
    } catch (e, st) {
      throw StorageException(
        message: 'Failed to read a challenge',
        cause: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<void> saveChallenge(Challenge challenge) async {
    try {
      final row = _toCompanion(challenge);
      await _db
          .into(_db.challenges)
          .insert(
            row,
            // Every column except `created_at` is overwritten on conflict.
            // `insertOnConflictUpdate` would have written that one too,
            // which quietly breaks the contract
            // `domain/challenge_repository.dart#saveChallenge` states: the
            // stored `createdAt` is the first-ever save's, so callers never
            // read-before-write and re-joining a challenge they already
            // hold cannot move the moment they picked it up.
            onConflict: DoUpdate(
              (_) => row.copyWith(createdAt: const Value.absent()),
            ),
          );
    } catch (e, st) {
      throw StorageException(
        message: 'Failed to save a challenge',
        cause: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<void> deleteChallenge(String id) async {
    try {
      await (_db.delete(_db.challenges)..where((t) => t.id.equals(id))).go();
    } catch (e, st) {
      throw StorageException(
        message: 'Failed to delete a challenge',
        cause: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<void> deleteAllData() async {
    try {
      await _db.delete(_db.challenges).go();
    } catch (e, st) {
      throw StorageException(
        message: 'Failed to delete challenges',
        cause: e,
        stackTrace: st,
      );
    }
  }

  db.ChallengesCompanion _toCompanion(Challenge challenge) {
    final blueprint = challenge.blueprint;
    final buddy = challenge.buddy;
    return db.ChallengesCompanion.insert(
      id: blueprint.id,
      kind: blueprint.kind.toStorage(),
      activityTypes: _encodeTypes(blueprint.activityTypes),
      targetUnits: blueprint.targetUnits,
      windowStart: blueprint.windowStart.toIso(),
      windowEnd: blueprint.windowEnd.toIso(),
      salt: blueprint.salt,
      selfDisplayName: challenge.selfDisplayName,
      origin: challenge.origin.toStorage(),
      authorTag: challenge.authorTag,
      buddyDisplayName: Value(buddy?.displayName),
      buddyProgressPercent: Value(buddy?.progressPercent),
      buddyAsOf: Value(buddy?.asOf.toIso()),
      createdAt: challenge.createdAt.toUtc().millisecondsSinceEpoch,
    );
  }

  Challenge _toEntity(db.ChallengeRow row) {
    final buddyName = row.buddyDisplayName;
    final buddyPercent = row.buddyProgressPercent;
    final buddyAsOf = row.buddyAsOf;
    return Challenge(
      blueprint: ChallengeBlueprint(
        id: row.id,
        kind: ChallengeKind.fromStorage(row.kind),
        activityTypes: _decodeTypes(row.activityTypes),
        targetUnits: row.targetUnits,
        windowStart: LocalDate.parse(row.windowStart),
        windowEnd: LocalDate.parse(row.windowEnd),
        salt: row.salt,
      ),
      selfDisplayName: row.selfDisplayName,
      origin: ChallengeOrigin.fromStorage(row.origin),
      authorTag: row.authorTag,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        row.createdAt,
        isUtc: true,
      ),
      // The three buddy columns are written together and read together:
      // a snapshot with a name but no date would be a snapshot that
      // cannot be compared for freshness, so a partial row reads as no
      // snapshot at all rather than as a half-known buddy.
      buddy: (buddyName == null || buddyPercent == null || buddyAsOf == null)
          ? null
          : ChallengeBuddySnapshot(
              displayName: buddyName,
              progressPercent: buddyPercent,
              asOf: LocalDate.parse(buddyAsOf),
            ),
    );
  }

  /// Comma-separated storage keys; `''` means "any type counts". Order is
  /// normalised to the enum's own so the stored string is stable for a
  /// given set (a set has no order, and an unstable serialisation would
  /// make identical rows compare unequal in tests and diffs).
  static String _encodeTypes(Set<ActivityType> types) {
    final ordered = ActivityType.values.where(types.contains);
    return ordered.map((type) => type.toStorage()).join(',');
  }

  static Set<ActivityType> _decodeTypes(String stored) {
    if (stored.isEmpty) return const <ActivityType>{};
    return stored
        .split(',')
        .where((key) => key.isNotEmpty)
        .map(ActivityType.fromStorage)
        .toSet();
  }
}
