/// Reading one FatSecret food record — the `food` object with a structured
/// `servings.serving[]` list — into a [ProviderFood].
///
/// One shape, three endpoints (2026-10-02): `food.get.v5`'s `food`,
/// `food.find_id_for_barcode.v2`'s `food`, and every hit in
/// `foods.search.v5`'s `foods_search.results.food[]`. Search used to carry a
/// pre-formatted `food_description` string that had to be parsed with
/// regular expressions; v5 search returns the same structured servings as a
/// detail record, so the same parser reads both and a search row can no
/// longer disagree with the record behind it about what a serving is.
///
/// Moved out of `fat_secret_mapper.dart` with no change to how a serving is
/// chosen or measured, apart from honouring `is_default` as the last
/// tie-break (see [_selectPrimaryServing]).
library;

import 'package:menfit_app/features/nutrition/data/fat_secret_json.dart';
import 'package:menfit_app/features/nutrition/data/fat_secret_serving_units.dart';
import 'package:menfit_app/features/nutrition/domain/food.dart';
import 'package:menfit_app/features/nutrition/domain/provider_food.dart';

/// Parses one FatSecret `food` object.
///
/// [ProviderFood.barcode] is [resolvedBarcode] — the GTIN the lookup
/// started from — and `null` when there was none (a record reached by its
/// `food_id`, or a search hit). The `food_id` goes to
/// [ProviderFood.providerFoodId] and **never** to the barcode (B23).
///
/// Robust to missing fields: no servings gives a "no nutrition data"
/// record, an unreadable number is `null` (never `0`), and absent
/// categories/attributes are `null`.
ProviderFood parseFatSecretFoodRecord(
  Map<String, dynamic> food, {
  String? fallbackFoodId,
  String? resolvedBarcode,
}) {
  final foodId = fatSecretText(food['food_id']) ?? fallbackFoodId;
  final trimmedBarcode = resolvedBarcode?.trim();
  final barcode = (trimmedBarcode == null || trimmedBarcode.isEmpty)
      ? null
      : trimmedBarcode;
  final foodName = fatSecretText(food['food_name']) ?? barcode ?? foodId ?? '';
  final brandName = fatSecretText(food['brand_name']);

  final servingsList = _servingsOf(food['servings']);

  if (servingsList.isEmpty) {
    return ProviderFood(
      source: FoodSource.fatSecret,
      barcode: barcode,
      providerFoodId: foodId,
      name: foodName,
      brand: brandName,
      servingDescription: '1 serving',
      servingBasis: ServingBasis.per100g,
      hasNoNutritionData: true,
    );
  }

  // Only stated units determine a serving; food names never imply density.
  final primaryServing = _selectPrimaryServing(
    servingsList,
  );

  final rawServingDesc =
      fatSecretText(primaryServing['serving_description']) ?? '1 serving';

  // The metric fields are the provider's own statement of the size and are
  // believed first; when they are absent (FatSecret leaves them null on
  // plenty of stated servings) the description is the only size there is,
  // and it is read with the same unit rules — "1 package (16 oz)" is
  // 454 g, not an unmeasured serving.
  final measured = _measure(primaryServing);
  final servingGrams = measured.grams;
  final servingVolumeMl = measured.volumeMl;

  final servingDesc = formatFatSecretServingDescription(
    rawServingDesc,
    servingGrams: servingGrams,
    servingVolumeMl: servingVolumeMl,
    // A drink is described in the volume it is sold in: 24 oz of Starbucks
    // is "710 ml" on the cup, not "680 g", even though both are known and
    // both are kept on the record for logging (schema v25 dual units).
    preferVolume: servingVolumeMl != null,
  );

  final normalisedDesc = servingDesc.trim().toLowerCase();
  final ServingBasis basis;
  if (normalisedDesc == '100 g' || normalisedDesc == '100g') {
    basis = ServingBasis.per100g;
  } else if (normalisedDesc == '100 ml' || normalisedDesc == '100ml') {
    basis = ServingBasis.per100ml;
  } else {
    basis = ServingBasis.statedPerServing;
  }

  double? readOrBackfill(String key) {
    final direct = fatSecretNumber(primaryServing[key]);
    if (direct != null) return direct;
    return _backfillNutrientFromSiblings(
      servingsList,
      primaryServing: primaryServing,
      primaryMeasured: measured,

      nutrientKey: key,
    );
  }

  final calories = fatSecretNumber(primaryServing['calories']);
  final protein = fatSecretNumber(primaryServing['protein']);
  final carbs = fatSecretNumber(primaryServing['carbohydrate']);
  final fat = fatSecretNumber(primaryServing['fat']);

  return ProviderFood(
    source: FoodSource.fatSecret,
    barcode: barcode,
    providerFoodId: foodId,
    name: foodName,
    brand: brandName,
    servingDescription: servingDesc,
    servingBasis: basis,
    servingGrams: servingGrams,
    servingVolumeMl: servingVolumeMl,
    caloriesKcal: calories,
    proteinGrams: protein,
    carbsGrams: carbs,
    fatGrams: fat,
    ironMg: readOrBackfill('iron'),
    calciumMg: readOrBackfill('calcium'),
    vitaminDMcg: readOrBackfill('vitamin_d'),
    vitaminCMg: readOrBackfill('vitamin_c'),
    fiberGrams: readOrBackfill('fiber'),
    sodiumMg: readOrBackfill('sodium'),
    potassiumMg: readOrBackfill('potassium'),
    saturatedFatGrams: readOrBackfill('saturated_fat'),
    hasCompleteNutritionFacts:
        calories != null && protein != null && carbs != null && fat != null,
  );
}

/// The `serving` objects under `servings`, whether FatSecret sent a list or
/// (the XML-to-JSON quirk) a single object.
List<Map<String, dynamic>> _servingsOf(dynamic servingsWrapper) {
  if (servingsWrapper is! Map<String, dynamic>) return const [];
  final rawServing = servingsWrapper['serving'];
  if (rawServing is List) {
    return rawServing.whereType<Map<String, dynamic>>().toList();
  }
  if (rawServing is Map<String, dynamic>) return [rawServing];
  return const [];
}

double? _backfillNutrientFromSiblings(
  List<Map<String, dynamic>> servings, {
  required Map<String, dynamic> primaryServing,
  required FatSecretMeasurement primaryMeasured,

  required String nutrientKey,
}) {
  for (final candidate in servings) {
    if (identical(candidate, primaryServing)) continue;
    final value = fatSecretNumber(candidate[nutrientKey]);
    if (value == null) continue;
    final candidateMeasured = _measure(candidate);
    if (primaryMeasured.grams != null &&
        primaryMeasured.grams! > 0 &&
        candidateMeasured.grams != null &&
        candidateMeasured.grams! > 0) {
      return value * (primaryMeasured.grams! / candidateMeasured.grams!);
    }
    if (primaryMeasured.volumeMl != null &&
        primaryMeasured.volumeMl! > 0 &&
        candidateMeasured.volumeMl != null &&
        candidateMeasured.volumeMl! > 0) {
      return value * (primaryMeasured.volumeMl! / candidateMeasured.volumeMl!);
    }
  }
  return null;
}

/// Picks the serving a record resolves to.
///
/// **Stated beats derived, always.** FatSecret marks the servings it
/// derived itself — "1 oz", "100 g" — with `serving_id` `0`, and lists the
/// brand's own serving first. Preferring a gram-metric serving (as this did
/// until 2026-09-08) promoted the derived `100 g` row over a 24 oz
/// Starbucks drink, so a branded product resolved to "100 g · 24 kcal" and
/// the search row said so.
///
/// Among servings of the same standing, a **stated metric size** comes
/// next: `2 tbsp (32g)` carries `metric_serving_amount`/`_unit` where
/// `1 package (16 oz)` — listed before it — carries neither, and a serving
/// with no size collapses the unit picker to "serving" alone. Then
/// calories-and-macros over calories over neither; then the serving
/// FatSecret flags `is_default` (requested with `flag_default_serving`);
/// then earliest in the list, which is the provider's own order.
///
/// The weights are spaced so each rule strictly outranks every combination
/// of the ones below it: default 1, nutrition 0/2/4, metric 6, stated 12.
Map<String, dynamic> _selectPrimaryServing(
  List<Map<String, dynamic>> servings,
) {
  int score(Map<String, dynamic> s) {
    final hasCals = fatSecretNumber(s['calories']) != null;
    final hasMacros =
        fatSecretNumber(s['protein']) != null &&
        fatSecretNumber(s['carbohydrate']) != null &&
        fatSecretNumber(s['fat']) != null;

    final nutrition = hasCals && hasMacros
        ? 2
        : hasCals
        ? 1
        : 0;
    final hasMetricSize = measureFatSecretServing(
      metricAmount: fatSecretNumber(s['metric_serving_amount']),
      metricUnit: fatSecretText(s['metric_serving_unit']),
    ).hasAny;
    final isDefault = fatSecretNumber(s['is_default']) == 1;

    return (_isDerivedServing(s) ? 0 : 12) +
        (hasMetricSize ? 6 : 0) +
        nutrition * 2 +
        (isDefault ? 1 : 0);
  }

  var primary = servings.first;
  var best = score(primary);
  for (final s in servings) {
    final candidate = score(s);
    if (candidate > best) {
      primary = s;
      best = candidate;
    }
  }
  return primary;
}

/// The chosen serving's size, from its metric fields when it has them and
/// from its description when it does not.
FatSecretMeasurement _measure(Map<String, dynamic> serving) {
  final fromMetric = measureFatSecretServing(
    metricAmount: fatSecretNumber(serving['metric_serving_amount']),
    metricUnit: fatSecretText(serving['metric_serving_unit']),
  );
  if (fromMetric.hasAny) return fromMetric;

  return measureFatSecretPortion(
    fatSecretText(serving['serving_description']) ?? '',
  );
}

/// Whether FatSecret derived this serving itself rather than reading it
/// off the product.
///
/// `serving_id` `0` (or absent) is the marker, verified against the live
/// API on 2026-09-08: every "1 oz" and "100 g" row FatSecret computes for
/// a branded food carries id `0`, while the brand's own serving — and
/// every serving of a generic food — carries a real one.
bool _isDerivedServing(Map<String, dynamic> serving) {
  final id = fatSecretText(serving['serving_id']);
  return id == null || id == '0';
}
