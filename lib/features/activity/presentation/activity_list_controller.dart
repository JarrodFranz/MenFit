import 'package:menfit_app/features/activity/activity_providers.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'activity_list_controller.g.dart';

/// Watches every non-deleted activity, newest first.
@riverpod
class ActivityListController extends _$ActivityListController {
  @override
  Stream<List<Activity>> build() {
    final repository = ref.watch(activityRepositoryProvider);
    return repository.watchActivities();
  }
}
