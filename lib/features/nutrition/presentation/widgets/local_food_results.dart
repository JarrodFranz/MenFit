import 'package:flutter/material.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/nutrition/domain/food.dart';
import 'package:menfit_app/features/nutrition/presentation/nutrition_format.dart';

/// Labels one of the picker's two result regions.
///
/// The two are labelled rather than merely spaced apart because they mean
/// different things: one is the user's own catalogue, the other is a
/// stranger's crowd-sourced database with per-100 g figures.
class FoodPickerSectionHeader extends StatelessWidget {
  const FoodPickerSectionHeader({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.spacingMd,
        vertical: tokens.spacingSm,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(title, style: Theme.of(context).textTheme.titleSmall),
      ),
    );
  }
}

/// One of the user's own saved foods, with its **per-serving** figures.
///
/// Honours the hide-calorie-numbers preference: the picker is inside its
/// documented scope (`knowledge/domain/nutrition.md`).
class LocalFoodResultTile extends StatelessWidget {
  const LocalFoodResultTile({
    required this.food,
    required this.hideCalorieNumbers,
    required this.busy,
    required this.onPick,
    super.key,
  });

  final Food food;
  final bool hideCalorieNumbers;

  /// Whether a barcode lookup is in flight. The app bar's actions have
  /// always been gated on this; a tile that stays tappable during one lets
  /// the user open the log dialog and then have the finished lookup push a
  /// review screen on top of it — two destinations from one errand.
  final bool busy;

  final ValueChanged<Food> onPick;

  @override
  Widget build(BuildContext context) {
    final facts = food.perServing;
    return ListTile(
      title: Text(food.displayName),
      isThreeLine: true,
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Per ${food.servingDescription}'),
          Text(formatMacroLine(facts)),
        ],
      ),
      trailing: hideCalorieNumbers
          ? null
          : Text(formatKcal(facts.caloriesKcal)),
      onTap: busy ? null : () => onPick(food),
    );
  }
}

/// Shown when the user's own catalogue has no match.
///
/// Offers "create a new food" right here as well as in the app bar: an
/// empty result list is exactly the moment that action is needed, and
/// making someone find a menu then would be the wrong shape.
class NoLocalFoodsMessage extends StatelessWidget {
  const NoLocalFoodsMessage({required this.onCreate, super.key});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return Padding(
      padding: EdgeInsets.all(tokens.spacingLg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Nothing here matches that yet. You can add it yourself — it'll "
            'be in your list next time.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          SizedBox(height: tokens.spacingLg),
          FilledButton.icon(
            onPressed: onCreate,
            icon: const Icon(Icons.add),
            label: const Text('Create a new food'),
          ),
        ],
      ),
    );
  }
}
