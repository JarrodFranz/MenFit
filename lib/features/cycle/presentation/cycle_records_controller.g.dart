// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cycle_records_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Watches every non-deleted [CycleRecord], newest period-start first (same
/// shape as `features/activity/presentation/activity_list_controller.dart`'s
/// `ActivityListController`).

@ProviderFor(CycleRecordsController)
final cycleRecordsControllerProvider = CycleRecordsControllerProvider._();

/// Watches every non-deleted [CycleRecord], newest period-start first (same
/// shape as `features/activity/presentation/activity_list_controller.dart`'s
/// `ActivityListController`).
final class CycleRecordsControllerProvider
    extends $StreamNotifierProvider<CycleRecordsController, List<CycleRecord>> {
  /// Watches every non-deleted [CycleRecord], newest period-start first (same
  /// shape as `features/activity/presentation/activity_list_controller.dart`'s
  /// `ActivityListController`).
  CycleRecordsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cycleRecordsControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cycleRecordsControllerHash();

  @$internal
  @override
  CycleRecordsController create() => CycleRecordsController();
}

String _$cycleRecordsControllerHash() =>
    r'824e737d10339ae93a197ebf2ae13cb716d0462b';

/// Watches every non-deleted [CycleRecord], newest period-start first (same
/// shape as `features/activity/presentation/activity_list_controller.dart`'s
/// `ActivityListController`).

abstract class _$CycleRecordsController
    extends $StreamNotifier<List<CycleRecord>> {
  Stream<List<CycleRecord>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<CycleRecord>>, List<CycleRecord>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<CycleRecord>>, List<CycleRecord>>,
              AsyncValue<List<CycleRecord>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Watches whether streak pausing during a logged period is enabled.

@ProviderFor(StreakPausingController)
final streakPausingControllerProvider = StreakPausingControllerProvider._();

/// Watches whether streak pausing during a logged period is enabled.
final class StreakPausingControllerProvider
    extends $StreamNotifierProvider<StreakPausingController, bool> {
  /// Watches whether streak pausing during a logged period is enabled.
  StreakPausingControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'streakPausingControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$streakPausingControllerHash();

  @$internal
  @override
  StreakPausingController create() => StreakPausingController();
}

String _$streakPausingControllerHash() =>
    r'c8d47c8b43c16739ec9cf6824bad98bc477084ec';

/// Watches whether streak pausing during a logged period is enabled.

abstract class _$StreakPausingController extends $StreamNotifier<bool> {
  Stream<bool> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<bool>, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<bool>, bool>,
              AsyncValue<bool>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
