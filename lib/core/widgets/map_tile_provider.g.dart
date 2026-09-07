// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map_tile_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The [TileProvider] every flutter_map tile layer in the app fetches
/// through.
///
/// A `@Riverpod(keepAlive: true)` provider (rather than a constructor
/// parameter threaded through each map widget) is the seam widget tests
/// substitute a no-network fake through, overridden in a `ProviderScope`
/// — the same pattern as `locationAdapterProvider`
/// (`core/platform/location/location_providers.dart`). Defaults to
/// [CachedTileProvider], which checks the on-device offline tile store
/// before falling back to network requests: tests MUST override this
/// provider (see `test/features/activity/route_map_test.dart` for the
/// no-network fake).
///
/// Lives in `core/widgets/` (not a feature's presentation layer) because
/// multiple features' maps share it — `activity`'s `RouteMap` and the
/// `routes` feature's suggest/detail maps — and ADR 007 forbids one
/// feature importing another's presentation code.

@ProviderFor(mapTileProvider)
final mapTileProviderProvider = MapTileProviderProvider._();

/// The [TileProvider] every flutter_map tile layer in the app fetches
/// through.
///
/// A `@Riverpod(keepAlive: true)` provider (rather than a constructor
/// parameter threaded through each map widget) is the seam widget tests
/// substitute a no-network fake through, overridden in a `ProviderScope`
/// — the same pattern as `locationAdapterProvider`
/// (`core/platform/location/location_providers.dart`). Defaults to
/// [CachedTileProvider], which checks the on-device offline tile store
/// before falling back to network requests: tests MUST override this
/// provider (see `test/features/activity/route_map_test.dart` for the
/// no-network fake).
///
/// Lives in `core/widgets/` (not a feature's presentation layer) because
/// multiple features' maps share it — `activity`'s `RouteMap` and the
/// `routes` feature's suggest/detail maps — and ADR 007 forbids one
/// feature importing another's presentation code.

final class MapTileProviderProvider
    extends $FunctionalProvider<TileProvider, TileProvider, TileProvider>
    with $Provider<TileProvider> {
  /// The [TileProvider] every flutter_map tile layer in the app fetches
  /// through.
  ///
  /// A `@Riverpod(keepAlive: true)` provider (rather than a constructor
  /// parameter threaded through each map widget) is the seam widget tests
  /// substitute a no-network fake through, overridden in a `ProviderScope`
  /// — the same pattern as `locationAdapterProvider`
  /// (`core/platform/location/location_providers.dart`). Defaults to
  /// [CachedTileProvider], which checks the on-device offline tile store
  /// before falling back to network requests: tests MUST override this
  /// provider (see `test/features/activity/route_map_test.dart` for the
  /// no-network fake).
  ///
  /// Lives in `core/widgets/` (not a feature's presentation layer) because
  /// multiple features' maps share it — `activity`'s `RouteMap` and the
  /// `routes` feature's suggest/detail maps — and ADR 007 forbids one
  /// feature importing another's presentation code.
  MapTileProviderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mapTileProviderProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mapTileProviderHash();

  @$internal
  @override
  $ProviderElement<TileProvider> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TileProvider create(Ref ref) {
    return mapTileProvider(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TileProvider value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TileProvider>(value),
    );
  }
}

String _$mapTileProviderHash() => r'839751484d6b1fa64c67b263369e87e087cd36ac';
