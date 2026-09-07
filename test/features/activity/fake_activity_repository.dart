import 'dart:async';

import 'package:menfit_app/core/errors/app_exception.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/activity/domain/activity_repository.dart';
import 'package:menfit_app/features/activity/domain/activity_sample.dart';

/// In-memory [ActivityRepository] whose writes can be made to fail.
///
/// [failSaves] is the point of it: a repository that always succeeds cannot
/// show whether a controller leaves a session recoverable when the disk
/// does not, and "the write threw" is the one path every save button has
/// and almost no test exercises.
class FakeActivityRepository implements ActivityRepository {
  final List<Activity> saved = [];
  final _controller = StreamController<List<Activity>>.broadcast();

  /// While true, every [saveActivity] throws a [StorageException] — the
  /// same sealed type the Drift repository wraps its failures in.
  bool failSaves = false;

  /// How many times a save was attempted, successful or not.
  int saveAttempts = 0;

  Future<void> dispose() => _controller.close();

  @override
  Stream<List<Activity>> watchActivities() async* {
    yield saved;
    yield* _controller.stream;
  }

  @override
  Future<List<Activity>> getActivities() async => List.of(saved);

  @override
  Stream<Activity?> watchActivity(String id) => watchActivities().map(
    (list) => list.where((a) => a.id == id).firstOrNull,
  );

  @override
  Future<Activity?> getActivity(String id) async =>
      saved.where((a) => a.id == id).firstOrNull;

  @override
  Future<void> saveActivity(Activity activity) async {
    saveAttempts++;
    if (failSaves) {
      throw const StorageException(message: 'disk full');
    }
    saved
      ..removeWhere((a) => a.id == activity.id)
      ..add(activity);
    _controller.add(List.of(saved));
  }

  final Map<String, List<ActivitySample>> savedSamples = {};

  @override
  Future<void> saveRecordedActivity(
    Activity activity,
    List<ActivitySample> samples,
  ) async {
    await saveActivity(activity);
    savedSamples[activity.id] = List.of(samples);
  }

  @override
  Future<void> deleteActivity(String id) async {
    saved.removeWhere((a) => a.id == id);
    savedSamples.remove(id);
    _controller.add(List.of(saved));
  }

  @override
  Future<void> insertSamples(List<ActivitySample> samples) async {
    for (final sample in samples) {
      savedSamples.putIfAbsent(sample.activityId, () => []).add(sample);
    }
  }

  @override
  Stream<List<ActivitySample>> watchSamples(String activityId) =>
      Stream.value(savedSamples[activityId] ?? const []);

  @override
  Future<List<ActivitySample>> getSamples(String activityId) async =>
      List.of(savedSamples[activityId] ?? const []);

  @override
  Future<Map<String, List<ActivitySample>>> getSamplesForActivities(
    List<String> activityIds,
  ) async {
    return {
      for (final id in activityIds)
        if (savedSamples.containsKey(id)) id: List.of(savedSamples[id]!),
    };
  }

  @override
  Future<void> deleteAllData() async {
    saved.clear();
    savedSamples.clear();
  }
}
