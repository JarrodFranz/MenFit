// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cycle_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Composition surface for the `cycle` feature (ADR 007).
///
/// The only legal way for another feature (or the composition root) to
/// reach this feature's persistence: other features may import this file,
/// never `data/` or `presentation/` directly - the streak engine (next
/// wave) will depend on this to read confirmed period records via
/// `domain/period_days.dart`'s pure functions.

@ProviderFor(cycleRepository)
final cycleRepositoryProvider = CycleRepositoryProvider._();

/// Composition surface for the `cycle` feature (ADR 007).
///
/// The only legal way for another feature (or the composition root) to
/// reach this feature's persistence: other features may import this file,
/// never `data/` or `presentation/` directly - the streak engine (next
/// wave) will depend on this to read confirmed period records via
/// `domain/period_days.dart`'s pure functions.

final class CycleRepositoryProvider
    extends
        $FunctionalProvider<CycleRepository, CycleRepository, CycleRepository>
    with $Provider<CycleRepository> {
  /// Composition surface for the `cycle` feature (ADR 007).
  ///
  /// The only legal way for another feature (or the composition root) to
  /// reach this feature's persistence: other features may import this file,
  /// never `data/` or `presentation/` directly - the streak engine (next
  /// wave) will depend on this to read confirmed period records via
  /// `domain/period_days.dart`'s pure functions.
  CycleRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cycleRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cycleRepositoryHash();

  @$internal
  @override
  $ProviderElement<CycleRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CycleRepository create(Ref ref) {
    return cycleRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CycleRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CycleRepository>(value),
    );
  }
}

String _$cycleRepositoryHash() => r'0fa57d9786309e53f1a275a0a6428ff3e1373042';
