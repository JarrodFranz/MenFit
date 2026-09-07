// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'period_entry_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Drives the period-entry dialog (log a new period, end an ongoing one, or
/// edit a past one).
///
/// A **family** provider keyed by [mode]/[record]: which record (if any) is
/// being edited, and the mode-appropriate initial dates, are derived once
/// in [build] from the constructor arguments, rather than via an imperative
/// `loadForEdit(...)`-style call from the dialog's `initState`. That
/// imperative-call shape (used by
/// `features/activity/presentation/manual_entry_controller.dart`'s
/// `loadForEdit`, called from an async gap after an `await`) doesn't work
/// here: this dialog has no `await` before it needs the pre-filled state,
/// so calling a notifier method straight from `initState` mutates the
/// provider synchronously *during* the widget tree's build phase, which
/// Riverpod rejects ("Tried to modify a provider while the widget tree was
/// building"). Computing the initial state as a pure function of the
/// family arguments inside [build] sidesteps that entirely - it's normal
/// first-read initialisation, not a post-construction mutation.
///
/// [_editingRecordId]/[_editingCreatedAt] stay plain instance fields (not
/// [PeriodEntryState] fields) for the same reason as
/// `ManualEntryController`'s equivalents: controller bookkeeping the UI
/// never reads, not view state.

@ProviderFor(PeriodEntryController)
final periodEntryControllerProvider = PeriodEntryControllerFamily._();

/// Drives the period-entry dialog (log a new period, end an ongoing one, or
/// edit a past one).
///
/// A **family** provider keyed by [mode]/[record]: which record (if any) is
/// being edited, and the mode-appropriate initial dates, are derived once
/// in [build] from the constructor arguments, rather than via an imperative
/// `loadForEdit(...)`-style call from the dialog's `initState`. That
/// imperative-call shape (used by
/// `features/activity/presentation/manual_entry_controller.dart`'s
/// `loadForEdit`, called from an async gap after an `await`) doesn't work
/// here: this dialog has no `await` before it needs the pre-filled state,
/// so calling a notifier method straight from `initState` mutates the
/// provider synchronously *during* the widget tree's build phase, which
/// Riverpod rejects ("Tried to modify a provider while the widget tree was
/// building"). Computing the initial state as a pure function of the
/// family arguments inside [build] sidesteps that entirely - it's normal
/// first-read initialisation, not a post-construction mutation.
///
/// [_editingRecordId]/[_editingCreatedAt] stay plain instance fields (not
/// [PeriodEntryState] fields) for the same reason as
/// `ManualEntryController`'s equivalents: controller bookkeeping the UI
/// never reads, not view state.
final class PeriodEntryControllerProvider
    extends $NotifierProvider<PeriodEntryController, PeriodEntryState> {
  /// Drives the period-entry dialog (log a new period, end an ongoing one, or
  /// edit a past one).
  ///
  /// A **family** provider keyed by [mode]/[record]: which record (if any) is
  /// being edited, and the mode-appropriate initial dates, are derived once
  /// in [build] from the constructor arguments, rather than via an imperative
  /// `loadForEdit(...)`-style call from the dialog's `initState`. That
  /// imperative-call shape (used by
  /// `features/activity/presentation/manual_entry_controller.dart`'s
  /// `loadForEdit`, called from an async gap after an `await`) doesn't work
  /// here: this dialog has no `await` before it needs the pre-filled state,
  /// so calling a notifier method straight from `initState` mutates the
  /// provider synchronously *during* the widget tree's build phase, which
  /// Riverpod rejects ("Tried to modify a provider while the widget tree was
  /// building"). Computing the initial state as a pure function of the
  /// family arguments inside [build] sidesteps that entirely - it's normal
  /// first-read initialisation, not a post-construction mutation.
  ///
  /// [_editingRecordId]/[_editingCreatedAt] stay plain instance fields (not
  /// [PeriodEntryState] fields) for the same reason as
  /// `ManualEntryController`'s equivalents: controller bookkeeping the UI
  /// never reads, not view state.
  PeriodEntryControllerProvider._({
    required PeriodEntryControllerFamily super.from,
    required (PeriodEntryMode, CycleRecord?) super.argument,
  }) : super(
         retry: null,
         name: r'periodEntryControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$periodEntryControllerHash();

  @override
  String toString() {
    return r'periodEntryControllerProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  PeriodEntryController create() => PeriodEntryController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PeriodEntryState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PeriodEntryState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is PeriodEntryControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$periodEntryControllerHash() =>
    r'17fd8a9983f4876c6d94f451ac7efe4304c5152e';

/// Drives the period-entry dialog (log a new period, end an ongoing one, or
/// edit a past one).
///
/// A **family** provider keyed by [mode]/[record]: which record (if any) is
/// being edited, and the mode-appropriate initial dates, are derived once
/// in [build] from the constructor arguments, rather than via an imperative
/// `loadForEdit(...)`-style call from the dialog's `initState`. That
/// imperative-call shape (used by
/// `features/activity/presentation/manual_entry_controller.dart`'s
/// `loadForEdit`, called from an async gap after an `await`) doesn't work
/// here: this dialog has no `await` before it needs the pre-filled state,
/// so calling a notifier method straight from `initState` mutates the
/// provider synchronously *during* the widget tree's build phase, which
/// Riverpod rejects ("Tried to modify a provider while the widget tree was
/// building"). Computing the initial state as a pure function of the
/// family arguments inside [build] sidesteps that entirely - it's normal
/// first-read initialisation, not a post-construction mutation.
///
/// [_editingRecordId]/[_editingCreatedAt] stay plain instance fields (not
/// [PeriodEntryState] fields) for the same reason as
/// `ManualEntryController`'s equivalents: controller bookkeeping the UI
/// never reads, not view state.

final class PeriodEntryControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          PeriodEntryController,
          PeriodEntryState,
          PeriodEntryState,
          PeriodEntryState,
          (PeriodEntryMode, CycleRecord?)
        > {
  PeriodEntryControllerFamily._()
    : super(
        retry: null,
        name: r'periodEntryControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Drives the period-entry dialog (log a new period, end an ongoing one, or
  /// edit a past one).
  ///
  /// A **family** provider keyed by [mode]/[record]: which record (if any) is
  /// being edited, and the mode-appropriate initial dates, are derived once
  /// in [build] from the constructor arguments, rather than via an imperative
  /// `loadForEdit(...)`-style call from the dialog's `initState`. That
  /// imperative-call shape (used by
  /// `features/activity/presentation/manual_entry_controller.dart`'s
  /// `loadForEdit`, called from an async gap after an `await`) doesn't work
  /// here: this dialog has no `await` before it needs the pre-filled state,
  /// so calling a notifier method straight from `initState` mutates the
  /// provider synchronously *during* the widget tree's build phase, which
  /// Riverpod rejects ("Tried to modify a provider while the widget tree was
  /// building"). Computing the initial state as a pure function of the
  /// family arguments inside [build] sidesteps that entirely - it's normal
  /// first-read initialisation, not a post-construction mutation.
  ///
  /// [_editingRecordId]/[_editingCreatedAt] stay plain instance fields (not
  /// [PeriodEntryState] fields) for the same reason as
  /// `ManualEntryController`'s equivalents: controller bookkeeping the UI
  /// never reads, not view state.

  PeriodEntryControllerProvider call(
    PeriodEntryMode mode,
    CycleRecord? record,
  ) => PeriodEntryControllerProvider._(argument: (mode, record), from: this);

  @override
  String toString() => r'periodEntryControllerProvider';
}

/// Drives the period-entry dialog (log a new period, end an ongoing one, or
/// edit a past one).
///
/// A **family** provider keyed by [mode]/[record]: which record (if any) is
/// being edited, and the mode-appropriate initial dates, are derived once
/// in [build] from the constructor arguments, rather than via an imperative
/// `loadForEdit(...)`-style call from the dialog's `initState`. That
/// imperative-call shape (used by
/// `features/activity/presentation/manual_entry_controller.dart`'s
/// `loadForEdit`, called from an async gap after an `await`) doesn't work
/// here: this dialog has no `await` before it needs the pre-filled state,
/// so calling a notifier method straight from `initState` mutates the
/// provider synchronously *during* the widget tree's build phase, which
/// Riverpod rejects ("Tried to modify a provider while the widget tree was
/// building"). Computing the initial state as a pure function of the
/// family arguments inside [build] sidesteps that entirely - it's normal
/// first-read initialisation, not a post-construction mutation.
///
/// [_editingRecordId]/[_editingCreatedAt] stay plain instance fields (not
/// [PeriodEntryState] fields) for the same reason as
/// `ManualEntryController`'s equivalents: controller bookkeeping the UI
/// never reads, not view state.

abstract class _$PeriodEntryController extends $Notifier<PeriodEntryState> {
  late final _$args = ref.$arg as (PeriodEntryMode, CycleRecord?);
  PeriodEntryMode get mode => _$args.$1;
  CycleRecord? get record => _$args.$2;

  PeriodEntryState build(PeriodEntryMode mode, CycleRecord? record);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<PeriodEntryState, PeriodEntryState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PeriodEntryState, PeriodEntryState>,
              PeriodEntryState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args.$1, _$args.$2));
  }
}
