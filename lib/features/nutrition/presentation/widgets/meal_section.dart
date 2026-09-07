import 'package:flutter/material.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/nutrition/domain/meal_type.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_entry.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_totals.dart';
import 'package:menfit_app/features/nutrition/presentation/nutrition_format.dart';

/// One meal's slice of the day: its entries, its subtotal, and its own way
/// in.
///
/// Every meal renders even when it's empty, so the day has the same shape
/// whatever is in it (`domain/nutrition_totals.dart` guarantees a subtotal
/// for every [MealType] for the same reason). The "Add food" action lives on
/// each section rather than on one screen-level button because the meal is
/// the thing being added to — picking the meal afterwards is an extra step
/// that the tap already answered.
///
/// With [hideCalorieNumbers] on, the subtotal and each row's trailing figure
/// become macro lines instead. No calorie figure is rendered anywhere in
/// this widget in that mode.
///
/// An empty meal additionally offers [onCopyFromYesterday] when the caller
/// supplies it — the fastest path there is for a breakfast that doesn't
/// change.
class MealSection extends StatelessWidget {
  const MealSection({
    required this.meal,
    required this.entries,
    required this.subtotal,
    required this.hideCalorieNumbers,
    required this.onAddFood,
    required this.onEditEntry,
    this.onQuickAdd,
    this.onCopyFromYesterday,
    super.key,
  });

  final MealType meal;
  final List<NutritionEntry> entries;
  final NutritionTotals subtotal;
  final bool hideCalorieNumbers;
  final VoidCallback onAddFood;
  final ValueChanged<NutritionEntry> onEditEntry;
  final VoidCallback? onQuickAdd;

  /// Repeats this meal from the day before, when there is one to repeat and
  /// nothing has been logged here yet.
  ///
  /// `null` covers every case where the offer would be wrong or unavailable:
  /// nothing logged for this meal yesterday, a copy already running, or a
  /// day the diary would refuse. The caller decides
  /// (`presentation/copy_meal_controller.dart`); this widget only renders
  /// what it is handed, and never shows the action on a meal that already
  /// has entries — a "copy" that appended to a meal they have started is a
  /// duplicate waiting to happen.
  final VoidCallback? onCopyFromYesterday;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: tokens.spacingSm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: tokens.spacingMd),
              child: Row(
                children: [
                  Expanded(
                    child: Text(meal.label, style: textTheme.titleMedium),
                  ),
                  if (!subtotal.isEmpty)
                    Text(
                      hideCalorieNumbers
                          ? formatMacroLine(subtotal.facts)
                          : formatKcal(subtotal.caloriesKcal),
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            if (entries.isEmpty)
              Padding(
                padding: EdgeInsets.fromLTRB(
                  tokens.spacingMd,
                  tokens.spacingSm,
                  tokens.spacingMd,
                  0,
                ),
                child: Text(
                  'Nothing here yet.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              )
            else
              for (final entry in entries)
                _EntryTile(
                  key: ValueKey(entry.id),
                  entry: entry,
                  hideCalorieNumbers: hideCalorieNumbers,
                  onTap: () => onEditEntry(entry),
                ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: tokens.spacingSm),
              // Wrap rather than Row: a third action does not fit beside the
              // other two at compact widths, and an overflowing action row
              // would hide the one this meal most needs.
              child: Wrap(
                spacing: tokens.spacingXs,
                runSpacing: tokens.spacingXs,
                children: [
                  TextButton.icon(
                    key: Key('addFood-${meal.name}'),
                    onPressed: onAddFood,
                    icon: const Icon(Icons.add),
                    label: const Text('Add food'),
                  ),
                  if (onQuickAdd != null)
                    TextButton.icon(
                      key: Key('quickAdd-${meal.name}'),
                      onPressed: onQuickAdd,
                      icon: const Icon(Icons.flash_on_outlined),
                      label: const Text('Quick add'),
                    ),
                  if (entries.isEmpty && onCopyFromYesterday != null)
                    TextButton.icon(
                      key: Key('copyYesterday-${meal.name}'),
                      onPressed: onCopyFromYesterday,
                      icon: const Icon(Icons.copy_outlined),
                      label: const Text('Copy from yesterday'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EntryTile extends StatelessWidget {
  const _EntryTile({
    required this.entry,
    required this.hideCalorieNumbers,
    required this.onTap,
    super.key,
  });

  final NutritionEntry entry;
  final bool hideCalorieNumbers;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final facts = entry.facts;
    final serving = entry.servingDescription;

    return ListTile(
      dense: true,
      onTap: onTap,
      title: Text(entry.displayName),
      isThreeLine: true,
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // What they logged, in the unit they logged it in — never the
          // converted serving count as well, which would print the same
          // fact twice in two different numbers.
          Text(
            serving == null
                ? entry.quantityLabel
                : '${entry.quantityLabel} · $serving',
          ),
          Text(formatMacroLine(facts), style: textTheme.bodySmall),
        ],
      ),
      trailing: hideCalorieNumbers
          ? null
          : Text(formatKcal(facts.caloriesKcal)),
    );
  }
}
