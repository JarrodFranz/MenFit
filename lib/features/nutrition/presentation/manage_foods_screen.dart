import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/app/router/routes.dart';
import 'package:menfit_app/core/errors/error_messages.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/nutrition/domain/food.dart';
import 'package:menfit_app/features/nutrition/nutrition_providers.dart';
import 'package:menfit_app/features/nutrition/presentation/food_form_seed.dart';
import 'package:menfit_app/features/nutrition/presentation/nutrition_format.dart';

/// `/nutrition/foods` — the user's food catalogue, where a definition can be
/// corrected or removed.
///
/// The picker adds foods and the diary logs them; until this screen existed
/// there was no way to take one back out, so a typo saved once was permanent
/// and `NutritionRepository.deleteFood` had no caller at all.
///
/// **Removing a food does not touch the diary.** Every entry carries its own
/// snapshot of the food's name and nutrition (`domain/nutrition_entry.dart`),
/// and the link back to the food is soft and never trusted to resolve — so a
/// removed food leaves the history it produced completely intact. The
/// confirmation says so, because "delete" in an app that also holds a log of
/// what you ate is a frightening word if nobody tells you what it reaches.
///
/// Honours the hide-calorie-numbers preference: this is a list of foods with
/// their figures on it, which is squarely inside the preference's documented
/// scope (`knowledge/domain/nutrition.md`). The **form** it opens is one of
/// the two documented exceptions, being an input surface.
class ManageFoodsScreen extends ConsumerStatefulWidget {
  const ManageFoodsScreen({super.key});

  @override
  ConsumerState<ManageFoodsScreen> createState() => _ManageFoodsScreenState();
}

class _ManageFoodsScreenState extends ConsumerState<ManageFoodsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final foodsAsync = ref.watch(foodsProvider);
    final hideCalories =
        ref.watch(nutritionGoalsProvider).value?.hideCalorieNumbers ?? false;

    return Scaffold(
      appBar: AppBar(title: const Text('My foods')),
      body: SafeArea(
        // Pinned to the top rather than centred: a Center around this floats
        // a short catalogue into the middle of the screen
        // (`knowledge/architecture/architecture_overview.md`, 2026-09-02).
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: tokens.contentMaxWidth),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(tokens.spacingMd),
                  child: TextField(
                    key: const Key('manageFoodsSearchField'),
                    controller: _searchController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Search your foods',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) => setState(() => _query = value),
                  ),
                ),
                Expanded(
                  child: switch (foodsAsync) {
                    AsyncError(:final error) => Center(
                      child: Padding(
                        padding: EdgeInsets.all(tokens.spacingLg),
                        child: Text(userMessageFor(error)),
                      ),
                    ),
                    AsyncData(value: final foods) => _FoodList(
                      foods: _filter(foods),
                      catalogueIsEmpty: foods.isEmpty,
                      hideCalorieNumbers: hideCalories,
                      onEdit: _edit,
                      onDelete: _confirmAndDelete,
                    ),
                    _ => const Center(child: CircularProgressIndicator()),
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Name-or-brand contains, case-insensitively — the same rule
  /// `NutritionRepository.searchFoods` applies, kept in Dart here for the
  /// same reason it is there: SQL `LIKE` would treat a food legitimately
  /// named "70% dark" as a wildcard.
  List<Food> _filter(List<Food> foods) {
    final needle = _query.trim().toLowerCase();
    if (needle.isEmpty) return foods;
    return [
      for (final food in foods)
        if (food.name.toLowerCase().contains(needle) ||
            (food.brand?.toLowerCase().contains(needle) ?? false))
          food,
    ];
  }

  /// Opens the food form seeded from [food].
  ///
  /// `FoodFormSeed.forEditing` rather than a hand-built seed: a seed with no
  /// food id makes the form *save a new food*, so editing from here would
  /// quietly duplicate every row it touched. The factory carries the id (and
  /// the source, which a hand-built seed also got wrong — it would relabel a
  /// food the user typed herself as provider-sourced).
  Future<void> _edit(Food food) async {
    await NutritionNewFoodRouteData(
      $extra: FoodFormSeed.forEditing(food),
    ).push<Food>(context);
  }

  Future<void> _confirmAndDelete(Food food) async {
    // Captured before the await: after it, `context` is an async-gap use.
    final messenger = ScaffoldMessenger.of(context);
    // `showDialog` already targets the root navigator by default, which is
    // what the shell-branch rule in
    // `knowledge/architecture/architecture_overview.md` requires — passing
    // `useRootNavigator: true` here would be a redundant-argument info.
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Remove ${food.displayName}?'),
        content: const Text(
          'It stops showing up when you add food. Anything already in your '
          'diary keeps its own record of what it was, and stays exactly as '
          'you logged it.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            key: const Key('confirmRemoveFoodButton'),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
              foregroundColor: Theme.of(dialogContext).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await ref.read(nutritionRepositoryProvider).deleteFood(food.id);
      // Confirms the thing the dialog just promised, in the same
      // ED-neutral voice: no praise or comment on the removal itself, just
      // what happened and what it does — and does not — touch.
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'Removed. Past diary entries keep their details.',
            ),
          ),
        );
    } on Object catch (error) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(userMessageFor(error))));
    }
  }
}

class _FoodList extends StatelessWidget {
  const _FoodList({
    required this.foods,
    required this.catalogueIsEmpty,
    required this.hideCalorieNumbers,
    required this.onEdit,
    required this.onDelete,
  });

  final List<Food> foods;

  /// Whether the catalogue itself is empty, as opposed to the current
  /// search matching nothing — two different situations that deserve two
  /// different sentences.
  final bool catalogueIsEmpty;

  final bool hideCalorieNumbers;
  final ValueChanged<Food> onEdit;
  final ValueChanged<Food> onDelete;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    if (foods.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(tokens.spacingLg),
        child: Text(
          catalogueIsEmpty
              ? "You haven't saved any foods yet. Anything you add from the "
                    'picker shows up here.'
              : 'Nothing here matches that.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.only(bottom: tokens.spacingXl),
      itemCount: foods.length,
      itemBuilder: (context, index) => _ManageFoodTile(
        key: ValueKey(foods[index].id),
        food: foods[index],
        hideCalorieNumbers: hideCalorieNumbers,
        onEdit: onEdit,
        onDelete: onDelete,
      ),
    );
  }
}

/// One catalogue row: what the food is, where its numbers came from, and the
/// two things that can be done to it.
///
/// Removal is offered twice on purpose. Long-press is the gesture a phone
/// user reaches for, and an explicit button is the only one a mouse or a
/// screen reader can find at all — this app ships on Windows and the web
/// (`knowledge/architecture/platform_architecture.md`), where a
/// swipe-to-dismiss row is functionally invisible.
class _ManageFoodTile extends StatelessWidget {
  const _ManageFoodTile({
    required this.food,
    required this.hideCalorieNumbers,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final Food food;
  final bool hideCalorieNumbers;
  final ValueChanged<Food> onEdit;
  final ValueChanged<Food> onDelete;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final facts = food.perServing;

    return ListTile(
      title: Text(food.displayName),
      isThreeLine: true,
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Per ${food.servingDescription}'),
          Text(formatMacroLine(facts)),
          SizedBox(height: tokens.spacingXs),
          _SourceBadge(source: food.source),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!hideCalorieNumbers) Text(formatKcal(facts.caloriesKcal)),
          IconButton(
            key: Key('removeFood-${food.id}'),
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Remove from my foods',
            onPressed: () => onDelete(food),
          ),
        ],
      ),
      onTap: () => onEdit(food),
      onLongPress: () => onDelete(food),
    );
  }
}

/// Where a food's numbers came from.
///
/// Provenance is meaningful rather than decorative (ADR 010): a figure the
/// user typed and a figure a crowd-sourced database supplied are different
/// kinds of claim, and only the row itself can say which this is.
class _SourceBadge extends StatelessWidget {
  const _SourceBadge({required this.source});

  final FoodSource source;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final label = switch (source) {
      FoodSource.custom => 'Yours',
      // No code writes this any more; rows that predate S1-5's named
      // providers still read back as it (`domain/food.dart`).
      FoodSource.provider => 'Food database',
      FoodSource.openFoodFacts => 'Open Food Facts',
      FoodSource.fatSecret => 'FatSecret',
    };

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.spacingSm,
        vertical: tokens.spacingXs / 2,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(tokens.radiusSm),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
