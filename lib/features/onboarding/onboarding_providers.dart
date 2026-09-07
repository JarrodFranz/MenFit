import 'package:menfit_app/core/config/shared_preferences_provider.dart';
import 'package:menfit_app/features/onboarding/data/onboarding_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'onboarding_providers.g.dart';

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
@Riverpod(keepAlive: true)
OnboardingRepository onboardingRepository(Ref ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return OnboardingRepository(prefs);
}

/// Whether onboarding has been completed on this device.
///
/// `keepAlive`: the router (app-scoped, see `app/router/router.dart`) reads
/// this to drive its redirect for the lifetime of the app.
@Riverpod(keepAlive: true)
class OnboardingStatus extends _$OnboardingStatus {
  @override
  bool build() {
    final repository = ref.watch(onboardingRepositoryProvider);
    return repository.isComplete;
  }

  /// Marks onboarding complete and updates state immediately, so anything
  /// listening (the router's redirect) re-evaluates right away rather than
  /// waiting on a rebuild.
  Future<void> markComplete() async {
    final repository = ref.read(onboardingRepositoryProvider);
    await repository.markComplete();
    state = true;
  }

  /// Resets onboarding to incomplete - used after a full local data wipe
  /// (see `features/settings/presentation/settings_screen.dart`) - and
  /// updates state immediately so the router's redirect sends the user
  /// back to onboarding without waiting on a rebuild.
  Future<void> markIncomplete() async {
    final repository = ref.read(onboardingRepositoryProvider);
    await repository.markIncomplete();
    state = false;
  }
}
