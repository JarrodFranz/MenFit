import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'shared_preferences_provider.g.dart';

/// Provides the app-wide [SharedPreferences] instance.
///
/// This throws by design: `main.dart`/`bootstrap.dart` must `await
/// SharedPreferences.getInstance()` before `runApp` and override this
/// provider on the root `ProviderScope`. Doing so keeps every consumer of
/// [SharedPreferences] synchronous and trivially testable via
/// `SharedPreferences.setMockInitialValues` + a provider override.
///
/// Lives in `core/config/` (not a feature) because more than one feature
/// needs it (settings, onboarding) — a feature's `presentation/` may not be
/// imported by another feature (see `architecture_overview.md` rule 2).
@Riverpod(keepAlive: true)
SharedPreferences sharedPreferences(Ref ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden with a real instance in '
    'the root ProviderScope (see bootstrap.dart).',
  );
}
