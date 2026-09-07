// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weight_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Composition surface for the `weight` feature (ADR 007).
///
/// The only legal way for another feature (or the composition root's
/// "Delete my data" flow) to reach this feature's persistence: other
/// features may import this file, never `data/` or `presentation/`
/// directly (see `knowledge/decisions/007_cross_feature_providers.md`).
///
/// Typed as the domain interface so nothing above `data/` knows Drift is
/// behind it.

@ProviderFor(weightRepository)
final weightRepositoryProvider = WeightRepositoryProvider._();

/// Composition surface for the `weight` feature (ADR 007).
///
/// The only legal way for another feature (or the composition root's
/// "Delete my data" flow) to reach this feature's persistence: other
/// features may import this file, never `data/` or `presentation/`
/// directly (see `knowledge/decisions/007_cross_feature_providers.md`).
///
/// Typed as the domain interface so nothing above `data/` knows Drift is
/// behind it.

final class WeightRepositoryProvider
    extends
        $FunctionalProvider<
          WeightRepository,
          WeightRepository,
          WeightRepository
        >
    with $Provider<WeightRepository> {
  /// Composition surface for the `weight` feature (ADR 007).
  ///
  /// The only legal way for another feature (or the composition root's
  /// "Delete my data" flow) to reach this feature's persistence: other
  /// features may import this file, never `data/` or `presentation/`
  /// directly (see `knowledge/decisions/007_cross_feature_providers.md`).
  ///
  /// Typed as the domain interface so nothing above `data/` knows Drift is
  /// behind it.
  WeightRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'weightRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$weightRepositoryHash();

  @$internal
  @override
  $ProviderElement<WeightRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  WeightRepository create(Ref ref) {
    return weightRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WeightRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WeightRepository>(value),
    );
  }
}

String _$weightRepositoryHash() => r'b647a93256744b47e2825869c06a6706825d61f1';
