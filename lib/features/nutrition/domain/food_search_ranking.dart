import 'package:menfit_app/features/nutrition/domain/provider_food.dart';

/// Completeness tier of a food item's nutritional information.
enum NutritionCompletenessTier {
  /// Both calories and all three macronutrients (P, C, F) are present.
  fullMacrosAndCalories(4),

  /// Calories and at least one macronutrient are present.
  partialMacrosAndCalories(3),

  /// Calories are present, but all macronutrients are missing.
  caloriesOnly(2),

  /// At least one macronutrient is present, but calories are missing.
  macrosOnly(1),

  /// Neither calories nor macros are present.
  none(0);

  const NutritionCompletenessTier(this.rank);
  final int rank;
}

/// Closeness tier of how well a food's name matches the user's search query.
enum MatchRelevanceTier {
  /// The food name or display name exactly matches the query.
  exact(5),

  /// The food name or display name starts with the search query.
  startsWith(4),

  /// The food name or display name contains the full search query phrase.
  containsPhrase(3),

  /// The food contains all individual words from the search query.
  allWords(2),

  /// The food contains some (at least one) words from the search query.
  someWords(1),

  /// None of the search query words are present.
  none(0);

  const MatchRelevanceTier(this.rank);
  final int rank;
}

/// Returns `true` if [food] provides either calorie information or at least
/// one macronutrient.
///
/// Foods where all nutrition fields are `null` (unpopulated / hollow records)
/// return `false`. Genuine zero-calorie foods (with numeric `0.0`) return
/// `true`.
bool hasCaloriesOrMacros(ProviderFoodSummary food) {
  final hasCalories =
      food.caloriesKcal != null || food.servingCaloriesKcal != null;
  final hasMacros =
      food.proteinGrams != null ||
      food.carbsGrams != null ||
      food.fatGrams != null;
  return hasCalories || hasMacros;
}

/// Determines the [NutritionCompletenessTier] for a [ProviderFoodSummary].
NutritionCompletenessTier evaluateNutritionTier(ProviderFoodSummary food) {
  final hasCalories =
      food.caloriesKcal != null || food.servingCaloriesKcal != null;
  final p = food.proteinGrams != null;
  final c = food.carbsGrams != null;
  final f = food.fatGrams != null;

  final macroCount = (p ? 1 : 0) + (c ? 1 : 0) + (f ? 1 : 0);

  if (hasCalories && macroCount == 3) {
    return NutritionCompletenessTier.fullMacrosAndCalories;
  }
  if (hasCalories && macroCount > 0) {
    return NutritionCompletenessTier.partialMacrosAndCalories;
  }
  if (hasCalories) {
    return NutritionCompletenessTier.caloriesOnly;
  }
  if (macroCount > 0) {
    return NutritionCompletenessTier.macrosOnly;
  }
  return NutritionCompletenessTier.none;
}

/// Internal ranking metrics for a search hit used by the multi-tier comparator.
class FoodSearchRank {
  const FoodSearchRank({
    required this.matchTier,
    required this.matchedWordCount,
    required this.nutritionTier,
    required this.lengthDelta,
    required this.firstMatchIndex,
    required this.originalIndex,
  });

  final MatchRelevanceTier matchTier;
  final int matchedWordCount;
  final NutritionCompletenessTier nutritionTier;
  final int lengthDelta;
  final int firstMatchIndex;
  final int originalIndex;

  /// Compares two search hits following the user's priority order:
  /// 1. Closer query word matching (matchTier, then matchedWordCount).
  /// 2. Nutritional completeness (macros + cals > cals only > macros only).
  /// 3. Compactness (shorter difference from query length).
  /// 4. Earlier appearance of match in the food's name.
  /// 5. Original provider order (stable tie-breaker).
  static int compare(FoodSearchRank a, FoodSearchRank b) {
    // 1. Search word matching closeness
    if (a.matchTier.rank != b.matchTier.rank) {
      return b.matchTier.rank.compareTo(a.matchTier.rank);
    }
    if (a.matchTier == MatchRelevanceTier.someWords ||
        a.matchTier == MatchRelevanceTier.allWords) {
      if (a.matchedWordCount != b.matchedWordCount) {
        return b.matchedWordCount.compareTo(a.matchedWordCount);
      }
    }

    // 2. Nutrition completeness
    if (a.nutritionTier.rank != b.nutritionTier.rank) {
      return b.nutritionTier.rank.compareTo(a.nutritionTier.rank);
    }

    // 3. Closeness / compactness (fewer extraneous characters)
    if (a.lengthDelta != b.lengthDelta) {
      return a.lengthDelta.compareTo(b.lengthDelta);
    }

    // 4. First match index (closer to beginning)
    if (a.firstMatchIndex != b.firstMatchIndex) {
      return a.firstMatchIndex.compareTo(b.firstMatchIndex);
    }

    // 5. Stable tie-breaker
    return a.originalIndex.compareTo(b.originalIndex);
  }
}

/// Computes the [FoodSearchRank] for a [food] against [query].
FoodSearchRank rankSearchHit(
  ProviderFoodSummary food, {
  required String query,
  required int originalIndex,
}) {
  final cleanQuery = query.trim().toLowerCase();
  final nutritionTier = evaluateNutritionTier(food);

  if (cleanQuery.isEmpty) {
    return FoodSearchRank(
      matchTier: MatchRelevanceTier.none,
      matchedWordCount: 0,
      nutritionTier: nutritionTier,
      lengthDelta: food.displayName.length,
      firstMatchIndex: 0,
      originalIndex: originalIndex,
    );
  }

  final name = food.name.trim().toLowerCase();
  final full = food.displayName.trim().toLowerCase();

  // Tier 5: Exact match
  if (name == cleanQuery || full == cleanQuery) {
    return FoodSearchRank(
      matchTier: MatchRelevanceTier.exact,
      matchedWordCount: 1,
      nutritionTier: nutritionTier,
      lengthDelta: (full.length - cleanQuery.length).abs(),
      firstMatchIndex: 0,
      originalIndex: originalIndex,
    );
  }

  // Tier 4: Starts with query
  if (name.startsWith(cleanQuery) || full.startsWith(cleanQuery)) {
    return FoodSearchRank(
      matchTier: MatchRelevanceTier.startsWith,
      matchedWordCount: 1,
      nutritionTier: nutritionTier,
      lengthDelta: (full.length - cleanQuery.length).abs(),
      firstMatchIndex: 0,
      originalIndex: originalIndex,
    );
  }

  // Tier 3: Contains full query phrase
  final phraseIdx = full.indexOf(cleanQuery);
  if (phraseIdx != -1) {
    return FoodSearchRank(
      matchTier: MatchRelevanceTier.containsPhrase,
      matchedWordCount: 1,
      nutritionTier: nutritionTier,
      lengthDelta: (full.length - cleanQuery.length).abs(),
      firstMatchIndex: phraseIdx,
      originalIndex: originalIndex,
    );
  }

  // Multi-word analysis
  final words = cleanQuery
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty)
      .toList();

  var matchedCount = 0;
  var earliestMatch = full.length;
  for (final word in words) {
    final idx = full.indexOf(word);
    if (idx != -1) {
      matchedCount++;
      if (idx < earliestMatch) earliestMatch = idx;
    }
  }

  if (words.isNotEmpty && matchedCount == words.length) {
    return FoodSearchRank(
      matchTier: MatchRelevanceTier.allWords,
      matchedWordCount: matchedCount,
      nutritionTier: nutritionTier,
      lengthDelta: (full.length - cleanQuery.length).abs(),
      firstMatchIndex: earliestMatch,
      originalIndex: originalIndex,
    );
  }

  if (matchedCount > 0) {
    return FoodSearchRank(
      matchTier: MatchRelevanceTier.someWords,
      matchedWordCount: matchedCount,
      nutritionTier: nutritionTier,
      lengthDelta: (full.length - cleanQuery.length).abs(),
      firstMatchIndex: earliestMatch,
      originalIndex: originalIndex,
    );
  }

  return FoodSearchRank(
    matchTier: MatchRelevanceTier.none,
    matchedWordCount: 0,
    nutritionTier: nutritionTier,
    lengthDelta: full.length,
    firstMatchIndex: full.length,
    originalIndex: originalIndex,
  );
}

/// Filters out hollow foods with no calories or macros, and sorts the
/// remaining foods by match closeness and nutritional completeness.
List<ProviderFoodSummary> filterAndRankFoodSearchResults(
  List<ProviderFoodSummary> hits, {
  required String query,
}) {
  final validHitsWithIndices = <({ProviderFoodSummary hit, int index})>[];
  for (var i = 0; i < hits.length; i++) {
    final item = hits[i];
    if (hasCaloriesOrMacros(item)) {
      validHitsWithIndices.add((hit: item, index: i));
    }
  }

  final ranked = validHitsWithIndices.map((entry) {
    final rank = rankSearchHit(
      entry.hit,
      query: query,
      originalIndex: entry.index,
    );
    return (entry.hit, rank);
  }).toList()..sort((a, b) => FoodSearchRank.compare(a.$2, b.$2));

  return ranked.map((e) => e.$1).toList();
}
