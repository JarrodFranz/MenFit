// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'safety_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(safetyRepository)
final safetyRepositoryProvider = SafetyRepositoryProvider._();

final class SafetyRepositoryProvider
    extends
        $FunctionalProvider<
          SafetyRepository,
          SafetyRepository,
          SafetyRepository
        >
    with $Provider<SafetyRepository> {
  SafetyRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'safetyRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$safetyRepositoryHash();

  @$internal
  @override
  $ProviderElement<SafetyRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SafetyRepository create(Ref ref) {
    return safetyRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SafetyRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SafetyRepository>(value),
    );
  }
}

String _$safetyRepositoryHash() => r'e261e86dfdb4e647fbec1e11e8f23049d864f0da';

@ProviderFor(safetyCheckinEngine)
final safetyCheckinEngineProvider = SafetyCheckinEngineProvider._();

final class SafetyCheckinEngineProvider
    extends
        $FunctionalProvider<
          SafetyCheckinEngine,
          SafetyCheckinEngine,
          SafetyCheckinEngine
        >
    with $Provider<SafetyCheckinEngine> {
  SafetyCheckinEngineProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'safetyCheckinEngineProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$safetyCheckinEngineHash();

  @$internal
  @override
  $ProviderElement<SafetyCheckinEngine> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SafetyCheckinEngine create(Ref ref) {
    return safetyCheckinEngine(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SafetyCheckinEngine value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SafetyCheckinEngine>(value),
    );
  }
}

String _$safetyCheckinEngineHash() =>
    r'2e5b05649643499e1585629112e329602f0f1ea0';

@ProviderFor(liveTrackingUrlBuilder)
final liveTrackingUrlBuilderProvider = LiveTrackingUrlBuilderProvider._();

final class LiveTrackingUrlBuilderProvider
    extends
        $FunctionalProvider<
          LiveTrackingUrlBuilder,
          LiveTrackingUrlBuilder,
          LiveTrackingUrlBuilder
        >
    with $Provider<LiveTrackingUrlBuilder> {
  LiveTrackingUrlBuilderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'liveTrackingUrlBuilderProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$liveTrackingUrlBuilderHash();

  @$internal
  @override
  $ProviderElement<LiveTrackingUrlBuilder> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LiveTrackingUrlBuilder create(Ref ref) {
    return liveTrackingUrlBuilder(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LiveTrackingUrlBuilder value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LiveTrackingUrlBuilder>(value),
    );
  }
}

String _$liveTrackingUrlBuilderHash() =>
    r'e4ad9afa84820e7a4bb134d86b067db3d29b28b8';

@ProviderFor(liveTrackingService)
final liveTrackingServiceProvider = LiveTrackingServiceProvider._();

final class LiveTrackingServiceProvider
    extends
        $FunctionalProvider<
          LiveTrackingService,
          LiveTrackingService,
          LiveTrackingService
        >
    with $Provider<LiveTrackingService> {
  LiveTrackingServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'liveTrackingServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$liveTrackingServiceHash();

  @$internal
  @override
  $ProviderElement<LiveTrackingService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LiveTrackingService create(Ref ref) {
    return liveTrackingService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LiveTrackingService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LiveTrackingService>(value),
    );
  }
}

String _$liveTrackingServiceHash() =>
    r'9cb6144d6ec48c6eac7cfa7911d28290a2323890';

@ProviderFor(activeLiveTrackingSession)
final activeLiveTrackingSessionProvider = ActiveLiveTrackingSessionProvider._();

final class ActiveLiveTrackingSessionProvider
    extends
        $FunctionalProvider<
          AsyncValue<LiveTrackingSession?>,
          LiveTrackingSession?,
          Stream<LiveTrackingSession?>
        >
    with
        $FutureModifier<LiveTrackingSession?>,
        $StreamProvider<LiveTrackingSession?> {
  ActiveLiveTrackingSessionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeLiveTrackingSessionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeLiveTrackingSessionHash();

  @$internal
  @override
  $StreamProviderElement<LiveTrackingSession?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<LiveTrackingSession?> create(Ref ref) {
    return activeLiveTrackingSession(ref);
  }
}

String _$activeLiveTrackingSessionHash() =>
    r'74d4894fbcea70ffe1cf7c976a2ebad8d5c0c6fa';

@ProviderFor(TrustedContactsController)
final trustedContactsControllerProvider = TrustedContactsControllerProvider._();

final class TrustedContactsControllerProvider
    extends $NotifierProvider<TrustedContactsController, List<TrustedContact>> {
  TrustedContactsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'trustedContactsControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$trustedContactsControllerHash();

  @$internal
  @override
  TrustedContactsController create() => TrustedContactsController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<TrustedContact> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<TrustedContact>>(value),
    );
  }
}

String _$trustedContactsControllerHash() =>
    r'b877224a7bef2b0c9115e8881f915a78b53bb5e2';

abstract class _$TrustedContactsController
    extends $Notifier<List<TrustedContact>> {
  List<TrustedContact> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<List<TrustedContact>, List<TrustedContact>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<TrustedContact>, List<TrustedContact>>,
              List<TrustedContact>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(SafetyPreferencesController)
final safetyPreferencesControllerProvider =
    SafetyPreferencesControllerProvider._();

final class SafetyPreferencesControllerProvider
    extends $NotifierProvider<SafetyPreferencesController, SafetyPreferences> {
  SafetyPreferencesControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'safetyPreferencesControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$safetyPreferencesControllerHash();

  @$internal
  @override
  SafetyPreferencesController create() => SafetyPreferencesController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SafetyPreferences value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SafetyPreferences>(value),
    );
  }
}

String _$safetyPreferencesControllerHash() =>
    r'b40623427f6d1004b72ec924bde0d7592aedde52';

abstract class _$SafetyPreferencesController
    extends $Notifier<SafetyPreferences> {
  SafetyPreferences build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<SafetyPreferences, SafetyPreferences>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SafetyPreferences, SafetyPreferences>,
              SafetyPreferences,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(SafetyMonitorController)
final safetyMonitorControllerProvider = SafetyMonitorControllerProvider._();

final class SafetyMonitorControllerProvider
    extends $NotifierProvider<SafetyMonitorController, SafetyMonitorState> {
  SafetyMonitorControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'safetyMonitorControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$safetyMonitorControllerHash();

  @$internal
  @override
  SafetyMonitorController create() => SafetyMonitorController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SafetyMonitorState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SafetyMonitorState>(value),
    );
  }
}

String _$safetyMonitorControllerHash() =>
    r'bc3f7e65b0efa92cfbba2e7ffa71ba70d915cf93';

abstract class _$SafetyMonitorController extends $Notifier<SafetyMonitorState> {
  SafetyMonitorState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<SafetyMonitorState, SafetyMonitorState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SafetyMonitorState, SafetyMonitorState>,
              SafetyMonitorState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
