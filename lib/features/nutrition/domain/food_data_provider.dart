import 'package:menfit_app/features/nutrition/domain/food.dart';
import 'package:menfit_app/features/nutrition/domain/food_search_region.dart';
import 'package:menfit_app/features/nutrition/domain/provider_food.dart';

/// Look-up of food products in an external food database ("scan this
/// barcode", "search for porridge oats").
///
/// The abstraction boundary for the external food-data provider (Open Food
/// Facts today — `data/open_food_facts_service.dart`); nothing above the
/// data layer knows which provider is in use, which is what
/// `knowledge/domain/nutrition.md` means by keeping food sourcing
/// source-agnostic.
///
/// Results are [ProviderFood]/[ProviderFoodSummary] **candidates**, never
/// `Food`s: see `domain/provider_food.dart` for why turning one into the
/// other is a decision only the user can make.
///
/// Failures are typed `AppException`s:
/// - `NetworkException` — connectivity, timeout, non-2xx response, or a
///   response this client could not make sense of. A provider under load
///   answers with an HTML error page, so "could not parse" is a network
///   failure here, never a `FormatException` escaping the data layer.
/// - `ValidationException` — a malformed argument, or a code the provider
///   rejects as not a product code at all (see [findByBarcode]).
///
/// Implementations must keep exception messages **static**: a barcode or a
/// search query identifies a specific product a specific person is about to
/// eat (S2, `knowledge/engineering/security_and_privacy.md`), so neither
/// may ever reach a message, a log line, or an analytics event. The
/// original error travels as `AppException.cause` instead.
abstract interface class FoodDataProvider {
  /// The [FoodSource] discriminator for foods produced by this provider.
  FoodSource get foodSource;

  /// Human-readable name of the data source, for the attribution every
  /// screen showing provider data must carry (`'Open Food Facts'`).
  ///
  /// Attribution is a licence obligation, not decoration — Open Food Facts
  /// data is ODbL, which requires attribution wherever the data is used.
  String get attributionName;

  /// Home page of the data source, paired with [attributionName].
  String get attributionUrl;

  /// The provider that produced a result with this [source].
  ///
  /// Single-source providers return `this` — [source] is expected to equal
  /// [foodSource], but nothing here need check that, since a single-source
  /// provider has nothing else to return. Exists so a caller holding a
  /// composite provider (`domain/fallback_food_data_provider.dart`) can
  /// resolve a *specific result's* attribution and product page rather than
  /// always getting the composite's own, which describes both of its
  /// sources at once.
  FoodDataProvider providerFor(FoodSource source);

  /// The provider's public page for [barcode] — where a user is sent to
  /// check, correct, or complete a product's record.
  ///
  /// Part of the contract rather than an implementation detail because
  /// ODbL attribution is satisfied by linking to the specific source
  /// record, and because a crowd-sourced database improves only if the
  /// people using it can reach the thing they want fixed.
  Uri productPageUrl(String barcode);

  /// Whether [search] can work on this platform at all.
  ///
  /// `true` everywhere with the Open Food Facts implementation, including
  /// Flutter Web — the browser-reachable endpoint differs from the native
  /// one, but that is a transport detail entirely inside
  /// `data/open_food_facts_service.dart` and nothing above the data layer
  /// sees it.
  ///
  /// The flag stays on this interface because it is a **provider**
  /// capability rather than a platform one: a future provider may have no
  /// text search at all, or none in a browser, and the UI needs to be able
  /// to ask. It is not a web discriminator, and a provider that answers
  /// `false` should say why in its own doc.
  ///
  /// UI gates on this and hides the search affordance; calling [search]
  /// when this is `false` throws a `ValidationException` rather than
  /// producing a request that is certain to fail.
  bool get supportsTextSearch;

  /// Looks up the product with [barcode].
  ///
  /// Returns `null` when the provider has no such product — a normal,
  /// expected outcome for a crowd-sourced database (the UI offers "add it
  /// yourself"), not an error. Exceptions are reserved for transport and
  /// response-shape failures, per this class's doc.
  ///
  /// Throws a `ValidationException` when [barcode] is blank or the
  /// provider rejects it as not a product code at all — distinct from
  /// "not found", because "that scan didn't read as a barcode" and "we
  /// don't have that product" call for different things from the user.
  ///
  /// [scope]'s **language** is used, its region is not: a barcode is a
  /// global identifier and a product found by one is the product on the
  /// packet in the user's hand, wherever it was catalogued. Filtering that
  /// by country could only turn a correct answer into "not found". The
  /// language still applies, because a found record may hold names in
  /// several and the user should see theirs.
  Future<ProviderFood?> findByBarcode(String barcode, {FoodSearchScope scope});

  /// Fetches a search hit by its provider identity, never by guessed barcode.
  Future<ProviderFood?> fetchDetails(
    ProviderFoodSummary hit, {
    FoodSearchScope scope,
  });

  /// Free-text product search, [pageSize] hits at a time, [page] counting
  /// from 1.
  ///
  /// Returns an empty list for a blank [query] and for any page past the
  /// end of the results, **without** making a request. Callers paginate by
  /// asking for successive pages until one comes back with fewer than
  /// [pageSize] hits: the total-result count providers report is a capped
  /// estimate, so this contract deliberately gives callers no "total" to
  /// render as if it were exact.
  ///
  /// [scope] confines the search to one country's products and asks for
  /// names in one language. It is a **request** parameter, never a filter
  /// applied to the answer: a result the provider returned for the region
  /// asked for is shown as it came, because "this name doesn't look like
  /// their alphabet" is a heuristic that would drop legitimate products
  /// (`domain/food_search_region.dart`).
  ///
  /// Throws a `ValidationException` when [supportsTextSearch] is `false`,
  /// or when [page]/[pageSize] are out of range.
  Future<List<ProviderFoodSummary>> search(
    String query, {
    int page,
    int pageSize,
    FoodSearchScope scope,
  });
}
