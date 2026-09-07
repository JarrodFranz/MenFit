// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The app's single [LocationAdapter] instance.

@ProviderFor(locationAdapter)
final locationAdapterProvider = LocationAdapterProvider._();

/// The app's single [LocationAdapter] instance.

final class LocationAdapterProvider
    extends
        $FunctionalProvider<LocationAdapter, LocationAdapter, LocationAdapter>
    with $Provider<LocationAdapter> {
  /// The app's single [LocationAdapter] instance.
  LocationAdapterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'locationAdapterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$locationAdapterHash();

  @$internal
  @override
  $ProviderElement<LocationAdapter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LocationAdapter create(Ref ref) {
    return locationAdapter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LocationAdapter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LocationAdapter>(value),
    );
  }
}

String _$locationAdapterHash() => r'772c3fd3db8be2e88c03bd5898acd392bafcca0d';
