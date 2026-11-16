import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/app/router/routes.dart';
import 'package:menfit_app/core/domain/entity_id.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/errors/error_messages.dart';
import 'package:menfit_app/core/platform/barcode_scanning.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/nutrition/domain/food.dart';
import 'package:menfit_app/features/nutrition/domain/meal_type.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_facts.dart';
import 'package:menfit_app/features/nutrition/domain/provider_food.dart';
import 'package:menfit_app/features/nutrition/nutrition_providers.dart';
import 'package:menfit_app/features/nutrition/presentation/barcode_entry_dialog.dart';
import 'package:menfit_app/features/nutrition/presentation/barcode_lookup_controller.dart';
import 'package:menfit_app/features/nutrition/presentation/barcode_scan_screen.dart';
import 'package:menfit_app/features/nutrition/presentation/food_form_seed.dart';
import 'package:menfit_app/features/nutrition/presentation/log_entry_dialog.dart';
import 'package:menfit_app/features/nutrition/presentation/online_food_search_controller.dart';
import 'package:menfit_app/features/nutrition/presentation/online_lookup_notice_dialog.dart';
import 'package:menfit_app/features/nutrition/presentation/quick_add_dialog.dart';
import 'package:menfit_app/features/nutrition/presentation/widgets/local_food_results.dart';
import 'package:menfit_app/features/nutrition/presentation/widgets/online_food_results.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'food_search_screen.g.dart';

/// Foods matching [query], for the picker.
///
/// A blank query deliberately lists the catalogue rather than nothing — see
/// `domain/nutrition_repository.dart#searchFoods`.
@riverpod
Future<List<Food>> foodSearchResults(Ref ref, String query) {
  return ref.watch(nutritionRepositoryProvider).searchFoods(query);
}

/// `/nutrition/add` — pick a food for [meal] on [day], scan or type a
/// barcode, search the food database, or create a food by hand.
///
/// ## Three regions, one search box
///
/// **Recent** is the shortcut, and it only exists while the search box is
/// empty: it answers "the same thing again", which is what most logging
/// actually is, and an alphabetical catalogue answers badly. The moment the
/// user types they are looking for something specific, so it gets out of the
/// way rather than sitting above results that ignore their query.
///
/// **Your foods** searches the local catalogue as the user types, exactly as
/// it always has. **Online results** appear only after an explicit
/// action — the search button, or submitting the field.
///
/// Picking anything opens [LogEntryDialog] on top of this screen (quantity,
/// meal, and what the chosen quantity works out to, all before anything is
/// written). A successful log closes this screen too, since the errand it
/// was opened for is finished. A provider result goes to the review screen
/// first: provider data is a candidate the user checks, never something the
/// app accepts on their behalf (ADR 010).
///
/// ## Platform honesty
///
/// Every online affordance here works on every platform the app ships on,
/// web included — web reaches the food database's search by a different
/// endpoint (`data/open_food_facts_service.dart#search`), which is the data
/// layer's business and not something this screen mentions. The search
/// affordance is still absent — not present and broken — where
/// `FoodDataProvider.supportsTextSearch` is `false`, which no provider we
/// ship answers today but a future one might.
///
/// Scanning is offered only where there is a camera to scan with; **typing
/// a code is offered everywhere**, because on Windows and Web it is the only
/// path there is.
class FoodSearchScreen extends ConsumerStatefulWidget {
  const FoodSearchScreen({required this.day, required this.meal, super.key});

  final LocalDate day;
  final MealType meal;

  @override
  ConsumerState<FoodSearchScreen> createState() => _FoodSearchScreenState();
}

class _FoodSearchScreenState extends ConsumerState<FoodSearchScreen> {
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
    final resultsAsync = ref.watch(foodSearchResultsProvider(_query));
    final hideCalories = ref.watch(hideCalorieNumbersProvider);
    final dataProvider = ref.watch(foodDataProviderProvider);
    final region = ref.watch(foodSearchRegionControllerProvider);
    final onlineState = ref.watch(onlineFoodSearchControllerProvider);
    final lookupState = ref.watch(barcodeLookupControllerProvider);
    // Gates every way into a lookup, the result tiles included: a second
    // one started before the first lands sends a second request and pushes
    // a second review screen, because the first completion clears this flag
    // while the second is still in flight. The controller refuses re-entry
    // as well; this is the half that keeps the screen honest about it.
    final busy = lookupState.isLookingUp;
    // Only while the box is empty — see the class doc. `.value ?? const []`
    // rather than a `when`: a recents shortcut that has not loaded yet is
    // simply absent, and blocking the whole picker on it would be worse
    // than not having it.
    final recent = _query.trim().isEmpty
        ? (ref.watch(recentFoodsProvider).value ?? const <Food>[])
        : const <Food>[];

    ref.listen(barcodeLookupControllerProvider, (previous, next) {
      final message = next.errorMessage;
      if (message == null || message == previous?.errorMessage) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(message),
            duration: const Duration(seconds: 3),
          ),
        );
      ref.read(barcodeLookupControllerProvider.notifier).clearError();
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Add to ${widget.meal.label.toLowerCase()}'),
        actions: [
          // Only where there is a camera the scanner can use.
          if (barcodeScanningSupported)
            IconButton(
              key: const Key('scanBarcodeAction'),
              icon: const Icon(Icons.qr_code_scanner),
              tooltip: 'Scan a barcode',
              onPressed: busy ? null : _scanBarcode,
            ),
          // Always. On Windows and Web this is the only barcode path there
          // is (`core/platform/barcode_scanning.dart`), and everywhere else
          // it is what a refused permission or a scuffed label leaves.
          IconButton(
            key: const Key('enterBarcodeAction'),
            icon: const Icon(Icons.keyboard_outlined),
            tooltip: 'Enter a barcode',
            onPressed: busy ? null : _enterBarcode,
          ),
          // Overflow menu for secondary catalogue and quick-add actions,
          // keeping the app bar uncluttered so the title does not truncate
          // on narrow phones (deferred item 129).
          PopupMenuButton<void>(
            key: const Key('foodSearchOverflowAction'),
            enabled: !busy,
            itemBuilder: (context) => [
              PopupMenuItem<void>(
                key: const Key('quickAddMenuItem'),
                onTap: _quickAdd,
                child: const Row(
                  children: [
                    Icon(Icons.flash_on_outlined),
                    SizedBox(width: 12),
                    Expanded(child: Text('Quick add generic meal')),
                  ],
                ),
              ),
              PopupMenuItem<void>(
                key: const Key('createFoodMenuItem'),
                onTap: _createFood,
                child: const Row(
                  children: [
                    Icon(Icons.add),
                    SizedBox(width: 12),
                    Expanded(child: Text('Create a new food')),
                  ],
                ),
              ),
              PopupMenuItem<void>(
                key: const Key('manageFoodsMenuItem'),
                onTap: () =>
                    const NutritionManageFoodsRouteData().push<void>(context),
                child: const Row(
                  children: [
                    Icon(Icons.restaurant_menu_outlined),
                    SizedBox(width: 12),
                    Expanded(child: Text('Manage foods')),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: busy
            ? const PreferredSize(
                preferredSize: Size.fromHeight(4),
                child: LinearProgressIndicator(),
              )
            : null,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: tokens.contentMaxWidth),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(tokens.spacingMd),
                  child: TextField(
                    key: const Key('foodSearchField'),
                    controller: _searchController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Search your foods',
                      prefixIcon: Icon(Icons.search),
                    ),
                    textInputAction: TextInputAction.search,
                    onChanged: _onQueryChanged,
                    // Submitting is one of the two explicit actions that
                    // may send the query online. Typing alone never is.
                    onSubmitted: dataProvider.supportsTextSearch
                        ? (_) => _searchOnline()
                        : null,
                  ),
                ),
                Expanded(
                  child: resultsAsync.when(
                    data: (foods) => CustomScrollView(
                      slivers: [
                        if (recent.isNotEmpty) ...[
                          const SliverToBoxAdapter(
                            child: FoodPickerSectionHeader(title: 'Recent'),
                          ),
                          SliverList.builder(
                            itemCount: recent.length,
                            itemBuilder: (context, index) =>
                                LocalFoodResultTile(
                                  // Prefixed: the same food is very likely
                                  // in both regions, and two slivers may
                                  // not share a key.
                                  key: ValueKey('recent-${recent[index].id}'),
                                  food: recent[index],
                                  hideCalorieNumbers: hideCalories,
                                  busy: busy,
                                  onPick: _pick,
                                ),
                          ),
                        ],
                        // Lazy for the local list, which can run to the
                        // repository's 50-row cap; the online region below
                        // is user-paged and short enough to build whole.
                        const SliverToBoxAdapter(
                          child: FoodPickerSectionHeader(title: 'Your foods'),
                        ),
                        if (foods.isEmpty)
                          SliverToBoxAdapter(
                            child: NoLocalFoodsMessage(onCreate: _createFood),
                          )
                        else
                          SliverList.builder(
                            itemCount: foods.length,
                            itemBuilder: (context, index) =>
                                LocalFoodResultTile(
                                  key: ValueKey(foods[index].id),
                                  food: foods[index],
                                  hideCalorieNumbers: hideCalories,
                                  busy: busy,
                                  onPick: _pick,
                                ),
                          ),
                        SliverToBoxAdapter(
                          child: OnlineFoodSection(
                            supportsTextSearch: dataProvider.supportsTextSearch,
                            attributionName: dataProvider.attributionName,
                            attributionUrl: dataProvider.attributionUrl,
                            regionLabel: region.label,
                            state: onlineState,
                            hideCalorieNumbers: hideCalories,
                            busy: busy,
                            onSearch: _searchOnline,
                            onLoadMore: _loadMoreOnline,
                            onPick: _pickOnline,
                            onChangeRegion: _changeRegion,
                          ),
                        ),
                      ],
                    ),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, stackTrace) =>
                        Center(child: Text(userMessageFor(error))),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onQueryChanged(String value) {
    setState(() => _query = value);
    // Online results belong to the words that produced them; leaving them
    // under a box that now says something else would misattribute them.
    if (ref.read(onlineFoodSearchControllerProvider).hasSearched) {
      ref.read(onlineFoodSearchControllerProvider.notifier).clear();
    }
  }

  /// The first-run notice. Returning `false` here aborts the lookup before
  /// anything is sent (`data/online_lookup_notice_store.dart`).
  Future<bool> _confirmOnlineLookup() async {
    if (!mounted) return false;
    final dataProvider = ref.read(foodDataProviderProvider);
    return OnlineLookupNoticeDialog.show(
      context,
      attributionName: dataProvider.attributionName,
      attributionUrl: dataProvider.attributionUrl,
    );
  }

  Future<void> _searchOnline() async {
    await ref
        .read(onlineFoodSearchControllerProvider.notifier)
        .search(_query, confirmOnlineLookup: _confirmOnlineLookup);
  }

  /// Sends the user to the Settings row that owns the region.
  ///
  /// `go`, not `push`: the row lives in the settings shell branch, and the
  /// picker is a modal errand ("add something to breakfast"). Someone who
  /// has stopped to change where their food database searches has abandoned
  /// that errand for now, and returning them to a half-finished picker
  /// underneath Settings would be the confusing outcome, not the helpful
  /// one.
  void _changeRegion() => const SettingsRouteData().go(context);

  void _loadMoreOnline() {
    unawaited(
      ref.read(onlineFoodSearchControllerProvider.notifier).loadMore(),
    );
  }

  Future<void> _scanBarcode() async {
    // Pushed imperatively, not routed: the scanner *returns a value* and
    // typed routes have no return channel, and a URL that silently opens
    // someone's camera is exactly the thing not to build
    // (`presentation/barcode_scan_screen.dart`).
    final code = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const BarcodeScanScreen()),
    );
    if (code == null || !mounted) return;
    await _lookUpBarcode(code);
  }

  Future<void> _enterBarcode() async {
    final code = await BarcodeEntryDialog.show(context);
    if (code == null || !mounted) return;
    await _lookUpBarcode(code);
  }

  Future<void> _lookUpBarcode(String code) async {
    final result = await ref
        .read(barcodeLookupControllerProvider.notifier)
        .lookUp(code, confirmOnlineLookup: _confirmOnlineLookup);
    if (!mounted) return;
    await _route(result);
  }

  /// A search hit is only ever a *summary*; the full record has to be
  /// fetched before anything can become a food — see
  /// `BarcodeLookupController.fetchFullRecord` for why iron makes this
  /// mandatory rather than an optimisation.
  Future<void> _pickOnline(ProviderFoodSummary summary) async {
    final result = await ref
        .read(barcodeLookupControllerProvider.notifier)
        .fetchFullRecord(summary, confirmOnlineLookup: _confirmOnlineLookup);
    if (!mounted) return;
    await _route(result);
  }

  Future<void> _route(BarcodeLookupResult? result) async {
    switch (result) {
      // Nowhere to go: an unreadable code, a declined notice, or a failed
      // request. The message, where there is one, arrives via the listener.
      case null:
        return;
      case LocalFoodMatched(:final food):
        await _pick(food);
      case ProviderFoodFetched(:final food):
        if (food.hasCompleteMacros) {
          final mappedFood = Food(
            id: EntityId.generate(),
            name: food.name,
            brand: food.brand,
            servingDescription: food.servingDescription,
            servingGrams: food.servingGrams,
            perServing: NutritionFacts(
              caloriesKcal: food.caloriesKcal ?? 0,
              proteinGrams: food.proteinGrams ?? 0,
              carbsGrams: food.carbsGrams ?? 0,
              fatGrams: food.fatGrams ?? 0,
              saturatedFatGrams: food.saturatedFatGrams,
              fiberGrams: food.fiberGrams,
              sodiumMg: food.sodiumMg,
              potassiumMg: food.potassiumMg,
              calciumMg: food.calciumMg,
              vitaminDMcg: food.vitaminDMcg,
              vitaminCMg: food.vitaminCMg,
              ironMg: food.ironMg,
            ),
            createdAt: DateTime.now().toUtc(),
            updatedAt: DateTime.now().toUtc(),
            barcode: food.barcode,
            source: food.source,
          );
          await _pick(mappedFood);
        } else {
          await _review(FoodFormSeed.fromProviderFood(food));
        }
      case ProviderHasNoProduct(:final barcode):
        await _review(FoodFormSeed.forUnknownBarcode(barcode));
    }
  }

  Future<void> _review(FoodFormSeed seed) async {
    final created = await NutritionNewFoodRouteData(
      $extra: seed,
    ).push<Food>(context);
    if (created == null || !mounted) return;
    ref.invalidate(foodSearchResultsProvider);
    await _pick(created);
  }

  Future<void> _pick(Food food) async {
    final logged = await LogEntryDialog.show(
      context,
      day: widget.day,
      meal: widget.meal,
      food: food,
    );
    if (logged != true || !mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _quickAdd() async {
    final navigator = Navigator.of(context);
    final saved = await QuickAddDialog.show(
      context,
      day: widget.day,
      meal: widget.meal,
    );
    if ((saved ?? false) && mounted) {
      navigator.pop();
    }
  }

  Future<void> _createFood() async {
    final created = await const NutritionNewFoodRouteData().push<Food>(context);
    if (created == null || !mounted) return;
    // A one-shot future provider won't notice a food saved behind its back,
    // so the whole family is dropped: without this the list the user returns
    // to would still say nothing matches, moments after they added the thing
    // that does.
    ref.invalidate(foodSearchResultsProvider);
    await _pick(created);
  }
}
