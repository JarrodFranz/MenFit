import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/db/app_database.dart' as db;
import 'package:menfit_app/features/activity/data/drift_yoga_sequence_repository.dart';
import 'package:menfit_app/features/activity/domain/yoga_sequence.dart';

void main() {
  late db.AppDatabase database;
  late DriftYogaSequenceRepository repository;

  final stamp = DateTime.utc(2026, 9, 4, 7);

  YogaSequence sequence({
    String id = 'seq-1',
    String name = 'Morning',
    String description = '',
    List<YogaPose> poses = const [
      YogaPose(name: 'Mountain', holdSeconds: 30),
    ],
    int transitionSeconds = 5,
    String? style,
    DateTime? updatedAt,
  }) {
    return YogaSequence(
      id: id,
      name: name,
      createdAt: stamp,
      updatedAt: updatedAt ?? stamp,
      description: description,
      poses: poses,
      transitionSeconds: transitionSeconds,
      style: style,
    );
  }

  /// Writes a row straight through Drift, bypassing the repository, so a
  /// pose blob the domain would never produce can be planted.
  Future<void> insertRaw({
    required String id,
    required String posesJson,
    String name = 'Corrupt',
    int updatedAt = 0,
  }) {
    return database
        .into(database.yogaSequences)
        .insert(
          db.YogaSequencesCompanion.insert(
            id: id,
            name: name,
            posesJson: posesJson,
            createdAt: 0,
            updatedAt: updatedAt,
          ),
        );
  }

  setUp(() {
    database = db.AppDatabase.forTesting(NativeDatabase.memory());
    repository = DriftYogaSequenceRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  group('saveSequence + watchSequences', () {
    test('a saved sequence comes back with every field intact', () async {
      await repository.saveSequence(
        sequence(
          description: 'Short and slow.',
          style: 'Yin',
          transitionSeconds: 8,
          poses: const [
            YogaPose(name: 'Mountain', holdSeconds: 30, cue: 'Stand tall.'),
            YogaPose(
              name: 'Pigeon',
              holdSeconds: 45,
              side: YogaPoseSide.right,
              cue: 'Cushion under the hip if that helps.',
            ),
          ],
        ),
      );

      final stored = await repository.watchSequences().first;

      expect(stored, hasLength(1));
      final restored = stored.single;
      expect(restored.id, 'seq-1');
      expect(restored.name, 'Morning');
      expect(restored.description, 'Short and slow.');
      expect(restored.style, 'Yin');
      expect(restored.transitionSeconds, 8);
      expect(restored.createdAt, stamp);
      expect(restored.updatedAt, stamp);
      expect(restored.poses, hasLength(2));
      expect(restored.poses.last.side, YogaPoseSide.right);
      expect(restored.poses.last.cue, 'Cushion under the hip if that helps.');
      expect(restored.totalDuration, const Duration(seconds: 83));
    });

    test('a null style stays null rather than becoming empty text', () async {
      await repository.saveSequence(sequence());
      expect((await repository.watchSequences().first).single.style, isNull);
    });

    test('a sequence with no poses round-trips as empty, not as an '
        'error', () async {
      await repository.saveSequence(sequence(poses: const []));
      final stored = (await repository.watchSequences().first).single;
      expect(stored.isEmpty, isTrue);
      expect(stored.totalDuration, Duration.zero);
    });

    test('saving the same id twice updates rather than duplicating', () async {
      await repository.saveSequence(sequence());
      await repository.saveSequence(
        sequence(
          name: 'Morning, revised',
          updatedAt: stamp.add(
            const Duration(hours: 1),
          ),
        ),
      );

      final stored = await repository.watchSequences().first;
      expect(stored, hasLength(1));
      expect(stored.single.name, 'Morning, revised');
    });

    test('the list is ordered by updatedAt, most recent first', () async {
      await repository.saveSequence(
        sequence(id: 'oldest', name: 'Oldest', updatedAt: stamp),
      );
      await repository.saveSequence(
        sequence(
          id: 'newest',
          name: 'Newest',
          updatedAt: stamp.add(const Duration(days: 2)),
        ),
      );
      await repository.saveSequence(
        sequence(
          id: 'middle',
          name: 'Middle',
          updatedAt: stamp.add(const Duration(days: 1)),
        ),
      );

      final stored = await repository.watchSequences().first;
      expect(stored.map((s) => s.id), ['newest', 'middle', 'oldest']);
    });

    test('re-saving an old sequence moves it to the front', () async {
      await repository.saveSequence(sequence(id: 'a', updatedAt: stamp));
      await repository.saveSequence(
        sequence(id: 'b', updatedAt: stamp.add(const Duration(days: 1))),
      );

      await repository.saveSequence(
        sequence(id: 'a', updatedAt: stamp.add(const Duration(days: 5))),
      );

      final stored = await repository.watchSequences().first;
      expect(stored.map((s) => s.id), ['a', 'b']);
    });

    test('the stream emits again when a sequence is saved', () async {
      final emissions = <List<YogaSequence>>[];
      final subscription = repository.watchSequences().listen(emissions.add);
      addTearDown(subscription.cancel);

      await pumpEventQueue();
      await repository.saveSequence(sequence());
      await pumpEventQueue();

      expect(emissions.first, isEmpty);
      expect(emissions.last, hasLength(1));
    });

    test('a starter saved as a copy is an ordinary row under its new '
        'id', () async {
      final copy = YogaSequenceStarters.morningFlow.copyAsNew();

      await repository.saveSequence(copy);

      final stored = (await repository.watchSequences().first).single;
      expect(stored.id, copy.id);
      expect(stored.id, isNot(YogaSequenceStarters.morningFlowId));
      expect(stored.poseCount, 8);
      expect(
        stored.totalDuration,
        YogaSequenceStarters.morningFlow.totalDuration,
      );
    });

    test('starters are never rows of their own', () async {
      // The repository returns stored rows and nothing else, so a fresh
      // install is honestly empty.
      expect(await repository.watchSequences().first, isEmpty);
    });
  });

  group('getSequence', () {
    test('returns the sequence by id', () async {
      await repository.saveSequence(sequence(id: 'wanted', name: 'Wanted'));
      await repository.saveSequence(sequence(id: 'other'));

      expect((await repository.getSequence('wanted'))?.name, 'Wanted');
    });

    test('returns null for an unknown id', () async {
      expect(await repository.getSequence('nope'), isNull);
    });

    test('returns null for a soft-deleted sequence', () async {
      await repository.saveSequence(sequence(id: 'gone'));
      await repository.deleteSequence('gone');

      expect(await repository.getSequence('gone'), isNull);
    });

    test('returns null for a row whose poses cannot be parsed', () async {
      await insertRaw(id: 'broken', posesJson: 'not json at all');
      expect(await repository.getSequence('broken'), isNull);
    });
  });

  group('deleteSequence', () {
    test('hides the sequence from the watch stream', () async {
      await repository.saveSequence(sequence(id: 'a'));
      await repository.saveSequence(sequence(id: 'b'));

      await repository.deleteSequence('a');

      final stored = await repository.watchSequences().first;
      expect(stored.map((s) => s.id), ['b']);
    });

    test('is a soft delete - the row is still there, flagged', () async {
      await repository.saveSequence(sequence(id: 'a'));

      await repository.deleteSequence('a');

      final rows = await database.select(database.yogaSequences).get();
      expect(rows, hasLength(1));
      expect(rows.single.deletedAt, isNotNull);
    });

    test('saving the same id again revives it', () async {
      await repository.saveSequence(sequence(id: 'a'));
      await repository.deleteSequence('a');

      await repository.saveSequence(sequence(id: 'a', name: 'Back'));

      final stored = await repository.watchSequences().first;
      expect(stored.single.name, 'Back');
    });

    test('deleting an unknown id is a no-op, not an error', () async {
      await repository.saveSequence(sequence(id: 'a'));
      await repository.deleteSequence('missing');
      expect(await repository.watchSequences().first, hasLength(1));
    });
  });

  group('malformed poses_json', () {
    test('a row with unparseable poses is skipped, not fatal', () async {
      await repository.saveSequence(sequence(id: 'good', name: 'Good'));
      await insertRaw(id: 'broken', posesJson: '{ this is not json');

      final stored = await repository.watchSequences().first;

      expect(
        stored.map((s) => s.id),
        ['good'],
        reason: 'one unreadable row must not take the list down with it',
      );
    });

    test('a JSON object where a list belongs is skipped too', () async {
      await repository.saveSequence(sequence(id: 'good'));
      await insertRaw(id: 'object', posesJson: '{"name":"Mountain"}');

      final stored = await repository.watchSequences().first;
      expect(stored.map((s) => s.id), ['good']);
    });

    test('a list of non-objects is skipped rather than half-parsed', () async {
      await repository.saveSequence(sequence(id: 'good'));
      await insertRaw(id: 'scalars', posesJson: '[1, 2, 3]');

      final stored = await repository.watchSequences().first;
      expect(stored.map((s) => s.id), ['good']);
    });

    test('an empty pose list is valid data, not a malformed row', () async {
      await insertRaw(id: 'empty', posesJson: '[]');

      final stored = await repository.watchSequences().first;
      expect(stored.map((s) => s.id), ['empty']);
      expect(stored.single.isEmpty, isTrue);
    });

    test('a pose missing optional keys takes its defaults', () async {
      await insertRaw(id: 'sparse', posesJson: '[{"name":"Mountain"}]');

      final pose =
          (await repository.watchSequences().first).single.poses.single;
      expect(pose.name, 'Mountain');
      expect(pose.holdSeconds, defaultPoseHoldSeconds);
      expect(pose.side, YogaPoseSide.none);
      expect(pose.cue, '');
    });
  });

  group('deleteAllData', () {
    test('hard-deletes every row, soft-deleted ones included', () async {
      await repository.saveSequence(sequence(id: 'live'));
      await repository.saveSequence(sequence(id: 'hidden'));
      await repository.deleteSequence('hidden');

      await repository.deleteAllData();

      expect(await database.select(database.yogaSequences).get(), isEmpty);
    });

    test('on an empty table it is a no-op', () async {
      await repository.deleteAllData();
      expect(await repository.watchSequences().first, isEmpty);
    });
  });
}
