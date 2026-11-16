import 'package:menfit_app/core/errors/app_exception.dart';
import 'package:menfit_app/features/nutrition/domain/food.dart';
import 'package:menfit_app/features/nutrition/domain/food_data_provider.dart';
import 'package:menfit_app/features/nutrition/domain/food_search_region.dart';
import 'package:menfit_app/features/nutrition/domain/provider_food.dart';

/// A [FoodDataProvider] that tries [primary] first and falls back to
/// [fallback] when the primary is unreachable or has nothing to offer.
///
/// Built for FatSecret-as-primary, Open Food Facts-as-backup (see ADR 016),
/// but nothing here names either service: this is generic composition over
/// two providers of the same interface.
///
/// ## What triggers a fallback, and what does not
///
/// - [findByBarcode]: a `NetworkException` from [primary] falls back, and so
///   does a plain `null` — a barcode is a global identifier, so a miss in
///   one catalogue is exactly the case a backup catalogue exists for. If
///   [primary] answered `null` (authoritatively: it does not have this
///   product) and [fallback] then throws `NetworkException`, the answer is
///   `null` rather than an exception — the primary already gave a real
///   answer, and a backup being unreachable does not make that answer wrong.
///   If **both** throw `NetworkException`, the primary's is rethrown.
///   `ValidationException` from [primary] propagates without ever trying
///   [fallback] — a malformed barcode is not a "this catalogue doesn't have
///   it" outcome.
/// - [search]: falls back to [fallback] when [primary] does not support text
///   search at all, or throws `NetworkException`. An **empty** result from
///   [primary] does *not* fall back — pages have to come from one catalogue
///   for pagination (`page`/`pageSize`) to stay coherent, and a caller
///   paging through primary results must not silently start receiving
///   fallback ones partway through. `ValidationException` propagates without
///   trying [fallback], for the same reason as [findByBarcode].
///
/// ## No logging
///
/// Nothing here logs, by design: every argument these methods take is S2
/// data (`knowledge/engineering/security_and_privacy.md`), and the static
/// exception messages already carry everything worth knowing about a
/// failure.
class FallbackFoodDataProvider implements FoodDataProvider {
  FallbackFoodDataProvider({required this.primary, required this.fallback});

  final FoodDataProvider primary;
  final FoodDataProvider fallback;

  @override
  FoodSource get foodSource => primary.foodSource;

  /// Names both sources, because a lookup through this provider may in fact
  /// have reached either one — an attribution or a consent notice that named
  /// only [primary] would be dishonest about where a result actually came
  /// from.
  @override
  String get attributionName =>
      '${primary.attributionName} and ${fallback.attributionName}';

  @override
  String get attributionUrl => primary.attributionUrl;

  @override
  Uri productPageUrl(String barcode) => primary.productPageUrl(barcode);

  /// The provider that actually produced a result with this [source] —
  /// [primary] when it matches [primary]'s own source, [fallback] when it
  /// matches [fallback]'s, and [primary] for anything else (a source this
  /// composite never produced itself, which has nothing better to resolve
  /// to).
  @override
  FoodDataProvider providerFor(FoodSource source) {
    if (source == fallback.foodSource) return fallback;
    return primary;
  }

  @override
  bool get supportsTextSearch =>
      primary.supportsTextSearch || fallback.supportsTextSearch;

  @override
  Future<ProviderFood?> findByBarcode(
    String barcode, {
    FoodSearchScope scope = FoodSearchScope.anywhereInEnglish,
  }) async {
    NetworkException? primaryNetworkFailure;
    ProviderFood? primaryResult;
    try {
      primaryResult = await primary.findByBarcode(barcode, scope: scope);
    } on NetworkException catch (e) {
      primaryNetworkFailure = e;
    }

    if (primaryNetworkFailure == null && primaryResult != null) {
      return primaryResult;
    }

    try {
      // Primary was unreachable: the fallback's answer is all we have.
      // Primary answered `null` authoritatively: the fallback's answer, if
      // any, is a genuine second opinion either way.
      return await fallback.findByBarcode(barcode, scope: scope);
    } on NetworkException {
      // Primary already gave a real (if empty) answer; the backup being
      // unreachable does not turn that into a failure.
      if (primaryNetworkFailure == null) return null;
      // Neither provider was reachable — surface the primary's failure, not
      // the fallback's.
      throw primaryNetworkFailure;
    }
  }

  /// Routed to the provider that produced [hit] — see
  /// [FoodDataProvider.fetchDetails]. No fallback: an id from one catalogue
  /// means nothing in the other.
  @override
  Future<ProviderFood?> fetchDetails(
    ProviderFoodSummary hit, {
    FoodSearchScope scope = FoodSearchScope.anywhereInEnglish,
  }) => providerFor(hit.source).fetchDetails(hit, scope: scope);

  @override
  Future<List<ProviderFoodSummary>> search(
    String query, {
    int page = 1,
    int pageSize = 20,
    FoodSearchScope scope = FoodSearchScope.anywhereInEnglish,
  }) async {
    if (!primary.supportsTextSearch) {
      return fallback.search(
        query,
        page: page,
        pageSize: pageSize,
        scope: scope,
      );
    }

    NetworkException? primaryNetworkFailure;
    try {
      return await primary.search(
        query,
        page: page,
        pageSize: pageSize,
        scope: scope,
      );
    } on NetworkException catch (e) {
      primaryNetworkFailure = e;
    }

    try {
      return await fallback.search(
        query,
        page: page,
        pageSize: pageSize,
        scope: scope,
      );
    } on NetworkException {
      // Both unreachable — surface the primary's failure, not the
      // fallback's.
      throw primaryNetworkFailure;
    }
  }
}
