import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:menfit_app/core/errors/error_messages.dart';
import 'package:menfit_app/features/nutrition/data/online_lookup_notice_store.dart';
import 'package:menfit_app/features/nutrition/domain/food.dart';
import 'package:menfit_app/features/nutrition/domain/food_search_ranking.dart';
import 'package:menfit_app/features/nutrition/domain/provider_food.dart';
import 'package:menfit_app/features/nutrition/nutrition_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'online_food_search_controller.freezed.dart';
part 'online_food_search_controller.g.dart';

/// How many hits one page asks for. Also the number that decides the end of
/// the results: a page that comes back with fewer than this was the last
/// one (`domain/food_data_provider.dart#search`).
const int onlineFoodSearchPageSize = 20;

/// Results of a text search against the food database.
@freezed
abstract class OnlineFoodSearchState with _$OnlineFoodSearchState {
  const factory OnlineFoodSearchState({
    @Default(<ProviderFoodSummary>[]) List<ProviderFoodSummary> results,
    @Default(false) bool isSearching,

    /// Whether a search has been run at all in this session — what tells an
    /// empty results list apart from a region nobody has asked anything of
    /// yet.
    @Default(false) bool hasSearched,

    /// Whether a further page is worth asking for. Goes `false` the moment
    /// a short page arrives, which is the provider's only end-of-results
    /// signal.
    @Default(false) bool hasMore,

    /// Ready-to-show copy, never the query itself — S2.
    String? errorMessage,

    /// The query the current results belong to, kept so
    /// [OnlineFoodSearchController.loadMore] pages the same search rather
    /// than whatever is in the field by then.
    @Default('') String query,

    /// Last page fetched; the next request asks for this plus one.
    @Default(0) int page,
  }) = _OnlineFoodSearchState;
}

/// Runs text searches against the food database — **only when asked**.
///
/// ## Never search-as-you-type
///
/// Typing searches the local catalogue and nothing else. Sending a query
/// online is a button press, and there are two independent reasons, either
/// of which alone would settle it:
///
/// 1. **Privacy.** The words a person types into a food search are theirs, and
///    ADR 010 makes sending them an explicit act rather than a side-effect
///    of typing. This is the first feature in the app to send user-typed
///    content off-device at all.
/// 2. **Rate limits.** Open Food Facts documents **10 search requests per
///    minute** per IP, which for a client-side app means per end-user. A
///    live-search box fires one per keystroke and would be blocked within
///    seconds of the first word.
///
/// Anyone "improving" this into a live-search box has to solve the second
/// before arguing about the first
/// (`data/open_food_facts_service.dart` says the same at the wire).
///
/// ## Paging
///
/// One page per explicit request, following the contract's rule: keep asking
/// for successive pages until one comes back with fewer than
/// [onlineFoodSearchPageSize] hits. Eagerly draining every page would burn
/// the whole per-minute budget on a common word, so the next page is a
/// button too. The provider's total count is a **capped estimate** and is
/// deliberately never rendered.
@riverpod
class OnlineFoodSearchController extends _$OnlineFoodSearchController {
  @override
  OnlineFoodSearchState build() => const OnlineFoodSearchState();

  /// Runs [query] as a fresh search, replacing whatever was showing.
  ///
  /// [confirmOnlineLookup] shows the first-run notice; a `false` from it
  /// abandons the search and **nothing is sent**.
  Future<void> search(
    String query, {
    required Future<bool> Function() confirmOnlineLookup,
  }) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty || state.isSearching) return;

    // Consent before anything is sent, and **before** the busy flag: a
    // spinner behind a question the user has not answered yet would be
    // claiming a request is already out.
    //
    // Inside the `try` for a reason that is easy to lose: recording the
    // acknowledgement can fail (`markNoticeSeen` throws when the preference
    // write comes back `false`), and this method is invoked as a
    // `VoidCallback`, so nothing awaits its future. An exception escaping
    // here would reach `PlatformDispatcher.onError` and the user would see
    // *nothing at all* — no spinner, no message, no state change, a button
    // that did not work. `BarcodeLookupController` has always surfaced the
    // same failure; this path was the inconsistent one.
    try {
      final granted = await grantOnlineLookupConsent(
        ref.read(onlineLookupNoticeStoreProvider),
        confirmOnlineLookup,
      );
      if (!granted) {
        // Back to untouched: declining is not a search that returned
        // nothing.
        _set(const OnlineFoodSearchState());
        return;
      }
    } on Object catch (error) {
      _set(OnlineFoodSearchState(errorMessage: userMessageFor(error)));
      return;
    }

    _set(OnlineFoodSearchState(query: trimmed, isSearching: true));
    await _fetchPage(trimmed, 1, const []);
  }

  /// Asks for the next page of the current search.
  ///
  /// The notice is not re-shown: it is a first-run explanation, and by here
  /// the user has already agreed and pressed search.
  Future<void> loadMore() async {
    if (state.isSearching || !state.hasMore || state.query.isEmpty) return;
    final current = state;
    _set(current.copyWith(isSearching: true, errorMessage: null));
    await _fetchPage(current.query, current.page + 1, current.results);
  }

  /// Writes [next] unless this controller has already been disposed — a
  /// search outlives the picker whenever the user backs out mid-request,
  /// and assigning `state` after disposal throws.
  void _set(OnlineFoodSearchState next) {
    if (ref.mounted) state = next;
  }

  /// Empties the region — used when the local query changes underneath it,
  /// so results never sit under a search box that says something else.
  void clear() => _set(const OnlineFoodSearchState());

  /// [query] travels as an argument rather than being re-read off the
  /// state: the state may be gone by the time the response lands.
  Future<void> _fetchPage(
    String query,
    int page,
    List<ProviderFoodSummary> existing,
  ) async {
    try {
      final provider = ref.read(foodDataProviderProvider);
      // Read once and reused for the enrichment fetches below, so a page and
      // the records behind it can never be resolved under two different
      // languages if the preference changes mid-request.
      final scope = ref.read(foodSearchScopeProvider);
      final rawHits = await provider.search(
        query,
        page: page,
        pageSize: onlineFoodSearchPageSize,
        scope: scope,
      );

      // Search index (Search-a-licious) only indexes 100g fields and omits
      // serving sizes. Enrich the hits with actual serving sizes and
      // per-serving macros by checking the local catalogue first, then
      // looking up product records in parallel.
      final nutritionRepo = ref.read(nutritionRepositoryProvider);
      final enrichedHits = await Future.wait(
        rawHits.map((summary) async {
          try {
            final code = summary.barcode;
            final local =
                await nutritionRepo.getFoodByProviderId(
                  summary.source,
                  summary.providerFoodId,
                ) ??
                (code == null
                    ? null
                    : await nutritionRepo.getFoodByBarcode(code));
            if (local != null) {
              return _rebase(
                summary.copyWith(
                  name: local.name,
                  brand: local.brand,
                  servingDescription: local.servingDescription,
                ),
                servingGrams: local.servingGrams,
                servingVolumeMl: local.servingVolumeMl,
                caloriesKcal: local.perServing.caloriesKcal,
                proteinGrams: local.perServing.proteinGrams,
                carbsGrams: local.perServing.carbsGrams,
                fatGrams: local.perServing.fatGrams,
              );
            }
            // Structured FatSecret hits already contain their serving figures.
            if (summary.source == FoodSource.fatSecret &&
                summary.caloriesKcal != null) {
              return summary;
            }
            final product = await provider.fetchDetails(summary, scope: scope);
            if (product == null ||
                (product.providerFoodId ?? product.barcode) !=
                    summary.providerFoodId) {
              return summary;
            }
            return _rebase(
              summary.copyWith(
                name: product.name,
                brand: product.brand,
                servingDescription: product.servingDescription,
              ),
              servingGrams: product.servingGrams,
              servingVolumeMl: product.servingVolumeMl,
              caloriesKcal: product.caloriesKcal,
              proteinGrams: product.proteinGrams,
              carbsGrams: product.carbsGrams,
              fatGrams: product.fatGrams,
            );
          } on Object catch (_) {
            return summary;
          }
        }),
      );

      final rankedFreshHits = filterAndRankFoodSearchResults(
        enrichedHits,
        query: query,
      );

      final existingBarcodes = existing
          .map((e) => (e.source, e.providerFoodId))
          .toSet();
      final fresh = rankedFreshHits
          .where(
            (e) => !existingBarcodes.contains((e.source, e.providerFoodId)),
          )
          .toList();

      _set(
        OnlineFoodSearchState(
          results: [...existing, ...fresh],
          hasSearched: true,
          hasMore: rawHits.length == onlineFoodSearchPageSize,
          query: query,
          page: page,
        ),
      );
    } on Object catch (error) {
      _set(
        OnlineFoodSearchState(
          results: existing,
          hasSearched: true,
          query: query,
          page: page - 1,
          errorMessage: userMessageFor(error),
        ),
      );
    }
  }
}

/// Keeps the numbers and their basis together; never infers mass from volume.
ProviderFoodSummary _rebase(
  ProviderFoodSummary summary, {
  required double? servingGrams,
  required double? servingVolumeMl,
  required double? caloriesKcal,
  required double? proteinGrams,
  required double? carbsGrams,
  required double? fatGrams,
}) {
  final grams =
      servingGrams != null && servingGrams.isFinite && servingGrams > 0
      ? servingGrams
      : null;
  final ml =
      servingVolumeMl != null && servingVolumeMl.isFinite && servingVolumeMl > 0
      ? servingVolumeMl
      : null;
  final divisor = grams ?? ml;
  double? per(double? value) => value == null || !value.isFinite
      ? null
      : divisor == null
      ? value
      : value * 100 / divisor;
  return summary.copyWith(
    servingGrams: grams,
    servingVolumeMl: ml,
    servingCaloriesKcal: caloriesKcal,
    macroBasis: grams != null
        ? SummaryMacroBasis.per100g
        : ml != null
        ? SummaryMacroBasis.per100ml
        : SummaryMacroBasis.perServing,
    caloriesKcal: per(caloriesKcal),
    proteinGrams: per(proteinGrams),
    carbsGrams: per(carbsGrams),
    fatGrams: per(fatGrams),
  );
}
