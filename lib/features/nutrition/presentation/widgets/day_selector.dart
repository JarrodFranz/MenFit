import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/theme/tokens.dart';

/// The diary's day browser: back a day, the day itself (tap to pick), and
/// forward a day.
///
/// Forward is disabled on today and the picker's `lastDate` is today, so a
/// future day can't be reached at all — `validateNutritionEntry` would
/// refuse anything logged there, and offering a day you can't use is worse
/// than not offering it.
///
/// Every control is an [IconButton] or an [InkWell], all of which are
/// focusable and activate on Enter/Space, so the browser works without a
/// pointer on web and desktop.
class DaySelector extends StatelessWidget {
  const DaySelector({
    required this.day,
    required this.onChanged,
    super.key,
  });

  final LocalDate day;
  final ValueChanged<LocalDate> onChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final today = LocalDate.today();
    final canGoForward = day.isBefore(today);

    return Row(
      children: [
        IconButton(
          onPressed: () => onChanged(day.addDays(-1)),
          icon: const Icon(Icons.chevron_left),
          tooltip: 'Previous day',
        ),
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(tokens.radiusSm),
            onTap: () => _pick(context, today),
            // A bare `InkWell` gets no tap-target floor from Material the
            // way a button does, so this one laid out at 40dp — under the
            // platform minimum on every platform and at every accessibility
            // setting. Unconditional, and it also squares this control up
            // with the 48dp chevron buttons either side of it.
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48),
              // `heightFactor: 1` so the box is the label's height raised
              // to the 48dp minimum, never stretched to whatever vertical
              // space the enclosing row happens to offer.
              child: Center(
                heightFactor: 1,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: tokens.spacingSm),
                  child: Text(
                    _label(day, today),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: canGoForward ? () => onChanged(day.addDays(1)) : null,
          icon: const Icon(Icons.chevron_right),
          tooltip: 'Next day',
        ),
      ],
    );
  }

  Future<void> _pick(BuildContext context, LocalDate today) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _asDateTime(day),
      firstDate: DateTime(today.year - 5),
      lastDate: _asDateTime(today),
    );
    if (picked == null) return;
    onChanged(LocalDate.fromDateTime(picked));
  }
}

String _label(LocalDate day, LocalDate today) {
  if (day == today) return 'Today';
  if (day == today.addDays(-1)) return 'Yesterday';
  return DateFormat('EEEE, MMM d').format(_asDateTime(day));
}

DateTime _asDateTime(LocalDate date) =>
    DateTime(date.year, date.month, date.day);
