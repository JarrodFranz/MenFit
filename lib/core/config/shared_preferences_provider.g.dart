// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shared_preferences_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
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

@ProviderFor(sharedPreferences)
final sharedPreferencesProvider = SharedPreferencesProvider._();

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

final class SharedPreferencesProvider
    extends
        $FunctionalProvider<
          SharedPreferences,
          SharedPreferences,
          SharedPreferences
        >
    with $Provider<SharedPreferences> {
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
  SharedPreferencesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sharedPreferencesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sharedPreferencesHash();

  @$internal
  @override
  $ProviderElement<SharedPreferences> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SharedPreferences create(Ref ref) {
    return sharedPreferences(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SharedPreferences value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SharedPreferences>(value),
    );
  }
}

String _$sharedPreferencesHash() => r'fd8a8feb3605128e8b58561eb3f8f9ae5e57e83d';
