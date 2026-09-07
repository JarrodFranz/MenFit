// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'log_entry_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Drives the log-a-food dialog (`presentation/log_entry_dialog.dart`).
///
/// A **family** keyed by what the dialog was opened with, the same
/// family-derives-initial-state shape as `FlareController`:
///
/// - [existing] non-null → editing that diary entry ([food] is ignored).
/// - [existing] null and [food] non-null → logging a new entry for [day]
///   into [meal].
///
/// Exactly one of the two is expected; a call with neither can't build an
/// entry and [save] reports that rather than throwing.

@ProviderFor(LogEntryController)
final logEntryControllerProvider = LogEntryControllerFamily._();

/// Drives the log-a-food dialog (`presentation/log_entry_dialog.dart`).
///
/// A **family** keyed by what the dialog was opened with, the same
/// family-derives-initial-state shape as `FlareController`:
///
/// - [existing] non-null → editing that diary entry ([food] is ignored).
/// - [existing] null and [food] non-null → logging a new entry for [day]
///   into [meal].
///
/// Exactly one of the two is expected; a call with neither can't build an
/// entry and [save] reports that rather than throwing.
final class LogEntryControllerProvider
    extends $NotifierProvider<LogEntryController, LogEntryFormState> {
  /// Drives the log-a-food dialog (`presentation/log_entry_dialog.dart`).
  ///
  /// A **family** keyed by what the dialog was opened with, the same
  /// family-derives-initial-state shape as `FlareController`:
  ///
  /// - [existing] non-null → editing that diary entry ([food] is ignored).
  /// - [existing] null and [food] non-null → logging a new entry for [day]
  ///   into [meal].
  ///
  /// Exactly one of the two is expected; a call with neither can't build an
  /// entry and [save] reports that rather than throwing.
  LogEntryControllerProvider._({
    required LogEntryControllerFamily super.from,
    required (NutritionEntry?, Food?, LocalDate, MealType) super.argument,
  }) : super(
         retry: null,
         name: r'logEntryControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$logEntryControllerHash();

  @override
  String toString() {
    return r'logEntryControllerProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  LogEntryController create() => LogEntryController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LogEntryFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LogEntryFormState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is LogEntryControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$logEntryControllerHash() =>
    r'822a6e3b75d8b7a11db099a65decf5768ae2065f';

/// Drives the log-a-food dialog (`presentation/log_entry_dialog.dart`).
///
/// A **family** keyed by what the dialog was opened with, the same
/// family-derives-initial-state shape as `FlareController`:
///
/// - [existing] non-null → editing that diary entry ([food] is ignored).
/// - [existing] null and [food] non-null → logging a new entry for [day]
///   into [meal].
///
/// Exactly one of the two is expected; a call with neither can't build an
/// entry and [save] reports that rather than throwing.

final class LogEntryControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          LogEntryController,
          LogEntryFormState,
          LogEntryFormState,
          LogEntryFormState,
          (NutritionEntry?, Food?, LocalDate, MealType)
        > {
  LogEntryControllerFamily._()
    : super(
        retry: null,
        name: r'logEntryControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Drives the log-a-food dialog (`presentation/log_entry_dialog.dart`).
  ///
  /// A **family** keyed by what the dialog was opened with, the same
  /// family-derives-initial-state shape as `FlareController`:
  ///
  /// - [existing] non-null → editing that diary entry ([food] is ignored).
  /// - [existing] null and [food] non-null → logging a new entry for [day]
  ///   into [meal].
  ///
  /// Exactly one of the two is expected; a call with neither can't build an
  /// entry and [save] reports that rather than throwing.

  LogEntryControllerProvider call(
    NutritionEntry? existing,
    Food? food,
    LocalDate day,
    MealType meal,
  ) => LogEntryControllerProvider._(
    argument: (existing, food, day, meal),
    from: this,
  );

  @override
  String toString() => r'logEntryControllerProvider';
}

/// Drives the log-a-food dialog (`presentation/log_entry_dialog.dart`).
///
/// A **family** keyed by what the dialog was opened with, the same
/// family-derives-initial-state shape as `FlareController`:
///
/// - [existing] non-null → editing that diary entry ([food] is ignored).
/// - [existing] null and [food] non-null → logging a new entry for [day]
///   into [meal].
///
/// Exactly one of the two is expected; a call with neither can't build an
/// entry and [save] reports that rather than throwing.

abstract class _$LogEntryController extends $Notifier<LogEntryFormState> {
  late final _$args = ref.$arg as (NutritionEntry?, Food?, LocalDate, MealType);
  NutritionEntry? get existing => _$args.$1;
  Food? get food => _$args.$2;
  LocalDate get day => _$args.$3;
  MealType get meal => _$args.$4;

  LogEntryFormState build(
    NutritionEntry? existing,
    Food? food,
    LocalDate day,
    MealType meal,
  );
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<LogEntryFormState, LogEntryFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<LogEntryFormState, LogEntryFormState>,
              LogEntryFormState,
              Object?,
              Object?
            >;
    return element.handleCreate(
      ref,
      () => build(_$args.$1, _$args.$2, _$args.$3, _$args.$4),
    );
  }
}
