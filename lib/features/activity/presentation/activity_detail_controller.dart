import 'package:menfit_app/features/activity/activity_providers.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/activity/domain/activity_sample.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'activity_detail_controller.g.dart';

/// Watches a single activity by [activityId] and exposes a delete
/// operation. `null` data means the activity doesn't exist (or has been
/// deleted).
@riverpod
class ActivityDetailController extends _$ActivityDetailController {
  @override
  Stream<Activity?> build(String activityId) {
    final repository = ref.watch(activityRepositoryProvider);
    return repository.watchActivity(activityId);
  }

  /// Soft-deletes this activity (see
  /// `domain/activity_repository.dart#deleteActivity`).
  Future<void> delete() {
    final repository = ref.read(activityRepositoryProvider);
    return repository.deleteActivity(activityId);
  }
}

/// Watches every GPS/HR sample belonging to [activityId], ascending by
/// timestamp. Used by the detail screen's route map for `recorded`
/// activities (see `presentation/widgets/route_map.dart`) - manual
/// activities never have samples and never call this.
@riverpod
Stream<List<ActivitySample>> activitySamples(Ref ref, String activityId) {
  final repository = ref.watch(activityRepositoryProvider);
  return repository.watchSamples(activityId);
}

/// One-shot fetch of an activity by [activityId] for edit forms.
@riverpod
Future<Activity?> fetchActivity(Ref ref, String activityId) {
  final repository = ref.watch(activityRepositoryProvider);
  return repository.getActivity(activityId);
}
