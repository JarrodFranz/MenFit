// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Composition surface for the `health` feature (ADR 007). Not to be
/// confused with `core/platform/health/health_providers.dart` (the watch
/// adapter); import with a prefix where both are needed.

@ProviderFor(healthReadingsRepository)
final healthReadingsRepositoryProvider = HealthReadingsRepositoryProvider._();

/// Composition surface for the `health` feature (ADR 007). Not to be
/// confused with `core/platform/health/health_providers.dart` (the watch
/// adapter); import with a prefix where both are needed.

final class HealthReadingsRepositoryProvider
    extends
        $FunctionalProvider<
          HealthReadingsRepository,
          HealthReadingsRepository,
          HealthReadingsRepository
        >
    with $Provider<HealthReadingsRepository> {
  /// Composition surface for the `health` feature (ADR 007). Not to be
  /// confused with `core/platform/health/health_providers.dart` (the watch
  /// adapter); import with a prefix where both are needed.
  HealthReadingsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'healthReadingsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$healthReadingsRepositoryHash();

  @$internal
  @override
  $ProviderElement<HealthReadingsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  HealthReadingsRepository create(Ref ref) {
    return healthReadingsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HealthReadingsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HealthReadingsRepository>(value),
    );
  }
}

String _$healthReadingsRepositoryHash() =>
    r'b05979e8e0a713a052929dfd0dd9d2d8f9b677f0';

@ProviderFor(bloodPressureReadings)
final bloodPressureReadingsProvider = BloodPressureReadingsFamily._();

final class BloodPressureReadingsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<BloodPressureReading>>,
          List<BloodPressureReading>,
          Stream<List<BloodPressureReading>>
        >
    with
        $FutureModifier<List<BloodPressureReading>>,
        $StreamProvider<List<BloodPressureReading>> {
  BloodPressureReadingsProvider._({
    required BloodPressureReadingsFamily super.from,
    required DateTime? super.argument,
  }) : super(
         retry: null,
         name: r'bloodPressureReadingsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$bloodPressureReadingsHash();

  @override
  String toString() {
    return r'bloodPressureReadingsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<BloodPressureReading>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<BloodPressureReading>> create(Ref ref) {
    final argument = this.argument as DateTime?;
    return bloodPressureReadings(ref, since: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is BloodPressureReadingsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$bloodPressureReadingsHash() =>
    r'704cc00b8ffaf305f9dc60fe5864e552bd306230';

final class BloodPressureReadingsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<List<BloodPressureReading>>,
          DateTime?
        > {
  BloodPressureReadingsFamily._()
    : super(
        retry: null,
        name: r'bloodPressureReadingsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  BloodPressureReadingsProvider call({DateTime? since}) =>
      BloodPressureReadingsProvider._(argument: since, from: this);

  @override
  String toString() => r'bloodPressureReadingsProvider';
}

@ProviderFor(bloodMarkerReadings)
final bloodMarkerReadingsProvider = BloodMarkerReadingsFamily._();

final class BloodMarkerReadingsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<BloodMarkerReading>>,
          List<BloodMarkerReading>,
          Stream<List<BloodMarkerReading>>
        >
    with
        $FutureModifier<List<BloodMarkerReading>>,
        $StreamProvider<List<BloodMarkerReading>> {
  BloodMarkerReadingsProvider._({
    required BloodMarkerReadingsFamily super.from,
    required (BloodMarker, {DateTime? since}) super.argument,
  }) : super(
         retry: null,
         name: r'bloodMarkerReadingsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$bloodMarkerReadingsHash();

  @override
  String toString() {
    return r'bloodMarkerReadingsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<List<BloodMarkerReading>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<BloodMarkerReading>> create(Ref ref) {
    final argument = this.argument as (BloodMarker, {DateTime? since});
    return bloodMarkerReadings(ref, argument.$1, since: argument.since);
  }

  @override
  bool operator ==(Object other) {
    return other is BloodMarkerReadingsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$bloodMarkerReadingsHash() =>
    r'be22cc6fcc7304a6bc92424b9bd139da88b47a10';

final class BloodMarkerReadingsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<List<BloodMarkerReading>>,
          (BloodMarker, {DateTime? since})
        > {
  BloodMarkerReadingsFamily._()
    : super(
        retry: null,
        name: r'bloodMarkerReadingsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  BloodMarkerReadingsProvider call(BloodMarker marker, {DateTime? since}) =>
      BloodMarkerReadingsProvider._(
        argument: (marker, since: since),
        from: this,
      );

  @override
  String toString() => r'bloodMarkerReadingsProvider';
}
