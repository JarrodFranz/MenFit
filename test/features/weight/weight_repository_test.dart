import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/db/app_database.dart' as db;
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/errors/app_exception.dart';
import 'package:menfit_app/features/weight/data/drift_weight_repository.dart';
import 'package:menfit_app/features/weight/domain/weight_log.dart';

void main() {
  late db.AppDatabase database;
  late DriftWeightRepository repository;

  final day = LocalDate(2026, 9, 1);
  final createdAt = DateTime.utc(2026, 9, 1, 7);

  WeightLog log({
    required String id,
    LocalDate? on,
    // Deliberately not a value any test asserts on: every test that cares
    // about the number passes its own.
    double weightKg = 60,
    String? notes,
    WeightLogSource source = WeightLogSource.manual,
    DateTime? at,
  }) {
    final stamp = at ?? createdAt;
    return WeightLog(
      id: id,
      day: on ?? day,
      weightKg: weightKg,
      notes: notes,
      source: source,
      createdAt: stamp,
      updatedAt: stamp,
    );
  }

  setUp(() {
    database = db.AppDatabase.forTesting(NativeDatabase.memory());
    repository = DriftWeightRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  group('saveLog', () {
    test('round-trips every field, notes included', () async {
      await repository.saveLog(
        log(id: 'a', weightKg: 63.4, notes: 'morning, before breakfast'),
      );

      final stored = await repository.getLogsForRange(day, day);
      expect(stored, hasLength(1));
      final entry = stored.single;
      expect(entry.id, 'a');
      expect(entry.day, day);
      expect(entry.weightKg, 63.4);
      expect(entry.notes, 'morning, before breakfast');
      expect(entry.source, WeightLogSource.manual);
    });

    test('persists a null note as null, not an empty string', () async {
      await repository.saveLog(log(id: 'a'));

      final entry = (await repository.getLogsForRange(day, day)).single;
      expect(entry.notes, isNull);
    });

    test('round-trips every source value', () async {
      for (final source in WeightLogSource.values) {
        await repository.saveLog(log(id: source.name, source: source));
      }

      final stored = await repository.getLogsForRange(day, day);
      expect(
        stored.map((e) => e.source).toSet(),
        WeightLogSource.values.toSet(),
      );
    });

    test('upserts by id: a second save replaces rather than adds', () async {
      await repository.saveLog(log(id: 'a', weightKg: 64, notes: 'first'));
      await repository.saveLog(log(id: 'a', weightKg: 65, notes: 'second'));

      final stored = await repository.getLogsForRange(day, day);
      expect(stored, hasLength(1));
      expect(stored.single.weightKg, 65);
      expect(stored.single.notes, 'second');
    });

    test('an update clearing the note actually clears it', () async {
      await repository.saveLog(log(id: 'a', notes: 'a note'));
      await repository.saveLog(log(id: 'a'));

      final entry = (await repository.getLogsForRange(day, day)).single;
      expect(entry.notes, isNull);
    });

    test(
      'preserves createdAt across an update, and stamps updatedAt',
      () async {
        await repository.saveLog(log(id: 'a'));
        final first = (await repository.getLogsForRange(day, day)).single;

        await repository.saveLog(
          log(id: 'a', weightKg: 65, at: DateTime.utc(2030)),
        );
        final second = (await repository.getLogsForRange(day, day)).single;

        expect(
          second.createdAt,
          first.createdAt,
          reason:
              'the first-ever save owns createdAt - a later save with a '
              'different value must not move it',
        );
        expect(
          second.updatedAt.isAfter(first.createdAt),
          isTrue,
          reason:
              'updatedAt is always stamped to UTC-now, never taken from '
              'the caller',
        );
      },
    );

    test('allows several logs on the same day', () async {
      // Distinct `createdAt`s, and deliberately named so that `id` sorts
      // the *other* way ('evening' < 'morning'): the documented order
      // within a day is `createdAt` ascending, and a fixture that let the
      // id tiebreak decide would assert nothing about it.
      await repository.saveLog(
        log(id: 'morning', weightKg: 64.1, at: DateTime.utc(2026, 9, 1, 7)),
      );
      await repository.saveLog(
        log(id: 'evening', weightKg: 64.9, at: DateTime.utc(2026, 9, 1, 19)),
      );

      final stored = await repository.getLogsForRange(day, day);
      expect(stored, hasLength(2));
      expect(stored.map((e) => e.weightKg), [64.1, 64.9]);
    });
  });

  group('range reads', () {
    Future<void> seedThreeDays() async {
      await repository.saveLog(
        log(id: 'before', on: day.addDays(-1), weightKg: 63),
      );
      await repository.saveLog(log(id: 'start', weightKg: 64));
      await repository.saveLog(
        log(id: 'middle', on: day.addDays(1), weightKg: 65),
      );
      await repository.saveLog(
        log(id: 'end', on: day.addDays(2), weightKg: 66),
      );
      await repository.saveLog(
        log(id: 'after', on: day.addDays(3), weightKg: 67),
      );
    }

    test('both range ends are inclusive', () async {
      await seedThreeDays();

      final stored = await repository.getLogsForRange(day, day.addDays(2));

      expect(
        stored.map((e) => e.id),
        ['start', 'middle', 'end'],
        reason:
            'the start day and the end day are both in the window; the '
            'days either side of it are not',
      );
    });

    test('returns an empty list for a window with nothing logged', () async {
      await repository.saveLog(log(id: 'a'));

      final stored = await repository.getLogsForRange(
        day.addDays(10),
        day.addDays(20),
      );
      expect(stored, isEmpty);
    });

    test('an inverted range (start after end) yields nothing', () async {
      await seedThreeDays();

      final stored = await repository.getLogsForRange(day.addDays(2), day);
      expect(stored, isEmpty);
    });

    test('orders oldest first, ties broken by createdAt then id', () async {
      await repository.saveLog(
        log(id: 'z-same-instant', at: DateTime.utc(2026, 9, 1, 7)),
      );
      await repository.saveLog(
        log(id: 'a-same-instant', at: DateTime.utc(2026, 9, 1, 7)),
      );
      await repository.saveLog(
        log(id: 'earlier-instant', at: DateTime.utc(2026, 9, 1, 6)),
      );
      await repository.saveLog(log(id: 'previous-day', on: day.addDays(-1)));

      final stored = await repository.getLogsForRange(day.addDays(-1), day);

      expect(stored.map((e) => e.id), [
        'previous-day',
        'earlier-instant',
        'a-same-instant',
        'z-same-instant',
      ]);
    });

    test(
      'watchLogsForRange emits the same window as getLogsForRange',
      () async {
        await seedThreeDays();

        final watched = await repository
            .watchLogsForRange(day, day.addDays(2))
            .first;
        final fetched = await repository.getLogsForRange(day, day.addDays(2));

        expect(watched.map((e) => e.id), fetched.map((e) => e.id));
      },
    );

    test('watchLogsForRange re-emits when a log is added', () async {
      // emitsThrough, not emitsInOrder([[], ...]): whether the initial
      // "nothing logged yet" read lands before or after the write below is
      // a genuine race (same reasoning as `profile_repository_test.dart`);
      // what must hold is that the stream eventually reflects the save.
      final expectation = expectLater(
        repository.watchLogsForRange(day, day.addDays(2)),
        emitsThrough(
          predicate<List<WeightLog>>(
            (logs) => logs.length == 1 && logs.single.id == 'a',
          ),
        ),
      );

      await repository.saveLog(log(id: 'a'));
      await expectation;
    });
  });

  group('recent reads', () {
    test(
      'the window covers `days` days ending at today, both ends inclusive',
      () async {
        await repository.saveLog(log(id: 'too-old', on: day.addDays(-7)));
        await repository.saveLog(log(id: 'window-start', on: day.addDays(-6)));
        await repository.saveLog(log(id: 'today', on: day));

        final stored = await repository.getRecentLogs(7, day);

        expect(stored.map((e) => e.id), ['window-start', 'today']);
      },
    );

    test('a future-dated log is outside the window', () async {
      await repository.saveLog(log(id: 'tomorrow', on: day.addDays(1)));

      expect(await repository.getRecentLogs(7, day), isEmpty);
    });

    test('watchRecentLogs matches getRecentLogs', () async {
      await repository.saveLog(log(id: 'a', on: day.addDays(-3)));
      await repository.saveLog(log(id: 'b', on: day));

      final watched = await repository.watchRecentLogs(7, day).first;
      final fetched = await repository.getRecentLogs(7, day);

      expect(watched.map((e) => e.id), fetched.map((e) => e.id));
      expect(watched.map((e) => e.id), ['a', 'b']);
    });
  });

  group('latest', () {
    test('is null when nothing has ever been logged', () async {
      expect(await repository.getLatestLog(), isNull);
      expect(await repository.watchLatestLog().first, isNull);
    });

    test('is the last reading of the most recent day', () async {
      await repository.saveLog(log(id: 'older-day', on: day.addDays(-1)));
      await repository.saveLog(
        log(id: 'morning', weightKg: 64.1, at: DateTime.utc(2026, 9, 1, 7)),
      );
      await repository.saveLog(
        log(id: 'evening', weightKg: 64.9, at: DateTime.utc(2026, 9, 1, 20)),
      );

      final latest = await repository.getLatestLog();
      expect(latest?.id, 'evening');
      expect((await repository.watchLatestLog().first)?.id, 'evening');
    });
  });

  group('deletion', () {
    test('deleteLog removes only that log', () async {
      await repository.saveLog(log(id: 'a'));
      await repository.saveLog(log(id: 'b'));

      await repository.deleteLog('a');

      final stored = await repository.getLogsForRange(day, day);
      expect(stored.map((e) => e.id), ['b']);
    });

    test('deleteLog on an unknown id is a no-op, not an error', () async {
      await repository.saveLog(log(id: 'a'));

      await expectLater(repository.deleteLog('nope'), completes);
      expect(await repository.getLogsForRange(day, day), hasLength(1));
    });

    test('deleteAllData wipes every log, notes included', () async {
      await repository.saveLog(log(id: 'a', notes: 'a private note'));
      await repository.saveLog(log(id: 'b', on: day.addDays(-30)));

      await repository.deleteAllData();

      expect(
        await database.select(database.weightLogs).get(),
        isEmpty,
        reason:
            'a hard delete - no soft-deleted rows may survive with '
            'their notes',
      );
    });
  });

  group('error wrapping', () {
    test('a failed read throws a StorageException, not a raw error', () async {
      // A genuine raw error from the SQL layer (not a contrived one) - the
      // repository must catch it and never let it cross the boundary as-is.
      await database.customStatement('DROP TABLE weight_logs');

      await expectLater(
        repository.getLogsForRange(day, day),
        throwsA(isA<StorageException>()),
      );
    });

    test('a failed write throws a StorageException', () async {
      await database.customStatement('DROP TABLE weight_logs');

      await expectLater(
        repository.saveLog(log(id: 'a')),
        throwsA(isA<StorageException>()),
      );
    });

    test(
      'a StorageException message carries no weight value or note',
      () async {
        await database.customStatement('DROP TABLE weight_logs');

        try {
          await repository.saveLog(
            log(id: 'a', weightKg: 63.4, notes: 'secret'),
          );
          fail('expected a StorageException');
        } on StorageException catch (e) {
          expect(e.message, 'Failed to save weight log');
          expect(e.message, isNot(contains('63.4')));
          expect(e.message, isNot(contains('secret')));
        }
      },
    );
  });

  group('WeightLogSource storage keys', () {
    test('every value round-trips through its storage key', () {
      for (final source in WeightLogSource.values) {
        expect(WeightLogSource.fromStorage(source.toStorage()), source);
      }
    });

    test('the keys are the ones the schema and migration write', () {
      expect(WeightLogSource.manual.toStorage(), 'manual');
      expect(
        WeightLogSource.profileMigration.toStorage(),
        'profile-migration',
        reason:
            'the v18 migration writes this literal - changing it silently '
            'orphans every seeded row',
      );
      expect(WeightLogSource.healthSync.toStorage(), 'health-sync');
    });

    test('an unknown or null key falls back to manual, losing no row', () {
      expect(
        WeightLogSource.fromStorage('something-new'),
        WeightLogSource.manual,
      );
      expect(WeightLogSource.fromStorage(null), WeightLogSource.manual);
    });
  });
}
