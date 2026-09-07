// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for the platform health adapter (can be overridden in widget/unit tests).

@ProviderFor(healthPlatformAdapter)
final healthPlatformAdapterProvider = HealthPlatformAdapterProvider._();

/// Provider for the platform health adapter (can be overridden in widget/unit tests).

final class HealthPlatformAdapterProvider
    extends
        $FunctionalProvider<
          HealthPlatformAdapter,
          HealthPlatformAdapter,
          HealthPlatformAdapter
        >
    with $Provider<HealthPlatformAdapter> {
  /// Provider for the platform health adapter (can be overridden in widget/unit tests).
  HealthPlatformAdapterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'healthPlatformAdapterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$healthPlatformAdapterHash();

  @$internal
  @override
  $ProviderElement<HealthPlatformAdapter> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  HealthPlatformAdapter create(Ref ref) {
    return healthPlatformAdapter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HealthPlatformAdapter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HealthPlatformAdapter>(value),
    );
  }
}

String _$healthPlatformAdapterHash() =>
    r'6365b6f35b0b9ee1dd1b1c75684f11618dc212e1';

/// Notifier controlling health synchronization, permission requests,
/// and live device data.

@ProviderFor(HealthSync)
final healthSyncProvider = HealthSyncProvider._();

/// Notifier controlling health synchronization, permission requests,
/// and live device data.
final class HealthSyncProvider
    extends $NotifierProvider<HealthSync, HealthSyncState> {
  /// Notifier controlling health synchronization, permission requests,
  /// and live device data.
  HealthSyncProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'healthSyncProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$healthSyncHash();

  @$internal
  @override
  HealthSync create() => HealthSync();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HealthSyncState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HealthSyncState>(value),
    );
  }
}

String _$healthSyncHash() => r'0bff415e232c69999877b3868461a3f257a9049f';

/// Notifier controlling health synchronization, permission requests,
/// and live device data.

abstract class _$HealthSync extends $Notifier<HealthSyncState> {
  HealthSyncState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<HealthSyncState, HealthSyncState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<HealthSyncState, HealthSyncState>,
              HealthSyncState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Fetches health data snapshot for a specific date.

@ProviderFor(dateHealthSnapshot)
final dateHealthSnapshotProvider = DateHealthSnapshotFamily._();

/// Fetches health data snapshot for a specific date.

final class DateHealthSnapshotProvider
    extends
        $FunctionalProvider<
          AsyncValue<HealthDataSnapshot?>,
          HealthDataSnapshot?,
          FutureOr<HealthDataSnapshot?>
        >
    with
        $FutureModifier<HealthDataSnapshot?>,
        $FutureProvider<HealthDataSnapshot?> {
  /// Fetches health data snapshot for a specific date.
  DateHealthSnapshotProvider._({
    required DateHealthSnapshotFamily super.from,
    required LocalDate super.argument,
  }) : super(
         retry: null,
         name: r'dateHealthSnapshotProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$dateHealthSnapshotHash();

  @override
  String toString() {
    return r'dateHealthSnapshotProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<HealthDataSnapshot?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<HealthDataSnapshot?> create(Ref ref) {
    final argument = this.argument as LocalDate;
    return dateHealthSnapshot(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is DateHealthSnapshotProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$dateHealthSnapshotHash() =>
    r'd26b4893cca99321dfe829ef1a02bfb9f02a4ec6';

/// Fetches health data snapshot for a specific date.

final class DateHealthSnapshotFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<HealthDataSnapshot?>, LocalDate> {
  DateHealthSnapshotFamily._()
    : super(
        retry: null,
        name: r'dateHealthSnapshotProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Fetches health data snapshot for a specific date.

  DateHealthSnapshotProvider call(LocalDate date) =>
      DateHealthSnapshotProvider._(argument: date, from: this);

  @override
  String toString() => r'dateHealthSnapshotProvider';
}
