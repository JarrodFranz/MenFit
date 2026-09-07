import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/db/app_database.dart' as db;
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/errors/app_exception.dart';
import 'package:menfit_app/features/streaks/data/drift_recovery_repository.dart';
import 'package:menfit_app/features/streaks/domain/recovery_day_entry.dart';
import 'package:menfit_app/features/streaks/domain/recovery_validation.dart';

void main() {
  late db.AppDatabase database;
  late DriftRecoveryRepository repository;

  setUp(() {
    database = db.AppDatabase.forTesting(NativeDatabase.memory());
    repository = DriftRecoveryRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  test(
    'watchRecoveryDays emits an empty set before anything is marked',
    () async {
      expect(await repository.watchRecoveryDays().first, isEmpty);
    },
  );

  test('markRecoveryDay then watch round-trips the marked day', () async {
    final day = LocalDate(2026, 8, 20);

    final expectation = expectLater(
      repository.watchRecoveryDays(),
      emitsThrough(predicate<Set<LocalDate>>((days) => days.contains(day))),
    );
    await repository.markRecoveryDay(day);
    await expectation;
  });

  test(
    'marking the SAME DAY twice upserts to one row, keeping the first '
    'row id and createdAt',
    () async {
      final day = LocalDate(2026, 8, 20);
      await repository.markRecoveryDay(day, note: 'first note');
      await repository.markRecoveryDay(day, note: 'second note');

      final rows = await database.select(database.recoveryDays).get();
      expect(rows, hasLength(1));
      expect(rows.single.note, 'second note');
    },
  );

  test(
    'markRecoveryDay preserves the originally-persisted createdAt across '
    'an update to the same day',
    () async {
      final day = LocalDate(2026, 8, 20);
      await repository.markRecoveryDay(day);
      final firstRow = await database.select(database.recoveryDays).getSingle();

      await repository.markRecoveryDay(day, note: 'updated');
      final rows = await database.select(database.recoveryDays).get();
      expect(rows, hasLength(1));
      expect(rows.single.id, firstRow.id);
      expect(rows.single.createdAt, firstRow.createdAt);
    },
  );

  test('note is null when never provided', () async {
    final day = LocalDate(2026, 8, 20);
    await repository.markRecoveryDay(day);

    final row = await database.select(database.recoveryDays).getSingle();
    expect(row.note, isNull);
  });

  test('multiple different days can be marked independently', () async {
    await repository.markRecoveryDay(LocalDate(2026, 8, 20));
    await repository.markRecoveryDay(LocalDate(2026, 8, 21));

    final days = await repository.watchRecoveryDays().first;
    expect(days, {LocalDate(2026, 8, 20), LocalDate(2026, 8, 21)});
  });

  test(
    'markRecoveryDay rejects a future day with a ValidationException, and '
    'persists nothing',
    () async {
      final today = LocalDate.today();
      final future = today.addDays(1);

      await expectLater(
        repository.markRecoveryDay(future),
        throwsA(isA<ValidationException>()),
      );

      final rows = await database.select(database.recoveryDays).get();
      expect(rows, isEmpty);
    },
  );

  test('markRecoveryDay allows today and any day in the past', () async {
    final today = LocalDate.today();
    await repository.markRecoveryDay(today);
    await repository.markRecoveryDay(today.addDays(-30));

    final days = await repository.watchRecoveryDays().first;
    expect(days, {today, today.addDays(-30)});
  });

  test(
    'unmarkRecoveryDay hard-deletes: the row is gone, not just hidden',
    () async {
      final day = LocalDate(2026, 8, 20);
      await repository.markRecoveryDay(day);
      expect(await repository.watchRecoveryDays().first, contains(day));

      await repository.unmarkRecoveryDay(day);

      expect(await repository.watchRecoveryDays().first, isNot(contains(day)));
      final rows = await database.select(database.recoveryDays).get();
      expect(rows, isEmpty);
    },
  );

  test('unmarkRecoveryDay is a no-op for a day never marked', () async {
    await repository.unmarkRecoveryDay(LocalDate(2026, 8, 20));
    expect(await repository.watchRecoveryDays().first, isEmpty);
  });

  test('deleteAllData hard-deletes every row', () async {
    await repository.markRecoveryDay(LocalDate(2026, 8, 20));
    await repository.markRecoveryDay(LocalDate(2026, 8, 21));

    await repository.deleteAllData();

    final rows = await database.select(database.recoveryDays).get();
    expect(rows, isEmpty);
    expect(await repository.watchRecoveryDays().first, isEmpty);
  });

  test('wraps a lower-level database error as StorageException', () async {
    await database.customStatement('DROP TABLE recovery_days');
    await expectLater(
      repository.watchRecoveryDays().first,
      throwsA(isA<StorageException>()),
    );
  });

  test(
    'a StorageException from markRecoveryDay never interpolates the day '
    'value into its message (S3-adjacent)',
    () async {
      await database.customStatement('DROP TABLE recovery_days');
      try {
        await repository.markRecoveryDay(LocalDate(2026, 8, 20));
        fail('expected a StorageException');
      } on StorageException catch (e) {
        expect(e.message, 'Failed to save recovery day');
        expect(e.message, isNot(contains('2026')));
      }
    },
  );

  group('markRecoveryDays / unmarkRecoveryDays (inclusive ranges)', () {
    test(
      'marks every day in the inclusive range, endpoints included',
      () async {
        final from = LocalDate(2026, 8, 18);
        final to = LocalDate(2026, 8, 22);

        await repository.markRecoveryDays(from, to, note: 'Rest week');

        final days = await repository.watchRecoveryDays().first;
        expect(days, {
          from,
          from.addDays(1),
          from.addDays(2),
          from.addDays(3),
          to,
        });
        final rows = await database.select(database.recoveryDays).get();
        expect(rows, hasLength(5));
        expect(rows.every((r) => r.note == 'Rest week'), isTrue);
        // Neither side of the range leaks.
        expect(days, isNot(contains(from.addDays(-1))));
        expect(days, isNot(contains(to.addDays(1))));
      },
    );

    test('a from == to range marks exactly that one day', () async {
      final day = LocalDate(2026, 8, 20);
      await repository.markRecoveryDays(day, day);

      expect(await repository.watchRecoveryDays().first, {day});
    });

    test(
      'days already marked keep their id and createdAt - the range is an '
      'upsert by calendar day, not a wipe-and-reinsert',
      () async {
        final alreadyMarked = LocalDate(2026, 8, 20);
        await repository.markRecoveryDay(alreadyMarked, note: 'original');
        final before = await database.select(database.recoveryDays).getSingle();

        await repository.markRecoveryDays(
          LocalDate(2026, 8, 18),
          LocalDate(2026, 8, 22),
          note: 'Rest week',
        );

        final after = await (database.select(
          database.recoveryDays,
        )..where((t) => t.day.equals(alreadyMarked.toIso()))).getSingle();
        expect(after.id, before.id);
        expect(after.createdAt, before.createdAt);
        expect(after.note, 'Rest week', reason: 'the note is replaced');
        expect(
          await database.select(database.recoveryDays).get(),
          hasLength(5),
          reason: 'the pre-existing day is updated, not duplicated',
        );
      },
    );

    test(
      'markRecoveryDay is the single-day case of markRecoveryDays and still '
      'rejects a future day with the same ValidationException',
      () async {
        final today = LocalDate.today();
        await expectLater(
          repository.markRecoveryDay(today.addDays(1)),
          throwsA(isA<ValidationException>()),
        );
        expect(await database.select(database.recoveryDays).get(), isEmpty);
      },
    );

    test(
      'a range whose end is in the future is rejected and persists nothing '
      '- not even the valid days at its start',
      () async {
        final today = LocalDate.today();

        await expectLater(
          repository.markRecoveryDays(today.addDays(-3), today.addDays(2)),
          throwsA(isA<ValidationException>()),
        );

        expect(await database.select(database.recoveryDays).get(), isEmpty);
      },
    );

    test('a range whose end precedes its start is rejected', () async {
      await expectLater(
        repository.markRecoveryDays(
          LocalDate(2026, 8, 22),
          LocalDate(2026, 8, 18),
        ),
        throwsA(isA<ValidationException>()),
      );
      expect(await database.select(database.recoveryDays).get(), isEmpty);
    });

    test('a range longer than maxRecoveryRangeDays is rejected', () async {
      final today = LocalDate.today();
      await expectLater(
        repository.markRecoveryDays(
          today.addDays(-maxRecoveryRangeDays),
          today,
        ),
        throwsA(isA<ValidationException>()),
      );
      expect(await database.select(database.recoveryDays).get(), isEmpty);
    });

    test(
      'a mid-range failure rolls the whole transaction back, leaving days '
      'marked before the call untouched and no new days marked',
      () async {
        final survivor = LocalDate(2026, 7, 1);
        await repository.markRecoveryDay(survivor, note: 'kept');

        // A trigger that aborts on one specific day inside the range is the
        // cleanest way to provoke a failure *inside* the transaction (after
        // some days have already been written) rather than at validation
        // time, which never gets as far as the database.
        await database.customStatement('''
          CREATE TRIGGER reject_one_day BEFORE INSERT ON recovery_days
          WHEN NEW.day = '2026-08-21'
          BEGIN SELECT RAISE(ABORT, 'simulated failure'); END
        ''');

        await expectLater(
          repository.markRecoveryDays(
            LocalDate(2026, 8, 18),
            LocalDate(2026, 8, 22),
          ),
          throwsA(isA<StorageException>()),
        );

        final rows = await database.select(database.recoveryDays).get();
        expect(rows, hasLength(1));
        expect(rows.single.day, survivor.toIso());
        expect(rows.single.note, 'kept');
      },
    );

    test('unmarkRecoveryDays clears every day in the range', () async {
      await repository.markRecoveryDays(
        LocalDate(2026, 8, 18),
        LocalDate(2026, 8, 22),
      );

      await repository.unmarkRecoveryDays(
        LocalDate(2026, 8, 18),
        LocalDate(2026, 8, 22),
      );

      expect(await repository.watchRecoveryDays().first, isEmpty);
      expect(await database.select(database.recoveryDays).get(), isEmpty);
    });

    test(
      'unmarkRecoveryDays only clears days inside the range, leaving days '
      'either side marked',
      () async {
        await repository.markRecoveryDays(
          LocalDate(2026, 8, 16),
          LocalDate(2026, 8, 24),
        );

        await repository.unmarkRecoveryDays(
          LocalDate(2026, 8, 18),
          LocalDate(2026, 8, 22),
        );

        expect(await repository.watchRecoveryDays().first, {
          LocalDate(2026, 8, 16),
          LocalDate(2026, 8, 17),
          LocalDate(2026, 8, 23),
          LocalDate(2026, 8, 24),
        });
      },
    );

    test('unmarkRecoveryDays is a no-op on a range never marked', () async {
      await repository.unmarkRecoveryDays(
        LocalDate(2026, 8, 18),
        LocalDate(2026, 8, 22),
      );
      expect(await repository.watchRecoveryDays().first, isEmpty);
    });

    test(
      'unmarkRecoveryDays skips unmarked days inside a partially-marked '
      'range rather than failing',
      () async {
        await repository.markRecoveryDay(LocalDate(2026, 8, 20));

        await repository.unmarkRecoveryDays(
          LocalDate(2026, 8, 18),
          LocalDate(2026, 8, 22),
        );

        expect(await repository.watchRecoveryDays().first, isEmpty);
      },
    );

    test(
      'the note carries through a range mark and back out via '
      'watchRecoveryDayEntries',
      () async {
        await repository.markRecoveryDays(
          LocalDate(2026, 8, 18),
          LocalDate(2026, 8, 20),
          note: 'Post-race week',
        );

        final entries = await repository.watchRecoveryDayEntries().first;
        expect(entries, hasLength(3));
        expect(entries.every((e) => e.note == 'Post-race week'), isTrue);
      },
    );
  });

  group('watchRecoveryDayEntries', () {
    test('emits an empty list before anything is marked', () async {
      expect(await repository.watchRecoveryDayEntries().first, isEmpty);
    });

    test('carries the note through, unlike watchRecoveryDays', () async {
      final day = LocalDate(2026, 8, 20);
      await repository.markRecoveryDay(day, note: 'Ankle twinge');

      final entries = await repository.watchRecoveryDayEntries().first;
      expect(entries, [RecoveryDayEntry(day: day, note: 'Ankle twinge')]);
    });

    test('a day marked with no note comes back with a null note', () async {
      final day = LocalDate(2026, 8, 20);
      await repository.markRecoveryDay(day);

      final entries = await repository.watchRecoveryDayEntries().first;
      expect(entries.single.note, isNull);
    });

    test('newest day first', () async {
      await repository.markRecoveryDay(LocalDate(2026, 8, 18));
      await repository.markRecoveryDay(LocalDate(2026, 8, 20));
      await repository.markRecoveryDay(LocalDate(2026, 8, 19));

      final entries = await repository.watchRecoveryDayEntries().first;
      expect(entries.map((e) => e.day).toList(), [
        LocalDate(2026, 8, 20),
        LocalDate(2026, 8, 19),
        LocalDate(2026, 8, 18),
      ]);
    });

    test('unmarking a day removes it from the emitted list', () async {
      final day = LocalDate(2026, 8, 20);
      await repository.markRecoveryDay(day, note: 'Note');
      expect(await repository.watchRecoveryDayEntries().first, isNotEmpty);

      await repository.unmarkRecoveryDay(day);
      expect(await repository.watchRecoveryDayEntries().first, isEmpty);
    });

    test('wraps a lower-level database error as StorageException', () async {
      await database.customStatement('DROP TABLE recovery_days');
      await expectLater(
        repository.watchRecoveryDayEntries().first,
        throwsA(isA<StorageException>()),
      );
    });
  });
}
