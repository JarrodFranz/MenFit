// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'accessibility_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for the [AccessibilityRepository].

@ProviderFor(accessibilityRepository)
final accessibilityRepositoryProvider = AccessibilityRepositoryProvider._();

/// Provider for the [AccessibilityRepository].

final class AccessibilityRepositoryProvider
    extends
        $FunctionalProvider<
          AccessibilityRepository,
          AccessibilityRepository,
          AccessibilityRepository
        >
    with $Provider<AccessibilityRepository> {
  /// Provider for the [AccessibilityRepository].
  AccessibilityRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accessibilityRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accessibilityRepositoryHash();

  @$internal
  @override
  $ProviderElement<AccessibilityRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AccessibilityRepository create(Ref ref) {
    return accessibilityRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AccessibilityRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AccessibilityRepository>(value),
    );
  }
}

String _$accessibilityRepositoryHash() =>
    r'86909f0fe84d76ef7c09c4e5d8731a85d394d7f5';

/// State notifier managing user accessibility preferences.

@ProviderFor(AccessibilityController)
final accessibilityControllerProvider = AccessibilityControllerProvider._();

/// State notifier managing user accessibility preferences.
final class AccessibilityControllerProvider
    extends
        $NotifierProvider<AccessibilityController, AccessibilityPreferences> {
  /// State notifier managing user accessibility preferences.
  AccessibilityControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accessibilityControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accessibilityControllerHash();

  @$internal
  @override
  AccessibilityController create() => AccessibilityController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AccessibilityPreferences value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AccessibilityPreferences>(value),
    );
  }
}

String _$accessibilityControllerHash() =>
    r'10d02114c0922a5dc466a9258d689e821c262e57';

/// State notifier managing user accessibility preferences.

abstract class _$AccessibilityController
    extends $Notifier<AccessibilityPreferences> {
  AccessibilityPreferences build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AccessibilityPreferences, AccessibilityPreferences>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AccessibilityPreferences, AccessibilityPreferences>,
              AccessibilityPreferences,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
