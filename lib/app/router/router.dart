import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:menfit_app/app/router/routes.dart';
import 'package:menfit_app/features/onboarding/onboarding_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'router.g.dart';

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
@Riverpod(keepAlive: true)
GoRouter router(Ref ref) {
  final refreshNotifier = _OnboardingRefreshNotifier(ref);
  ref.onDispose(refreshNotifier.dispose);

  return GoRouter(
    initialLocation: '/home',
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final onboardingComplete = ref.read(onboardingStatusProvider);
      final atOnboarding = state.matchedLocation == '/onboarding';

      if (!onboardingComplete && !atOnboarding) {
        return '/onboarding';
      }
      if (onboardingComplete && atOnboarding) {
        return '/home';
      }
      return null;
    },
    routes: $appRoutes,
  );
}

/// Bridges [OnboardingStatus] (a Riverpod provider) to go_router's
/// [Listenable]-based `refreshListenable`.
class _OnboardingRefreshNotifier extends ChangeNotifier {
  _OnboardingRefreshNotifier(Ref ref) {
    ref.listen(onboardingStatusProvider, (previous, next) {
      if (previous != next) {
        notifyListeners();
      }
    });
  }
}
