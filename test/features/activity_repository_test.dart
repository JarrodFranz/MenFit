import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/db/app_database.dart' as db;
import 'package:menfit_app/core/domain/entity_id.dart';
import 'package:menfit_app/core/errors/app_exception.dart';
import 'package:menfit_app/features/activity/data/drift_activity_repository.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/activity/domain/activity_sample.dart';

void main() {
  late db.AppDatabase database;
  late DriftActivityRepository repository;

  setUp(() {
    database = db.AppDatabase.forTesting(NativeDatabase.memory());
    repository = DriftActivityRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  Activity buildActivity({
    String? id,
    DateTime? startedAt,
    DateTime? createdAt,
    String title = 'Morning Run',
    double distanceMeters = 5000,
  }) {
    final created = createdAt ?? DateTime.utc(2026);
    return Activity(
      id: id ?? EntityId.generate(),
      activityType: ActivityType.run,
      title: title,
      startedAt: startedAt ?? DateTime.utc(2026),
      movingTime: const Duration(minutes: 30),
      elapsedTime: const Duration(minutes: 30),
      distanceMeters: distanceMeters,
      source: ActivitySource.manual,
      createdAt: created,
      updatedAt: created,
    );
  }

  group('saveActivity / watchActivities', () {
    test('save then watch round-trips the saved activity', () async {
      final activity = buildActivity();

      final expectation = expectLater(
        repository.watchActivities(),
        emitsThrough(
          predicate<List<Activity>>(
            (list) => list.any((a) => a.id == activity.id),
          ),
        ),
      );

      await repository.saveActivity(activity);
      await expectation;

      final all = await repository.watchActivities().first;
      expect(all, hasLength(1));
      expect(all.single.title, 'Morning Run');
      expect(all.single.distanceMeters, 5000);
    });

    test('watchActivities emits newest startedAt first', () async {
      final older = buildActivity(
        id: EntityId.generate(),
        startedAt: DateTime.utc(2026),
        title: 'Older',
      );
      final newer = buildActivity(
        id: EntityId.generate(),
        startedAt: DateTime.utc(2026, 1, 3),
        title: 'Newer',
      );
      final middle = buildActivity(
        id: EntityId.generate(),
        startedAt: DateTime.utc(2026, 1, 2),
        title: 'Middle',
      );

      await repository.saveActivity(older);
      await repository.saveActivity(newer);
      await repository.saveActivity(middle);

      final all = await repository.watchActivities().first;
      expect(all.map((a) => a.title).toList(), ['Newer', 'Middle', 'Older']);
    });

    test(
      'saving again with the same id upserts rather than duplicating',
      () async {
        final activity = buildActivity();
        await repository.saveActivity(activity);
        await repository.saveActivity(
          activity.copyWith(title: 'Updated title', distanceMeters: 6000),
        );

        final all = await repository.watchActivities().first;
        expect(all, hasLength(1));
        expect(all.single.title, 'Updated title');
        expect(all.single.distanceMeters, 6000);
      },
    );

    test(
      'saveActivity preserves createdAt from the first save, ignoring a '
      'different createdAt passed on a later call for the same id',
      () async {
        final original = DateTime.utc(2024);
        final activity = buildActivity(createdAt: original);
        await repository.saveActivity(activity);

        final laterButWrong = DateTime.utc(2030);
        await repository.saveActivity(
          activity.copyWith(createdAt: laterButWrong, title: 'Renamed'),
        );

        final all = await repository.watchActivities().first;
        expect(all.single.createdAt, original);
        expect(all.single.title, 'Renamed');
      },
    );

    test('saveActivity always advances updatedAt to now, in UTC', () async {
      final past = DateTime.utc(2020);
      final activity = buildActivity(
        createdAt: past,
      ).copyWith(updatedAt: past);

      final before = DateTime.now().toUtc();
      await repository.saveActivity(activity);
      final after = DateTime.now().toUtc();

      final all = await repository.watchActivities().first;
      final saved = all.single;
      expect(saved.updatedAt.isUtc, isTrue);
      expect(
        saved.updatedAt.isAfter(before.subtract(const Duration(seconds: 1))),
        isTrue,
      );
      expect(
        saved.updatedAt.isBefore(after.add(const Duration(seconds: 1))),
        isTrue,
      );
      expect(saved.createdAt, past);
    });
  });

  group('watchActivity', () {
    test('emits the matching activity by id', () async {
      final activity = buildActivity();
      await repository.saveActivity(activity);

      final found = await repository.watchActivity(activity.id).first;
      expect(found, isNotNull);
      expect(found!.id, activity.id);
    });

    test('emits null for an id that does not exist', () async {
      final found = await repository.watchActivity('nope').first;
      expect(found, isNull);
    });
  });

  group('getActivities', () {
    test('one-shot fetch, newest startedAt first', () async {
      final older = buildActivity(startedAt: DateTime.utc(2026, 1, 5));
      final newer = buildActivity(startedAt: DateTime.utc(2026, 3, 9));
      await repository.saveActivity(older);
      await repository.saveActivity(newer);

      final fetched = await repository.getActivities();
      expect(fetched.map((a) => a.id).toList(), [newer.id, older.id]);
    });

    test('returns an empty list before anything is saved', () async {
      expect(await repository.getActivities(), isEmpty);
    });

    test('excludes soft-deleted activities', () async {
      final activity = buildActivity();
      await repository.saveActivity(activity);
      await repository.deleteActivity(activity.id);

      expect(await repository.getActivities(), isEmpty);
    });

    test('returns the same snapshot watchActivities emits', () async {
      await repository.saveActivity(
        buildActivity(startedAt: DateTime.utc(2026, 2, 2)),
      );
      await repository.saveActivity(
        buildActivity(startedAt: DateTime.utc(2026, 4, 4)),
      );

      final watched = await repository.watchActivities().first;
      final fetched = await repository.getActivities();
      expect(fetched.map((a) => a.id).toList(), watched.map((a) => a.id));
    });

    test('wraps a lower-level database error as StorageException', () async {
      await database.customStatement('DROP TABLE activities');
      await expectLater(
        repository.getActivities(),
        throwsA(isA<StorageException>()),
      );
    });
  });

  group('deleteActivity (soft delete)', () {
    test(
      'hides the activity from watchActivities/watchActivity but the row '
      'remains in the underlying table',
      () async {
        final activity = buildActivity();
        await repository.saveActivity(activity);
        expect(await repository.watchActivities().first, hasLength(1));

        final expectation = expectLater(
          repository.watchActivities(),
          emitsThrough(isEmpty),
        );
        await repository.deleteActivity(activity.id);
        await expectation;

        expect(await repository.watchActivity(activity.id).first, isNull);

        // The row is soft-deleted, not gone - it's still present in the
        // underlying Drift table with `deletedAt` set (ADR 004).
        final rawRows = await database.select(database.activities).get();
        expect(rawRows, hasLength(1));
        expect(rawRows.single.id, activity.id);
        expect(rawRows.single.deletedAt, isNotNull);
      },
    );
  });

  group('insertSamples / watchSamples', () {
    test(
      'batch-inserts samples and watches them ordered by timestamp',
      () async {
        final activity = buildActivity();
        await repository.saveActivity(activity);

        final base = DateTime.utc(2026, 1, 1, 8);
        final samples = [
          ActivitySample(
            id: EntityId.generate(),
            activityId: activity.id,
            timestamp: base.add(const Duration(seconds: 10)),
            latitude: 51.501,
            longitude: -0.141,
          ),
          ActivitySample(
            id: EntityId.generate(),
            activityId: activity.id,
            timestamp: base,
            latitude: 51.5,
            longitude: -0.14,
          ),
          ActivitySample(
            id: EntityId.generate(),
            activityId: activity.id,
            timestamp: base.add(const Duration(seconds: 20)),
            latitude: 51.502,
            longitude: -0.142,
          ),
        ];

        await repository.insertSamples(samples);

        final watched = await repository.watchSamples(activity.id).first;
        expect(watched, hasLength(3));
        expect(
          watched.map((s) => s.timestamp).toList(),
          [
            base,
            base.add(const Duration(seconds: 10)),
            base.add(const Duration(seconds: 20)),
          ],
        );
      },
    );

    test('excludes samples belonging to a different activity', () async {
      final activityA = buildActivity(id: EntityId.generate());
      final activityB = buildActivity(id: EntityId.generate());
      await repository.saveActivity(activityA);
      await repository.saveActivity(activityB);

      await repository.insertSamples([
        ActivitySample(
          id: EntityId.generate(),
          activityId: activityA.id,
          timestamp: DateTime.utc(2026),
          latitude: 1,
          longitude: 1,
        ),
        ActivitySample(
          id: EntityId.generate(),
          activityId: activityB.id,
          timestamp: DateTime.utc(2026),
          latitude: 2,
          longitude: 2,
        ),
      ]);

      final watchedA = await repository.watchSamples(activityA.id).first;
      expect(watchedA, hasLength(1));
      expect(watchedA.single.activityId, activityA.id);
    });

    test('insertSamples with an empty list is a no-op', () async {
      await repository.insertSamples(const []);
      final rows = await database.select(database.activitySamples).get();
      expect(rows, isEmpty);
    });
  });

  group('getSamples', () {
    test('one-shot fetch, ordered by timestamp ascending', () async {
      final activity = buildActivity();
      await repository.saveActivity(activity);

      final base = DateTime.utc(2026, 1, 1, 8);
      await repository.insertSamples([
        ActivitySample(
          id: EntityId.generate(),
          activityId: activity.id,
          timestamp: base.add(const Duration(seconds: 20)),
          latitude: 51.502,
          longitude: -0.142,
        ),
        ActivitySample(
          id: EntityId.generate(),
          activityId: activity.id,
          timestamp: base,
          latitude: 51.5,
          longitude: -0.14,
        ),
      ]);

      final fetched = await repository.getSamples(activity.id);
      expect(fetched.map((s) => s.timestamp).toList(), [
        base,
        base.add(const Duration(seconds: 20)),
      ]);
    });

    test('returns an empty list for an activity with no samples', () async {
      final activity = buildActivity();
      await repository.saveActivity(activity);

      expect(await repository.getSamples(activity.id), isEmpty);
    });

    test('returns an empty list for an id that does not exist', () async {
      expect(await repository.getSamples('nope'), isEmpty);
    });

    test('wraps a lower-level database error as StorageException', () async {
      await database.customStatement('DROP TABLE activity_samples');
      await expectLater(
        repository.getSamples('any-id'),
        throwsA(isA<StorageException>()),
      );
    });
  });

  group('getSamplesForActivities', () {
    ActivitySample sampleAt(String activityId, DateTime timestamp) {
      return ActivitySample(
        id: EntityId.generate(),
        activityId: activityId,
        timestamp: timestamp,
        latitude: 51.5,
        longitude: -0.14,
      );
    }

    test('groups by activity id, each entry timestamp-ascending', () async {
      final first = buildActivity();
      final second = buildActivity();
      await repository.saveActivity(first);
      await repository.saveActivity(second);

      final base = DateTime.utc(2026, 1, 1, 8);
      await repository.insertSamples([
        sampleAt(first.id, base.add(const Duration(seconds: 30))),
        sampleAt(second.id, base.add(const Duration(seconds: 10))),
        sampleAt(first.id, base),
        sampleAt(second.id, base.add(const Duration(seconds: 40))),
      ]);

      final grouped = await repository.getSamplesForActivities([
        first.id,
        second.id,
      ]);

      expect(grouped.keys.toSet(), {first.id, second.id});
      expect(grouped[first.id]!.map((s) => s.timestamp).toList(), [
        base,
        base.add(const Duration(seconds: 30)),
      ]);
      expect(grouped[second.id]!.map((s) => s.timestamp).toList(), [
        base.add(const Duration(seconds: 10)),
        base.add(const Duration(seconds: 40)),
      ]);
      expect(
        grouped[first.id]!.every((s) => s.activityId == first.id),
        isTrue,
        reason: "no other activity's samples leak into an entry",
      );
    });

    test('matches getSamples exactly for each requested id', () async {
      final activity = buildActivity();
      await repository.saveActivity(activity);

      final base = DateTime.utc(2026, 1, 1, 8);
      await repository.insertSamples([
        sampleAt(activity.id, base.add(const Duration(seconds: 20))),
        sampleAt(activity.id, base),
        sampleAt(activity.id, base.add(const Duration(seconds: 5))),
      ]);

      final one = await repository.getSamples(activity.id);
      final many = await repository.getSamplesForActivities([activity.id]);

      expect(many[activity.id]!.map((s) => s.id).toList(), [
        for (final sample in one) sample.id,
      ]);
    });

    test('omits ids with no samples rather than mapping them to []', () async {
      final withSamples = buildActivity();
      final manual = buildActivity();
      await repository.saveActivity(withSamples);
      await repository.saveActivity(manual);
      await repository.insertSamples([
        sampleAt(withSamples.id, DateTime.utc(2026, 1, 1, 8)),
      ]);

      final grouped = await repository.getSamplesForActivities([
        withSamples.id,
        manual.id,
        'does-not-exist',
      ]);

      expect(grouped.keys, [withSamples.id]);
      expect(grouped.containsKey(manual.id), isFalse);
      expect(grouped[manual.id] ?? const [], isEmpty);
    });

    test('collapses duplicate ids instead of repeating their rows', () async {
      final activity = buildActivity();
      await repository.saveActivity(activity);
      await repository.insertSamples([
        sampleAt(activity.id, DateTime.utc(2026, 1, 1, 8)),
      ]);

      final grouped = await repository.getSamplesForActivities([
        activity.id,
        activity.id,
      ]);

      expect(grouped[activity.id], hasLength(1));
    });

    test(
      'empty ids returns an empty map without touching the database',
      () async {
        // The table is gone, so any query at all would throw - proving the
        // empty-input short circuit never reaches storage.
        await database.customStatement('DROP TABLE activity_samples');

        expect(await repository.getSamplesForActivities(const []), isEmpty);
      },
    );

    test('wraps a lower-level database error as StorageException', () async {
      await database.customStatement('DROP TABLE activity_samples');
      await expectLater(
        repository.getSamplesForActivities(const ['any-id']),
        throwsA(isA<StorageException>()),
      );
    });
  });

  group('saveRecordedActivity', () {
    ActivitySample sampleFor(String activityId, {String? id}) {
      return ActivitySample(
        id: id ?? EntityId.generate(),
        activityId: activityId,
        timestamp: DateTime.utc(2026, 1, 1, 8),
        latitude: 51.5,
        longitude: -0.14,
      );
    }

    test('persists the activity and its samples together', () async {
      final activity = buildActivity();
      final samples = [sampleFor(activity.id), sampleFor(activity.id)];

      await repository.saveRecordedActivity(activity, samples);

      expect(await repository.watchActivity(activity.id).first, isNotNull);
      expect(await repository.getSamples(activity.id), hasLength(2));
    });

    test(
      'rolls the activity back when the sample write fails - never leaves a '
      'recorded activity with an empty GPS track',
      () async {
        final activity = buildActivity();
        // Two samples sharing one id: the batch insert violates the primary
        // key, failing mid-transaction after the activity row was written.
        const duplicateId = 'duplicate-sample-id';
        final samples = [
          sampleFor(activity.id, id: duplicateId),
          sampleFor(activity.id, id: duplicateId),
        ];

        await expectLater(
          repository.saveRecordedActivity(activity, samples),
          throwsA(isA<StorageException>()),
        );

        expect(
          await repository.watchActivity(activity.id).first,
          isNull,
          reason:
              'the activity row must not survive a failed sample write - '
              'an orphaned activity is unrecoverable once the pending data '
              'leaves controller memory',
        );
        expect(await repository.getSamples(activity.id), isEmpty);
      },
    );

    test('accepts an empty sample list (a recording with no fixes)', () async {
      final activity = buildActivity();

      await repository.saveRecordedActivity(activity, const []);

      expect(await repository.watchActivity(activity.id).first, isNotNull);
      expect(await repository.getSamples(activity.id), isEmpty);
    });
  });

  test('wraps a lower-level database error as StorageException', () async {
    await database.customStatement('DROP TABLE activities');
    await expectLater(
      repository.watchActivities().first,
      throwsA(isA<StorageException>()),
    );
  });
}
