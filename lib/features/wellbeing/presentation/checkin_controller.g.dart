// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'checkin_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Drives the check-in sheet (`widgets/checkin_sheet.dart` — home's
/// invite/edit card opens it for `LocalDate.today()`).
///
/// A **family** provider keyed by [day]/[existing]: the day being checked
/// into, and the check-in already logged for it (if any, for pre-filling an
/// edit), are derived once in [build] from the constructor arguments — same
/// reasoning as `PeriodEntryController`'s dartdoc for why this isn't an
/// imperative `loadForEdit(...)` call from `initState`.

@ProviderFor(CheckinController)
final checkinControllerProvider = CheckinControllerFamily._();

/// Drives the check-in sheet (`widgets/checkin_sheet.dart` — home's
/// invite/edit card opens it for `LocalDate.today()`).
///
/// A **family** provider keyed by [day]/[existing]: the day being checked
/// into, and the check-in already logged for it (if any, for pre-filling an
/// edit), are derived once in [build] from the constructor arguments — same
/// reasoning as `PeriodEntryController`'s dartdoc for why this isn't an
/// imperative `loadForEdit(...)` call from `initState`.
final class CheckinControllerProvider
    extends $NotifierProvider<CheckinController, CheckinFormState> {
  /// Drives the check-in sheet (`widgets/checkin_sheet.dart` — home's
  /// invite/edit card opens it for `LocalDate.today()`).
  ///
  /// A **family** provider keyed by [day]/[existing]: the day being checked
  /// into, and the check-in already logged for it (if any, for pre-filling an
  /// edit), are derived once in [build] from the constructor arguments — same
  /// reasoning as `PeriodEntryController`'s dartdoc for why this isn't an
  /// imperative `loadForEdit(...)` call from `initState`.
  CheckinControllerProvider._({
    required CheckinControllerFamily super.from,
    required (LocalDate, DailyCheckin?) super.argument,
  }) : super(
         retry: null,
         name: r'checkinControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$checkinControllerHash();

  @override
  String toString() {
    return r'checkinControllerProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  CheckinController create() => CheckinController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CheckinFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CheckinFormState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CheckinControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$checkinControllerHash() => r'd6819c414a49c3acb6320ce2025244e6fb4b8748';

/// Drives the check-in sheet (`widgets/checkin_sheet.dart` — home's
/// invite/edit card opens it for `LocalDate.today()`).
///
/// A **family** provider keyed by [day]/[existing]: the day being checked
/// into, and the check-in already logged for it (if any, for pre-filling an
/// edit), are derived once in [build] from the constructor arguments — same
/// reasoning as `PeriodEntryController`'s dartdoc for why this isn't an
/// imperative `loadForEdit(...)` call from `initState`.

final class CheckinControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          CheckinController,
          CheckinFormState,
          CheckinFormState,
          CheckinFormState,
          (LocalDate, DailyCheckin?)
        > {
  CheckinControllerFamily._()
    : super(
        retry: null,
        name: r'checkinControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Drives the check-in sheet (`widgets/checkin_sheet.dart` — home's
  /// invite/edit card opens it for `LocalDate.today()`).
  ///
  /// A **family** provider keyed by [day]/[existing]: the day being checked
  /// into, and the check-in already logged for it (if any, for pre-filling an
  /// edit), are derived once in [build] from the constructor arguments — same
  /// reasoning as `PeriodEntryController`'s dartdoc for why this isn't an
  /// imperative `loadForEdit(...)` call from `initState`.

  CheckinControllerProvider call(LocalDate day, DailyCheckin? existing) =>
      CheckinControllerProvider._(argument: (day, existing), from: this);

  @override
  String toString() => r'checkinControllerProvider';
}

/// Drives the check-in sheet (`widgets/checkin_sheet.dart` — home's
/// invite/edit card opens it for `LocalDate.today()`).
///
/// A **family** provider keyed by [day]/[existing]: the day being checked
/// into, and the check-in already logged for it (if any, for pre-filling an
/// edit), are derived once in [build] from the constructor arguments — same
/// reasoning as `PeriodEntryController`'s dartdoc for why this isn't an
/// imperative `loadForEdit(...)` call from `initState`.

abstract class _$CheckinController extends $Notifier<CheckinFormState> {
  late final _$args = ref.$arg as (LocalDate, DailyCheckin?);
  LocalDate get day => _$args.$1;
  DailyCheckin? get existing => _$args.$2;

  CheckinFormState build(LocalDate day, DailyCheckin? existing);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<CheckinFormState, CheckinFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CheckinFormState, CheckinFormState>,
              CheckinFormState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args.$1, _$args.$2));
  }
}
