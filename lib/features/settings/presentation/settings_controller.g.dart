// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The repository used to persist user-facing settings.

@ProviderFor(settingsRepository)
final settingsRepositoryProvider = SettingsRepositoryProvider._();

/// The repository used to persist user-facing settings.

final class SettingsRepositoryProvider
    extends
        $FunctionalProvider<
          SettingsRepository,
          SettingsRepository,
          SettingsRepository
        >
    with $Provider<SettingsRepository> {
  /// The repository used to persist user-facing settings.
  SettingsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsRepositoryHash();

  @$internal
  @override
  $ProviderElement<SettingsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SettingsRepository create(Ref ref) {
    return settingsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SettingsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SettingsRepository>(value),
    );
  }
}

String _$settingsRepositoryHash() =>
    r'51d78788c24da1d15991f57a0d8c2030fa5519cc';

/// Controller for the app's theme mode.

@ProviderFor(ThemeModeController)
final themeModeControllerProvider = ThemeModeControllerProvider._();

/// Controller for the app's theme mode.
final class ThemeModeControllerProvider
    extends $AsyncNotifierProvider<ThemeModeController, ThemeMode> {
  /// Controller for the app's theme mode.
  ThemeModeControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'themeModeControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$themeModeControllerHash();

  @$internal
  @override
  ThemeModeController create() => ThemeModeController();
}

String _$themeModeControllerHash() =>
    r'da29e0d76612d4e46eb96b50f72f5e4f4ce1c4b2';

/// Controller for the app's theme mode.

abstract class _$ThemeModeController extends $AsyncNotifier<ThemeMode> {
  FutureOr<ThemeMode> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<ThemeMode>, ThemeMode>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ThemeMode>, ThemeMode>,
              AsyncValue<ThemeMode>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Controller for whether workout energy expenditure estimates are shown.

@ProviderFor(ActivityEnergyEstimatesController)
final activityEnergyEstimatesControllerProvider =
    ActivityEnergyEstimatesControllerProvider._();

/// Controller for whether workout energy expenditure estimates are shown.
final class ActivityEnergyEstimatesControllerProvider
    extends $NotifierProvider<ActivityEnergyEstimatesController, bool> {
  /// Controller for whether workout energy expenditure estimates are shown.
  ActivityEnergyEstimatesControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activityEnergyEstimatesControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() =>
      _$activityEnergyEstimatesControllerHash();

  @$internal
  @override
  ActivityEnergyEstimatesController create() =>
      ActivityEnergyEstimatesController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$activityEnergyEstimatesControllerHash() =>
    r'73e19fcaafe1daa3b3a4b7cceacc936a1c5a2209';

/// Controller for whether workout energy expenditure estimates are shown.

abstract class _$ActivityEnergyEstimatesController extends $Notifier<bool> {
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

/// Controller for whether fitness device synchronization is enabled.

@ProviderFor(FitnessDeviceSyncController)
final fitnessDeviceSyncControllerProvider =
    FitnessDeviceSyncControllerProvider._();

/// Controller for whether fitness device synchronization is enabled.
final class FitnessDeviceSyncControllerProvider
    extends $NotifierProvider<FitnessDeviceSyncController, bool> {
  /// Controller for whether fitness device synchronization is enabled.
  FitnessDeviceSyncControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'fitnessDeviceSyncControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$fitnessDeviceSyncControllerHash();

  @$internal
  @override
  FitnessDeviceSyncController create() => FitnessDeviceSyncController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$fitnessDeviceSyncControllerHash() =>
    r'e2d6a72598d8705b8548cbabdd93e58ea76dcaef';

/// Controller for whether fitness device synchronization is enabled.

abstract class _$FitnessDeviceSyncController extends $Notifier<bool> {
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
