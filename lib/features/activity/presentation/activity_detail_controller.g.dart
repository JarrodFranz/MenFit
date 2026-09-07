// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_detail_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Watches a single activity by [activityId] and exposes a delete
/// operation. `null` data means the activity doesn't exist (or has been
/// deleted).

@ProviderFor(ActivityDetailController)
final activityDetailControllerProvider = ActivityDetailControllerFamily._();

/// Watches a single activity by [activityId] and exposes a delete
/// operation. `null` data means the activity doesn't exist (or has been
/// deleted).
final class ActivityDetailControllerProvider
    extends $StreamNotifierProvider<ActivityDetailController, Activity?> {
  /// Watches a single activity by [activityId] and exposes a delete
  /// operation. `null` data means the activity doesn't exist (or has been
  /// deleted).
  ActivityDetailControllerProvider._({
    required ActivityDetailControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'activityDetailControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$activityDetailControllerHash();

  @override
  String toString() {
    return r'activityDetailControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ActivityDetailController create() => ActivityDetailController();

  @override
  bool operator ==(Object other) {
    return other is ActivityDetailControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$activityDetailControllerHash() =>
    r'e25390c79ddb415addce67cd27a43575520ca6d1';

/// Watches a single activity by [activityId] and exposes a delete
/// operation. `null` data means the activity doesn't exist (or has been
/// deleted).

final class ActivityDetailControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          ActivityDetailController,
          AsyncValue<Activity?>,
          Activity?,
          Stream<Activity?>,
          String
        > {
  ActivityDetailControllerFamily._()
    : super(
        retry: null,
        name: r'activityDetailControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Watches a single activity by [activityId] and exposes a delete
  /// operation. `null` data means the activity doesn't exist (or has been
  /// deleted).

  ActivityDetailControllerProvider call(String activityId) =>
      ActivityDetailControllerProvider._(argument: activityId, from: this);

  @override
  String toString() => r'activityDetailControllerProvider';
}

/// Watches a single activity by [activityId] and exposes a delete
/// operation. `null` data means the activity doesn't exist (or has been
/// deleted).

abstract class _$ActivityDetailController extends $StreamNotifier<Activity?> {
  late final _$args = ref.$arg as String;
  String get activityId => _$args;

  Stream<Activity?> build(String activityId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Activity?>, Activity?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Activity?>, Activity?>,
              AsyncValue<Activity?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

/// Watches every GPS/HR sample belonging to [activityId], ascending by
/// timestamp. Used by the detail screen's route map for `recorded`
/// activities (see `presentation/widgets/route_map.dart`) - manual
/// activities never have samples and never call this.

@ProviderFor(activitySamples)
final activitySamplesProvider = ActivitySamplesFamily._();

/// Watches every GPS/HR sample belonging to [activityId], ascending by
/// timestamp. Used by the detail screen's route map for `recorded`
/// activities (see `presentation/widgets/route_map.dart`) - manual
/// activities never have samples and never call this.

final class ActivitySamplesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ActivitySample>>,
          List<ActivitySample>,
          Stream<List<ActivitySample>>
        >
    with
        $FutureModifier<List<ActivitySample>>,
        $StreamProvider<List<ActivitySample>> {
  /// Watches every GPS/HR sample belonging to [activityId], ascending by
  /// timestamp. Used by the detail screen's route map for `recorded`
  /// activities (see `presentation/widgets/route_map.dart`) - manual
  /// activities never have samples and never call this.
  ActivitySamplesProvider._({
    required ActivitySamplesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'activitySamplesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$activitySamplesHash();

  @override
  String toString() {
    return r'activitySamplesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<ActivitySample>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<ActivitySample>> create(Ref ref) {
    final argument = this.argument as String;
    return activitySamples(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ActivitySamplesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$activitySamplesHash() => r'683f978cf653127e57a42efc5e4875f1eeb165e0';

/// Watches every GPS/HR sample belonging to [activityId], ascending by
/// timestamp. Used by the detail screen's route map for `recorded`
/// activities (see `presentation/widgets/route_map.dart`) - manual
/// activities never have samples and never call this.

final class ActivitySamplesFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<ActivitySample>>, String> {
  ActivitySamplesFamily._()
    : super(
        retry: null,
        name: r'activitySamplesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Watches every GPS/HR sample belonging to [activityId], ascending by
  /// timestamp. Used by the detail screen's route map for `recorded`
  /// activities (see `presentation/widgets/route_map.dart`) - manual
  /// activities never have samples and never call this.

  ActivitySamplesProvider call(String activityId) =>
      ActivitySamplesProvider._(argument: activityId, from: this);

  @override
  String toString() => r'activitySamplesProvider';
}

/// One-shot fetch of an activity by [activityId] for edit forms.

@ProviderFor(fetchActivity)
final fetchActivityProvider = FetchActivityFamily._();

/// One-shot fetch of an activity by [activityId] for edit forms.

final class FetchActivityProvider
    extends
        $FunctionalProvider<
          AsyncValue<Activity?>,
          Activity?,
          FutureOr<Activity?>
        >
    with $FutureModifier<Activity?>, $FutureProvider<Activity?> {
  /// One-shot fetch of an activity by [activityId] for edit forms.
  FetchActivityProvider._({
    required FetchActivityFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'fetchActivityProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$fetchActivityHash();

  @override
  String toString() {
    return r'fetchActivityProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Activity?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Activity?> create(Ref ref) {
    final argument = this.argument as String;
    return fetchActivity(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is FetchActivityProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$fetchActivityHash() => r'f82f61d9f5a8b2103ea4e9b0ea8b729e0d450f38';

/// One-shot fetch of an activity by [activityId] for edit forms.

final class FetchActivityFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Activity?>, String> {
  FetchActivityFamily._()
    : super(
        retry: null,
        name: r'fetchActivityProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One-shot fetch of an activity by [activityId] for edit forms.

  FetchActivityProvider call(String activityId) =>
      FetchActivityProvider._(argument: activityId, from: this);

  @override
  String toString() => r'fetchActivityProvider';
}
