import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/features/activity/activity_providers.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/activity/domain/activity_repository.dart';
import 'package:menfit_app/features/activity/domain/activity_sample.dart';
import 'package:menfit_app/features/activity/domain/personal_records.dart';

/// A controllable [ActivityRepository] fake: [watchActivities] is driven
/// directly by the test via [emit], and [getSamples] for a given activity
/// id doesn't resolve until the test explicitly [resolveSamples] for it -
/// this is what lets a test land two overlapping rescans mid-flight and
/// control which one's `getSamples` future resolves first.
class _GatedRepository implements ActivityRepository {
  final _activitiesController = StreamController<List<Activity>>.broadcast();
  final Map<String, Completer<List<ActivitySample>>> _gates = {};

  @override
  Stream<List<Activity>> watchActivities() => _activitiesController.stream;

  @override
  Future<List<Activity>> getActivities() => throw UnimplementedError();

  @override
  Future<Activity?> getActivity(String id) => throw UnimplementedError();

  @override
  Future<List<ActivitySample>> getSamples(String activityId) {
    final gate = _gates.putIfAbsent(
      activityId,
      Completer<List<ActivitySample>>.new,
    );
    return gate.future;
  }

  void emit(List<Activity> activities) => _activitiesController.add(activities);

  void resolveSamples(String activityId) {
    _gates[activityId]!.complete(const <ActivitySample>[]);
  }

  Future<void> close() => _activitiesController.close();

  @override
  Stream<Activity?> watchActivity(String id) => throw UnimplementedError();

  @override
  Future<void> saveActivity(Activity activity) => throw UnimplementedError();

  @override
  Future<void> saveRecordedActivity(
    Activity activity,
    List<ActivitySample> samples,
  ) => throw UnimplementedError();

  @override
  Future<void> deleteActivity(String id) => throw UnimplementedError();

  @override
  Future<void> insertSamples(List<ActivitySample> samples) =>
      throw UnimplementedError();

  @override
  Stream<List<ActivitySample>> watchSamples(String activityId) =>
      throw UnimplementedError();

  @override
  Future<Map<String, List<ActivitySample>>> getSamplesForActivities(
    List<String> ids,
  ) => throw UnimplementedError();

  @override
  Future<void> deleteAllData() => throw UnimplementedError();
}

Activity _recordedActivity({
  required String id,
  required double distanceMeters,
}) {
  final when = DateTime.utc(2026);
  return Activity(
    id: id,
    activityType: ActivityType.run,
    title: id,
    startedAt: when,
    movingTime: const Duration(minutes: 10),
    elapsedTime: const Duration(minutes: 10),
    distanceMeters: distanceMeters,
    source: ActivitySource.recorded,
    createdAt: when,
    updatedAt: when,
  );
}

void main() {
  test(
    'a slow, superseded rescan never overwrites a faster, newer one - the '
    'final state reflects only the last emission (F7)',
    () async {
      final repository = _GatedRepository();
      final container = ProviderContainer(
        overrides: [activityRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);
      addTearDown(repository.close);

      final seenStates = <PersonalRecords>[];
      container.listen(personalRecordsProvider, (previous, next) {
        next.whenData(seenStates.add);
      });
      // Activate the provider/subscribe to watchActivities().
      await Future<void>.delayed(Duration.zero);

      // Emission 1: activity "a" (distance 1000m). Its rescan will await
      // getSamples('a'), which stays gated (unresolved) throughout most of
      // this test - simulating a slow rescan.
      repository.emit([_recordedActivity(id: 'a', distanceMeters: 1000)]);
      await Future<void>.delayed(Duration.zero);

      // Emission 2 arrives before emission 1's rescan has resolved its
      // getSamples await - a newer emission superseding an in-flight one.
      repository.emit([_recordedActivity(id: 'b', distanceMeters: 2000)]);
      await Future<void>.delayed(Duration.zero);

      // Resolve the NEWER rescan's samples first - it should land normally.
      repository.resolveSamples('b');
      await Future<void>.delayed(Duration.zero);

      expect(seenStates, hasLength(1));
      expect(seenStates.single.longestDistance!.activityId, 'b');

      // Now let the OLDER (stale) rescan's getSamples finally resolve. It
      // must be abandoned - not emit a second, regressive state.
      repository.resolveSamples('a');
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(
        seenStates,
        hasLength(1),
        reason:
            'the stale rescan for "a" must never emit after being '
            'superseded by "b"',
      );
      expect(seenStates.single.longestDistance!.activityId, 'b');
    },
  );
}
