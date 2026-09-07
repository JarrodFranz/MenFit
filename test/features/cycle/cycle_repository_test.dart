import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/db/app_database.dart' as db;
import 'package:menfit_app/core/domain/entity_id.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/errors/app_exception.dart';
import 'package:menfit_app/features/cycle/data/drift_cycle_repository.dart';
import 'package:menfit_app/features/cycle/domain/cycle_record.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late db.AppDatabase database;
  late SharedPreferences prefs;
  late DriftCycleRepository repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    database = db.AppDatabase.forTesting(NativeDatabase.memory());
    repository = DriftCycleRepository(database, prefs);
  });

  tearDown(() async {
    await database.close();
  });

  CycleRecord buildRecord({
    String? id,
    LocalDate? start,
    LocalDate? end,
    DateTime? createdAt,
  }) {
    final now = createdAt ?? DateTime.utc(2026);
    return CycleRecord(
      id: id ?? EntityId.generate(),
      periodStart: start ?? LocalDate(2026, 8, 1),
      periodEnd: end,
      createdAt: now,
      updatedAt: now,
    );
  }

  group('records', () {
    test(
      'watchRecords emits an empty list before any record is saved',
      () async {
        expect(await repository.watchRecords().first, isEmpty);
      },
    );

    test('save then watch round-trips the saved record', () async {
      final record = buildRecord(
        start: LocalDate(2026, 8, 1),
        end: LocalDate(2026, 8, 5),
      );

      final expectation = expectLater(
        repository.watchRecords(),
        emitsThrough(
          predicate<List<CycleRecord>>(
            (records) =>
                records.length == 1 &&
                records.first.id == record.id &&
                records.first.periodStart == LocalDate(2026, 8, 1) &&
                records.first.periodEnd == LocalDate(2026, 8, 5),
          ),
        ),
      );

      await repository.saveRecord(record);
      await expectation;
    });

    test(
      'an ongoing record (null end) round-trips with a null periodEnd',
      () async {
        final record = buildRecord(start: LocalDate(2026, 8, 20));
        await repository.saveRecord(record);

        final records = await repository.watchRecords().first;
        expect(records.single.periodEnd, isNull);
        expect(records.single.isOngoing, isTrue);
      },
    );

    test('watchRecords orders newest periodStart first', () async {
      final older = buildRecord(id: 'a', start: LocalDate(2026, 1, 1));
      final newer = buildRecord(id: 'b', start: LocalDate(2026, 6, 1));
      final newest = buildRecord(id: 'c', start: LocalDate(2026, 8, 1));

      // Save out of order to prove ordering comes from the query, not
      // insertion order.
      await repository.saveRecord(newer);
      await repository.saveRecord(older);
      await repository.saveRecord(newest);

      final records = await repository.watchRecords().first;
      expect(records.map((r) => r.id).toList(), ['c', 'b', 'a']);
    });

    test(
      'saving again with the same id upserts rather than duplicating',
      () async {
        final record = buildRecord(id: 'r1', start: LocalDate(2026, 8, 1));
        await repository.saveRecord(record);
        await repository.saveRecord(
          record.copyWith(periodEnd: LocalDate(2026, 8, 5)),
        );

        final records = await repository.watchRecords().first;
        expect(records, hasLength(1));
        expect(records.single.periodEnd, LocalDate(2026, 8, 5));
      },
    );

    test('saveRecords persists multiple records atomically', () async {
      final r1 = buildRecord(
        id: 'b1',
        start: LocalDate(2026, 5, 1),
        end: LocalDate(2026, 5, 5),
      );
      final r2 = buildRecord(
        id: 'b2',
        start: LocalDate(2026, 6, 1),
        end: LocalDate(2026, 6, 5),
      );

      await repository.saveRecords([r1, r2]);

      final records = await repository.watchRecords().first;
      expect(records, hasLength(2));
      expect(records.map((r) => r.id).toList(), containsAll(['b1', 'b2']));
    });

    test(
      'saveRecord preserves the originally-persisted createdAt across an '
      'update, ignoring a different createdAt passed on a later call',
      () async {
        final original = DateTime.utc(2024);
        final record = buildRecord(
          id: 'r1',
          start: LocalDate(2026, 8, 1),
          createdAt: original,
        );
        await repository.saveRecord(record);

        final laterButWrong = DateTime.utc(2030);
        await repository.saveRecord(
          record.copyWith(
            createdAt: laterButWrong,
            periodEnd: LocalDate(2026, 8, 5),
          ),
        );

        final rows = await database.select(database.cycleRecords).get();
        expect(rows.single.createdAt, original.millisecondsSinceEpoch);
      },
    );

    test(
      'clearing periodEnd back to null (re-opening a period) is applied',
      () async {
        final record = buildRecord(
          id: 'r1',
          start: LocalDate(2026, 8, 1),
          end: LocalDate(2026, 8, 5),
        );
        await repository.saveRecord(record);
        await repository.saveRecord(record.copyWith(periodEnd: null));

        final records = await repository.watchRecords().first;
        expect(records.single.periodEnd, isNull);
      },
    );

    test(
      'deleteRecord hard-deletes: the row is gone, not just hidden',
      () async {
        final record = buildRecord(id: 'r1', start: LocalDate(2026, 8, 1));
        await repository.saveRecord(record);
        expect(await repository.watchRecords().first, hasLength(1));

        final expectation = expectLater(
          repository.watchRecords(),
          emitsThrough(isEmpty),
        );
        await repository.deleteRecord('r1');
        await expectation;

        // B2: a hard delete, not a soft one - the underlying row must be
        // gone entirely, not merely hidden behind `deletedAt`. Forensic
        // recoverability of a "deleted" period contradicts both the
        // delete-confirmation dialog's "This can't be undone" promise and
        // womens_health.md's strongest-protection rule for this S3 data.
        final rows = await database.select(database.cycleRecords).get();
        expect(rows, isEmpty);
      },
    );

    test('deleteAllData hard-deletes every row', () async {
      await repository.saveRecord(buildRecord(id: 'r1'));
      await repository.saveRecord(
        buildRecord(id: 'r2', start: LocalDate(2026, 6, 1)),
      );

      await repository.deleteAllData();

      final rows = await database.select(database.cycleRecords).get();
      expect(rows, isEmpty);
      expect(await repository.watchRecords().first, isEmpty);
    });

    test('wraps a lower-level database error as StorageException', () async {
      await database.customStatement('DROP TABLE cycle_records');
      await expectLater(
        repository.watchRecords().first,
        throwsA(isA<StorageException>()),
      );
    });
  });

  group('getRecords', () {
    test('returns an empty list before any record is saved', () async {
      expect(await repository.getRecords(), isEmpty);
    });

    test('one-shot fetch, newest periodStart first', () async {
      await repository.saveRecord(
        buildRecord(id: 'b', start: LocalDate(2026, 6, 1)),
      );
      await repository.saveRecord(
        buildRecord(id: 'a', start: LocalDate(2026, 1, 1)),
      );
      await repository.saveRecord(
        buildRecord(id: 'c', start: LocalDate(2026, 8, 1)),
      );

      expect(
        (await repository.getRecords()).map((r) => r.id).toList(),
        ['c', 'b', 'a'],
      );
    });

    test('returns the same snapshot watchRecords emits', () async {
      await repository.saveRecord(
        buildRecord(
          id: 'r1',
          start: LocalDate(2026, 8, 1),
          end: LocalDate(2026, 8, 5),
        ),
      );

      final watched = await repository.watchRecords().first;
      final fetched = await repository.getRecords();
      expect(fetched.map((r) => r.id).toList(), watched.map((r) => r.id));
      expect(fetched.single.periodEnd, watched.single.periodEnd);
    });

    test('wraps a lower-level database error as StorageException', () async {
      await database.customStatement('DROP TABLE cycle_records');
      await expectLater(
        repository.getRecords(),
        throwsA(isA<StorageException>()),
      );
    });
  });

  group('streak-pausing preference', () {
    test(
      // S1-2: default flipped from true to false (see
      // `domain/cycle_repository.dart#watchStreakPausingEnabled`'s
      // dartdoc for the accepted §5.8 resolution) - period-day protection
      // is no longer the only protection source, so it no longer defaults
      // on.
      'defaults to false when nothing has been saved yet',
      () async {
        expect(await repository.watchStreakPausingEnabled().first, isFalse);
      },
    );

    test(
      'setStreakPausingEnabled persists and the stream emits the change',
      () async {
        final expectation = expectLater(
          repository.watchStreakPausingEnabled(),
          emitsInOrder([false, true]),
        );
        await repository.setStreakPausingEnabled(enabled: true);
        await expectation;
      },
    );

    test('a fresh repository instance reads the persisted value', () async {
      await repository.setStreakPausingEnabled(enabled: true);

      final prefs = await SharedPreferences.getInstance();
      final freshRepository = DriftCycleRepository(database, prefs);
      expect(await freshRepository.watchStreakPausingEnabled().first, isTrue);
    });

    test('multiple subscribers each get the current value first', () async {
      await repository.setStreakPausingEnabled(enabled: true);
      expect(await repository.watchStreakPausingEnabled().first, isTrue);
      expect(await repository.watchStreakPausingEnabled().first, isTrue);
    });
  });

  group('F4: grandfathering the streak-pausing default', () {
    test(
      'an absent key with an existing cycle record grandfathers to true, '
      'and persists it',
      () async {
        // Seed a record via a throwaway repository instance before the
        // repository under test is even constructed, so its "first
        // read/watch" seed check (`_ensureGrandfatheredDefault`) finds it
        // already there.
        await DriftCycleRepository(database, prefs).saveRecord(buildRecord());

        final freshRepository = DriftCycleRepository(database, prefs);
        // The correction lands as a later emission, not necessarily the
        // first one (the seed genuinely needs an async `cycle_records`
        // query) - `emitsThrough`, same idiom this file already uses for
        // eventual-consistency assertions above.
        await expectLater(
          freshRepository.watchStreakPausingEnabled(),
          emitsThrough(isTrue),
        );
        expect(prefs.getBool('cycle_pause_streaks'), isTrue);
      },
    );

    test(
      'an absent key with no existing cycle records stays false and '
      'unpersisted (a genuinely new install)',
      () async {
        final freshRepository = DriftCycleRepository(database, prefs);
        expect(
          await freshRepository.watchStreakPausingEnabled().first,
          isFalse,
        );

        // Barrier: Drift's `NativeDatabase` serialises queries on a single
        // connection, so awaiting one more query here guarantees the
        // grandfathering seed's own (no-op) `cycle_records` query - already
        // dispatched by the `.first` subscription above - has completed,
        // without guessing at timing.
        await database.select(database.cycleRecords).get();

        expect(prefs.containsKey('cycle_pause_streaks'), isFalse);
      },
    );

    test(
      'an explicit false is never overwritten by grandfathering, even with '
      'existing cycle records',
      () async {
        await repository.setStreakPausingEnabled(enabled: false);
        await DriftCycleRepository(database, prefs).saveRecord(buildRecord());

        final freshRepository = DriftCycleRepository(database, prefs);
        expect(
          await freshRepository.watchStreakPausingEnabled().first,
          isFalse,
        );
        await database.select(database.cycleRecords).get(); // barrier
        expect(prefs.getBool('cycle_pause_streaks'), isFalse);
      },
    );
  });

  group('clearStreakPausingPreference', () {
    test('removes the key entirely, not just sets it to false', () async {
      await repository.setStreakPausingEnabled(enabled: true);
      expect(prefs.containsKey('cycle_pause_streaks'), isTrue);

      await repository.clearStreakPausingPreference();

      expect(prefs.containsKey('cycle_pause_streaks'), isFalse);
      expect(await repository.watchStreakPausingEnabled().first, isFalse);
    });
  });
}
