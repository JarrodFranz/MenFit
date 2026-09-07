// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wearables_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(watchCompanionAdapter)
final watchCompanionAdapterProvider = WatchCompanionAdapterProvider._();

final class WatchCompanionAdapterProvider
    extends
        $FunctionalProvider<
          WatchCompanionAdapter,
          WatchCompanionAdapter,
          WatchCompanionAdapter
        >
    with $Provider<WatchCompanionAdapter> {
  WatchCompanionAdapterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'watchCompanionAdapterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$watchCompanionAdapterHash();

  @$internal
  @override
  $ProviderElement<WatchCompanionAdapter> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  WatchCompanionAdapter create(Ref ref) {
    return watchCompanionAdapter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WatchCompanionAdapter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WatchCompanionAdapter>(value),
    );
  }
}

String _$watchCompanionAdapterHash() =>
    r'688ff15c8217210129b98338065de637b30a49ba';

@ProviderFor(wearableWorkoutSyncService)
final wearableWorkoutSyncServiceProvider =
    WearableWorkoutSyncServiceProvider._();

final class WearableWorkoutSyncServiceProvider
    extends
        $FunctionalProvider<
          WearableWorkoutSyncService,
          WearableWorkoutSyncService,
          WearableWorkoutSyncService
        >
    with $Provider<WearableWorkoutSyncService> {
  WearableWorkoutSyncServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'wearableWorkoutSyncServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$wearableWorkoutSyncServiceHash();

  @$internal
  @override
  $ProviderElement<WearableWorkoutSyncService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  WearableWorkoutSyncService create(Ref ref) {
    return wearableWorkoutSyncService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WearableWorkoutSyncService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WearableWorkoutSyncService>(value),
    );
  }
}

String _$wearableWorkoutSyncServiceHash() =>
    r'3549d331f061e0ee32cfc1b3c4a41f39cc5687f0';

@ProviderFor(WearablesController)
final wearablesControllerProvider = WearablesControllerProvider._();

final class WearablesControllerProvider
    extends $NotifierProvider<WearablesController, WearablesState> {
  WearablesControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'wearablesControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$wearablesControllerHash();

  @$internal
  @override
  WearablesController create() => WearablesController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WearablesState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WearablesState>(value),
    );
  }
}

String _$wearablesControllerHash() =>
    r'4d5b25b2790bac313eb4d2952d334d8fbcba7742';

abstract class _$WearablesController extends $Notifier<WearablesState> {
  WearablesState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<WearablesState, WearablesState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<WearablesState, WearablesState>,
              WearablesState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
