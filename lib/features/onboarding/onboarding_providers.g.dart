// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Composition surface for the `onboarding` feature (ADR 007).
///
/// The only legal way for another feature (or the composition root's
/// router) to reach onboarding-completion state: other features may import
/// this file, never `data/` or `presentation/` directly (see
/// `knowledge/decisions/007_cross_feature_providers.md`). Lives at the
/// feature root rather than under `presentation/` for the same reason
/// `profileRepositoryProvider` moved out of `profile/data/` - a provider
/// another feature depends on can't live in a layer that feature isn't
/// allowed to import.

@ProviderFor(onboardingRepository)
final onboardingRepositoryProvider = OnboardingRepositoryProvider._();

/// Composition surface for the `onboarding` feature (ADR 007).
///
/// The only legal way for another feature (or the composition root's
/// router) to reach onboarding-completion state: other features may import
/// this file, never `data/` or `presentation/` directly (see
/// `knowledge/decisions/007_cross_feature_providers.md`). Lives at the
/// feature root rather than under `presentation/` for the same reason
/// `profileRepositoryProvider` moved out of `profile/data/` - a provider
/// another feature depends on can't live in a layer that feature isn't
/// allowed to import.

final class OnboardingRepositoryProvider
    extends
        $FunctionalProvider<
          OnboardingRepository,
          OnboardingRepository,
          OnboardingRepository
        >
    with $Provider<OnboardingRepository> {
  /// Composition surface for the `onboarding` feature (ADR 007).
  ///
  /// The only legal way for another feature (or the composition root's
  /// router) to reach onboarding-completion state: other features may import
  /// this file, never `data/` or `presentation/` directly (see
  /// `knowledge/decisions/007_cross_feature_providers.md`). Lives at the
  /// feature root rather than under `presentation/` for the same reason
  /// `profileRepositoryProvider` moved out of `profile/data/` - a provider
  /// another feature depends on can't live in a layer that feature isn't
  /// allowed to import.
  OnboardingRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onboardingRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onboardingRepositoryHash();

  @$internal
  @override
  $ProviderElement<OnboardingRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  OnboardingRepository create(Ref ref) {
    return onboardingRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OnboardingRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OnboardingRepository>(value),
    );
  }
}

String _$onboardingRepositoryHash() =>
    r'f83fbffae7a17b513124ce55b2df8df85a9b116d';

/// Whether onboarding has been completed on this device.
///
/// `keepAlive`: the router (app-scoped, see `app/router/router.dart`) reads
/// this to drive its redirect for the lifetime of the app.

@ProviderFor(OnboardingStatus)
final onboardingStatusProvider = OnboardingStatusProvider._();

/// Whether onboarding has been completed on this device.
///
/// `keepAlive`: the router (app-scoped, see `app/router/router.dart`) reads
/// this to drive its redirect for the lifetime of the app.
final class OnboardingStatusProvider
    extends $NotifierProvider<OnboardingStatus, bool> {
  /// Whether onboarding has been completed on this device.
  ///
  /// `keepAlive`: the router (app-scoped, see `app/router/router.dart`) reads
  /// this to drive its redirect for the lifetime of the app.
  OnboardingStatusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onboardingStatusProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onboardingStatusHash();

  @$internal
  @override
  OnboardingStatus create() => OnboardingStatus();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$onboardingStatusHash() => r'5a0c325105452cebc0e8632c2522b4c8fa3a487a';

/// Whether onboarding has been completed on this device.
///
/// `keepAlive`: the router (app-scoped, see `app/router/router.dart`) reads
/// this to drive its redirect for the lifetime of the app.

abstract class _$OnboardingStatus extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
