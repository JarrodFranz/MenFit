// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flare_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Drives the flare dialog (`presentation/flare_dialog.dart`).
///
/// A **family** provider keyed by [existing] / [initialDay]: `null` to log a
/// new flare (defaulting to [initialDay] or today), or an existing [FlareEvent]
/// to edit/delete — same family-derives-initial-state reasoning as
/// `CheckinController`/`PeriodEntryController`.
///
/// Reaching into `streaks`' composition surface for
/// `recoveryRepositoryProvider` is ADR-007-legal (a feature may depend on
/// another feature's `<name>_providers.dart`), the same import
/// `wellbeing_screen.dart` already makes.

@ProviderFor(FlareController)
final flareControllerProvider = FlareControllerFamily._();

/// Drives the flare dialog (`presentation/flare_dialog.dart`).
///
/// A **family** provider keyed by [existing] / [initialDay]: `null` to log a
/// new flare (defaulting to [initialDay] or today), or an existing [FlareEvent]
/// to edit/delete — same family-derives-initial-state reasoning as
/// `CheckinController`/`PeriodEntryController`.
///
/// Reaching into `streaks`' composition surface for
/// `recoveryRepositoryProvider` is ADR-007-legal (a feature may depend on
/// another feature's `<name>_providers.dart`), the same import
/// `wellbeing_screen.dart` already makes.
final class FlareControllerProvider
    extends $NotifierProvider<FlareController, FlareFormState> {
  /// Drives the flare dialog (`presentation/flare_dialog.dart`).
  ///
  /// A **family** provider keyed by [existing] / [initialDay]: `null` to log a
  /// new flare (defaulting to [initialDay] or today), or an existing [FlareEvent]
  /// to edit/delete — same family-derives-initial-state reasoning as
  /// `CheckinController`/`PeriodEntryController`.
  ///
  /// Reaching into `streaks`' composition surface for
  /// `recoveryRepositoryProvider` is ADR-007-legal (a feature may depend on
  /// another feature's `<name>_providers.dart`), the same import
  /// `wellbeing_screen.dart` already makes.
  FlareControllerProvider._({
    required FlareControllerFamily super.from,
    required (FlareEvent?, LocalDate?) super.argument,
  }) : super(
         retry: null,
         name: r'flareControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$flareControllerHash();

  @override
  String toString() {
    return r'flareControllerProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  FlareController create() => FlareController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FlareFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FlareFormState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is FlareControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$flareControllerHash() => r'477be0cc0a668804bf2a79c28c832ceb363d8874';

/// Drives the flare dialog (`presentation/flare_dialog.dart`).
///
/// A **family** provider keyed by [existing] / [initialDay]: `null` to log a
/// new flare (defaulting to [initialDay] or today), or an existing [FlareEvent]
/// to edit/delete — same family-derives-initial-state reasoning as
/// `CheckinController`/`PeriodEntryController`.
///
/// Reaching into `streaks`' composition surface for
/// `recoveryRepositoryProvider` is ADR-007-legal (a feature may depend on
/// another feature's `<name>_providers.dart`), the same import
/// `wellbeing_screen.dart` already makes.

final class FlareControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          FlareController,
          FlareFormState,
          FlareFormState,
          FlareFormState,
          (FlareEvent?, LocalDate?)
        > {
  FlareControllerFamily._()
    : super(
        retry: null,
        name: r'flareControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Drives the flare dialog (`presentation/flare_dialog.dart`).
  ///
  /// A **family** provider keyed by [existing] / [initialDay]: `null` to log a
  /// new flare (defaulting to [initialDay] or today), or an existing [FlareEvent]
  /// to edit/delete — same family-derives-initial-state reasoning as
  /// `CheckinController`/`PeriodEntryController`.
  ///
  /// Reaching into `streaks`' composition surface for
  /// `recoveryRepositoryProvider` is ADR-007-legal (a feature may depend on
  /// another feature's `<name>_providers.dart`), the same import
  /// `wellbeing_screen.dart` already makes.

  FlareControllerProvider call(FlareEvent? existing, [LocalDate? initialDay]) =>
      FlareControllerProvider._(argument: (existing, initialDay), from: this);

  @override
  String toString() => r'flareControllerProvider';
}

/// Drives the flare dialog (`presentation/flare_dialog.dart`).
///
/// A **family** provider keyed by [existing] / [initialDay]: `null` to log a
/// new flare (defaulting to [initialDay] or today), or an existing [FlareEvent]
/// to edit/delete — same family-derives-initial-state reasoning as
/// `CheckinController`/`PeriodEntryController`.
///
/// Reaching into `streaks`' composition surface for
/// `recoveryRepositoryProvider` is ADR-007-legal (a feature may depend on
/// another feature's `<name>_providers.dart`), the same import
/// `wellbeing_screen.dart` already makes.

abstract class _$FlareController extends $Notifier<FlareFormState> {
  late final _$args = ref.$arg as (FlareEvent?, LocalDate?);
  FlareEvent? get existing => _$args.$1;
  LocalDate? get initialDay => _$args.$2;

  FlareFormState build(FlareEvent? existing, [LocalDate? initialDay]);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<FlareFormState, FlareFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<FlareFormState, FlareFormState>,
              FlareFormState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args.$1, _$args.$2));
  }
}
