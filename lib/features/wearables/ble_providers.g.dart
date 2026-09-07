// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ble_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the active [BleHeartRateAdapter] singleton.

@ProviderFor(bleHeartRateAdapter)
final bleHeartRateAdapterProvider = BleHeartRateAdapterProvider._();

/// Provides the active [BleHeartRateAdapter] singleton.

final class BleHeartRateAdapterProvider
    extends
        $FunctionalProvider<
          BleHeartRateAdapter,
          BleHeartRateAdapter,
          BleHeartRateAdapter
        >
    with $Provider<BleHeartRateAdapter> {
  /// Provides the active [BleHeartRateAdapter] singleton.
  BleHeartRateAdapterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bleHeartRateAdapterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bleHeartRateAdapterHash();

  @$internal
  @override
  $ProviderElement<BleHeartRateAdapter> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  BleHeartRateAdapter create(Ref ref) {
    return bleHeartRateAdapter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BleHeartRateAdapter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BleHeartRateAdapter>(value),
    );
  }
}

String _$bleHeartRateAdapterHash() =>
    r'd51b39f00e831cabc111fd6e86650a3307961af8';

/// Controls scanning for nearby Bluetooth Heart Rate monitors.

@ProviderFor(BleScanningController)
final bleScanningControllerProvider = BleScanningControllerProvider._();

/// Controls scanning for nearby Bluetooth Heart Rate monitors.
final class BleScanningControllerProvider
    extends $NotifierProvider<BleScanningController, BleScanningState> {
  /// Controls scanning for nearby Bluetooth Heart Rate monitors.
  BleScanningControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bleScanningControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bleScanningControllerHash();

  @$internal
  @override
  BleScanningController create() => BleScanningController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BleScanningState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BleScanningState>(value),
    );
  }
}

String _$bleScanningControllerHash() =>
    r'db2f00e32f9a6e2a5dde607c07b3a902247362a5';

/// Controls scanning for nearby Bluetooth Heart Rate monitors.

abstract class _$BleScanningController extends $Notifier<BleScanningState> {
  BleScanningState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<BleScanningState, BleScanningState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<BleScanningState, BleScanningState>,
              BleScanningState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Manages connection, telemetry subscription, and live BPM streaming from a
/// connected Bluetooth Heart Rate monitor.

@ProviderFor(BleConnectionController)
final bleConnectionControllerProvider = BleConnectionControllerProvider._();

/// Manages connection, telemetry subscription, and live BPM streaming from a
/// connected Bluetooth Heart Rate monitor.
final class BleConnectionControllerProvider
    extends $NotifierProvider<BleConnectionController, BleConnectionState> {
  /// Manages connection, telemetry subscription, and live BPM streaming from a
  /// connected Bluetooth Heart Rate monitor.
  BleConnectionControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bleConnectionControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bleConnectionControllerHash();

  @$internal
  @override
  BleConnectionController create() => BleConnectionController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BleConnectionState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BleConnectionState>(value),
    );
  }
}

String _$bleConnectionControllerHash() =>
    r'7991d3be3ceee1c7caa7780d5936eef7c8fd09d6';

/// Manages connection, telemetry subscription, and live BPM streaming from a
/// connected Bluetooth Heart Rate monitor.

abstract class _$BleConnectionController extends $Notifier<BleConnectionState> {
  BleConnectionState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<BleConnectionState, BleConnectionState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<BleConnectionState, BleConnectionState>,
              BleConnectionState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Streams the current instantaneous heart rate in BPM, or null when
/// disconnected.

@ProviderFor(currentLiveHeartRate)
final currentLiveHeartRateProvider = CurrentLiveHeartRateProvider._();

/// Streams the current instantaneous heart rate in BPM, or null when
/// disconnected.

final class CurrentLiveHeartRateProvider
    extends $FunctionalProvider<int?, int?, int?>
    with $Provider<int?> {
  /// Streams the current instantaneous heart rate in BPM, or null when
  /// disconnected.
  CurrentLiveHeartRateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentLiveHeartRateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentLiveHeartRateHash();

  @$internal
  @override
  $ProviderElement<int?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int? create(Ref ref) {
    return currentLiveHeartRate(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int?>(value),
    );
  }
}

String _$currentLiveHeartRateHash() =>
    r'0568efadcb679e56b4c351a6b6b385c9e1ac919a';
