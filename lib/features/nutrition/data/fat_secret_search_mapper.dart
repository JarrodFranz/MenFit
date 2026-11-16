/// Reading `foods.search.v5` hits into summaries.
///
/// Since 2026-10-02 every hit carries the same structured
/// `servings.serving[]` list a `food.get.v5` record does (plus, when asked,
/// `food_sub_categories` and `food_attributes`), so each hit is read by the
/// detail parser (`fat_secret_food_record.dart`) and then reduced to a
/// summary here. The old `foods.search` `food_description` string — "Per
/// 100g - Calories: 389kcal | ..." — is no longer requested or parsed.
library;

import 'package:menfit_app/features/nutrition/data/fat_secret_food_record.dart';
import 'package:menfit_app/features/nutrition/data/fat_secret_json.dart';
import 'package:menfit_app/features/nutrition/domain/food.dart';
import 'package:menfit_app/features/nutrition/domain/provider_food.dart';

/// Parses search results from FatSecret `foods.search.v5`:
/// `{"foods_search": {"results": {"food": [ ... ]}}}`.
///
/// The pre-v5 `{"foods": {"food": [ ... ]}}` wrapper is accepted too, so a
/// proxy or fixture still answering in the old envelope degrades to rows
/// without nutrition rather than to nothing — but its `food_description`
/// string is not parsed.
List<ProviderFoodSummary> parseFatSecretSearchHits(Map<String, dynamic> json) {
  final results = <ProviderFoodSummary>[];
  for (final item in _hitsOf(json)) {
    final summary = _parseSearchHit(item);
    if (summary != null) results.add(summary);
  }
  return results;
}

Iterable<Map<String, dynamic>> _hitsOf(Map<String, dynamic> json) {
  dynamic rawFood;
  final search = json['foods_search'];
  if (search is Map<String, dynamic>) {
    final results = search['results'];
    if (results is Map<String, dynamic>) rawFood = results['food'];
  } else {
    final legacy = json['foods'];
    if (legacy is Map<String, dynamic>) rawFood = legacy['food'];
  }
  if (rawFood is List) return rawFood.whereType<Map<String, dynamic>>();
  if (rawFood is Map<String, dynamic>) return [rawFood];
  return const [];
}

/// One hit, reduced to a summary. `null` without a `food_id` and a name.
ProviderFoodSummary? _parseSearchHit(Map<String, dynamic> item) {
  final foodId = fatSecretText(item['food_id']);
  final foodName = fatSecretText(item['food_name']);
  if (foodId == null || foodName == null) return null;

  // No barcode is passed: a search hit states none, and the food_id is the
  // record's key, never its barcode — an 8-digit id can pass the EAN-8
  // check digit (B23).
  final record = parseFatSecretFoodRecord(item, fallbackFoodId: foodId);

  final base = ProviderFoodSummary(
    source: FoodSource.fatSecret,
    providerFoodId: foodId,
    name: foodName,
    brand: record.brand,
  );
  if (record.hasNoNutritionData) {
    return base.copyWith(macroBasis: SummaryMacroBasis.perServing);
  }

  final grams = record.servingGrams;
  final millilitres = record.servingVolumeMl;
  final hasGrams = grams != null && grams > 0;
  final hasVolume = millilitres != null && millilitres > 0;

  // Which measurement the figures are divided by decides what they end up
  // being *per*, so the basis is read off the same choice rather than
  // assumed: divided by grams they are per 100 g, by millilitres per
  // 100 ml, and undivided they stay per the serving the hit named.
  final divisor = hasGrams ? grams : (hasVolume ? millilitres : null);
  final basis = hasGrams
      ? SummaryMacroBasis.per100g
      : (hasVolume ? SummaryMacroBasis.per100ml : SummaryMacroBasis.perServing);
  double? per(double? value) {
    if (value == null) return null;
    return divisor == null ? value : value * 100 / divisor;
  }

  return base.copyWith(
    servingDescription: record.servingDescription,
    servingGrams: grams,
    servingVolumeMl: millilitres,
    servingCaloriesKcal: record.caloriesKcal,
    macroBasis: basis,
    caloriesKcal: per(record.caloriesKcal),
    proteinGrams: per(record.proteinGrams),
    carbsGrams: per(record.carbsGrams),
    fatGrams: per(record.fatGrams),
  );
}
