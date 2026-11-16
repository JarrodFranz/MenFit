import 'package:flutter/material.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/core/widgets/field_error_text.dart';
import 'package:menfit_app/features/nutrition/domain/food.dart';
import 'package:menfit_app/features/nutrition/domain/provider_food.dart';
import 'package:menfit_app/features/nutrition/presentation/online_food_search_controller.dart';
import 'package:menfit_app/features/nutrition/presentation/online_result_display.dart';
import 'package:menfit_app/features/nutrition/presentation/widgets/food_data_attribution.dart';
import 'package:menfit_app/features/nutrition/presentation/widgets/local_food_results.dart';

/// The picker's second region: what the **food database** has, kept
/// visibly apart from the user's own foods above it.
///
/// Renders one of two things. Where text search works — every platform the
/// app ships on, web included — the explicit search action and whatever it
/// has returned. Where a provider does not support it at all
/// (`FoodDataProvider.supportsTextSearch`), an honest note saying so **and**
/// pointing at the barcode path, which is unaffected. Never a disabled
/// button that would look like a bug.
///
/// Nothing here says which endpoint served the results. Web reaches the
/// food database by a different route than the other platforms
/// (`data/open_food_facts_service.dart#search`) and a user has no decision
/// to make about that, so the screen does not mention it.
class OnlineFoodSection extends StatelessWidget {
  const OnlineFoodSection({
    required this.supportsTextSearch,
    required this.attributionName,
    required this.attributionUrl,
    required this.regionLabel,
    required this.state,
    required this.hideCalorieNumbers,
    required this.busy,
    required this.onSearch,
    required this.onLoadMore,
    required this.onPick,
    required this.onChangeRegion,
    super.key,
  });

  final bool supportsTextSearch;
  final String attributionName;
  final String attributionUrl;

  /// The region these results are (or will be) confined to, from
  /// `FoodSearchRegion.label`.
  final String regionLabel;

  final OnlineFoodSearchState state;
  final bool hideCalorieNumbers;

  /// Whether a *barcode* lookup is in flight — which includes the fetch a
  /// result tile starts. Folded into the search button's disabled state
  /// **and** into the tiles' own, so one screen never has two requests out:
  /// picking a second hit while the first is still loading would spend two
  /// of a 15/minute budget and stack two review screens, since the first
  /// completion clears the flag while the second is still running.
  final bool busy;

  final VoidCallback onSearch;
  final VoidCallback onLoadMore;
  final ValueChanged<ProviderFoodSummary> onPick;

  /// Takes the user to where the region is chosen. The caption is the only
  /// place the setting is discoverable from *inside* the failure it
  /// explains — an empty result set is the moment "we only searched
  /// Australia" stops being trivia.
  final VoidCallback onChangeRegion;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        FoodPickerSectionHeader(title: attributionName),
        if (!supportsTextSearch)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: tokens.spacingMd),
            child: Text(
              "Searching $attributionName by name isn't available here. "
              'Barcodes still are — use "Enter a barcode" above and we\'ll '
              'look the product up.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          )
        else ...[
          _RegionCaption(
            regionLabel: regionLabel,
            onChangeRegion: onChangeRegion,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: tokens.spacingMd),
            child: FilledButton.tonalIcon(
              key: const Key('onlineSearchButton'),
              // Disabled while a request is out — one press, one request.
              onPressed: state.isSearching || busy ? null : onSearch,
              icon: state.isSearching
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.travel_explore_outlined),
              label: Text('Search $attributionName'),
            ),
          ),
          if (!state.hasSearched)
            Padding(
              padding: EdgeInsets.all(tokens.spacingMd),
              child: Text(
                'Typing only searches your own foods. Nothing is sent '
                'anywhere until you press this.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          _OnlineFoodResults(
            state: state,
            hideCalorieNumbers: hideCalorieNumbers,
            attributionName: attributionName,
            attributionUrl: attributionUrl,
            busy: busy,
            onPick: onPick,
            onLoadMore: onLoadMore,
          ),
        ],
      ],
    );
  }
}

/// "Showing Australia results · Change" — the one line that makes an empty
/// result set explainable rather than mysterious.
///
/// It sits **above** the search button rather than under the results,
/// because the useful moment is before the request as well as after it: a
/// user who knows the search is confined to one country can widen it before
/// spending one of a documented 10-per-minute budget.
///
/// "Change" is a real button rather than a styled span in the sentence: it
/// navigates, so it needs a tap target and a role, not an underline.
class _RegionCaption extends StatelessWidget {
  const _RegionCaption({
    required this.regionLabel,
    required this.onChangeRegion,
  });

  final String regionLabel;
  final VoidCallback onChangeRegion;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final style = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );

    return Padding(
      padding: EdgeInsets.only(left: tokens.spacingMd),
      child: Row(
        children: [
          Flexible(
            child: Text('Showing $regionLabel results ·', style: style),
          ),
          TextButton(
            key: const Key('onlineRegionChangeButton'),
            onPressed: onChangeRegion,
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }
}

/// The results themselves.
///
/// Two things this deliberately does not do:
///
/// - **No total count.** The provider's is a capped estimate (10000 with
///   `is_count_exact: false`), so rendering it would print a number that is
///   not true. The end of the results is a short page, not a count.
/// - **No calorie figure when `hideCalorieNumbers` is on.** This is the
///   food picker, which `knowledge/domain/nutrition.md` puts squarely
///   inside the preference's scope — exactly as the local list above
///   already honours it.
///
/// Every figure here is **per 100 g** and says so. Search hits carry no
/// per-serving values at all (`domain/provider_food.dart`), and a per-100 g
/// number presented as a serving would be wrong by an invisible factor.
class _OnlineFoodResults extends StatelessWidget {
  const _OnlineFoodResults({
    required this.state,
    required this.hideCalorieNumbers,
    required this.attributionName,
    required this.attributionUrl,
    required this.busy,
    required this.onPick,
    required this.onLoadMore,
  });

  final OnlineFoodSearchState state;
  final bool hideCalorieNumbers;
  final String attributionName;
  final String attributionUrl;
  final bool busy;
  final ValueChanged<ProviderFoodSummary> onPick;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final error = state.errorMessage;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (error != null)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: tokens.spacingMd),
            child: FieldErrorText(error),
          ),
        if (state.hasSearched && state.results.isEmpty && error == null)
          Padding(
            padding: EdgeInsets.all(tokens.spacingMd),
            child: Text(
              'Nothing under those words at $attributionName. Different '
              'wording sometimes helps — or you can add the food yourself.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        if (state.results.isNotEmpty) ...[
          for (final summary in state.results)
            _OnlineResultTile(
              key: ValueKey(
                'online-${summary.source.name}-${summary.providerFoodId}',
              ),
              summary: summary,
              hideCalorieNumbers: hideCalorieNumbers,
              busy: busy,
              onPick: onPick,
            ),
        ],
        if (state.hasMore)
          Padding(
            padding: EdgeInsets.all(tokens.spacingMd),
            child: OutlinedButton(
              key: const Key('onlineSearchMoreButton'),
              // Another page is another request, so it is another explicit
              // act — see `OnlineFoodSearchController`'s note on the
              // per-minute budget.
              onPressed: state.isSearching ? null : onLoadMore,
              child: const Text('Show more results'),
            ),
          ),
        for (final source in state.results.map((hit) => hit.source).toSet())
          if (source == FoodSource.fatSecret ||
              source == FoodSource.openFoodFacts)
            FoodDataAttribution(
              name: source == FoodSource.fatSecret
                  ? 'FatSecret'
                  : 'Open Food Facts',
              url: source == FoodSource.fatSecret
                  ? 'https://platform.fatsecret.com'
                  : 'https://world.openfoodfacts.org',
            ),
        if (state.hasSearched && state.results.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: tokens.spacingMd),
            child: FoodDataAttribution(
              name: attributionName,
              url: attributionUrl,
            ),
          ),
      ],
    );
  }
}

class _OnlineResultTile extends StatelessWidget {
  const _OnlineResultTile({
    required this.summary,
    required this.hideCalorieNumbers,
    required this.busy,
    required this.onPick,
    super.key,
  });

  final ProviderFoodSummary summary;
  final bool hideCalorieNumbers;
  final bool busy;
  final ValueChanged<ProviderFoodSummary> onPick;

  @override
  Widget build(BuildContext context) {
    final display = resolveOnlineResultDisplay(
      summary,
      hideCalorieNumbers: hideCalorieNumbers,
    );
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return ListTile(
      title: Text(summary.displayName),
      isThreeLine: true,
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(display.basisLine),
          Text(display.macroLine),
          SizedBox(height: tokens.spacingXs),
          _OnlineSourceBadge(source: summary.source),
        ],
      ),
      // Picking a hit starts a fetch; a second tap while one is running is
      // a second request and a second review screen — see [busy].
      onTap: busy ? null : () => onPick(summary),
    );
  }
}

/// Displays the food database provenance for an online search hit.
class _OnlineSourceBadge extends StatelessWidget {
  const _OnlineSourceBadge({required this.source});

  final FoodSource source;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final (label, icon) = switch (source) {
      FoodSource.fatSecret => ('FatSecret', Icons.cloud_outlined),
      FoodSource.openFoodFacts => ('Open Food Facts', Icons.public_outlined),
      FoodSource.custom => ('Yours', Icons.person_outline),
      FoodSource.provider => ('Food database', Icons.storage_outlined),
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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: colorScheme.onSurfaceVariant,
          ),
          SizedBox(width: tokens.spacingXs / 2),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
