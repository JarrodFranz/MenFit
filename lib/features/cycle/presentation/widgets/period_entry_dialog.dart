import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/cycle/domain/cycle_record.dart';
import 'package:menfit_app/features/cycle/presentation/cycle_records_controller.dart';
import 'package:menfit_app/features/cycle/presentation/period_entry_controller.dart';
import 'package:menfit_app/features/wellbeing/wellbeing_providers.dart';
import 'package:menfit_app/features/wellbeing/wellbeing_widgets.dart';

/// Modal dialog for logging, ending, or editing a period - the only entry
/// point into cycle data (no dedicated routes; see the cycle feature's
/// scope note in `presentation/cycle_screen.dart`).
///
/// All the mode-specific behaviour (which fields to show, and the
/// mode-appropriate initial dates) lives in
/// `presentation/period_entry_controller.dart`'s [PeriodEntryController] -
/// a family provider keyed by [mode]/[record] - so this widget stays a
/// plain [ConsumerWidget] with no `initState` of its own (see that
/// controller's dartdoc for why an `initState`-driven "load" call doesn't
/// work for this dialog).
///
/// S1: `logNew` now also renders an *optional* end date
/// ([_OptionalDateField]) - "End date (leave empty if ongoing)" - so a
/// completed past period (e.g. logging July's period after August's is
/// already underway) can be backfilled in one step instead of needing a
/// separate "end it" pass, and so an overlap against that end date has
/// somewhere on screen to show up (see B1 below).
class PeriodEntryDialog extends ConsumerWidget {
  const PeriodEntryDialog({required this.mode, super.key, this.record})
    : assert(
        mode == PeriodEntryMode.logNew || record != null,
        'endOngoing and editPast require a record',
      );

  final PeriodEntryMode mode;

  /// The record being ended or edited. Unused (and unrequired) for
  /// [PeriodEntryMode.logNew].
  final CycleRecord? record;

  /// Shows this dialog. Awaiting the result tells the caller only that the
  /// dialog closed, not whether a save happened - the underlying save
  /// already took effect via [PeriodEntryController] by the time it closes.
  static Future<void> show(
    BuildContext context, {
    required PeriodEntryMode mode,
    CycleRecord? record,
  }) {
    return showDialog<void>(
      context: context,
      builder: (_) => PeriodEntryDialog(mode: mode, record: record),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final provider = periodEntryControllerProvider(mode, record);
    final state = ref.watch(provider);
    final controller = ref.read(provider.notifier);
    final recordsAsync = ref.watch(cycleRecordsControllerProvider);
    final existingRecords = recordsAsync.value ?? const [];
    // Nit N2: while the existing-period history hasn't loaded yet,
    // `existingRecords` above is an empty placeholder, not "confirmed no
    // other periods exist" - validating (and saving) against it could
    // silently miss a real overlap against a period that just hasn't
    // arrived from the stream yet. Block save instead of racing it.
    final historyLoading = !recordsAsync.hasValue;
    final today = LocalDate.today();
    final farBack = LocalDate(today.year - 10, 1, 1);

    ref.listen(provider, (previous, next) {
      final justSaved = next.didSave && !(previous?.didSave ?? false);
      if (justSaved && Navigator.of(context).canPop()) {
        final startDay = next.periodStart;
        Navigator.of(context).pop();
        if (mode == PeriodEntryMode.logNew) {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            final repo = ref.read(wellbeingRepositoryProvider);
            final checkin = await repo.getCheckinFor(startDay);
            if ((checkin == null || checkin.isEmpty) && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                    'Period logged. Would you like to log your check-in?',
                  ),
                  action: SnackBarAction(
                    label: 'Check in',
                    onPressed: () {
                      if (context.mounted) {
                        unawaited(CheckinSheet.show(context, day: startDay));
                      }
                    },
                  ),
                  duration: const Duration(seconds: 5),
                ),
              );
            }
          });
        }
      }
    });

    // B1: every validation error must be visible somewhere. `startError`
    // is normally shown inline by the interactive start-date field, but
    // `endOngoing` mode renders the start date read-only (nit N3) with no
    // error slot of its own - if `startError` were ever set in that mode
    // (not reachable today, since that mode's start date is fixed from an
    // already-valid record rather than user-editable, but defended
    // anyway), it would otherwise be silently dropped. Anything an
    // on-screen field can't show routes through the same bottom error
    // slot used for `submitError`, so `save()` can never return `false`
    // without something visible changing on screen.
    final showsStartFieldError = mode != PeriodEntryMode.endOngoing;
    final hiddenError = showsStartFieldError ? null : state.startError;
    final generalError = hiddenError ?? state.submitError;

    final saveButton = FilledButton(
      onPressed: (state.isSubmitting || historyLoading)
          ? null
          : () => controller.save(existingRecords),
      child: state.isSubmitting
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(_actionLabelFor(mode)),
    );

    return AlertDialog(
      title: Text(_titleFor(mode)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (mode == PeriodEntryMode.endOngoing)
            // Nit N3: matches PeriodEntryController's own doc - endOngoing
            // treats the start date as fixed, so it's shown but not
            // editable here.
            _ReadOnlyDateField(label: 'Start date', value: state.periodStart)
          else
            _DateField(
              label: 'Start date',
              value: state.periodStart,
              errorText: state.startError,
              firstDate: farBack,
              lastDate: today,
              onChanged: controller.updatePeriodStart,
            ),
          SizedBox(height: tokens.spacingMd),
          if (mode == PeriodEntryMode.logNew)
            _OptionalDateField(
              value: state.periodEnd,
              errorText: state.endError,
              firstDate: state.periodStart,
              lastDate: today,
              onChanged: controller.updatePeriodEnd,
            )
          else
            _DateField(
              label: 'End date',
              value: state.periodEnd ?? today,
              errorText: state.endError,
              firstDate: state.periodStart,
              lastDate: today,
              onChanged: controller.updatePeriodEnd,
            ),
          if (generalError != null) ...[
            SizedBox(height: tokens.spacingMd),
            Text(
              generalError,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        // Nit N2: a plain disabled button gives no reason why - wrap it so
        // hover/long-press explains it's not stuck, just waiting on data.
        if (historyLoading)
          Tooltip(message: 'Loading your history…', child: saveButton)
        else
          saveButton,
      ],
    );
  }

  String _titleFor(PeriodEntryMode mode) => switch (mode) {
    PeriodEntryMode.logNew => 'Log your period',
    PeriodEntryMode.endOngoing => 'End your period',
    PeriodEntryMode.editPast => 'Edit period',
  };

  String _actionLabelFor(PeriodEntryMode mode) => switch (mode) {
    PeriodEntryMode.logNew => 'Log period',
    PeriodEntryMode.endOngoing => 'End period',
    PeriodEntryMode.editPast => 'Save',
  };
}

/// A required, user-picked date field with an inline error slot.
class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.errorText,
    required this.firstDate,
    required this.lastDate,
    required this.onChanged,
  });

  final String label;
  final LocalDate value;
  final String? errorText;
  final LocalDate firstDate;
  final LocalDate lastDate;
  final ValueChanged<LocalDate> onChanged;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: label,
        errorText: errorText,
      ),
      child: InkWell(
        onTap: () => _pick(context),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(DateFormat.yMMMd().format(_asDateTime(value))),
            const Icon(Icons.edit_calendar_outlined),
          ],
        ),
      ),
    );
  }

  Future<void> _pick(BuildContext context) async {
    // B3: `value` can already be outside `[firstDate, lastDate]` by the
    // time this opens (e.g. the start date just moved past a stale end
    // date on the same rebuild) - `showDatePicker` asserts `initialDate`
    // is within range and crashes instead of clamping it itself, so this
    // does that defensively before ever calling it.
    final initial = _clampDate(value, firstDate, lastDate);
    final picked = await showDatePicker(
      context: context,
      initialDate: _asDateTime(initial),
      firstDate: _asDateTime(firstDate),
      lastDate: _asDateTime(lastDate),
    );
    if (picked == null) return;
    onChanged(LocalDate.fromDateTime(picked));
  }
}

/// S1: an optional, user-picked date field - `logNew`'s end date, which may
/// be left unset (period still ongoing) or cleared back to unset after
/// being picked.
class _OptionalDateField extends StatelessWidget {
  const _OptionalDateField({
    required this.value,
    required this.errorText,
    required this.firstDate,
    required this.lastDate,
    required this.onChanged,
  });

  final LocalDate? value;
  final String? errorText;
  final LocalDate firstDate;
  final LocalDate lastDate;
  final ValueChanged<LocalDate?> onChanged;

  @override
  Widget build(BuildContext context) {
    final current = value;
    return InputDecorator(
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: 'End date (leave empty if ongoing)',
        errorText: errorText,
      ),
      child: InkWell(
        onTap: () => _pick(context),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              current == null
                  ? 'Ongoing'
                  : DateFormat.yMMMd().format(_asDateTime(current)),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (current != null)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    tooltip: 'Clear end date (still ongoing)',
                    onPressed: () => onChanged(null),
                  ),
                const Icon(Icons.edit_calendar_outlined),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pick(BuildContext context) async {
    // B3: same defensive clamp as `_DateField._pick` - see its comment.
    final initial = _clampDate(value ?? lastDate, firstDate, lastDate);
    final picked = await showDatePicker(
      context: context,
      initialDate: _asDateTime(initial),
      firstDate: _asDateTime(firstDate),
      lastDate: _asDateTime(lastDate),
    );
    if (picked == null) return;
    onChanged(LocalDate.fromDateTime(picked));
  }
}

/// Nit N3: a fixed date shown for context, with no picker interaction and
/// no error slot (nothing ever routes an error to it - see
/// [PeriodEntryDialog.build]'s `showsStartFieldError`).
class _ReadOnlyDateField extends StatelessWidget {
  const _ReadOnlyDateField({required this.label, required this.value});

  final String label;
  final LocalDate value;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: label,
      ),
      child: Text(DateFormat.yMMMd().format(_asDateTime(value))),
    );
  }
}

DateTime _asDateTime(LocalDate date) =>
    DateTime(date.year, date.month, date.day);

/// Clamps [value] into `[firstDate, lastDate]` - shared by both date
/// fields' `_pick` (B3).
LocalDate _clampDate(LocalDate value, LocalDate firstDate, LocalDate lastDate) {
  if (value.isBefore(firstDate)) return firstDate;
  if (value.isAfter(lastDate)) return lastDate;
  return value;
}
