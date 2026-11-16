/// Turns Open Food Facts' decoded JSON into this app's domain candidates.
///
/// Split out of `open_food_facts_service.dart` so that file holds only
/// transport — endpoints, headers, status/body branching, exception
/// mapping — and this one holds only the reading of a response. They change
/// for different reasons: the transport rules come from OFF's API contract
/// and rate limits, while everything here comes from the *shape* of
/// contributor-entered records, which is where all the surprises live.
///
/// Nothing in this file performs I/O, and nothing in it throws: a field it
/// cannot read is absent, never zero and never an error. That is the same
/// rule `domain/provider_food.dart` states from the other side — a gap in a
/// crowd-sourced database must not become a claim about a food.
///
/// The quirks these functions exist to absorb, all verified against live
/// responses on 2026-08-27:
///
/// - `energy_100g` is **kilojoules** and is never read; calories come from
///   `energy-kcal_100g`/`energy-kcal_serving` only.
/// - Protein is `proteins_` — plural. The singular key does not exist and
///   yields `null` forever.
/// - Iron arrives in **grams** and is multiplied by 1000.
/// - The `_value`/`_unit` pairs are contributor-entered and
///   unit-inconsistent, so only the SI-normalised `_100g`/`_serving` keys
///   are used for arithmetic.
/// - The same field arrives as `int` or `double` depending on the record,
///   and `""` stands in for `null` throughout.
/// - `brands` is a comma-joined `String` on the product API and a `List` on
///   Search-a-licious. The legacy CGI search (the web search path) shares
///   the product API's serialiser, so a hit from *it* carries the String
///   form — same function, both shapes, no branch at the call site.
/// - `serving_size`/`quantity` are free text **in the contributor's own
///   language and script** — a live Bulgarian record read `"500 г"`. That
///   text is displayed verbatim (it is what is printed on the packet) but
///   [_extractMeasurements] must return empty for it rather than reading the
///   500: a serving weight is arithmetic, and "500 of something we did not
///   recognise" is not a weight. Its unit alternation is Latin-only, which
///   is what makes the Cyrillic case fall through to `null` — do not
///   "improve" it into a bare leading-number parse.
library;

import 'package:menfit_app/features/nutrition/domain/food.dart';
import 'package:menfit_app/features/nutrition/domain/food_search_region.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_validation.dart';
import 'package:menfit_app/features/nutrition/domain/provider_food.dart';

/// The states tag Open Food Facts sets once a product's nutrition table has
/// been filled in.
const String _nutritionCompleteTag = 'en:nutrition-facts-completed';

/// Reads one product record from the v3 product endpoint.
///
/// [echoedCode] is the `code` the envelope carried, used when the product
/// object itself has none. Either way the result keys on what the **server**
/// said, never on what was asked for — see [ProviderFood.barcode].
/// [languageCode] is the user's food-search language
/// (`domain/food_search_region.dart`), already normalised. It selects which
/// `product_name_<lc>` field is preferred — see [_productName].
ProviderFood parseOpenFoodFactsProduct(
  Map<String, dynamic> product, {
  required String echoedCode,
  String languageCode = defaultFoodSearchLanguage,
}) {
  final barcode = jsonText(product['code']) ?? echoedCode;
  final nutriments = product['nutriments'];
  final perServing = _macros(nutriments, 'serving');
  final per100g = _macros(nutriments, '100g');
  final measurements = _servingMeasurements(product);
  final servingGrams = measurements.grams;
  final servingVolumeMl = measurements.volumeMl;
  final servingSize =
      jsonText(product['serving_size']) ?? jsonText(product['quantity']);

  final ServingBasis basis;
  final _Macros values;
  final double? grams;
  final double? volumeMl;
  final String description;
  if (perServing.hasAny) {
    basis = ServingBasis.statedPerServing;
    values = perServing;
    grams = servingGrams;
    volumeMl = servingVolumeMl;
    description =
        servingSize ??
        (volumeMl != null && grams != null
            ? '${_grams(grams)}, ${_ml(volumeMl)}'
            : volumeMl != null
            ? _ml(volumeMl)
            : grams != null
            ? _grams(grams)
            : '1 serving');
  } else if (per100g.hasAny &&
      (servingGrams != null || servingVolumeMl != null)) {
    if (servingGrams != null) {
      basis = ServingBasis.derivedFromPer100g;
      values = per100g.scaled(servingGrams / 100);
    } else {
      basis = ServingBasis.per100ml;
      values = per100g.scaled(servingVolumeMl! / 100);
    }
    grams = servingGrams;
    volumeMl = servingVolumeMl;
    description =
        servingSize ??
        (volumeMl != null && grams != null
            ? '${_grams(grams)}, ${_ml(volumeMl)}'
            : volumeMl != null
            ? _ml(volumeMl)
            : _grams(servingGrams!));
  } else if (per100g.hasAny ||
      (servingGrams == null &&
          servingVolumeMl == null &&
          servingSize == null)) {
    final isLiquid = servingVolumeMl != null;
    if (isLiquid) {
      basis = ServingBasis.per100ml;
      values = per100g;
      grams = null;
      volumeMl = 100;
      description = '100 ml';
    } else {
      basis = ServingBasis.per100g;
      values = per100g;
      grams = 100;
      volumeMl = null;
      description = '100 g';
    }
  } else {
    basis = ServingBasis.statedPerServing;
    values = const _Macros();
    grams = servingGrams;
    volumeMl = servingVolumeMl;
    description =
        servingSize ??
        (volumeMl != null && grams != null
            ? '${_grams(grams)}, ${_ml(volumeMl)}'
            : volumeMl != null
            ? _ml(volumeMl)
            : grams != null
            ? _grams(grams)
            : '1 serving');
  }

  final statesTags = product['states_tags'];
  return ProviderFood(
    source: FoodSource.openFoodFacts,
    barcode: barcode,
    providerFoodId: barcode,
    name: _productName(product, languageCode) ?? barcode,
    servingDescription: description,
    servingBasis: basis,
    brand: _brand(product['brands']),
    servingGrams: grams,
    servingVolumeMl: volumeMl,
    caloriesKcal: values.caloriesKcal,
    proteinGrams: values.proteinGrams,
    carbsGrams: values.carbsGrams,
    fatGrams: values.fatGrams,
    ironMg: values.ironMg,
    completeness: _number(product['completeness']),
    hasCompleteNutritionFacts:
        statesTags is List && statesTags.contains(_nutritionCompleteTag),
    hasNoNutritionData: _flag(product['no_nutrition_data']),
  );
}

/// Reads one search result, or `null` when it carries no product code and
/// so could never be looked up again.
///
/// Serves **both** search endpoints — Search-a-licious' `hits` and the
/// legacy CGI search's `products` (`open_food_facts_service.dart#search`).
/// The two envelopes differ; the records inside them agree on everything a
/// [ProviderFoodSummary] holds, apart from the `brands` shape [_brand]
/// already absorbs. One reader keeps the two paths from drifting into
/// producing subtly different summaries for the same product.
ProviderFoodSummary? parseOpenFoodFactsHit(
  Map<String, dynamic> hit, {
  String languageCode = defaultFoodSearchLanguage,
}) {
  final barcode = jsonText(hit['code']);
  if (barcode == null) return null;
  final per100g = _macros(hit['nutriments'], '100g');
  final perServing = _macros(hit['nutriments'], 'serving');
  final measurements = _servingMeasurements(hit);
  final servingGrams = measurements.grams;
  final servingVolumeMl = measurements.volumeMl;
  final servingSize =
      jsonText(hit['serving_size']) ?? jsonText(hit['quantity']);

  final double? servingCaloriesKcal;
  if (perServing.caloriesKcal != null) {
    servingCaloriesKcal = perServing.caloriesKcal;
  } else if (per100g.caloriesKcal != null &&
      (servingGrams != null || servingVolumeMl != null)) {
    final scale = servingGrams != null
        ? (servingGrams / 100)
        : (servingVolumeMl! / 100);
    servingCaloriesKcal = per100g.caloriesKcal! * scale;
  } else {
    servingCaloriesKcal = null;
  }

  final String? servingDesc;
  if (servingSize != null) {
    servingDesc = servingSize;
  } else if (servingVolumeMl != null && servingGrams != null) {
    servingDesc = '${_grams(servingGrams)}, ${_ml(servingVolumeMl)}';
  } else if (servingVolumeMl != null) {
    servingDesc = _ml(servingVolumeMl);
  } else if (servingGrams != null) {
    servingDesc = _grams(servingGrams);
  } else {
    servingDesc = null;
  }

  final divisor = servingGrams ?? servingVolumeMl;
  final calories100g =
      per100g.caloriesKcal ??
      (perServing.caloriesKcal != null && divisor != null && divisor > 0
          ? perServing.caloriesKcal! * 100 / divisor
          : perServing.caloriesKcal);

  final protein100g =
      per100g.proteinGrams ??
      (perServing.proteinGrams != null && divisor != null && divisor > 0
          ? perServing.proteinGrams! * 100 / divisor
          : perServing.proteinGrams);

  final carbs100g =
      per100g.carbsGrams ??
      (perServing.carbsGrams != null && divisor != null && divisor > 0
          ? perServing.carbsGrams! * 100 / divisor
          : perServing.carbsGrams);

  final fat100g =
      per100g.fatGrams ??
      (perServing.fatGrams != null && divisor != null && divisor > 0
          ? perServing.fatGrams! * 100 / divisor
          : perServing.fatGrams);

  return ProviderFoodSummary(
    source: FoodSource.openFoodFacts,
    // An Open Food Facts product is keyed on its barcode, so here the two
    // genuinely are the same string.
    providerFoodId: barcode,
    barcode: barcode,
    name: _productName(hit, languageCode) ?? barcode,
    brand: _brand(hit['brands']),
    caloriesKcal: calories100g,
    proteinGrams: protein100g,
    carbsGrams: carbs100g,
    fatGrams: fat100g,
    servingDescription: servingDesc,
    servingGrams: servingGrams,
    servingVolumeMl: servingVolumeMl,
    servingCaloriesKcal: servingCaloriesKcal,
  );
}

/// A JSON string field, or `null` when absent **or empty**: Open Food Facts
/// uses `""` where another API would use `null`, and `?? fallback` does not
/// catch that.
///
/// Public because the transport layer needs it too, to read the `code` off
/// the response envelope before a product is parsed at all.
String? jsonText(Object? value) {
  if (value is! String) return null;
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

class _ServingMeasurements {
  const _ServingMeasurements({this.grams, this.volumeMl});
  final double? grams;
  final double? volumeMl;
}

_ServingMeasurements _extractMeasurements(String? text) {
  if (text == null) return const _ServingMeasurements();
  final trimmed = text.trim();
  if (trimmed.isEmpty) return const _ServingMeasurements();

  final unitRegex = RegExp(
    r'(\d+(?:[.,]\d+)?)\s*(kg|kilograms?|g|grams?|ml|milliliters?|millilitres?|cl|l|liters?|litres?)\b',
    caseSensitive: false,
  );
  final matches = unitRegex.allMatches(trimmed);
  double? grams;
  double? volumeMl;

  if (matches.isNotEmpty) {
    for (final match in matches.toList().reversed) {
      final numStr = match.group(1)?.replaceAll(',', '.');
      final unit = match.group(2)?.toLowerCase();
      if (numStr == null || unit == null) continue;
      final val = double.tryParse(numStr);
      if (val == null || val <= 0) continue;

      if (unit == 'cl') {
        final ml = val * 10;
        if (ml <= maxServingVolumeMl) volumeMl ??= ml;
      } else if (unit == 'l' ||
          unit.startsWith('liter') ||
          unit.startsWith('litre')) {
        final ml = val * 1000;
        if (ml <= maxServingVolumeMl) volumeMl ??= ml;
      } else if (unit == 'ml' || unit.startsWith('millilit')) {
        if (val <= maxServingVolumeMl) volumeMl ??= val;
      } else if (unit == 'kg' || unit.startsWith('kilogram')) {
        final g = val * 1000;
        if (g <= maxServingGrams) grams ??= g;
      } else if (unit == 'g' || unit.startsWith('gram')) {
        if (val <= maxServingGrams) grams ??= val;
      }
    }
    if (grams != null || volumeMl != null) {
      return _ServingMeasurements(grams: grams, volumeMl: volumeMl);
    }
  }

  final direct = double.tryParse(trimmed.replaceAll(',', '.'));
  if (direct != null && direct > 0 && direct <= maxServingGrams) {
    return _ServingMeasurements(grams: direct);
  }

  return const _ServingMeasurements();
}

_ServingMeasurements _servingMeasurements(Map<String, dynamic> product) {
  final fromServingSize = _extractMeasurements(
    jsonText(product['serving_size']),
  );
  final fromQuantity = _extractMeasurements(jsonText(product['quantity']));

  var grams = fromServingSize.grams ?? fromQuantity.grams;
  final volumeMl = fromServingSize.volumeMl ?? fromQuantity.volumeMl;

  // Fall back to serving_quantity as grams only if no unit-specified
  // measurement was found in serving_size or quantity. serving_quantity_unit is
  // contributor-entered and frequently wrong (e.g. "ml" on dry cereal), so the
  // textual serving_size/quantity strings take priority.
  final qty = _number(product['serving_quantity']);
  if (qty != null && qty > 0 && qty <= maxServingGrams) {
    if (grams == null && volumeMl == null) {
      grams = qty;
    }
  }

  return _ServingMeasurements(grams: grams, volumeMl: volumeMl);
}

/// Whole numbers render without a decimal point: `28 g`, not `28.0 g`.
String _grams(double grams) {
  final rounded = grams.roundToDouble();
  return rounded == grams
      ? '${rounded.toInt()} g'
      : '${grams.toStringAsFixed(1)} g';
}

String _ml(double ml) {
  final rounded = ml.roundToDouble();
  return rounded == ml
      ? '${rounded.toInt()} ml'
      : '${ml.toStringAsFixed(1)} ml';
}

/// Localisation is resolved client-side: `lc=`/`cc=`/country subdomains do
/// not reliably localise `product_name`, and every one of these fields can
/// be present but empty. The request asks for `product_name_<lc>` in the
/// `fields` allowlist (`open_food_facts_service.dart`); reading it is this
/// function's half of the bargain.
///
/// The fallback to the un-suffixed `product_name` is deliberate and
/// unconditional. It is the record's name in whatever language its
/// contributor entered, which for a product actually sold in the user's
/// country is very often exactly right — and dropping a result because its
/// name is not in their language would hide products they can buy. Locality is
/// handled by the country filter on the request, not by second-guessing the
/// names that come back (`domain/food_search_region.dart`).
String? _productName(Map<String, dynamic> product, String languageCode) =>
    jsonText(product['product_name_$languageCode']) ??
    jsonText(product['product_name']) ??
    jsonText(product['generic_name']);

/// `brands` is a comma-joined `String` on the product API (and on the
/// legacy CGI search, which shares its serialiser) but a `List<String>` on
/// Search-a-licious — same field name, different type. The first entry is
/// the primary brand in every case.
String? _brand(Object? raw) {
  if (raw is List) {
    for (final entry in raw) {
      final brand = jsonText(entry);
      if (brand != null) return brand;
    }
    return null;
  }
  final joined = jsonText(raw);
  if (joined == null) return null;
  for (final part in joined.split(',')) {
    final brand = jsonText(part);
    if (brand != null) return brand;
  }
  return null;
}

_Macros _macros(Object? nutriments, String suffix) {
  if (nutriments is! Map<String, dynamic>) return const _Macros();
  final altSuffix = suffix == '100g' ? '100ml' : null;
  final iron =
      _number(nutriments['iron_$suffix']) ??
      (altSuffix != null ? _number(nutriments['iron_$altSuffix']) : null);
  return _Macros(
    // `energy_$suffix` is kilojoules and is never read.
    caloriesKcal:
        _number(nutriments['energy-kcal_$suffix']) ??
        (altSuffix != null
            ? _number(nutriments['energy-kcal_$altSuffix'])
            : null),
    proteinGrams:
        _number(nutriments['proteins_$suffix']) ??
        (altSuffix != null ? _number(nutriments['proteins_$altSuffix']) : null),
    carbsGrams:
        _number(nutriments['carbohydrates_$suffix']) ??
        (altSuffix != null
            ? _number(nutriments['carbohydrates_$altSuffix'])
            : null),
    fatGrams:
        _number(nutriments['fat_$suffix']) ??
        (altSuffix != null ? _number(nutriments['fat_$altSuffix']) : null),
    // Open Food Facts states iron in GRAMS; this app uses milligrams.
    ironMg: iron == null ? null : iron * 1000,
  );
}

/// A JSON number field.
///
/// Decoded as `num` then widened: the same field arrives as int or double
/// depending on the record (`completeness` was `1` and `0.7875`), and
/// `as double` throws on the int case. Numeric strings are accepted because
/// contributor-entered values occasionally arrive quoted.
double? _number(Object? value) {
  if (value is num) {
    final asDouble = value.toDouble();
    return asDouble.isFinite ? asDouble : null;
  }
  if (value is String) {
    final parsed = double.tryParse(value.trim());
    return parsed != null && parsed.isFinite ? parsed : null;
  }
  return null;
}

/// A JSON boolean-ish field. Open Food Facts writes checkbox flags as the
/// string `"on"`, not as `true`.
bool _flag(Object? value) =>
    value == true || value == 'on' || value == '1' || value == 1;

/// The four macros plus iron read off one nutriment suffix.
class _Macros {
  const _Macros({
    this.caloriesKcal,
    this.proteinGrams,
    this.carbsGrams,
    this.fatGrams,
    this.ironMg,
  });

  final double? caloriesKcal;
  final double? proteinGrams;
  final double? carbsGrams;
  final double? fatGrams;
  final double? ironMg;

  /// Whether the source stated anything at all at this suffix. Iron alone
  /// counts: a product with only iron on a per-serving basis still tells us
  /// the source has per-serving data.
  ///
  /// ## The known cost, accepted deliberately
  ///
  /// This selects a whole suffix block, so a record stating *some*
  /// per-serving values but not `iron_serving` yields per-serving macros and
  /// **no iron** — even where `iron_100g` exists and could have been scaled.
  /// Iron then reads as unknown rather than as a number, and the review
  /// screen asks the user for it.
  ///
  /// Kept that way on purpose. Mixing suffixes would mean presenting one
  /// figure the provider stated per serving beside another this app derived,
  /// under a single [ServingBasis] that could only describe one of them —
  /// and `domain/provider_food.dart` exists to stop exactly that kind of
  /// quiet blending. Unknown-instead-of-derived is the conservative failure
  /// for the app's headline micronutrient. It is also narrow in practice:
  /// Open Food Facts computes the `_serving` values itself from the
  /// per-100 g table, so a block with some `_serving` keys and no
  /// `iron_serving` usually means the record has no iron at all.
  bool get hasAny =>
      caloriesKcal != null ||
      proteinGrams != null ||
      carbsGrams != null ||
      fatGrams != null ||
      ironMg != null;

  /// Scaled by [factor], leaving unknown values unknown — scaling `null`
  /// cannot invent a number (`domain/nutrition_facts.dart`'s rule).
  _Macros scaled(double factor) => _Macros(
    caloriesKcal: caloriesKcal == null ? null : caloriesKcal! * factor,
    proteinGrams: proteinGrams == null ? null : proteinGrams! * factor,
    carbsGrams: carbsGrams == null ? null : carbsGrams! * factor,
    fatGrams: fatGrams == null ? null : fatGrams! * factor,
    ironMg: ironMg == null ? null : ironMg! * factor,
  );
}
