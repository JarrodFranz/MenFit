// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Composition surface for the `settings` feature (ADR 007).
///
/// The only legal way for another feature (or the composition root) to
/// reach this feature's persistence: other features may import this file,
/// never `data/` or `presentation/` directly.

@ProviderFor(deleteMyDataService)
final deleteMyDataServiceProvider = DeleteMyDataServiceProvider._();

/// Composition surface for the `settings` feature (ADR 007).
///
/// The only legal way for another feature (or the composition root) to
/// reach this feature's persistence: other features may import this file,
/// never `data/` or `presentation/` directly.

final class DeleteMyDataServiceProvider
    extends
        $FunctionalProvider<
          DeleteMyDataService,
          DeleteMyDataService,
          DeleteMyDataService
        >
    with $Provider<DeleteMyDataService> {
  /// Composition surface for the `settings` feature (ADR 007).
  ///
  /// The only legal way for another feature (or the composition root) to
  /// reach this feature's persistence: other features may import this file,
  /// never `data/` or `presentation/` directly.
  DeleteMyDataServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deleteMyDataServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deleteMyDataServiceHash();

  @$internal
  @override
  $ProviderElement<DeleteMyDataService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DeleteMyDataService create(Ref ref) {
    return deleteMyDataService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeleteMyDataService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeleteMyDataService>(value),
    );
  }
}

String _$deleteMyDataServiceHash() =>
    r'fe829a57d7c415e6b5aaa3e82d10952b1cdf39dd';
