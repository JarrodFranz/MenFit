import 'package:flutter/material.dart';

/// Inline error copy under a control that has no [InputDecoration] of its
/// own (segmented buttons, dropdowns, option rows, checkboxes).
///
/// Lives in `core/widgets/` — a design-system widget, not a feature one —
/// so `wellbeing` and `nutrition` can both use it without either importing
/// the other's `presentation/` layer (`architecture_overview.md` dependency
/// rule 2), the same reasoning as `core/widgets/single_choice_chips.dart`.
class FieldErrorText extends StatelessWidget {
  const FieldErrorText(this.message, {super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.error,
        ),
      ),
    );
  }
}
