// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The app's single [GoRouter] instance. `keepAlive` so navigation state
/// survives rebuilds of unrelated providers.
///
/// Redirect logic (ADR 002: centralised, single file, none in individual
/// screens/routes): before onboarding completes, every location redirects
/// to `/onboarding`; once complete, `/onboarding` itself redirects to
/// `/home`. Driven by [OnboardingStatus] via a small [ChangeNotifier]
/// bridge so go_router re-runs `redirect` whenever onboarding-complete
/// flips, without recreating the router (and therefore without losing
/// navigation state) on every unrelated rebuild.

@ProviderFor(router)
final routerProvider = RouterProvider._();

/// The app's single [GoRouter] instance. `keepAlive` so navigation state
/// survives rebuilds of unrelated providers.
///
/// Redirect logic (ADR 002: centralised, single file, none in individual
/// screens/routes): before onboarding completes, every location redirects
/// to `/onboarding`; once complete, `/onboarding` itself redirects to
/// `/home`. Driven by [OnboardingStatus] via a small [ChangeNotifier]
/// bridge so go_router re-runs `redirect` whenever onboarding-complete
/// flips, without recreating the router (and therefore without losing
/// navigation state) on every unrelated rebuild.

final class RouterProvider
    extends $FunctionalProvider<GoRouter, GoRouter, GoRouter>
    with $Provider<GoRouter> {
  /// The app's single [GoRouter] instance. `keepAlive` so navigation state
  /// survives rebuilds of unrelated providers.
  ///
  /// Redirect logic (ADR 002: centralised, single file, none in individual
  /// screens/routes): before onboarding completes, every location redirects
  /// to `/onboarding`; once complete, `/onboarding` itself redirects to
  /// `/home`. Driven by [OnboardingStatus] via a small [ChangeNotifier]
  /// bridge so go_router re-runs `redirect` whenever onboarding-complete
  /// flips, without recreating the router (and therefore without losing
  /// navigation state) on every unrelated rebuild.
  RouterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'routerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$routerHash();

  @$internal
  @override
  $ProviderElement<GoRouter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GoRouter create(Ref ref) {
    return router(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoRouter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoRouter>(value),
    );
  }
}

String _$routerHash() => r'f6919f33fbcacb2a577844e663af5e889c0aa9ac';
