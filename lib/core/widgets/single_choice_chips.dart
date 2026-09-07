import 'package:flutter/material.dart';
import 'package:menfit_app/core/theme/tokens.dart';

/// A row of [ChoiceChip]s representing a single optional choice from
/// [options]: tapping the already-selected chip clears the selection back
/// to `null` (Flutter's [ChoiceChip] already calls `onSelected(false)` in
/// that case, so this needs no separate "tap again" bookkeeping), tapping a
/// different chip selects it.
///
/// Used by `features/profile/presentation/widgets/training_section.dart`
/// for the fitness-goal and running/strength-experience pickers, and by
/// `features/onboarding/presentation/onboarding_steps.dart`'s optional
/// "Tell us a little more" step — all optional, single-select
/// (`knowledge/product/product_vision.md`: never force disclosure).
/// Lives in `core/widgets/` (a design-system widget, not feature-specific)
/// so both features can use it without either depending on the other's
/// `presentation/` layer (`architecture_overview.md` dependency rule 2).
class SingleChoiceChips<T> extends StatelessWidget {
  const SingleChoiceChips({
    required this.options,
    required this.labelFor,
    required this.selected,
    required this.onChanged,
    super.key,
  });

  final List<T> options;
  final String Function(T option) labelFor;
  final T? selected;

  /// Called with the newly-chosen option, or `null` when the selection was
  /// cleared.
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return Wrap(
      spacing: tokens.spacingSm,
      runSpacing: tokens.spacingSm,
      children: [
        for (final option in options)
          ChoiceChip(
            label: Text(labelFor(option)),
            selected: selected == option,
            onSelected: (isSelected) => onChanged(isSelected ? option : null),
          ),
      ],
    );
  }
}
