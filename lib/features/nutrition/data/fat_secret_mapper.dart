import 'package:menfit_app/features/nutrition/data/fat_secret_food_record.dart';
import 'package:menfit_app/features/nutrition/data/fat_secret_search_mapper.dart';
import 'package:menfit_app/features/nutrition/domain/provider_food.dart';

/// Turns FatSecret Platform API JSON responses into domain candidates.
///
/// Handles XML-to-JSON quirks common in FatSecret responses:
/// - Single items may arrive as a [Map] rather than a single-element [List].
/// - Numeric values frequently arrive as strings (e.g. `"150"` or `"2.50"`).
/// - Missing or blank fields are treated as null rather than defaulted to zero.
///
/// Every endpoint this app calls returns the same structured food record
/// (2026-10-02): `foods.search.v5` hits, `food.get.v5` and
/// `food.find_id_for_barcode.v2`. That record is read by one parser,
/// `fat_secret_food_record.dart`; search-response unwrapping lives in
/// `fat_secret_search_mapper.dart` and the unit arithmetic in
/// `fat_secret_serving_units.dart`.
class FatSecretMapper {
  const FatSecretMapper();

  /// Parses search results from FatSecret `foods.search.v5`.
  List<ProviderFoodSummary> parseSearchHits(Map<String, dynamic> json) =>
      parseFatSecretSearchHits(json);

  /// Parses the `food` record in a `food.get.v5` or
  /// `food.find_id_for_barcode.v2` response; `null` when the response holds
  /// no `food` object.
  ///
  /// [ProviderFood.barcode] is [resolvedBarcode] — the GTIN the lookup
  /// started from, so the saved catalogue entry is keyed on the physical
  /// product barcode for instant offline re-scans — and `null` when there
  /// was none (a record fetched by `food_id` from a search hit). The
  /// `food_id` itself goes to [ProviderFood.providerFoodId] and **never**
  /// to the barcode (B23).
  ProviderFood? parseFoodDetail(
    Map<String, dynamic> json, {
    String? fallbackFoodId,
    String? resolvedBarcode,
  }) {
    final food = json['food'];
    if (food is! Map<String, dynamic>) return null;
    return parseFatSecretFoodRecord(
      food,
      fallbackFoodId: fallbackFoodId,
      resolvedBarcode: resolvedBarcode,
    );
  }
}
