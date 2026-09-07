import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:menfit_app/core/domain/local_date.dart';

/// Whether a wellbeing entry covers a single calendar day or an inclusive
/// range of them.
///
/// Shared by the flare dialog and the mark-recovery dialog so both offer
/// the same choice, with the same wording, in the same control.
enum DateSpanMode {
  single,
  range;

  String get label => switch (this) {
    DateSpanMode.single => 'Single day',
    DateSpanMode.range => 'Date range',
  };
}

/// The "Single day / Date range" choice.
///
/// A [SegmentedButton] to match the flare dialog's severity control (and
/// the check-in sheet's score rows); segmented buttons are focusable and
/// arrow/space operable, so this stays keyboard-reachable on web/desktop.
class DateSpanModeField extends StatelessWidget {
  const DateSpanModeField({
    required this.mode,
    required this.onChanged,
    this.enabled = true,
    super.key,
  });

  final DateSpanMode mode;
  final ValueChanged<DateSpanMode> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<DateSpanMode>(
      segments: [
        for (final value in DateSpanMode.values)
          ButtonSegment(value: value, label: Text(value.label)),
      ],
      selected: {mode},
      onSelectionChanged: enabled
          ? (selection) {
              if (selection.isEmpty) return;
              onChanged(selection.first);
            }
          : null,
    );
  }
}

/// A labelled, tappable calendar-day field backed by [showDatePicker].
///
/// [lastDate] is what actually stops a future day being picked at all —
/// callers pass today. Validation still runs on save (a picker is a
/// convenience, not the rule), and [errorText] renders whatever the
/// relevant validator returned for *this* control.
///
/// The tap target is an [InkWell], which is focusable and activates on
/// Enter/Space, so the field is reachable without a pointer.
class DateSpanDateField extends StatelessWidget {
  const DateSpanDateField({
    required this.label,
    required this.value,
    required this.firstDate,
    required this.lastDate,
    required this.onChanged,
    this.errorText,
    this.enabled = true,
    super.key,
  });

  final String label;
  final LocalDate value;
  final LocalDate firstDate;
  final LocalDate lastDate;
  final ValueChanged<LocalDate> onChanged;
  final String? errorText;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: label,
        errorText: errorText,
      ),
      child: InkWell(
        onTap: enabled ? () => _pick(context) : null,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(DateFormat.yMMMd().format(asDateTime(value))),
            const Icon(Icons.edit_calendar_outlined),
          ],
        ),
      ),
    );
  }

  Future<void> _pick(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: asDateTime(value),
      firstDate: asDateTime(firstDate),
      lastDate: asDateTime(lastDate),
    );
    if (picked == null) return;
    onChanged(LocalDate.fromDateTime(picked));
  }
}

/// The midday-free [DateTime] a [LocalDate] denotes, for the Material date
/// picker and [DateFormat] (both of which speak [DateTime]).
DateTime asDateTime(LocalDate date) =>
    DateTime(date.year, date.month, date.day);
