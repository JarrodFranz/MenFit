import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:menfit_app/core/domain/entity_id.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/errors/error_messages.dart';
import 'package:menfit_app/features/cycle/cycle_providers.dart';
import 'package:menfit_app/features/cycle/domain/cycle_record.dart';
import 'package:menfit_app/features/cycle/domain/cycle_validation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'period_entry_controller.freezed.dart';
part 'period_entry_controller.g.dart';

/// Which flow [PeriodEntryController] (and the dialog that drives it,
/// `widgets/period_entry_dialog.dart`) is running - each shows and edits a
/// different subset of fields (see `knowledge/domain/womens_health.md`'s
/// scope note: user-logged period tracking only, no phase estimation).
enum PeriodEntryMode {
  /// Log a new period: only a start date is asked for - the new record is
  /// created ongoing (no end date) until later ended.
  logNew,

  /// End an ongoing period: only an end date is asked for; the start date
  /// is fixed and shown read-only.
  endOngoing,

  /// Edit a past (already-ended) period: both dates are editable.
  editPast,
}

/// In-progress state of the period-entry dialog: logging a new period,
/// ending an ongoing one, or editing a past one all share this shape.
///
/// Validation is surfaced as typed state fields (`*Error`), not exceptions
/// - same convention as
/// `features/activity/presentation/manual_entry_controller.dart`.
@freezed
abstract class PeriodEntryState with _$PeriodEntryState {
  const factory PeriodEntryState({
    required LocalDate periodStart,
    LocalDate? periodEnd,
    String? startError,
    String? endError,
    @Default(false) bool isSubmitting,
    String? submitError,

    /// Flips to `true` once [PeriodEntryController.save] persists
    /// successfully - the dialog listens for this to close itself, exactly
    /// once, instead of the controller closing it directly (same
    /// convention as `ManualEntryState.didSave`).
    @Default(false) bool didSave,
  }) = _PeriodEntryState;
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
@riverpod
class PeriodEntryController extends _$PeriodEntryController {
  String? _editingRecordId;
  DateTime? _editingCreatedAt;

  @override
  PeriodEntryState build(PeriodEntryMode mode, CycleRecord? record) {
    switch (mode) {
      case PeriodEntryMode.logNew:
        _editingRecordId = null;
        _editingCreatedAt = null;
        return PeriodEntryState(periodStart: LocalDate.today());
      case PeriodEntryMode.endOngoing:
        final ongoing = record!;
        _editingRecordId = ongoing.id;
        _editingCreatedAt = ongoing.createdAt;
        return PeriodEntryState(
          periodStart: ongoing.periodStart,
          periodEnd: LocalDate.today(),
        );
      case PeriodEntryMode.editPast:
        final past = record!;
        _editingRecordId = past.id;
        _editingCreatedAt = past.createdAt;
        return PeriodEntryState(
          periodStart: past.periodStart,
          periodEnd: past.periodEnd,
        );
    }
  }

  /// B3: if the new start date would put [PeriodEntryState.periodEnd]
  /// before it (e.g. the user had already picked an end date, then moved
  /// the start date past it), clear the now-invalid end date rather than
  /// leaving `end < start` sitting in state - `_DateField`'s `firstDate`
  /// for the end picker is [value], so an un-cleared, now-out-of-range
  /// `periodEnd` would otherwise make `showDatePicker` crash when the
  /// dialog rebuilds (see the dialog's `_pick` clamp for the matching
  /// defensive fix on the picker side).
  void updatePeriodStart(LocalDate value) {
    final currentEnd = state.periodEnd;
    final clearsEnd = currentEnd != null && value.isAfter(currentEnd);
    state = state.copyWith(
      periodStart: value,
      startError: null,
      endError: null,
      periodEnd: clearsEnd ? null : currentEnd,
    );
  }

  void updatePeriodEnd(LocalDate? value) {
    state = state.copyWith(periodEnd: value, endError: null);
  }

  /// Validates the form against [existingRecords] and, if valid, saves it.
  /// Returns `true` on success. On failure, sets the relevant `*Error`
  /// field(s) and returns `false` without touching persistence.
  Future<bool> save(List<CycleRecord> existingRecords) async {
    final validation = validateCycleRecord(
      periodStart: state.periodStart,
      today: LocalDate.today(),
      existingRecords: existingRecords,
      periodEnd: state.periodEnd,
      excludingId: _editingRecordId,
    );
    if (!validation.isValid) {
      state = state.copyWith(
        startError: validation.startError,
        endError: validation.endError,
      );
      return false;
    }

    state = state.copyWith(isSubmitting: true, submitError: null);
    try {
      final repository = ref.read(cycleRepositoryProvider);
      final now = DateTime.now().toUtc();
      final record = CycleRecord(
        id: _editingRecordId ?? EntityId.generate(),
        periodStart: state.periodStart,
        periodEnd: state.periodEnd,
        createdAt: _editingCreatedAt ?? now,
        updatedAt: now,
      );

      await repository.saveRecord(record);
      state = state.copyWith(didSave: true, isSubmitting: false);
      return true;
    } on Object catch (error) {
      state = state.copyWith(
        submitError: userMessageFor(error),
        isSubmitting: false,
      );
      return false;
    }
  }
}
