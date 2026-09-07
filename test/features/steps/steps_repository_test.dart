import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/db/app_database.dart' as db;
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/steps/data/drift_steps_repository.dart';
import 'package:menfit_app/features/steps/domain/daily_steps.dart';

void main() {
  late db.AppDatabase database;
  late DriftStepsRepository repository;

  final syncedAt = DateTime.utc(2026, 9, 3, 18);

  DailySteps row(
    String isoDay,
    int steps, {
    String? source = 'Health Connect',
    DateTime? at,
  }) {
    return DailySteps(
      day: LocalDate.parse(isoDay),
      steps: steps,
      source: source,
      syncedAt: at ?? syncedAt,
    );
  }

  setUp(() {
    database = db.AppDatabase.forTesting(NativeDatabase.memory());
    repository = DriftStepsRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  group('upsertMany + getRange', () {
    test('round-trips every field', () async {
      await repository.upsertMany([row('2026-09-01', 8123)]);

      final stored = await repository.getRange(
        LocalDate(2026, 9, 1),
        LocalDate(2026, 9, 1),
      );
      expect(stored, hasLength(1));
      expect(stored.single.day, LocalDate(2026, 9, 1));
      expect(stored.single.steps, 8123);
      expect(stored.single.source, 'Health Connect');
      expect(stored.single.syncedAt, syncedAt);
    });

    test('a null source round-trips as null, not as an empty string', () async {
      await repository.upsertMany([row('2026-09-01', 10, source: null)]);
      final stored = await repository.getRange(
        LocalDate(2026, 9, 1),
        LocalDate(2026, 9, 1),
      );
      expect(stored.single.source, isNull);
    });

    test('zero steps is stored as zero, not dropped', () async {
      await repository.upsertMany([row('2026-09-01', 0)]);
      final stored = await repository.getRange(
        LocalDate(2026, 9, 1),
        LocalDate(2026, 9, 1),
      );
      expect(stored, hasLength(1));
      expect(stored.single.steps, 0);
    });

    test('an empty list is a no-op', () async {
      await repository.upsertMany(const []);
      expect(
        await repository.getRange(
          LocalDate(2026, 9, 1),
          LocalDate(2026, 9, 30),
        ),
        isEmpty,
      );
    });

    test('upserting the same day overwrites it rather than adding a '
        'second row', () async {
      final later = DateTime.utc(2026, 9, 3, 22);
      await repository.upsertMany([row('2026-09-01', 4000)]);
      await repository.upsertMany([
        row('2026-09-01', 9500, source: 'Apple Health', at: later),
      ]);

      final stored = await repository.getRange(
        LocalDate(2026, 9, 1),
        LocalDate(2026, 9, 1),
      );
      expect(stored, hasLength(1), reason: 'one row per day, always');
      expect(stored.single.steps, 9500);
      expect(stored.single.source, 'Apple Health');
      expect(stored.single.syncedAt, later);
    });

    test('a re-sync that can no longer name the source clears it', () async {
      await repository.upsertMany([row('2026-09-01', 4000)]);
      await repository.upsertMany([row('2026-09-01', 4200, source: null)]);

      final stored = await repository.getRange(
        LocalDate(2026, 9, 1),
        LocalDate(2026, 9, 1),
      );
      expect(
        stored.single.source,
        isNull,
        reason:
            'the companion sets source explicitly, so an absent source is '
            'applied rather than leaving the old label standing',
      );
    });

    test('writes several days in one call', () async {
      await repository.upsertMany([
        row('2026-09-01', 100),
        row('2026-09-02', 200),
        row('2026-09-03', 300),
      ]);
      expect(
        await repository.getRange(LocalDate(2026, 9, 1), LocalDate(2026, 9, 3)),
        hasLength(3),
      );
    });
  });

  group('range semantics', () {
    setUp(() async {
      await repository.upsertMany([
        row('2026-08-31', 1),
        row('2026-09-01', 2),
        // 2026-09-02 deliberately absent: a day never synced has no row.
        row('2026-09-03', 4),
        row('2026-09-04', 5),
      ]);
    });

    test('both ends are inclusive', () async {
      final stored = await repository.getRange(
        LocalDate(2026, 9, 1),
        LocalDate(2026, 9, 3),
      );
      expect(stored.map((r) => r.day.toIso()), [
        '2026-09-01',
        '2026-09-03',
      ]);
    });

    test('results are oldest first', () async {
      final stored = await repository.getRange(
        LocalDate(2026, 8, 31),
        LocalDate(2026, 9, 4),
      );
      expect(stored.map((r) => r.day.toIso()), [
        '2026-08-31',
        '2026-09-01',
        '2026-09-03',
        '2026-09-04',
      ]);
    });

    test('missing days are absent, not filled with zeroes', () async {
      final stored = await repository.getRange(
        LocalDate(2026, 9, 1),
        LocalDate(2026, 9, 4),
      );
      expect(
        stored.map((r) => r.day.toIso()),
        isNot(contains('2026-09-02')),
        reason:
            'a day nothing was synced for and a day of zero steps are '
            'different statements',
      );
    });

    test('an empty window yields an empty list, not an error', () async {
      expect(
        await repository.getRange(
          LocalDate(2027, 1, 1),
          LocalDate(2027, 1, 31),
        ),
        isEmpty,
      );
    });

    test('start after end yields an empty list rather than throwing', () async {
      expect(
        await repository.getRange(LocalDate(2026, 9, 4), LocalDate(2026, 9, 1)),
        isEmpty,
      );
    });

    test(
      'a range spanning a month boundary compares chronologically',
      () async {
        // ISO day strings make lexical comparison chronological - the whole
        // reason the column is TEXT.
        final stored = await repository.getRange(
          LocalDate(2026, 8, 31),
          LocalDate(2026, 9, 1),
        );
        expect(stored.map((r) => r.day.toIso()), ['2026-08-31', '2026-09-01']);
      },
    );
  });

  group('watchRange', () {
    test('emits the current window and again on every change', () async {
      final emissions = <List<DailySteps>>[];
      final subscription = repository
          .watchRange(LocalDate(2026, 9, 1), LocalDate(2026, 9, 3))
          .listen(emissions.add);
      addTearDown(subscription.cancel);

      await pumpEventQueue();
      await repository.upsertMany([row('2026-09-01', 100)]);
      await pumpEventQueue();
      await repository.upsertMany([row('2026-09-02', 200)]);
      await pumpEventQueue();

      expect(emissions.first, isEmpty);
      expect(emissions.last.map((r) => r.day.toIso()), [
        '2026-09-01',
        '2026-09-02',
      ]);
    });

    test('matches getRange exactly - same window, same order', () async {
      await repository.upsertMany([
        row('2026-08-31', 1),
        row('2026-09-01', 2),
        row('2026-09-03', 4),
      ]);
      final watched = await repository
          .watchRange(LocalDate(2026, 9, 1), LocalDate(2026, 9, 3))
          .first;
      final fetched = await repository.getRange(
        LocalDate(2026, 9, 1),
        LocalDate(2026, 9, 3),
      );
      expect(watched, equals(fetched));
    });
  });

  group('deleteAllData', () {
    test('is a hard delete - nothing is left hiding', () async {
      await repository.upsertMany([
        row('2026-09-01', 100),
        row('2026-09-02', 200),
      ]);

      await repository.deleteAllData();

      expect(
        await repository.getRange(
          LocalDate(2026, 1, 1),
          LocalDate(2026, 12, 31),
        ),
        isEmpty,
      );
      // Straight at the table: there is no soft-delete column to hide in,
      // so the rows must genuinely be gone.
      expect(await database.select(database.dailyStepTotals).get(), isEmpty);
    });

    test('on an empty history is a no-op, not an error', () async {
      await repository.deleteAllData();
      expect(await database.select(database.dailyStepTotals).get(), isEmpty);
    });
  });
}
