import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/db/app_database.dart' as db;
import 'package:menfit_app/core/domain/entity_id.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/errors/app_exception.dart';
import 'package:menfit_app/features/wellbeing/data/drift_wellbeing_repository.dart';
import 'package:menfit_app/features/wellbeing/domain/daily_checkin.dart';
import 'package:menfit_app/features/wellbeing/domain/flare_event.dart';
import 'package:menfit_app/features/wellbeing/domain/symptom_type.dart';

void main() {
  late db.AppDatabase database;
  late DriftWellbeingRepository repository;

  setUp(() {
    database = db.AppDatabase.forTesting(NativeDatabase.memory());
    repository = DriftWellbeingRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  DailyCheckin buildCheckin({
    String? id,
    LocalDate? day,
    int? energy,
    int? sleep,
    int? soreness,
    int? stress,
    int? pain,
    List<SymptomType> symptoms = const [],
    DateTime? createdAt,
  }) {
    final now = createdAt ?? DateTime.utc(2026);
    return DailyCheckin(
      id: id ?? EntityId.generate(),
      day: day ?? LocalDate(2026, 8, 20),
      energy: energy,
      sleep: sleep,
      soreness: soreness,
      stress: stress,
      pain: pain,
      symptoms: symptoms,
      createdAt: now,
      updatedAt: now,
    );
  }

  FlareEvent buildFlare({
    String? id,
    LocalDate? day,
    LocalDate? endDay,
    FlareSeverity severity = FlareSeverity.moderate,
    FlareImpact impact = FlareImpact.reducedTraining,
    List<SymptomType> symptoms = const [],
    FlareCategory? category,
    String? notes,
    DateTime? createdAt,
  }) {
    final now = createdAt ?? DateTime.utc(2026);
    return FlareEvent(
      id: id ?? EntityId.generate(),
      day: day ?? LocalDate(2026, 8, 20),
      endDay: endDay,
      severity: severity,
      impact: impact,
      symptoms: symptoms,
      category: category,
      notes: notes,
      createdAt: now,
      updatedAt: now,
    );
  }

  group('check-ins', () {
    test('watchCheckinFor emits null before anything is saved', () async {
      expect(
        await repository.watchCheckinFor(LocalDate(2026, 8, 20)).first,
        isNull,
      );
    });

    test('save then watch round-trips the saved check-in', () async {
      final checkin = buildCheckin(
        energy: 4,
        sleep: 3,
        symptoms: [SymptomType.cramping, SymptomType.fatigue],
      );

      final expectation = expectLater(
        repository.watchCheckinFor(checkin.day),
        emitsThrough(
          predicate<DailyCheckin?>(
            (c) =>
                c != null &&
                c.energy == 4 &&
                c.sleep == 3 &&
                c.symptoms.length == 2,
          ),
        ),
      );
      await repository.saveCheckin(checkin);
      await expectation;
    });

    test(
      'saving twice for the SAME DAY with different ids upserts to one row, '
      'keeping the first-persisted id and createdAt',
      () async {
        final original = DateTime.utc(2024);
        final first = buildCheckin(
          id: 'first-id',
          day: LocalDate(2026, 8, 20),
          energy: 2,
          createdAt: original,
        );
        await repository.saveCheckin(first);

        final second = buildCheckin(
          id: 'second-id',
          day: LocalDate(2026, 8, 20),
          energy: 5,
          createdAt: DateTime.utc(2030),
        );
        await repository.saveCheckin(second);

        final rows = await database.select(database.dailyCheckins).get();
        expect(rows, hasLength(1));
        expect(rows.single.id, 'first-id');
        expect(rows.single.energy, 5);
        expect(rows.single.createdAt, original.millisecondsSinceEpoch);
      },
    );

    test(
      'watchRecentCheckins only includes days within the window, newest '
      'first',
      () async {
        final today = LocalDate(2026, 8, 20);
        await repository.saveCheckin(
          buildCheckin(day: today, energy: 1),
        );
        await repository.saveCheckin(
          buildCheckin(day: today.addDays(-2), energy: 2),
        );
        await repository.saveCheckin(
          buildCheckin(day: today.addDays(-6), energy: 3),
        ); // outside a 5-day window
        await repository.saveCheckin(
          buildCheckin(day: today.addDays(1), energy: 4),
        ); // in the future, outside the window regardless of size

        final recent = await repository.watchRecentCheckins(5, today).first;
        expect(recent.map((c) => c.day).toList(), [
          today,
          today.addDays(-2),
        ]);
      },
    );

    test(
      'getRecentCheckins returns the same window watchRecentCheckins emits',
      () async {
        final today = LocalDate(2026, 8, 20);
        await repository.saveCheckin(buildCheckin(day: today, energy: 1));
        await repository.saveCheckin(
          buildCheckin(day: today.addDays(-2), energy: 2),
        );
        await repository.saveCheckin(
          buildCheckin(day: today.addDays(-6), energy: 3),
        ); // outside a 5-day window
        await repository.saveCheckin(
          buildCheckin(day: today.addDays(1), energy: 4),
        ); // in the future, outside the window regardless of size

        final fetched = await repository.getRecentCheckins(5, today);
        expect(fetched.map((c) => c.day).toList(), [
          today,
          today.addDays(-2),
        ]);

        final watched = await repository.watchRecentCheckins(5, today).first;
        expect(fetched.map((c) => c.id).toList(), watched.map((c) => c.id));
      },
    );

    test('getRecentCheckins returns an empty list for an empty window', () {
      expect(
        repository.getRecentCheckins(30, LocalDate(2026, 8, 20)),
        completion(isEmpty),
      );
    });

    test(
      'getRecentCheckins wraps a lower-level database error as '
      'StorageException',
      () async {
        await database.customStatement('DROP TABLE daily_checkins');
        await expectLater(
          repository.getRecentCheckins(7, LocalDate(2026, 8, 20)),
          throwsA(isA<StorageException>()),
        );
      },
    );

    test(
      'deleteCheckin hard-deletes: the row is gone, not just hidden',
      () async {
        final checkin = buildCheckin(id: 'c1');
        await repository.saveCheckin(checkin);
        expect(
          await repository.watchCheckinFor(checkin.day).first,
          isNotNull,
        );

        await repository.deleteCheckin('c1');

        expect(await repository.watchCheckinFor(checkin.day).first, isNull);
        final rows = await database.select(database.dailyCheckins).get();
        expect(rows, isEmpty);
      },
    );

    test('wraps a lower-level database error as StorageException', () async {
      await database.customStatement('DROP TABLE daily_checkins');
      await expectLater(
        repository.watchCheckinFor(LocalDate(2026, 8, 20)).first,
        throwsA(isA<StorageException>()),
      );
    });

    test(
      'F7: saving for a new day with an id already owned by a DIFFERENT '
      "day mints a fresh id instead of relocating the other day's row",
      () async {
        final dayA = LocalDate(2026, 8, 1);
        final dayB = LocalDate(2026, 8, 2);
        await repository.saveCheckin(
          buildCheckin(id: 'reused-id', day: dayA, energy: 1),
        );

        // A "new" check-in for a different day, reusing dayA's id (e.g. a
        // caller bug) - must NOT overwrite dayA's row in place.
        await repository.saveCheckin(
          buildCheckin(id: 'reused-id', day: dayB, energy: 5),
        );

        final dayARow = await repository.watchCheckinFor(dayA).first;
        expect(dayARow, isNotNull);
        expect(dayARow!.id, 'reused-id');
        expect(dayARow.energy, 1); // untouched

        final dayBRow = await repository.watchCheckinFor(dayB).first;
        expect(dayBRow, isNotNull);
        expect(dayBRow!.id, isNot('reused-id')); // minted fresh
        expect(dayBRow.energy, 5);

        final rows = await database.select(database.dailyCheckins).get();
        expect(rows, hasLength(2));
      },
    );

    test(
      'a StorageException from saveCheckin never interpolates '
      'day/score/symptom values into its message (S3)',
      () async {
        await database.customStatement('DROP TABLE daily_checkins');
        try {
          await repository.saveCheckin(
            buildCheckin(
              day: LocalDate(2026, 8, 20),
              energy: 5,
              symptoms: [SymptomType.cramping],
            ),
          );
          fail('expected a StorageException');
        } on StorageException catch (e) {
          expect(e.message, 'Failed to save check-in');
          expect(e.message, isNot(contains('2026')));
          expect(e.message, isNot(contains('cramping')));
        }
      },
    );
  });

  group('flares', () {
    test(
      'watchFlaresOn emits an empty list before anything is saved',
      () async {
        expect(
          await repository.watchFlaresOn(LocalDate(2026, 8, 20)).first,
          isEmpty,
        );
      },
    );

    test('save then watch round-trips the saved flare', () async {
      final flare = buildFlare(
        severity: FlareSeverity.severe,
        impact: FlareImpact.unableToTrain,
        symptoms: [SymptomType.pelvicPain],
        category: FlareCategory.endometriosis,
        notes: 'Rough day',
      );

      final expectation = expectLater(
        repository.watchFlaresOn(flare.day),
        emitsThrough(
          predicate<List<FlareEvent>>(
            (flares) =>
                flares.length == 1 &&
                flares.single.severity == FlareSeverity.severe &&
                flares.single.impact == FlareImpact.unableToTrain &&
                flares.single.symptoms.single == SymptomType.pelvicPain &&
                flares.single.category == FlareCategory.endometriosis &&
                flares.single.notes == 'Rough day',
          ),
        ),
      );
      await repository.saveFlare(flare);
      await expectation;
    });

    test('multiple flares can be logged for the same day', () async {
      final day = LocalDate(2026, 8, 20);
      await repository.saveFlare(buildFlare(id: 'a', day: day));
      await repository.saveFlare(buildFlare(id: 'b', day: day));

      final flares = await repository.watchFlaresOn(day).first;
      expect(flares, hasLength(2));
    });

    test(
      'category is null when never set (never required)',
      () async {
        final flare = buildFlare();
        await repository.saveFlare(flare);

        final flares = await repository.watchFlaresOn(flare.day).first;
        expect(flares.single.category, isNull);
      },
    );

    test(
      'saveFlare preserves the originally-persisted createdAt across an '
      'update to the same id',
      () async {
        final original = DateTime.utc(2024);
        final flare = buildFlare(id: 'f1', createdAt: original);
        await repository.saveFlare(flare);

        await repository.saveFlare(
          flare.copyWith(
            createdAt: DateTime.utc(2030),
            severity: FlareSeverity.severe,
          ),
        );

        final rows = await database.select(database.flareEvents).get();
        expect(rows, hasLength(1));
        expect(rows.single.createdAt, original.millisecondsSinceEpoch);
        expect(rows.single.severity, 'severe');
      },
    );

    test(
      'watchRecentFlares only includes days within the window, newest first',
      () async {
        final today = LocalDate(2026, 8, 20);
        await repository.saveFlare(buildFlare(id: 'a', day: today));
        await repository.saveFlare(
          buildFlare(id: 'b', day: today.addDays(-3)),
        );
        await repository.saveFlare(
          buildFlare(id: 'c', day: today.addDays(-10)),
        );

        final recent = await repository.watchRecentFlares(5, today).first;
        expect(recent.map((f) => f.id).toList(), ['a', 'b']);
      },
    );

    test(
      'deleteFlare hard-deletes: the row is gone, not just hidden',
      () async {
        final flare = buildFlare(id: 'f1');
        await repository.saveFlare(flare);
        expect(await repository.watchFlaresOn(flare.day).first, hasLength(1));

        await repository.deleteFlare('f1');

        expect(await repository.watchFlaresOn(flare.day).first, isEmpty);
        final rows = await database.select(database.flareEvents).get();
        expect(rows, isEmpty);
      },
    );

    test('wraps a lower-level database error as StorageException', () async {
      await database.customStatement('DROP TABLE flare_events');
      await expectLater(
        repository.watchFlaresOn(LocalDate(2026, 8, 20)).first,
        throwsA(isA<StorageException>()),
      );
    });

    test(
      'getFlaresOn returns an empty list before anything is saved',
      () async {
        expect(
          await repository.getFlaresOn(LocalDate(2026, 8, 20)),
          isEmpty,
        );
      },
    );

    test(
      'getFlaresOn one-shot-fetches every flare logged on the day',
      () async {
        final day = LocalDate(2026, 8, 20);
        await repository.saveFlare(buildFlare(id: 'a', day: day));
        await repository.saveFlare(buildFlare(id: 'b', day: day));
        await repository.saveFlare(
          buildFlare(id: 'c', day: day.addDays(1)),
        ); // a different day - excluded

        final flares = await repository.getFlaresOn(day);
        expect(flares.map((f) => f.id).toSet(), {'a', 'b'});
      },
    );
  });

  group('multi-day flares (schema v9)', () {
    final start = LocalDate(2026, 8, 20);

    test('endDay round-trips through save and read-back', () async {
      await repository.saveFlare(
        buildFlare(id: 'f1', day: start, endDay: start.addDays(4)),
      );

      final flare = (await repository.getFlaresOn(start)).single;
      expect(flare.endDay, start.addDays(4));
      expect(flare.lastDay, start.addDays(4));
      expect(flare.days, hasLength(5));
    });

    test(
      'watchFlaresOn matches a flare whose range COVERS the queried day '
      "without starting on it, and stops at the range's last day",
      () async {
        await repository.saveFlare(
          buildFlare(id: 'range', day: start, endDay: start.addDays(4)),
        );

        // A middle day and the inclusive end day both match...
        expect(
          (await repository.watchFlaresOn(start.addDays(2)).first).single.id,
          'range',
        );
        expect(
          (await repository.watchFlaresOn(start.addDays(4)).first).single.id,
          'range',
        );
        // ...the day after the range, and the day before it, do not.
        expect(await repository.watchFlaresOn(start.addDays(5)).first, isEmpty);
        expect(
          await repository.watchFlaresOn(start.addDays(-1)).first,
          isEmpty,
        );
      },
    );

    test(
      'getFlaresOn uses the same covering-range rule as watchFlaresOn',
      () async {
        await repository.saveFlare(
          buildFlare(id: 'range', day: start, endDay: start.addDays(4)),
        );

        expect(
          (await repository.getFlaresOn(start.addDays(3))).single.id,
          'range',
        );
        expect(await repository.getFlaresOn(start.addDays(5)), isEmpty);
      },
    );

    test(
      'backward compatibility: a single-day flare (end_day NULL) still '
      'matches only its own day',
      () async {
        await repository.saveFlare(buildFlare(id: 'single', day: start));

        final onDay = await repository.watchFlaresOn(start).first;
        expect(onDay.single.id, 'single');
        expect(onDay.single.endDay, isNull);
        expect(
          onDay.single.lastDay,
          start,
          reason: 'lastDay falls back to day',
        );
        expect(onDay.single.days, [start]);

        expect(await repository.watchFlaresOn(start.addDays(1)).first, isEmpty);
        expect(await repository.getFlaresOn(start.addDays(1)), isEmpty);
      },
    );

    test(
      'watchRecentFlares includes a flare that started BEFORE the window '
      'but extends into it',
      () async {
        final today = LocalDate(2026, 8, 20);
        // 5-day window = [2026-08-16, 2026-08-20].
        await repository.saveFlare(
          buildFlare(
            id: 'overlapping',
            day: today.addDays(-10),
            endDay: today.addDays(-4),
          ),
        );
        // Ends the day before the window opens - genuinely outside it.
        await repository.saveFlare(
          buildFlare(
            id: 'ended-before',
            day: today.addDays(-12),
            endDay: today.addDays(-5),
          ),
        );

        final recent = await repository.watchRecentFlares(5, today).first;
        expect(recent.map((f) => f.id).toList(), ['overlapping']);
      },
    );

    test(
      'watchRecentFlares still excludes a flare entirely after the window, '
      'and orders by start day (newest first)',
      () async {
        final today = LocalDate(2026, 8, 20);
        await repository.saveFlare(buildFlare(id: 'today', day: today));
        await repository.saveFlare(
          buildFlare(id: 'older', day: today.addDays(-3)),
        );
        await repository.saveFlare(
          buildFlare(id: 'future', day: today.addDays(2)),
        );

        final recent = await repository.watchRecentFlares(5, today).first;
        expect(recent.map((f) => f.id).toList(), ['today', 'older']);
      },
    );

    test(
      'watchProtectingFlareDays expands a multi-day unableToTrain flare '
      'into every day it covers',
      () async {
        await repository.saveFlare(
          buildFlare(
            id: 'range',
            day: start,
            endDay: start.addDays(4),
            impact: FlareImpact.unableToTrain,
          ),
        );

        final days = await repository.watchProtectingFlareDays().first;
        expect(days, {
          start,
          start.addDays(1),
          start.addDays(2),
          start.addDays(3),
          start.addDays(4),
        });
      },
    );

    test(
      'a multi-day flare with impact "none" protects no day at all, not '
      'even its first',
      () async {
        await repository.saveFlare(
          buildFlare(
            id: 'no-impact',
            day: start,
            endDay: start.addDays(4),
            impact: FlareImpact.none,
          ),
        );

        expect(await repository.watchProtectingFlareDays().first, isEmpty);
      },
    );

    test(
      'overlapping multi-day protecting flares collapse to the union of '
      'their days',
      () async {
        await repository.saveFlare(
          buildFlare(
            id: 'a',
            day: start,
            endDay: start.addDays(2),
            impact: FlareImpact.unableToTrain,
          ),
        );
        await repository.saveFlare(
          buildFlare(
            id: 'b',
            day: start.addDays(1),
            endDay: start.addDays(3),
            impact: FlareImpact.unableToTrain,
          ),
        );

        final days = await repository.watchProtectingFlareDays().first;
        expect(days, {
          start,
          start.addDays(1),
          start.addDays(2),
          start.addDays(3),
        });
      },
    );

    test(
      'an absurd stored range (well past the validated 90-day bound) is '
      'expanded defensively, capped at maxFlareRangeDays days',
      () async {
        // Written straight to the table, bypassing the validation the UI
        // runs - simulating a pre-validation or imported row.
        final now = DateTime.utc(2026).millisecondsSinceEpoch;
        await database.customStatement(
          'INSERT INTO flare_events '
          '(id, day, end_day, severity, symptoms, impact, created_at, '
          'updated_at) '
          "VALUES ('absurd', '2026-01-01', '2099-12-31', 'severe', '', "
          "'unableToTrain', $now, $now)",
        );

        final days = await repository.watchProtectingFlareDays().first;
        expect(days, hasLength(maxFlareRangeDays));
        expect(days, contains(LocalDate(2026, 1, 1)));
      },
    );

    test(
      'an inverted stored range (end before start) degrades to the single '
      'start day rather than producing nothing or an inverted range',
      () async {
        final now = DateTime.utc(2026).millisecondsSinceEpoch;
        await database.customStatement(
          'INSERT INTO flare_events '
          '(id, day, end_day, severity, symptoms, impact, created_at, '
          'updated_at) '
          "VALUES ('inverted', '2026-08-20', '2026-08-10', 'severe', '', "
          "'unableToTrain', $now, $now)",
        );

        final days = await repository.watchProtectingFlareDays().first;
        expect(days, {LocalDate(2026, 8, 20)});
      },
    );
  });

  group('watchProtectingFlareDays (F1)', () {
    test('emits an empty set before anything is saved', () async {
      expect(await repository.watchProtectingFlareDays().first, isEmpty);
    });

    test(
      'includes only days with an unableToTrain-impact flare - '
      'reducedTraining and none do not protect',
      () async {
        await repository.saveFlare(
          buildFlare(
            id: 'a',
            day: LocalDate(2026, 8, 1),
            impact: FlareImpact.unableToTrain,
          ),
        );
        await repository.saveFlare(
          buildFlare(id: 'b', day: LocalDate(2026, 8, 2)),
        );
        await repository.saveFlare(
          buildFlare(
            id: 'c',
            day: LocalDate(2026, 8, 3),
            impact: FlareImpact.none,
          ),
        );

        final expectation = expectLater(
          repository.watchProtectingFlareDays(),
          emitsThrough({LocalDate(2026, 8, 1)}),
        );
        await expectation;
      },
    );

    test(
      'F1: is unwindowed - a day far in the past (well beyond any fixed '
      'recency window) still appears, unlike watchRecentFlares',
      () async {
        final ancientDay = LocalDate(2020, 1, 1);
        await repository.saveFlare(
          buildFlare(
            id: 'ancient',
            day: ancientDay,
            impact: FlareImpact.unableToTrain,
          ),
        );

        final days = await repository.watchProtectingFlareDays().first;
        expect(days, contains(ancientDay));

        // The windowed sibling genuinely excludes it - confirms this is a
        // deliberate difference in behaviour, not both methods happening
        // to agree by coincidence.
        final recentOnly = await repository
            .watchRecentFlares(30, LocalDate(2026, 8, 20))
            .first;
        expect(recentOnly, isEmpty);
      },
    );

    test(
      'multiple flares on the same protecting day collapse to one',
      () async {
        final day = LocalDate(2026, 8, 1);
        await repository.saveFlare(
          buildFlare(id: 'a', day: day, impact: FlareImpact.unableToTrain),
        );
        await repository.saveFlare(
          buildFlare(id: 'b', day: day, impact: FlareImpact.unableToTrain),
        );

        final days = await repository.watchProtectingFlareDays().first;
        expect(days, {day});
      },
    );

    test('wraps a lower-level database error as StorageException', () async {
      await database.customStatement('DROP TABLE flare_events');
      await expectLater(
        repository.watchProtectingFlareDays().first,
        throwsA(isA<StorageException>()),
      );
    });
  });

  group('deleteAllData', () {
    test(
      'hard-deletes every check-in and flare row, transactionally',
      () async {
        await repository.saveCheckin(buildCheckin(id: 'c1'));
        await repository.saveFlare(buildFlare(id: 'f1'));
        await repository.saveFlare(buildFlare(id: 'f2'));

        await repository.deleteAllData();

        expect(await database.select(database.dailyCheckins).get(), isEmpty);
        expect(await database.select(database.flareEvents).get(), isEmpty);
      },
    );
  });

  group('watchCheckinsForRange', () {
    test('is inclusive at both ends and ordered oldest first', () async {
      for (final day in [
        LocalDate(2026, 7, 31),
        LocalDate(2026, 8, 1),
        LocalDate(2026, 8, 15),
        LocalDate(2026, 8, 31),
        LocalDate(2026, 9, 1),
      ]) {
        await repository.saveCheckin(buildCheckin(day: day, energy: 3));
      }

      final emitted = await repository
          .watchCheckinsForRange(LocalDate(2026, 8, 1), LocalDate(2026, 8, 31))
          .first;

      expect(emitted.map((c) => c.day), [
        LocalDate(2026, 8, 1),
        LocalDate(2026, 8, 15),
        LocalDate(2026, 8, 31),
      ]);
    });

    test('a range covering one day emits only that day', () async {
      await repository.saveCheckin(
        buildCheckin(day: LocalDate(2026, 8, 14), energy: 2),
      );
      await repository.saveCheckin(
        buildCheckin(day: LocalDate(2026, 8, 15), energy: 4),
      );

      final emitted = await repository
          .watchCheckinsForRange(LocalDate(2026, 8, 15), LocalDate(2026, 8, 15))
          .first;

      expect(emitted.single.day, LocalDate(2026, 8, 15));
      expect(emitted.single.energy, 4);
    });

    test('re-emits when a check-in inside the range is saved', () async {
      final emissions = <List<DailyCheckin>>[];
      final subscription = repository
          .watchCheckinsForRange(LocalDate(2026, 8, 1), LocalDate(2026, 8, 31))
          .listen(emissions.add);
      await pumpEventQueue();

      await repository.saveCheckin(
        buildCheckin(day: LocalDate(2026, 8, 10), sleep: 5),
      );
      await pumpEventQueue();

      expect(emissions.first, isEmpty);
      expect(emissions.last.single.day, LocalDate(2026, 8, 10));

      // Not awaited: an awaited Drift subscription cancel can wedge
      // teardown (central `testing-pitfalls.md`).
      unawaited(subscription.cancel());
    });
  });

  group('watchFlaresForRange', () {
    test('includes a flare that started before the range but runs into '
        'it', () async {
      await repository.saveFlare(
        buildFlare(
          id: 'straddles-start',
          day: LocalDate(2026, 7, 29),
          endDay: LocalDate(2026, 8, 2),
        ),
      );
      await repository.saveFlare(
        buildFlare(id: 'wholly-before', day: LocalDate(2026, 7, 20)),
      );

      final emitted = await repository
          .watchFlaresForRange(LocalDate(2026, 8, 1), LocalDate(2026, 8, 31))
          .first;

      expect(emitted.map((f) => f.id), ['straddles-start']);
    });

    test('includes a flare that starts inside the range and runs past its '
        'end', () async {
      await repository.saveFlare(
        buildFlare(
          id: 'straddles-end',
          day: LocalDate(2026, 8, 30),
          endDay: LocalDate(2026, 9, 3),
        ),
      );

      final emitted = await repository
          .watchFlaresForRange(LocalDate(2026, 8, 1), LocalDate(2026, 8, 31))
          .first;

      expect(emitted.map((f) => f.id), ['straddles-end']);
    });

    test(
      'is inclusive at both ends and ordered oldest start day first',
      () async {
        await repository.saveFlare(
          buildFlare(id: 'last', day: LocalDate(2026, 8, 31)),
        );
        await repository.saveFlare(
          buildFlare(id: 'first', day: LocalDate(2026, 8, 1)),
        );
        await repository.saveFlare(
          buildFlare(id: 'after', day: LocalDate(2026, 9, 1)),
        );

        final emitted = await repository
            .watchFlaresForRange(LocalDate(2026, 8, 1), LocalDate(2026, 8, 31))
            .first;

        expect(emitted.map((f) => f.id), ['first', 'last']);
      },
    );
  });

  group('symptomsFromCsv (CSV round-trip)', () {
    test('an empty CSV string decodes to an empty list', () {
      expect(symptomsFromCsv(''), isEmpty);
    });

    test('a single symptom round-trips', () async {
      final checkin = buildCheckin(symptoms: [SymptomType.headache]);
      await repository.saveCheckin(checkin);
      final row = await database.select(database.dailyCheckins).getSingle();
      expect(row.symptoms, 'headache');
      expect(symptomsFromCsv(row.symptoms), [SymptomType.headache]);
    });

    test('every symptom round-trips together, preserving order', () async {
      const all = SymptomType.values;
      final checkin = buildCheckin(symptoms: all);
      await repository.saveCheckin(checkin);
      final row = await database.select(database.dailyCheckins).getSingle();
      expect(symptomsFromCsv(row.symptoms), all);
    });
  });
}
