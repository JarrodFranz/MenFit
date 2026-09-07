import 'package:flutter/material.dart';
import 'package:menfit_app/core/domain/weekday.dart';
import 'package:menfit_app/core/theme/tokens.dart';

/// A row of seven [FilterChip]s (Mon..Sun), multi-select, for
/// `UserProfile.trainingDays`. Unlike `SingleChoiceChips`, any number of
/// days (including none) can be selected at once.
class WeekdayToggleRow extends StatelessWidget {
  const WeekdayToggleRow({
    required this.selected,
    required this.onChanged,
    super.key,
  });

  final Set<Weekday> selected;
  final ValueChanged<Set<Weekday>> onChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return Wrap(
      spacing: tokens.spacingSm,
      runSpacing: tokens.spacingSm,
      children: [
        for (final day in Weekday.values)
          FilterChip(
            label: Text(day.label),
            selected: selected.contains(day),
            onSelected: (isSelected) {
              final next = Set<Weekday>.of(selected);
              if (isSelected) {
                next.add(day);
              } else {
                next.remove(day);
              }
              onChanged(next);
            },
          ),
      ],
    );
  }
}
