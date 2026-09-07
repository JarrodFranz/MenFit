// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_locale.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// [readDeviceLocale] as a provider, so tests and future in-app overrides can
/// substitute one without reaching into the binding.
///
/// `keepAlive` because it is read from app-scoped services and the platform
/// value does not change under us within a session. A device whose locale is
/// changed while the app runs keeps the old value until restart — acceptable
/// for a search default that is also user-overridable in Settings, and the
/// alternative (a `WidgetsBindingObserver` here) would put a listener in a
/// leaf accessor.

@ProviderFor(deviceLocale)
final deviceLocaleProvider = DeviceLocaleProvider._();

/// [readDeviceLocale] as a provider, so tests and future in-app overrides can
/// substitute one without reaching into the binding.
///
/// `keepAlive` because it is read from app-scoped services and the platform
/// value does not change under us within a session. A device whose locale is
/// changed while the app runs keeps the old value until restart — acceptable
/// for a search default that is also user-overridable in Settings, and the
/// alternative (a `WidgetsBindingObserver` here) would put a listener in a
/// leaf accessor.

final class DeviceLocaleProvider
    extends $FunctionalProvider<DeviceLocale, DeviceLocale, DeviceLocale>
    with $Provider<DeviceLocale> {
  /// [readDeviceLocale] as a provider, so tests and future in-app overrides can
  /// substitute one without reaching into the binding.
  ///
  /// `keepAlive` because it is read from app-scoped services and the platform
  /// value does not change under us within a session. A device whose locale is
  /// changed while the app runs keeps the old value until restart — acceptable
  /// for a search default that is also user-overridable in Settings, and the
  /// alternative (a `WidgetsBindingObserver` here) would put a listener in a
  /// leaf accessor.
  DeviceLocaleProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deviceLocaleProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deviceLocaleHash();

  @$internal
  @override
  $ProviderElement<DeviceLocale> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DeviceLocale create(Ref ref) {
    return deviceLocale(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeviceLocale value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeviceLocale>(value),
    );
  }
}

String _$deviceLocaleHash() => r'56a60b2589696a544d999942409db5d7a23dfcf3';
