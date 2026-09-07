import 'package:drift/drift.dart';
import 'package:menfit_app/core/db/app_database.dart' as db;
import 'package:menfit_app/core/domain/entity_id.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/errors/app_exception.dart';
import 'package:menfit_app/features/wellbeing/domain/daily_checkin.dart';
import 'package:menfit_app/features/wellbeing/domain/flare_event.dart';
import 'package:menfit_app/features/wellbeing/domain/symptom_type.dart';
import 'package:menfit_app/features/wellbeing/domain/wellbeing_event.dart';
import 'package:menfit_app/features/wellbeing/domain/wellbeing_repository.dart';

/// [WellbeingRepository] backed by the `daily_checkins` and `flare_events`
/// Drift tables.
///
/// The generated Drift row classes for those tables are also named
/// `DailyCheckin`/`FlareEvent`, so this file imports `app_database.dart`
/// with the `db` prefix throughout to keep them distinct from the freezed
/// domain entities of the same name (same convention as
/// `features/cycle/data/drift_cycle_repository.dart`).
///
/// The provider for this repository lives in `../wellbeing_providers.dart`
/// (ADR 007), not here.
///
/// S3-tier data (`knowledge/engineering/security_and_privacy.md`): no
/// day/score/symptom values ever appear in a thrown [AppException]'s
/// `message` — those stay static strings, same as every other repository
/// in this codebase.
class DriftWellbeingRepository implements WellbeingRepository {
  DriftWellbeingRepository(this._db);

  final db.AppDatabase _db;

  @override
  Stream<DailyCheckin?> watchCheckinFor(LocalDate day) {
    final query = _db.select(_db.dailyCheckins)
      ..where((t) => t.day.equals(day.toIso()));
    return query
        .watchSingleOrNull()
        .map((row) => row == null ? null : _checkinToEntity(row))
        .handleError((Object error, StackTrace stackTrace) {
          throw StorageException(
            message: 'Failed to watch check-in',
            cause: error,
            stackTrace: stackTrace,
          );
        });
  }

  @override
  Future<DailyCheckin?> getCheckinFor(LocalDate day) async {
    try {
      final query = _db.select(_db.dailyCheckins)
        ..where((t) => t.day.equals(day.toIso()));
      final row = await query.getSingleOrNull();
      return row == null ? null : _checkinToEntity(row);
    } on Object catch (error, stackTrace) {
      throw StorageException(
        message: 'Failed to fetch check-in',
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }

  Selectable<db.DailyCheckin> _recentCheckinsQuery(int days, LocalDate today) {
    final windowStart = today.addDays(-(days - 1));
    return _db.select(_db.dailyCheckins)
      ..where(
        (t) =>
            t.day.isBiggerOrEqualValue(windowStart.toIso()) &
            t.day.isSmallerOrEqualValue(today.toIso()),
      )
      ..orderBy([(t) => OrderingTerm.desc(t.day)]);
  }

  @override
  Stream<List<DailyCheckin>> watchRecentCheckins(int days, LocalDate today) {
    return _recentCheckinsQuery(days, today)
        .watch()
        .map((rows) => rows.map(_checkinToEntity).toList())
        .handleError((Object error, StackTrace stackTrace) {
          throw StorageException(
            message: 'Failed to watch recent check-ins',
            cause: error,
            stackTrace: stackTrace,
          );
        });
  }

  @override
  Stream<List<DailyCheckin>> watchCheckinsForRange(
    LocalDate from,
    LocalDate to,
  ) {
    // `day` holds zero-padded ISO-8601, so SQLite's lexicographic string
    // comparison is exactly chronological comparison (same reasoning as
    // `_lastDay` below).
    final query = _db.select(_db.dailyCheckins)
      ..where(
        (t) =>
            t.day.isBiggerOrEqualValue(from.toIso()) &
            t.day.isSmallerOrEqualValue(to.toIso()),
      )
      ..orderBy([(t) => OrderingTerm.asc(t.day)]);
    return query
        .watch()
        .map((rows) => rows.map(_checkinToEntity).toList())
        .handleError((Object error, StackTrace stackTrace) {
          throw StorageException(
            message: 'Failed to watch check-ins',
            cause: error,
            stackTrace: stackTrace,
          );
        });
  }

  @override
  Future<List<DailyCheckin>> getRecentCheckins(
    int days,
    LocalDate today,
  ) async {
    try {
      final rows = await _recentCheckinsQuery(days, today).get();
      return rows.map(_checkinToEntity).toList();
    } catch (e, st) {
      throw StorageException(
        message: 'Failed to get recent check-ins',
        cause: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<void> saveCheckin(DailyCheckin checkin) async {
    final now = DateTime.now().toUtc();
    try {
      await _db.transaction(() async {
        // Upsert BY DAY, not by id: a check-in already logged for this day
        // is replaced in place, keeping its original id/createdAt (see
        // `domain/wellbeing_repository.dart#saveCheckin`'s dartdoc).
        final existing = await (_db.select(
          _db.dailyCheckins,
        )..where((t) => t.day.equals(checkin.day.toIso()))).getSingleOrNull();

        String id;
        int createdAtMillis;
        if (existing != null) {
          id = existing.id;
          createdAtMillis = existing.createdAt;
        } else {
          // F7 (id-relocation guard): no row exists for this day, so this
          // is genuinely a new row - but `checkin.id` might already belong
          // to a DIFFERENT day's row (a caller bug, or a stale id reused
          // across sessions/edits). `insertOnConflictUpdate` below keys on
          // `id`, so blindly reusing it would silently relocate that other
          // day's row onto this one (overwriting its `day` column in
          // place) instead of creating a new row - corrupting whichever
          // day used to own that id. If it's taken, mint a fresh id
          // instead; a genuinely new row for this day is correct either
          // way, regardless of what the caller happened to pass.
          final idOwner = await (_db.select(
            _db.dailyCheckins,
          )..where((t) => t.id.equals(checkin.id))).getSingleOrNull();
          id = idOwner == null ? checkin.id : EntityId.generate();
          createdAtMillis = checkin.createdAt.toUtc().millisecondsSinceEpoch;
        }

        await _db
            .into(_db.dailyCheckins)
            .insertOnConflictUpdate(
              db.DailyCheckinsCompanion.insert(
                id: id,
                day: checkin.day.toIso(),
                energy: Value(checkin.energy),
                sleep: Value(checkin.sleep),
                soreness: Value(checkin.soreness),
                stress: Value(checkin.stress),
                pain: Value(checkin.pain),
                symptoms: Value(
                  _symptomsToCsv(
                    checkin.symptoms,
                    customSymptom: checkin.customSymptom,
                  ),
                ),
                createdAt: createdAtMillis,
                updatedAt: now.millisecondsSinceEpoch,
              ),
            );
      });
    } catch (e, st) {
      throw StorageException(
        message: 'Failed to save check-in',
        cause: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<void> deleteCheckin(String id) async {
    // Hard delete, not soft — same S3 reasoning as
    // `DriftCycleRepository.deleteRecord`.
    try {
      await _db.transaction(() async {
        await (_db.delete(
          _db.dailyCheckins,
        )..where((t) => t.id.equals(id))).go();
      });
    } catch (e, st) {
      throw StorageException(
        message: 'Failed to delete check-in',
        cause: e,
        stackTrace: st,
      );
    }
  }

  /// The flare's effective inclusive last day in SQL: `end_day` when set,
  /// otherwise `day` (the single-day case, and every pre-schema-v9 row).
  ///
  /// Both columns hold zero-padded ISO-8601 (`YYYY-MM-DD`), so SQLite's
  /// lexicographic string comparison is exactly chronological comparison —
  /// no date functions or casts are needed for the range predicates below.
  Expression<String> _lastDay(db.$FlareEventsTable t) =>
      coalesce([t.endDay, t.day]);

  @override
  Stream<List<FlareEvent>> watchRecentFlares(int days, LocalDate today) {
    final windowStart = today.addDays(-(days - 1));
    // Overlap, not "starts within": a flare that began before the window
    // but runs into it happened during that window too (see the interface
    // dartdoc).
    final query = _db.select(_db.flareEvents)
      ..where(
        (t) =>
            t.day.isSmallerOrEqualValue(today.toIso()) &
            _lastDay(t).isBiggerOrEqualValue(windowStart.toIso()),
      )
      ..orderBy([(t) => OrderingTerm.desc(t.day)]);
    return query
        .watch()
        .map((rows) => rows.map(_flareToEntity).toList())
        .handleError((Object error, StackTrace stackTrace) {
          throw StorageException(
            message: 'Failed to watch recent flares',
            cause: error,
            stackTrace: stackTrace,
          );
        });
  }

  @override
  Stream<List<FlareEvent>> watchFlaresForRange(LocalDate from, LocalDate to) {
    // Overlap, not "starts within" — same rule as `watchRecentFlares`,
    // just over an arbitrary range.
    final query = _db.select(_db.flareEvents)
      ..where(
        (t) =>
            t.day.isSmallerOrEqualValue(to.toIso()) &
            _lastDay(t).isBiggerOrEqualValue(from.toIso()),
      )
      ..orderBy([(t) => OrderingTerm.asc(t.day)]);
    return query
        .watch()
        .map((rows) => rows.map(_flareToEntity).toList())
        .handleError((Object error, StackTrace stackTrace) {
          throw StorageException(
            message: 'Failed to watch flares',
            cause: error,
            stackTrace: stackTrace,
          );
        });
  }

  /// Matches every flare whose inclusive range covers [day].
  Expression<bool> _covers(db.$FlareEventsTable t, LocalDate day) {
    final iso = day.toIso();
    return t.day.isSmallerOrEqualValue(iso) &
        _lastDay(t).isBiggerOrEqualValue(iso);
  }

  @override
  Stream<List<FlareEvent>> watchFlaresOn(LocalDate day) {
    final query = _db.select(_db.flareEvents)
      ..where((t) => _covers(t, day))
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    return query
        .watch()
        .map((rows) => rows.map(_flareToEntity).toList())
        .handleError((Object error, StackTrace stackTrace) {
          throw StorageException(
            message: 'Failed to watch flares',
            cause: error,
            stackTrace: stackTrace,
          );
        });
  }

  @override
  Future<List<FlareEvent>> getFlaresOn(LocalDate day) async {
    try {
      final query = _db.select(_db.flareEvents)
        ..where((t) => _covers(t, day))
        ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
      final rows = await query.get();
      return rows.map(_flareToEntity).toList();
    } catch (e, st) {
      throw StorageException(
        message: 'Failed to fetch flares',
        cause: e,
        stackTrace: st,
      );
    }
  }

  @override
  Stream<Set<LocalDate>> watchProtectingFlareDays() {
    final query = _db.select(_db.flareEvents)
      ..where((t) => t.impact.equals(FlareImpact.unableToTrain.toStorage()));
    return query
        .watch()
        .map((rows) {
          // Expand each flare's inclusive range into individual days: a
          // five-day couldn't-train flare protects all five. `FlareEvent.days`
          // owns the cap that keeps an absurd stored range (a pre-validation
          // or imported row) from blowing up this set.
          final protecting = <LocalDate>{};
          for (final row in rows) {
            protecting.addAll(_flareToEntity(row).days);
          }
          return protecting;
        })
        .handleError((Object error, StackTrace stackTrace) {
          throw StorageException(
            message: 'Failed to watch protecting flare days',
            cause: error,
            stackTrace: stackTrace,
          );
        });
  }

  @override
  Future<void> saveFlare(FlareEvent flare) async {
    final now = DateTime.now().toUtc();
    try {
      await _db.transaction(() async {
        // Plain upsert by id — multiple flares per day are allowed, so
        // (unlike saveCheckin) there's no "day" identity to resolve first.
        final existing = await (_db.select(
          _db.flareEvents,
        )..where((t) => t.id.equals(flare.id))).getSingleOrNull();
        final createdAtMillis =
            existing?.createdAt ??
            flare.createdAt.toUtc().millisecondsSinceEpoch;

        await _db
            .into(_db.flareEvents)
            .insertOnConflictUpdate(
              db.FlareEventsCompanion.insert(
                id: flare.id,
                day: flare.day.toIso(),
                endDay: Value(flare.endDay?.toIso()),
                severity: flare.severity.toStorage(),
                symptoms: Value(
                  _symptomsToCsv(
                    flare.symptoms,
                    customSymptom: flare.customSymptom,
                  ),
                ),
                impact: flare.impact.toStorage(),
                category: Value(flare.category?.toStorage()),
                notes: Value(flare.notes),
                createdAt: createdAtMillis,
                updatedAt: now.millisecondsSinceEpoch,
              ),
            );
      });
    } catch (e, st) {
      throw StorageException(
        message: 'Failed to save flare',
        cause: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<void> deleteFlare(String id) async {
    try {
      await _db.transaction(() async {
        await (_db.delete(
          _db.flareEvents,
        )..where((t) => t.id.equals(id))).go();
      });
    } catch (e, st) {
      throw StorageException(
        message: 'Failed to delete flare',
        cause: e,
        stackTrace: st,
      );
    }
  }

  @override
  Stream<List<WellbeingEvent>> watchEventsOn(LocalDate day) {
    final query = _db.select(_db.wellbeingEvents)
      ..where((t) => t.day.equals(day.toIso()))
      ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]);
    return query
        .watch()
        .map((rows) => rows.map(_eventToEntity).toList())
        .handleError((Object error, StackTrace stackTrace) {
          throw StorageException(
            message: 'Failed to watch events',
            cause: error,
            stackTrace: stackTrace,
          );
        });
  }

  @override
  Future<List<WellbeingEvent>> getEventsOn(LocalDate day) async {
    try {
      final query = _db.select(_db.wellbeingEvents)
        ..where((t) => t.day.equals(day.toIso()))
        ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]);
      final rows = await query.get();
      return rows.map(_eventToEntity).toList();
    } catch (e, st) {
      throw StorageException(
        message: 'Failed to fetch events on day',
        cause: e,
        stackTrace: st,
      );
    }
  }

  @override
  Stream<List<WellbeingEvent>> watchEventsForRange(
    LocalDate from,
    LocalDate to,
  ) {
    final query = _db.select(_db.wellbeingEvents)
      ..where(
        (t) =>
            t.day.isBiggerOrEqualValue(from.toIso()) &
            t.day.isSmallerOrEqualValue(to.toIso()),
      )
      ..orderBy([(t) => OrderingTerm.asc(t.day)]);
    return query
        .watch()
        .map((rows) => rows.map(_eventToEntity).toList())
        .handleError((Object error, StackTrace stackTrace) {
          throw StorageException(
            message: 'Failed to watch events for range',
            cause: error,
            stackTrace: stackTrace,
          );
        });
  }

  @override
  Future<List<WellbeingEvent>> getEventsForRange(
    LocalDate from,
    LocalDate to,
  ) async {
    try {
      final query = _db.select(_db.wellbeingEvents)
        ..where(
          (t) =>
              t.day.isBiggerOrEqualValue(from.toIso()) &
              t.day.isSmallerOrEqualValue(to.toIso()),
        )
        ..orderBy([(t) => OrderingTerm.asc(t.day)]);
      final rows = await query.get();
      return rows.map(_eventToEntity).toList();
    } catch (e, st) {
      throw StorageException(
        message: 'Failed to fetch events for range',
        cause: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<void> saveEvent(WellbeingEvent event) async {
    try {
      final existing = await (_db.select(
        _db.wellbeingEvents,
      )..where((t) => t.id.equals(event.id))).getSingleOrNull();

      final now = DateTime.now().toUtc().millisecondsSinceEpoch;
      final createdAt =
          existing?.createdAt ?? event.createdAt.toUtc().millisecondsSinceEpoch;

      final companion = db.WellbeingEventsCompanion(
        id: Value(event.id),
        day: Value(event.day.toIso()),
        type: Value(event.type.toStorage()),
        title: Value(event.title.trim()),
        isCustomSaved: Value(event.isCustomSaved),
        notes: Value(event.notes),
        createdAt: Value(createdAt),
        updatedAt: Value(now),
      );

      await _db.into(_db.wellbeingEvents).insertOnConflictUpdate(companion);
    } catch (e, st) {
      throw StorageException(
        message: 'Failed to save event',
        cause: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<void> deleteEvent(String id) async {
    try {
      await (_db.delete(
        _db.wellbeingEvents,
      )..where((t) => t.id.equals(id))).go();
    } catch (e, st) {
      throw StorageException(
        message: 'Failed to delete event',
        cause: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<void> deleteAllData() async {
    try {
      await _db.transaction(() async {
        await _db.delete(_db.dailyCheckins).go();
        await _db.delete(_db.flareEvents).go();
        await _db.delete(_db.wellbeingEvents).go();
      });
    } catch (e, st) {
      throw StorageException(
        message: 'Failed to delete wellbeing data',
        cause: e,
        stackTrace: st,
      );
    }
  }

  WellbeingEvent _eventToEntity(db.WellbeingEvent row) {
    return WellbeingEvent(
      id: row.id,
      day: LocalDate.parse(row.day),
      type: WellbeingEventType.fromStorage(row.type),
      title: row.title,
      isCustomSaved: row.isCustomSaved,
      notes: row.notes,
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

  DailyCheckin _checkinToEntity(db.DailyCheckin row) {
    final (symptoms, customSymptom) = symptomsAndCustomFromCsv(row.symptoms);
    return DailyCheckin(
      id: row.id,
      day: LocalDate.parse(row.day),
      energy: row.energy,
      sleep: row.sleep,
      soreness: row.soreness,
      stress: row.stress,
      pain: row.pain,
      symptoms: symptoms,
      customSymptom: customSymptom,
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

  FlareEvent _flareToEntity(db.FlareEvent row) {
    final (symptoms, customSymptom) = symptomsAndCustomFromCsv(row.symptoms);
    return FlareEvent(
      id: row.id,
      day: LocalDate.parse(row.day),
      endDay: row.endDay == null ? null : LocalDate.parse(row.endDay!),
      severity: FlareSeverity.fromStorage(row.severity),
      symptoms: symptoms,
      customSymptom: customSymptom,
      impact: FlareImpact.fromStorage(row.impact),
      category: FlareCategory.fromStorage(row.category),
      notes: row.notes,
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

/// Encodes [symptoms] as the comma-separated storage form used by both
/// `daily_checkins.symptoms` and `flare_events.symptoms`.
String _symptomsToCsv(List<SymptomType> symptoms, {String? customSymptom}) {
  final tokens = <String>[];
  for (final s in symptoms) {
    if (s == SymptomType.other &&
        customSymptom != null &&
        customSymptom.trim().isNotEmpty) {
      tokens.add('other:${Uri.encodeComponent(customSymptom.trim())}');
    } else {
      tokens.add(s.toStorage());
    }
  }
  return tokens.join(',');
}

/// Decodes the comma-separated storage form back into [SymptomType]s and any
/// custom symptom text encoded in an `other:<text>` token.
(List<SymptomType>, String?) symptomsAndCustomFromCsv(String csv) {
  if (csv.isEmpty) return (const <SymptomType>[], null);
  final symptoms = <SymptomType>[];
  String? customSymptom;
  for (final raw in csv.split(',')) {
    if (raw.startsWith('other:') && raw.length > 6) {
      symptoms.add(SymptomType.other);
      try {
        customSymptom = Uri.decodeComponent(raw.substring(6));
      } on Object catch (_) {
        customSymptom = raw.substring(6);
      }
    } else {
      symptoms.add(SymptomType.fromStorage(raw));
    }
  }
  return (symptoms, customSymptom);
}

/// Decodes the comma-separated storage form back into [SymptomType]s.
/// `''` (never logged any symptom) decodes to an empty list, not a list
/// containing one bogus empty-string entry.
List<SymptomType> symptomsFromCsv(String csv) =>
    symptomsAndCustomFromCsv(csv).$1;
