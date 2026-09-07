// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map_tile_settings.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Manages the user's selected [MapTileSource].

@ProviderFor(MapTileSettingsController)
final mapTileSettingsControllerProvider = MapTileSettingsControllerProvider._();

/// Manages the user's selected [MapTileSource].
final class MapTileSettingsControllerProvider
    extends $NotifierProvider<MapTileSettingsController, MapTileSource> {
  /// Manages the user's selected [MapTileSource].
  MapTileSettingsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mapTileSettingsControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mapTileSettingsControllerHash();

  @$internal
  @override
  MapTileSettingsController create() => MapTileSettingsController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MapTileSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MapTileSource>(value),
    );
  }
}

String _$mapTileSettingsControllerHash() =>
    r'2e4f43f31e52a516749b098e6dba411014b9ba89';

/// Manages the user's selected [MapTileSource].

abstract class _$MapTileSettingsController extends $Notifier<MapTileSource> {
  MapTileSource build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<MapTileSource, MapTileSource>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<MapTileSource, MapTileSource>,
              MapTileSource,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Provides the active map tile URL template.

@ProviderFor(mapTileUrl)
final mapTileUrlProvider = MapTileUrlProvider._();

/// Provides the active map tile URL template.

final class MapTileUrlProvider
    extends $FunctionalProvider<String, String, String>
    with $Provider<String> {
  /// Provides the active map tile URL template.
  MapTileUrlProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mapTileUrlProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mapTileUrlHash();

  @$internal
  @override
  $ProviderElement<String> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String create(Ref ref) {
    return mapTileUrl(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$mapTileUrlHash() => r'637a0592f769393d92f2f934679d7a81f9575a56';

/// Provides the active map attribution copy.

@ProviderFor(mapTileAttribution)
final mapTileAttributionProvider = MapTileAttributionProvider._();

/// Provides the active map attribution copy.

final class MapTileAttributionProvider
    extends $FunctionalProvider<String, String, String>
    with $Provider<String> {
  /// Provides the active map attribution copy.
  MapTileAttributionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mapTileAttributionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mapTileAttributionHash();

  @$internal
  @override
  $ProviderElement<String> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String create(Ref ref) {
    return mapTileAttribution(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$mapTileAttributionHash() =>
    r'5c05675ace914fc0b18a7e17424b733843fcd786';
