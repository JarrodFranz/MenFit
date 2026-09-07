import 'package:flutter/material.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/nutrition/domain/macro_locks.dart';
import 'package:menfit_app/features/nutrition/domain/macro_targets.dart';
import 'package:menfit_app/features/nutrition/presentation/nutrition_format.dart';

/// One daily-target text field.
///
/// Shared by the calorie field in `daily_targets_section.dart` and by all
/// six macro fields here, so a target field looks and behaves the same
/// whichever number it holds.
class TargetField extends StatelessWidget {
  const TargetField({
    required this.fieldKey,
    required this.label,
    required this.controller,
    this.errorText,
    this.helperText,
    this.readOnly = false,
    super.key,
  });

  final String fieldKey;
  final String label;
  final TextEditingController controller;
  final String? errorText;

  /// A line under the field explaining where its value came from. Used by
  /// the computed macro target, which the user did not type.
  final String? helperText;

  /// When `true` the field displays a value the app worked out and refuses
  /// keystrokes. Filled rather than outlined so the difference reads without
  /// having to notice the helper line — and the helper line says it in words
  /// as well, because fill alone is a colour difference.
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return TextField(
      key: Key(fieldKey),
      controller: controller,
      readOnly: readOnly,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: label,
        errorText: errorText,
        helperText: helperText,
        helperMaxLines: 3,
        filled: readOnly,
      ),
    );
  }
}

/// The "Grams / Percent" choice for the three macro targets.
///
/// A [SegmentedButton] to match the app's other mode toggles (see
/// `features/wellbeing/presentation/widgets/date_span_fields.dart`); they
/// are focusable and arrow/space operable, so this stays keyboard-reachable
/// on web and desktop.
///
/// The calorie target is not affected by this choice and keeps its own
/// field either way.
class MacroTargetModeToggle extends StatelessWidget {
  const MacroTargetModeToggle({
    required this.mode,
    required this.onChanged,
    super.key,
  });

  final MacroTargetMode mode;
  final ValueChanged<MacroTargetMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<MacroTargetMode>(
      key: const Key('macroTargetModeToggle'),
      segments: [
        for (final value in MacroTargetMode.values)
          ButtonSegment(value: value, label: Text(value.label)),
      ],
      selected: {mode},
      onSelectionChanged: (selection) {
        if (selection.isEmpty) return;
        onChanged(selection.first);
      },
    );
  }
}

/// The screen-reader label for one lock toggle.
///
/// Names the macro **and** the state, because an icon button with neither is
/// just "button" to a screen reader. Public so the widget tests assert the
/// exact string a user would hear rather than a paraphrase of it.
String macroLockSemanticsLabel(MacroNutrient macro, {required bool locked}) =>
    locked
    ? '${macro.label} target is locked'
    : '${macro.label} target is not locked';

/// The three macro targets stated directly in grams, each with a lock.
///
/// **What a lock is for.** Locking two of the three lets the app work out
/// the remaining one from the day's calorie figure
/// (`domain/macro_targets.dart#solveMacroTargets`); the computed field then
/// shows that figure and stops taking keystrokes until a lock changes. With
/// fewer than two locked nothing is determined, and the app says so rather
/// than inventing a split (`knowledge/domain/mens_health.md` rule 1).
///
/// **Nothing is locked or prefilled by default**, here or anywhere else in
/// this form.
class MacroGramFields extends StatelessWidget {
  const MacroGramFields({
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.locks,
    required this.onLockChanged,
    this.computedMacro,
    this.computedNote,
    this.note,
    this.proteinError,
    this.carbsError,
    this.fatError,
    super.key,
  });

  final TextEditingController protein;
  final TextEditingController carbs;
  final TextEditingController fat;

  /// Which of the three the user has pinned.
  final MacroLocks locks;

  final void Function(MacroNutrient macro, {required bool locked})
  onLockChanged;

  /// The macro whose field currently holds a worked-out value, or `null`
  /// when nothing is being computed.
  final MacroNutrient? computedMacro;

  /// The line under the computed field saying where its number came from.
  final String? computedNote;

  /// What the lock set adds up to against the day's energy, or `null` when
  /// there is nothing to say (`domain/nutrition_validation.dart#macroLockNote`).
  final String? note;

  final String? proteinError;
  final String? carbsError;
  final String? fatError;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final theme = Theme.of(context);
    final message = note;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _GramField(
          fieldKey: 'proteinTargetField',
          label: 'Protein (g)',
          macro: MacroNutrient.protein,
          controller: protein,
          locked: locks.isLocked(MacroNutrient.protein),
          isComputed: computedMacro == MacroNutrient.protein,
          computedNote: computedNote,
          onLockChanged: onLockChanged,
          errorText: proteinError,
        ),
        SizedBox(height: tokens.spacingMd),
        _GramField(
          fieldKey: 'carbTargetField',
          label: 'Carbs (g)',
          macro: MacroNutrient.carbs,
          controller: carbs,
          locked: locks.isLocked(MacroNutrient.carbs),
          isComputed: computedMacro == MacroNutrient.carbs,
          computedNote: computedNote,
          onLockChanged: onLockChanged,
          errorText: carbsError,
        ),
        SizedBox(height: tokens.spacingMd),
        _GramField(
          fieldKey: 'fatTargetField',
          label: 'Fat (g)',
          macro: MacroNutrient.fat,
          controller: fat,
          locked: locks.isLocked(MacroNutrient.fat),
          isComputed: computedMacro == MacroNutrient.fat,
          computedNote: computedNote,
          onLockChanged: onLockChanged,
          errorText: fatError,
        ),
        if (message != null) ...[
          SizedBox(height: tokens.spacingSm),
          Text(
            message,
            key: const Key('macroLockNote'),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

/// One gram target and its lock toggle.
class _GramField extends StatelessWidget {
  const _GramField({
    required this.fieldKey,
    required this.label,
    required this.macro,
    required this.controller,
    required this.locked,
    required this.isComputed,
    required this.onLockChanged,
    this.computedNote,
    this.errorText,
  });

  final String fieldKey;
  final String label;
  final MacroNutrient macro;
  final TextEditingController controller;
  final bool locked;
  final bool isComputed;
  final void Function(MacroNutrient macro, {required bool locked})
  onLockChanged;
  final String? computedNote;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return Row(
      // The field grows downwards as an error or helper line appears; the
      // button stays put beside its top edge rather than drifting with it.
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TargetField(
            fieldKey: fieldKey,
            label: label,
            controller: controller,
            errorText: errorText,
            readOnly: isComputed,
            helperText: isComputed ? computedNote : null,
          ),
        ),
        SizedBox(width: tokens.spacingSm),
        Padding(
          padding: EdgeInsets.only(top: tokens.spacingXs),
          child: _MacroLockButton(
            fieldKey: fieldKey,
            macro: macro,
            locked: locked,
            onChanged: onLockChanged,
          ),
        ),
      ],
    );
  }
}

/// The lock toggle beside one gram field.
///
/// Locked and unlocked differ by **icon shape** — a solid closed padlock
/// against an open outlined one — not only by colour, so the state survives
/// a colour-blind user, a monochrome display and a screenshot. The tooltip
/// doubles as the semantics label ([macroLockSemanticsLabel]), which is what
/// makes the control usable without sight of the icon at all.
class _MacroLockButton extends StatelessWidget {
  const _MacroLockButton({
    required this.fieldKey,
    required this.macro,
    required this.locked,
    required this.onChanged,
  });

  final String fieldKey;
  final MacroNutrient macro;
  final bool locked;
  final void Function(MacroNutrient macro, {required bool locked}) onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return IconButton(
      key: Key('${fieldKey}Lock'),
      tooltip: macroLockSemanticsLabel(macro, locked: locked),
      isSelected: locked,
      icon: Icon(
        locked ? Icons.lock : Icons.lock_open_outlined,
        color: locked ? theme.colorScheme.primary : null,
      ),
      onPressed: () => onChanged(macro, locked: !locked),
    );
  }
}

/// The three macro targets stated as shares of the day's energy, each with
/// the grams it works out to underneath.
///
/// **The grams are shown on purpose.** They are the figures the diary
/// measures against, so a user who states her targets as percentages would
/// otherwise never see the numbers she is actually working to.
///
/// **The energy figure behind them is not always shown.**
/// [DerivedMacroTargetGrams.basisKcal] is
/// inside the scope of the hide-calorie-numbers preference
/// (`knowledge/domain/nutrition.md`): with [hideCalorieNumbers] on, this
/// section renders grams and percentages and no kcal figure anywhere. The
/// goals screen's documented exception covers the calorie target *field*,
/// which is an input; it is not licence to print an energy figure somewhere
/// new. Grams are not calories, so they stay either way.
class MacroPercentFields extends StatelessWidget {
  const MacroPercentFields({
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.derived,
    required this.hideCalorieNumbers,
    this.proteinError,
    this.carbsError,
    this.fatError,
    this.sumError,
    super.key,
  });

  final TextEditingController protein;
  final TextEditingController carbs;
  final TextEditingController fat;

  /// The grams the current percentages work out to, or the "nothing to take
  /// a percentage of" outcome.
  final MacroTargetGramsOutcome derived;

  final bool hideCalorieNumbers;
  final String? proteinError;
  final String? carbsError;
  final String? fatError;

  /// The message about the three fields together, e.g. that they come to
  /// 96%. Rendered once, below all three, because no single field is the
  /// wrong one.
  final String? sumError;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final theme = Theme.of(context);
    final derivedGrams = derived;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _basisNote,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: tokens.spacingMd),
        _PercentField(
          fieldKey: 'proteinPercentField',
          label: 'Protein (%)',
          controller: protein,
          errorText: proteinError,
          grams: derivedGrams is DerivedMacroTargetGrams
              ? derivedGrams.proteinGrams
              : null,
        ),
        SizedBox(height: tokens.spacingMd),
        _PercentField(
          fieldKey: 'carbPercentField',
          label: 'Carbs (%)',
          controller: carbs,
          errorText: carbsError,
          grams: derivedGrams is DerivedMacroTargetGrams
              ? derivedGrams.carbGrams
              : null,
        ),
        SizedBox(height: tokens.spacingMd),
        _PercentField(
          fieldKey: 'fatPercentField',
          label: 'Fat (%)',
          controller: fat,
          errorText: fatError,
          grams: derivedGrams is DerivedMacroTargetGrams
              ? derivedGrams.fatGrams
              : null,
        ),
        if (sumError != null) ...[
          SizedBox(height: tokens.spacingSm),
          Text(
            sumError!,
            key: const Key('macroPercentSumError'),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }

  /// What the percentages are percentages of, in words — and, unless the
  /// user has asked not to see calorie figures, the number itself.
  String get _basisNote {
    final outcome = derived;
    if (outcome is! DerivedMacroTargetGrams) {
      return 'Percentages need a daily calorie figure to work from. Set a '
          'calorie target above, or add your details so the estimate can '
          'stand in, and the grams will show up here.';
    }
    final source = outcome.basisIsEstimated
        ? 'your estimated daily target'
        : 'your daily calorie target';
    if (hideCalorieNumbers) return 'Shares of $source.';
    return 'Shares of $source (${formatKcal(outcome.basisKcal)}).';
  }
}

/// One percentage field with the grams it works out to underneath.
class _PercentField extends StatelessWidget {
  const _PercentField({
    required this.fieldKey,
    required this.label,
    required this.controller,
    required this.grams,
    this.errorText,
  });

  final String fieldKey;
  final String label;
  final TextEditingController controller;

  /// What this share works out to, or `null` when there is no basis or no
  /// percentage typed yet.
  final double? grams;

  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final theme = Theme.of(context);
    final derived = grams;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TargetField(
          fieldKey: fieldKey,
          label: label,
          controller: controller,
          errorText: errorText,
        ),
        if (derived != null) ...[
          SizedBox(height: tokens.spacingXs),
          Text(
            'Works out to ${formatGrams(derived)} a day',
            key: Key('${fieldKey}Derived'),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}
