import 'package:menfit_app/features/nutrition/domain/food.dart';
import 'package:menfit_app/features/nutrition/domain/provider_food.dart';

/// Turns FatSecret Platform API JSON responses into domain candidates.
///
/// Handles XML-to-JSON quirks common in FatSecret responses:
/// - Single items may arrive as a [Map] rather than a single-element [List].
/// - Numeric values frequently arrive as strings (e.g. `"150"` or `"2.50"`).
/// - Missing or blank fields are treated as null rather than defaulted to zero.
class FatSecretMapper {
  const FatSecretMapper();

  /// Parses search results from FatSecret `foods.search` (or
  /// `foods.search.v5`).
  List<ProviderFoodSummary> parseSearchHits(Map<String, dynamic> json) {
    final foodsWrapper = json['foods'];
    if (foodsWrapper is! Map<String, dynamic>) {
      return const [];
    }

    final rawFood = foodsWrapper['food'];
    final List<dynamic> items;
    if (rawFood is List) {
      items = rawFood;
    } else if (rawFood is Map<String, dynamic>) {
      items = [rawFood];
    } else {
      return const [];
    }

    final results = <ProviderFoodSummary>[];
    for (final item in items) {
      if (item is! Map<String, dynamic>) continue;
      final summary = _parseSearchHit(item);
      if (summary != null) {
        results.add(summary);
      }
    }
    return results;
  }

  /// Parses one hit from `foods.search`.
  ProviderFoodSummary? _parseSearchHit(Map<String, dynamic> item) {
    final foodId = _asString(item['food_id']);
    final foodName = _asString(item['food_name']);
    if (foodId == null || foodName == null || foodName.isEmpty) {
      return null;
    }

    final brand = _asString(item['brand_name']);
    final description = _asString(item['food_description']) ?? '';
    final parsed = _parseFoodDescription(description);

    return ProviderFoodSummary(
      source: FoodSource.fatSecret,
      barcode: foodId,
      name: foodName,
      brand: brand,
      caloriesKcal: parsed.caloriesKcal,
      proteinGrams: parsed.proteinGrams,
      carbsGrams: parsed.carbsGrams,
      fatGrams: parsed.fatGrams,
      servingDescription: parsed.servingDescription,
      servingGrams: parsed.servingGrams,
      servingVolumeMl: parsed.servingVolumeMl,
      servingCaloriesKcal: parsed.servingCaloriesKcal,
    );
  }

  /// Parses FatSecret `food_description` string.
  ///
  /// Examples:
  /// - `"Per 100g - Calories: 389kcal | Fat: 6.90g | Carbs: 66.30g | ..."`
  /// - `"Per 100ml - Calories: 42kcal | Fat: 0.10g | Carbs: 10.60g | ..."`
  /// - `"Per 1 serving (40g) - Calories: 150kcal | Fat: 3.00g | ..."`
  /// - `"Per 1 bottle (500ml) - Calories: 210kcal | Fat: 0.00g | ..."`
  _ParsedDescription _parseFoodDescription(String desc) {
    if (desc.isEmpty) return const _ParsedDescription();

    String? servingDescription;
    double? servingGrams;
    double? servingVolumeMl;
    double? calories;
    double? fat;
    double? carbs;
    double? protein;
    var isPer100g = false;
    var isPer100ml = false;

    // Extract portion prefix
    final matchPortion = RegExp(r'^Per\s+(.*?)\s*-\s*(.*)$').firstMatch(desc);
    if (matchPortion != null) {
      final portion = matchPortion.group(1)?.trim();
      if (portion != null) {
        servingDescription = portion;
        final portionLower = portion.toLowerCase();
        if (portionLower == '100g' || portionLower == '100 g') {
          isPer100g = true;
          servingGrams = 100;
        } else if (portionLower == '100ml' || portionLower == '100 ml') {
          isPer100ml = true;
          servingVolumeMl = 100;
        } else {
          final gMatch = RegExp(
            r'\(?(\d+(?:\.\d+)?)\s*g\)?',
            caseSensitive: false,
          ).firstMatch(portion);
          if (gMatch != null) {
            servingGrams = double.tryParse(gMatch.group(1)!);
          }
          final mlMatch = RegExp(
            r'\(?(\d+(?:\.\d+)?)\s*ml\)?',
            caseSensitive: false,
          ).firstMatch(portion);
          if (mlMatch != null) {
            servingVolumeMl = double.tryParse(mlMatch.group(1)!);
          }
        }
      }
    }

    // Extract macros
    final calMatch = RegExp(
      r'Calories:\s*(\d+(?:\.\d+)?)\s*kcal',
      caseSensitive: false,
    ).firstMatch(desc);
    if (calMatch != null) {
      calories = double.tryParse(calMatch.group(1)!);
    }

    final fatMatch = RegExp(
      r'Fat:\s*(\d+(?:\.\d+)?)\s*g',
      caseSensitive: false,
    ).firstMatch(desc);
    if (fatMatch != null) {
      fat = double.tryParse(fatMatch.group(1)!);
    }

    final carbsMatch = RegExp(
      r'Carbs:\s*(\d+(?:\.\d+)?)\s*g',
      caseSensitive: false,
    ).firstMatch(desc);
    if (carbsMatch != null) {
      carbs = double.tryParse(carbsMatch.group(1)!);
    }

    final proteinMatch = RegExp(
      r'Protein:\s*(\d+(?:\.\d+)?)\s*g',
      caseSensitive: false,
    ).firstMatch(desc);
    if (proteinMatch != null) {
      protein = double.tryParse(proteinMatch.group(1)!);
    }

    if (isPer100g) {
      return _ParsedDescription(
        caloriesKcal: calories,
        fatGrams: fat,
        carbsGrams: carbs,
        proteinGrams: protein,
        servingDescription: '100 g',
        servingGrams: 100,
      );
    }

    if (isPer100ml) {
      return _ParsedDescription(
        caloriesKcal: calories,
        fatGrams: fat,
        carbsGrams: carbs,
        proteinGrams: protein,
        servingDescription: '100 ml',
        servingVolumeMl: 100,
      );
    }

    final divisor = (servingGrams != null && servingGrams > 0)
        ? servingGrams
        : (servingVolumeMl != null && servingVolumeMl > 0
              ? servingVolumeMl
              : null);

    return _ParsedDescription(
      servingDescription: servingDescription,
      servingGrams: servingGrams,
      servingVolumeMl: servingVolumeMl,
      servingCaloriesKcal: calories,
      caloriesKcal: divisor != null
          ? (calories != null ? calories * 100 / divisor : null)
          : calories,
      fatGrams: divisor != null
          ? (fat != null ? fat * 100 / divisor : null)
          : fat,
      carbsGrams: divisor != null
          ? (carbs != null ? carbs * 100 / divisor : null)
          : carbs,
      proteinGrams: divisor != null
          ? (protein != null ? protein * 100 / divisor : null)
          : protein,
    );
  }

  /// Extracts food_id from `food.find_id_for_barcode` response.
  String? parseBarcodeToFoodId(Map<String, dynamic> json) {
    final foodIdObj = json['food_id'];
    if (foodIdObj is Map<String, dynamic>) {
      return _asString(foodIdObj['value']);
    }
    return _asString(foodIdObj);
  }

  /// Parses detailed food record from `food.get.v5`.
  ProviderFood? parseFoodDetail(
    Map<String, dynamic> json, {
    String? fallbackBarcode,
  }) {
    final food = json['food'];
    if (food is! Map<String, dynamic>) return null;

    final foodId = _asString(food['food_id']) ?? fallbackBarcode ?? '';
    final foodName = _asString(food['food_name']) ?? foodId;
    final brandName = _asString(food['brand_name']);

    final servingsWrapper = food['servings'];
    final List<dynamic> servingsList;
    if (servingsWrapper is Map<String, dynamic>) {
      final rawServing = servingsWrapper['serving'];
      if (rawServing is List) {
        servingsList = rawServing;
      } else if (rawServing is Map<String, dynamic>) {
        servingsList = [rawServing];
      } else {
        servingsList = const [];
      }
    } else {
      servingsList = const [];
    }

    if (servingsList.isEmpty) {
      return ProviderFood(
        source: FoodSource.fatSecret,
        barcode: foodId,
        name: foodName,
        brand: brandName,
        servingDescription: '1 serving',
        servingBasis: ServingBasis.per100g,
        hasNoNutritionData: true,
      );
    }

    // Select primary serving: prefer servings with macros & calories,
    // and among those prefer gram-metric servings.
    int servingScore(Map<String, dynamic> s) {
      final hasCals = _asDouble(s['calories']) != null;
      final hasMacros =
          _asDouble(s['protein']) != null &&
          _asDouble(s['carbohydrate']) != null &&
          _asDouble(s['fat']) != null;
      final unit = _asString(s['metric_serving_unit'])?.toLowerCase();
      final isMetric = unit == 'g' || unit == 'ml';

      if (hasCals && hasMacros && isMetric) return 5;
      if (hasCals && hasMacros) return 4;
      if (hasCals && isMetric) return 3;
      if (hasCals) return 2;
      if (isMetric) return 1;
      return 0;
    }

    var primaryServing = servingsList.first as Map<String, dynamic>;
    var bestScore = servingScore(primaryServing);
    for (final s in servingsList) {
      if (s is Map<String, dynamic>) {
        final score = servingScore(s);
        if (score > bestScore) {
          primaryServing = s;
          bestScore = score;
        }
      }
    }

    final rawServingDesc =
        _asString(primaryServing['serving_description']) ?? '1 serving';
    final metricAmount = _asDouble(primaryServing['metric_serving_amount']);
    final metricUnit = _asString(primaryServing['metric_serving_unit']);

    final double? servingGrams;
    final double? servingVolumeMl;
    if (metricUnit?.toLowerCase() == 'g' && metricAmount != null) {
      servingGrams = metricAmount;
      servingVolumeMl = null;
    } else if (metricUnit?.toLowerCase() == 'ml' && metricAmount != null) {
      servingGrams = null;
      servingVolumeMl = metricAmount;
    } else {
      servingGrams = _extractGrams(rawServingDesc);
      servingVolumeMl = _extractMl(rawServingDesc);
    }

    final servingDesc = _formatServingDescription(
      rawServingDesc,
      metricAmount: metricAmount,
      metricUnit: metricUnit,
    );

    final is100g =
        servingDesc.trim().toLowerCase() == '100 g' ||
        servingDesc.trim().toLowerCase() == '100g';
    final is100ml =
        servingDesc.trim().toLowerCase() == '100 ml' ||
        servingDesc.trim().toLowerCase() == '100ml';

    final ServingBasis basis;
    if (is100g) {
      basis = ServingBasis.per100g;
    } else if (is100ml) {
      basis = ServingBasis.per100ml;
    } else {
      basis = ServingBasis.statedPerServing;
    }

    final calories = _asDouble(primaryServing['calories']);
    final protein = _asDouble(primaryServing['protein']);
    final carbs = _asDouble(primaryServing['carbohydrate']);
    final fat = _asDouble(primaryServing['fat']);
    final satFat = _asDouble(primaryServing['saturated_fat']);
    final fiber = _asDouble(primaryServing['fiber']);
    final sodium = _asDouble(primaryServing['sodium']);
    final potassium = _asDouble(primaryServing['potassium']);
    final calcium = _asDouble(primaryServing['calcium']);
    final vitaminD = _asDouble(primaryServing['vitamin_d']);
    final vitaminC = _asDouble(primaryServing['vitamin_c']);
    final iron = _asDouble(primaryServing['iron']);

    return ProviderFood(
      source: FoodSource.fatSecret,
      barcode: foodId,
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
      ironMg: iron,
      calciumMg: calcium,
      vitaminDMcg: vitaminD,
      vitaminCMg: vitaminC,
      fiberGrams: fiber,
      sodiumMg: sodium,
      potassiumMg: potassium,
      saturatedFatGrams: satFat,
      hasCompleteNutritionFacts:
          calories != null && protein != null && carbs != null && fat != null,
    );
  }

  double? _extractGrams(String text) {
    final match = RegExp(
      r'\(?(\d+(?:\.\d+)?)\s*g\)?',
      caseSensitive: false,
    ).firstMatch(text);
    return match == null ? null : double.tryParse(match.group(1)!);
  }

  double? _extractMl(String text) {
    final match = RegExp(
      r'\(?(\d+(?:\.\d+)?)\s*ml\)?',
      caseSensitive: false,
    ).firstMatch(text);
    return match == null ? null : double.tryParse(match.group(1)!);
  }

  String _formatServingDescription(
    String desc, {
    double? metricAmount,
    String? metricUnit,
  }) {
    final trimmed = desc.trim();
    if (trimmed.isEmpty) return '1 serving';
    if (metricAmount == null || metricAmount <= 0 || metricUnit == null) {
      return trimmed;
    }

    final unit = metricUnit.toLowerCase().trim();
    final formattedAmount = metricAmount == metricAmount.roundToDouble()
        ? metricAmount.round().toString()
        : metricAmount.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '');
    final metricText = '$formattedAmount $unit';

    if (trimmed.toLowerCase() == '100g' || trimmed.toLowerCase() == '100 g') {
      return '100 g';
    }

    if (trimmed.toLowerCase() == '100ml' || trimmed.toLowerCase() == '100 ml') {
      return '100 ml';
    }

    final hasUnit = RegExp(
      '\\b$unit\\b|\\d+\\s*$unit',
      caseSensitive: false,
    ).hasMatch(trimmed);
    if (hasUnit) {
      return trimmed;
    }

    final isGenericServing = RegExp(
      r'^(1\s+)?(serving|portion)$',
      caseSensitive: false,
    ).hasMatch(trimmed);

    if (isGenericServing) {
      return '1 serving ($metricText)';
    }

    return '$trimmed ($metricText)';
  }

  String? _asString(dynamic value) {
    if (value == null) return null;
    final s = value.toString().trim();
    return s.isEmpty ? null : s;
  }

  double? _asDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) return null;
      return double.tryParse(trimmed);
    }
    return null;
  }
}

class _ParsedDescription {
  const _ParsedDescription({
    this.caloriesKcal,
    this.proteinGrams,
    this.carbsGrams,
    this.fatGrams,
    this.servingDescription,
    this.servingGrams,
    this.servingVolumeMl,
    this.servingCaloriesKcal,
  });

  final double? caloriesKcal;
  final double? proteinGrams;
  final double? carbsGrams;
  final double? fatGrams;
  final String? servingDescription;
  final double? servingGrams;
  final double? servingVolumeMl;
  final double? servingCaloriesKcal;
}
