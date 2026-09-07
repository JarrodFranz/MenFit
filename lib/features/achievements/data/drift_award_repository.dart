import 'package:drift/drift.dart';
import 'package:menfit_app/core/db/app_database.dart' as db;
import 'package:menfit_app/core/errors/app_exception.dart';
import 'package:menfit_app/features/achievements/domain/award_repository.dart';
import 'package:menfit_app/features/achievements/domain/badge_award.dart';
import 'package:menfit_app/features/achievements/domain/badge_tier.dart';

/// [AwardRepository] backed by the `badge_awards` Drift table.
///
/// The `watch`/`get` pair shares one query builder, so the stream and the
/// one-shot read can never drift apart in filter or ordering — the reason
/// the one-shot variant exists at all is that `await watchX().first`
/// deadlocks widget tests (central `testing-pitfalls.md`, 2026-09-01), and
/// a second hand-written query would reintroduce the divergence risk the
/// pattern is meant to avoid.
///
/// The provider for this repository lives in `../achievements_providers.dart`
/// (ADR 007), not here.
class DriftAwardRepository implements AwardRepository {
  const DriftAwardRepository(this._db);

  final db.AppDatabase _db;

  Selectable<db.BadgeAwardRow> _allQuery() {
    return _db.select(_db.badgeAwards)..orderBy([
      (t) => OrderingTerm.desc(t.awardedAt),
      (t) => OrderingTerm.desc(t.id),
    ]);
  }

  @override
  Stream<List<BadgeAward>> watchAwards() {
    return _allQuery()
        .watch()
        .map((rows) => rows.map(_toEntity).toList())
        .handleError((Object error, StackTrace stackTrace) {
          // Rethrowing from an error handler replaces the stream's error
          // event with this one - a raw platform exception must never
          // cross the repository boundary (error_handling.md).
          throw StorageException(
            message: 'Failed to watch badge awards',
            cause: error,
            stackTrace: stackTrace,
          );
        });
  }

  @override
  Future<List<BadgeAward>> getAwards() async {
    try {
      final rows = await _allQuery().get();
      return rows.map(_toEntity).toList();
    } catch (e, st) {
      throw StorageException(
        message: 'Failed to read badge awards',
        cause: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<void> recordAward(BadgeAward award) => recordAwards([award]);

  @override
  Future<void> recordAwards(List<BadgeAward> awards) async {
    if (awards.isEmpty) return;
    try {
      await _db.batch((batch) {
        batch.insertAll(
          _db.badgeAwards,
          awards.map(_toCompanion),
          // Idempotency, enforced by the table's UNIQUE(badge_id, tier_key)
          // rather than by a read-then-write: a second award of the same
          // badge+tier is dropped, the first one's id and awardedAt stand,
          // and nothing throws. `insertOnConflictUpdate` would be wrong
          // here - it keys on the primary key (a fresh UUID every time),
          // so it would not see the duplicate at all, and even if it did,
          // overwriting would move the moment she earned it.
          mode: InsertMode.insertOrIgnore,
        );
      });
    } catch (e, st) {
      throw StorageException(
        message: 'Failed to record badge awards',
        cause: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<void> deleteAllData() async {
    try {
      await _db.delete(_db.badgeAwards).go();
    } catch (e, st) {
      throw StorageException(
        message: 'Failed to delete badge awards',
        cause: e,
        stackTrace: st,
      );
    }
  }

  db.BadgeAwardsCompanion _toCompanion(BadgeAward award) {
    return db.BadgeAwardsCompanion.insert(
      id: award.id,
      badgeId: award.badgeId,
      tierKey: awardTierKey(award.tier),
      awardedAt: award.awardedAt.toUtc().millisecondsSinceEpoch,
    );
  }

  BadgeAward _toEntity(db.BadgeAwardRow row) {
    return BadgeAward(
      id: row.id,
      badgeId: row.badgeId,
      // `fromStorage` returns null for the one-off sentinel and for any
      // key a future version wrote and this one does not understand - both
      // read as "no tier", which is the safe way for an old build to meet
      // a new award rather than throwing on someone's trophy case.
      tier: BadgeTier.fromStorage(row.tierKey),
      awardedAt: DateTime.fromMillisecondsSinceEpoch(
        row.awardedAt,
        isUtc: true,
      ),
    );
  }
}
