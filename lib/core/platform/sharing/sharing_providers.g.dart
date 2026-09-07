// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sharing_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The app's single [SharingAdapter]. Widget tests override it with a
/// fake (`test/core/platform/sharing/fake_sharing_adapter.dart`) — no
/// test should ever reach the real share sheet.

@ProviderFor(sharingAdapter)
final sharingAdapterProvider = SharingAdapterProvider._();

/// The app's single [SharingAdapter]. Widget tests override it with a
/// fake (`test/core/platform/sharing/fake_sharing_adapter.dart`) — no
/// test should ever reach the real share sheet.

final class SharingAdapterProvider
    extends $FunctionalProvider<SharingAdapter, SharingAdapter, SharingAdapter>
    with $Provider<SharingAdapter> {
  /// The app's single [SharingAdapter]. Widget tests override it with a
  /// fake (`test/core/platform/sharing/fake_sharing_adapter.dart`) — no
  /// test should ever reach the real share sheet.
  SharingAdapterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sharingAdapterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sharingAdapterHash();

  @$internal
  @override
  $ProviderElement<SharingAdapter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SharingAdapter create(Ref ref) {
    return sharingAdapter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SharingAdapter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SharingAdapter>(value),
    );
  }
}

String _$sharingAdapterHash() => r'cd830e3060c355d397a841f517a6d7ed5ad78f18';
