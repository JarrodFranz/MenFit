// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_list_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Watches every non-deleted activity, newest first.

@ProviderFor(ActivityListController)
final activityListControllerProvider = ActivityListControllerProvider._();

/// Watches every non-deleted activity, newest first.
final class ActivityListControllerProvider
    extends $StreamNotifierProvider<ActivityListController, List<Activity>> {
  /// Watches every non-deleted activity, newest first.
  ActivityListControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activityListControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activityListControllerHash();

  @$internal
  @override
  ActivityListController create() => ActivityListController();
}

String _$activityListControllerHash() =>
    r'e6fceaa6afa623dc5c2737abcae444658f730bd3';

/// Watches every non-deleted activity, newest first.

abstract class _$ActivityListController
    extends $StreamNotifier<List<Activity>> {
  Stream<List<Activity>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Activity>>, List<Activity>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Activity>>, List<Activity>>,
              AsyncValue<List<Activity>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
