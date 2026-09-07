// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'route_cache_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Injects the singleton [TileStorage] instance.

@ProviderFor(tileStorage)
final tileStorageProvider = TileStorageProvider._();

/// Injects the singleton [TileStorage] instance.

final class TileStorageProvider
    extends $FunctionalProvider<TileStorage, TileStorage, TileStorage>
    with $Provider<TileStorage> {
  /// Injects the singleton [TileStorage] instance.
  TileStorageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tileStorageProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tileStorageHash();

  @$internal
  @override
  $ProviderElement<TileStorage> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TileStorage create(Ref ref) {
    return tileStorage(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TileStorage value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TileStorage>(value),
    );
  }
}

String _$tileStorageHash() => r'9777c63a5a12b7944db838297d1efbad5abc3d50';

/// Injects the [RouteTileCacheService].

@ProviderFor(routeTileCacheService)
final routeTileCacheServiceProvider = RouteTileCacheServiceProvider._();

/// Injects the [RouteTileCacheService].

final class RouteTileCacheServiceProvider
    extends
        $FunctionalProvider<
          RouteTileCacheService,
          RouteTileCacheService,
          RouteTileCacheService
        >
    with $Provider<RouteTileCacheService> {
  /// Injects the [RouteTileCacheService].
  RouteTileCacheServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'routeTileCacheServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$routeTileCacheServiceHash();

  @$internal
  @override
  $ProviderElement<RouteTileCacheService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RouteTileCacheService create(Ref ref) {
    return routeTileCacheService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RouteTileCacheService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RouteTileCacheService>(value),
    );
  }
}

String _$routeTileCacheServiceHash() =>
    r'af5c4e59d892303487e27b7096069197d194a299';

/// Watches cached metadata for a specific route.

@ProviderFor(RouteCacheMetadataNotifier)
final routeCacheMetadataProvider = RouteCacheMetadataNotifierFamily._();

/// Watches cached metadata for a specific route.
final class RouteCacheMetadataNotifierProvider
    extends $NotifierProvider<RouteCacheMetadataNotifier, RouteCacheMetadata?> {
  /// Watches cached metadata for a specific route.
  RouteCacheMetadataNotifierProvider._({
    required RouteCacheMetadataNotifierFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'routeCacheMetadataProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$routeCacheMetadataNotifierHash();

  @override
  String toString() {
    return r'routeCacheMetadataProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  RouteCacheMetadataNotifier create() => RouteCacheMetadataNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RouteCacheMetadata? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RouteCacheMetadata?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is RouteCacheMetadataNotifierProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$routeCacheMetadataNotifierHash() =>
    r'd12cf445c4c688fff349c9034fa585a0c51fb70e';

/// Watches cached metadata for a specific route.

final class RouteCacheMetadataNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          RouteCacheMetadataNotifier,
          RouteCacheMetadata?,
          RouteCacheMetadata?,
          RouteCacheMetadata?,
          String
        > {
  RouteCacheMetadataNotifierFamily._()
    : super(
        retry: null,
        name: r'routeCacheMetadataProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// Watches cached metadata for a specific route.

  RouteCacheMetadataNotifierProvider call(String routeId) =>
      RouteCacheMetadataNotifierProvider._(argument: routeId, from: this);

  @override
  String toString() => r'routeCacheMetadataProvider';
}

/// Watches cached metadata for a specific route.

abstract class _$RouteCacheMetadataNotifier
    extends $Notifier<RouteCacheMetadata?> {
  late final _$args = ref.$arg as String;
  String get routeId => _$args;

  RouteCacheMetadata? build(String routeId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<RouteCacheMetadata?, RouteCacheMetadata?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<RouteCacheMetadata?, RouteCacheMetadata?>,
              RouteCacheMetadata?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

/// Controls active tile downloads for a route.

@ProviderFor(RouteTileDownloadController)
final routeTileDownloadControllerProvider =
    RouteTileDownloadControllerProvider._();

/// Controls active tile downloads for a route.
final class RouteTileDownloadControllerProvider
    extends
        $NotifierProvider<
          RouteTileDownloadController,
          Map<String, RouteTileDownloadProgress>
        > {
  /// Controls active tile downloads for a route.
  RouteTileDownloadControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'routeTileDownloadControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$routeTileDownloadControllerHash();

  @$internal
  @override
  RouteTileDownloadController create() => RouteTileDownloadController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, RouteTileDownloadProgress> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<Map<String, RouteTileDownloadProgress>>(value),
    );
  }
}

String _$routeTileDownloadControllerHash() =>
    r'6d0020bbe4f3c38a2236fe0259fe78a2f4aec347';

/// Controls active tile downloads for a route.

abstract class _$RouteTileDownloadController
    extends $Notifier<Map<String, RouteTileDownloadProgress>> {
  Map<String, RouteTileDownloadProgress> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              Map<String, RouteTileDownloadProgress>,
              Map<String, RouteTileDownloadProgress>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                Map<String, RouteTileDownloadProgress>,
                Map<String, RouteTileDownloadProgress>
              >,
              Map<String, RouteTileDownloadProgress>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
