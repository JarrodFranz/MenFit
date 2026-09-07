import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:menfit_app/core/errors/app_exception.dart';
import 'package:menfit_app/features/nutrition/data/open_food_facts_mapper.dart';
import 'package:menfit_app/features/nutrition/domain/food.dart';
import 'package:menfit_app/features/nutrition/domain/food_data_provider.dart';
import 'package:menfit_app/features/nutrition/domain/food_search_region.dart';
import 'package:menfit_app/features/nutrition/domain/provider_food.dart';

/// Client version reported in the Open Food Facts User-Agent.
///
/// Kept in step with `pubspec.yaml`'s `version:` by a guard test
/// (`test/features/nutrition/open_food_facts_service_test.dart`) rather
/// than read at runtime: reading it properly needs `package_info_plus`, a
/// new dependency that would have to go through the `package-evaluation`
/// workflow to buy one string.
const String openFoodFactsClientVersion = '0.1.0';

/// [FoodDataProvider] backed by Open Food Facts.
///
/// Verified against live responses on 2026-08-27. Several points below are
/// the opposite of what widely-copied tutorials say — treat this as the
/// contract and check the wire before "correcting" it.
///
/// **Barcode lookup — API v3** (`GET {baseUrl}/api/v3/product/{code}.json`;
/// v2 is formally deprecated). The envelope is
/// `{code, product, result, status, errors, warnings}` where `status` is a
/// **String** that reads `"success"` *or* `"success_with_warnings"` for a
/// found product — testing `== "success"` alone silently loses products.
/// Not found answers HTTP 404 with `result.id == "product_not_found"`, and
/// an unusable code answers HTTP 404 with an `errors[].message.id` of
/// `"invalid_code"`, so this client **branches on the body, not the status
/// code**. The echoed `code` may differ from the requested one (server-side
/// normalisation), so [ProviderFood.barcode] carries the echoed value —
/// anything keyed on a barcode keys on that.
///
/// **Text search — two endpoints, one contract.** Off the web this is
/// **Search-a-licious** (`GET {searchBaseUrl}/search`), which is what Open
/// Food Facts recommends for new integrations and which ranks results
/// better. In a browser it is the **legacy CGI search**
/// (`GET {baseUrl}/cgi/search.pl`), because that is the only text search a
/// browser can reach at all — see [search] for the CORS measurement behind
/// that and for what the legacy endpoint costs us. Which one is used is the
/// `useLegacySearch` constructor flag, not a platform check in here:
/// `domain/` may not import Flutter, so the platform question is asked on
/// the composition surface (`nutrition_providers.dart`) and the answer
/// arrives as a flag.
///
/// **Region and language.** Every request carries the user's food-search
/// language, and every *search* request carries their region as a country
/// filter (`domain/food_search_region.dart`); [search] documents how each
/// endpoint spells them. Nothing about the user goes with it — a country and
/// a language are properties of the shelf being searched, not of the person.
///
/// Either way a hit carries only the handful of indexed nutriments — no
/// iron, no per-serving values, no completeness — hence the separate,
/// smaller [ProviderFoodSummary]. And either way the response is decoded
/// defensively: both endpoints were observed answering HTTP 503 with an
/// **HTML body** under load, so nothing here is handed straight to
/// `jsonDecode`.
///
/// **This class is the wire, not the reading of it.** Endpoints, headers,
/// status/body branching and exception mapping live here; turning a decoded
/// response into a [ProviderFood] lives in `open_food_facts_mapper.dart`,
/// which also documents the nutriment quirks (kilojoule `energy_100g`,
/// plural `proteins_`, iron in grams, int-or-double numbers, `""` for
/// `null`).
///
/// **Rate limits** (per-IP, and for a client-side app that means per
/// end-user): 15 requests/minute for product reads, 10/minute for search.
/// There is deliberately **no throttler here** — the UI makes an online
/// lookup an explicit user action (scan a barcode, press search), never
/// search-as-you-type, and that is the entire reason we stay inside the
/// limits. Anyone tempted to "improve" this into a live-search box has to
/// solve the rate limit first. HTTP 503 is Open Food Facts' global-limit
/// signal and is surfaced as its own retryable condition.
///
/// **Privacy.** No user identifier, no device id, no cookies, no analytics
/// leave this class; the only identifying header is the User-Agent Open
/// Food Facts requires, which identifies the *application*. Exception
/// messages are static — a barcode or a search query is S2 data
/// (`knowledge/engineering/security_and_privacy.md`) and never appears in a
/// message; the original error travels as `cause`.
class OpenFoodFactsService implements FoodDataProvider {
  OpenFoodFactsService({
    required this._dio,
    this._supportsTextSearch = true,
    this._useLegacySearch = false,
    this._baseUrl = defaultBaseUrl,
    this._searchBaseUrl = defaultSearchBaseUrl,
    String contact = '',
    String appName = 'MenFit',
    String appVersion = openFoodFactsClientVersion,
  }) : _userAgent = _buildUserAgent(
         appName: appName,
         appVersion: appVersion,
         contact: contact,
       );

  /// Production Open Food Facts host — see `core/config/env.dart`'s
  /// `offBaseUrl` for why production rather than the `.net` staging server.
  static const String defaultBaseUrl = 'https://world.openfoodfacts.org';

  /// Production Search-a-licious host. Unreachable from a browser (see
  /// [search]), so it goes unused when `useLegacySearch` is set.
  static const String defaultSearchBaseUrl = 'https://search.openfoodfacts.org';

  /// Cuts a product response from roughly 149 KB to under 1 KB (measured).
  /// Image fields are omitted on purpose: product photos are CC-BY-SA, a
  /// stricter licence than the ODbL data, and this app displays none.
  ///
  /// `fields=` is not strictly honoured — extra sibling keys come back
  /// unasked — so nothing here may assume an exact key set.
  ///
  /// `product_name_$languageCode` is asked for by name because Open Food
  /// Facts does **not** localise the plain `product_name` from `lc=` alone;
  /// the per-language field has to be requested and then preferred
  /// (`open_food_facts_mapper.dart`). For an English user this is exactly
  /// the field list this client has always sent.
  static String _productFields(String languageCode) =>
      'code,product_name,product_name_$languageCode,generic_name,brands,lang,'
      'quantity,product_quantity,serving_size,serving_quantity,'
      'serving_quantity_unit,nutrition_data_per,no_nutrition_data,nutriments,'
      'completeness,states_tags';

  /// Everything [ProviderFoodSummary] can hold.
  static String _searchFields(String languageCode) =>
      'code,product_name,product_name_$languageCode,generic_name,brands,lang,'
      'quantity,product_quantity,serving_size,serving_quantity,'
      'serving_quantity_unit,nutriments';

  final Dio _dio;
  final bool _supportsTextSearch;
  final bool _useLegacySearch;
  final String _baseUrl;
  final String _searchBaseUrl;
  final String _userAgent;

  @override
  FoodSource get foodSource => FoodSource.openFoodFacts;

  @override
  String get attributionName => 'Open Food Facts';

  @override
  String get attributionUrl => 'https://openfoodfacts.org';

  @override
  Uri productPageUrl(String barcode) =>
      Uri.parse('$_baseUrl/product/${Uri.encodeComponent(barcode.trim())}');

  @override
  FoodDataProvider providerFor(FoodSource source) => this;

  @override
  bool get supportsTextSearch => _supportsTextSearch;

  /// Looks up one product.
  ///
  /// [scope]'s region is deliberately **not** on this request. A barcode is
  /// a global identifier: the packet in the user's hand is the packet
  /// whether it was catalogued in Australia or Bulgaria, and a
  /// `countries_tags` filter here could only turn a correct answer into
  /// "not found". Its language is used, and only to ask for the right
  /// `product_name_<lc>` field.
  @override
  Future<ProviderFood?> findByBarcode(
    String barcode, {
    FoodSearchScope scope = FoodSearchScope.anywhereInEnglish,
  }) async {
    final code = barcode.trim();
    if (code.isEmpty) throw _invalidCode;

    final body = _decodeObject(
      await _get(
        '$_baseUrl/api/v3/product/${Uri.encodeComponent(code)}.json',
        queryParameters: {'fields': _productFields(scope.languageCode)},
      ),
    );

    // The body decides the outcome, not the HTTP status: both "not found"
    // and "that isn't a barcode" arrive as 404s and mean different things.
    if (_hasErrorId(body['errors'], 'invalid_code')) throw _invalidCode;

    final status = body['status'];
    final product = body['product'];
    final found = status == 'success' || status == 'success_with_warnings';
    if (found && product is Map<String, dynamic>) {
      return parseOpenFoodFactsProduct(
        product,
        echoedCode: jsonText(body['code']) ?? code,
        languageCode: scope.languageCode,
      );
    }
    if (body.containsKey('status') || body.containsKey('result')) {
      // A well-formed v3 envelope without a product: no such product.
      return null;
    }
    throw const NetworkException(
      message: 'Food database returned an unexpected response shape',
    );
  }

  /// Free-text search, served by whichever of the two endpoints the
  /// platform can actually reach.
  ///
  /// ## Why there are two
  ///
  /// `search.openfoodfacts.org` sends **no** `Access-Control-Allow-Origin`
  /// header (re-measured 2026-08-27), so every browser blocks it and no
  /// client-side code can fix that. `world.openfoodfacts.org` — the same
  /// host the product API already uses on web — sends
  /// `Access-Control-Allow-Origin: *`, and it still hosts the **legacy CGI
  /// search**. That is the whole reason this branch exists: it is the only
  /// text search a browser can reach. `/api/v2/search` on the same host is
  /// not a third option; it answers HTTP 503.
  ///
  /// ## What the legacy endpoint costs
  ///
  /// Open Food Facts explicitly discourages `/cgi/search.pl` for new
  /// integrations, and it is the first thing they shed under load — it was
  /// observed answering **HTTP 503 with an HTML body**, which is exactly why
  /// [_decodeObject] guards `jsonDecode` instead of trusting the response.
  /// We use it *only* because the alternative on web is no search at all.
  /// **If Search-a-licious ever sends the CORS header, delete this fallback
  /// rather than keep it** — upstream configures permissive CORS in
  /// `app/api.py` and something at the edge strips it, so this is an
  /// upstream bug we are working around, not a design we chose.
  ///
  /// The **10 requests/minute** search limit applies here as on the other
  /// path, and Open Food Facts says in as many words not to use search for
  /// search-as-you-type. Our UI makes searching an explicit action, which is
  /// the only reason we stay inside the budget — and this is the more
  /// fragile of the two endpoints to spend it on.
  ///
  /// ## Where the two responses differ
  ///
  /// The array is `products` here and `hits` on Search-a-licious, and
  /// `brands` arrives as the product API's **comma-joined String** rather
  /// than as a `List` (`open_food_facts_mapper.dart` reads both). Everything
  /// [ProviderFoodSummary] needs is shaped the same otherwise, so one
  /// mapper serves both. The legacy envelope does carry an exact `count`,
  /// and it is deliberately *not* surfaced: [FoodDataProvider.search]'s
  /// contract is that callers page until a short page, and one endpoint
  /// quietly gaining a total would make that contract platform-dependent.
  /// ## Where the region and the language go
  ///
  /// Open Food Facts is global and unlocalised by default, which is how a
  /// search from Australia came back full of Bulgarian products
  /// (`domain/food_search_region.dart`). Both endpoints take a country
  /// filter and a language, spelled differently:
  ///
  /// - **Search-a-licious** has no separate country parameter. Its `q`
  ///   accepts Lucene field syntax, so the filter is appended to the user's
  ///   words as `countries_tags:"en:australia"`. `lc` and `langs` carry the
  ///   language.
  /// - **The legacy CGI search** takes its filters as the numbered
  ///   `tagtype_N`/`tag_contains_N`/`tag_N` triple the HTML form posts —
  ///   `tagtype_0=countries`, `tag_contains_0=contains`,
  ///   `tag_0=australia`, the tag without its `en:` taxonomy prefix. It has
  ///   no `langs`; `lc` is all it takes.
  ///
  /// [FoodSearchRegion.anywhere] sends no country filter on either path and
  /// still sends the language — that is the pre-region behaviour, kept as a
  /// deliberate choice rather than as a default nobody picked.
  @override
  Future<List<ProviderFoodSummary>> search(
    String query, {
    int page = 1,
    int pageSize = 20,
    FoodSearchScope scope = FoodSearchScope.anywhereInEnglish,
  }) async {
    if (!_supportsTextSearch) {
      throw const ValidationException(
        message: 'Food database text search is unavailable on this platform',
        userMessageKey: 'error.nutrition.searchUnsupported',
      );
    }
    if (page < 1 || pageSize < 1 || pageSize > _maxPageSize) {
      throw const ValidationException(
        message: 'Food database search paging arguments out of range',
      );
    }
    final trimmed = query.trim();
    // A blank query spends a request from a 10/minute budget to learn
    // nothing.
    if (trimmed.isEmpty) return const [];

    final request = _searchRequest(
      trimmed,
      page: page,
      pageSize: pageSize,
      scope: scope,
    );
    final body = _decodeObject(
      await _get(request.url, queryParameters: request.query),
    );

    final entries = body[request.envelopeKey];
    if (entries is! List) {
      throw const NetworkException(
        message: 'Food database returned an unexpected search response shape',
      );
    }
    // Neither endpoint's total is surfaced: Search-a-licious' `count` is a
    // capped estimate (10000 with `is_count_exact: false`) and the legacy
    // one's is exact, and callers page until a short page either way.
    return [
      for (final entry in entries)
        if (entry is Map<String, dynamic>)
          ?parseOpenFoodFactsHit(entry, languageCode: scope.languageCode),
    ];
  }

  /// The endpoint, query and envelope key for one page of [query].
  ///
  /// Both parameter sets are exactly what was measured working and nothing
  /// more — an extra parameter on a search request is how a user identifier
  /// would end up on the wire, so the tests assert these maps whole.
  ({String url, Map<String, dynamic> query, String envelopeKey}) _searchRequest(
    String query, {
    required int page,
    required int pageSize,
    required FoodSearchScope scope,
  }) {
    final language = scope.languageCode;
    final region = scope.region;

    if (_useLegacySearch) {
      // `search_simple=1` + `action=process` is the CGI form's "one search
      // box" mode; `json=1` is what turns the HTML results page into JSON.
      // There is no `langs` equivalent here — `lc` is the whole language
      // story on this endpoint.
      return (
        url: '$_baseUrl/cgi/search.pl',
        query: {
          'search_terms': query,
          'search_simple': 1,
          'action': 'process',
          'json': 1,
          'lc': language,
          if (region.countrySlug case final slug?) ...{
            // The numbered filter triple the CGI form itself posts. `0` is
            // the first (and only) filter slot; a second would be
            // `tagtype_1`. `contains` rather than an exact match because
            // records carry several countries and the field is a list.
            'tagtype_0': 'countries',
            'tag_contains_0': 'contains',
            'tag_0': slug,
          },
          'page': page,
          'page_size': pageSize,
          'fields': _searchFields(language),
        },
        envelopeKey: 'products',
      );
    }
    return (
      url: '$_searchBaseUrl/search',
      query: {
        // Search-a-licious has no country parameter; its `q` is a Lucene
        // query, and a field term appended to the user's words is how a
        // filter is expressed. The user's text is passed through unaltered,
        // exactly as before — this adds a term, it does not rewrite theirs.
        'q': switch (region.countryTag) {
          final tag? => '$query countries_tags:"$tag"',
          null => query,
        },
        'page': page,
        'page_size': pageSize,
        'lc': language,
        'langs': language,
        'fields': _searchFields(language),
      },
      envelopeKey: 'hits',
    );
  }

  static const int _maxPageSize = 100;

  static const ValidationException _invalidCode = ValidationException(
    message: 'The scanned code is not a product barcode',
    userMessageKey: 'error.nutrition.invalidBarcode',
  );

  /// A GET returning the raw body text.
  ///
  /// Requested as plain text rather than as JSON so that an HTML error page
  /// (which Open Food Facts serves for 503s) reaches [_decodeObject] and
  /// becomes a clean [NetworkException] instead of a decoder crash.
  ///
  /// `validateStatus` lets 4xx through because the body is what decides the
  /// outcome: a 404 carries the JSON saying *which* kind of 404 it is. The
  /// one exception is 429, which is a rate-limit signal whose body says
  /// nothing useful — it is failed here so it lands on the retryable
  /// branch below rather than being read as a malformed product response.
  Future<String?> _get(
    String url, {
    required Map<String, dynamic> queryParameters,
  }) async {
    try {
      final response = await _dio.get<String>(
        url,
        queryParameters: queryParameters,
        options: Options(
          responseType: ResponseType.plain,
          validateStatus: (status) =>
              status != null && status < 500 && status != 429,
          headers: {
            // Browsers forbid scripts from setting `User-Agent` and drop it
            // silently; Open Food Facts allows `X-User-Agent` through CORS
            // for exactly that reason, so both are sent with one value.
            'User-Agent': _userAgent,
            'X-User-Agent': _userAgent,
            'Accept': 'application/json',
          },
        ),
      );
      return response.data;
    } on DioException catch (e, st) {
      // Static messages only — `e` (kept as `cause`) carries the request,
      // which contains the barcode or the search query.
      final status = e.response?.statusCode;
      if (e.type == DioExceptionType.badResponse &&
          (status == 503 || status == 429)) {
        throw NetworkException(
          message:
              'Food database is rate limiting or temporarily '
              'unavailable (HTTP $status)',
          userMessageKey: 'error.nutrition.foodDatabaseBusy',
          cause: e,
          stackTrace: st,
        );
      }
      final message = switch (e.type) {
        DioExceptionType.connectionTimeout ||
        DioExceptionType.sendTimeout ||
        DioExceptionType.receiveTimeout => 'Food database request timed out',
        DioExceptionType.badResponse => 'Food database returned HTTP $status',
        _ => 'Food database request failed',
      };
      throw NetworkException(message: message, cause: e, stackTrace: st);
    }
  }

  Map<String, dynamic> _decodeObject(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      throw const NetworkException(
        message: 'Food database returned an empty response',
      );
    }
    final Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } on FormatException catch (e, st) {
      // A `FormatException` must never escape the data layer — an HTML
      // error page is a network failure, not a programming error.
      throw NetworkException(
        message: 'Food database returned a non-JSON response',
        cause: e,
        stackTrace: st,
      );
    }
    if (decoded is! Map<String, dynamic>) {
      throw const NetworkException(
        message: 'Food database returned an unexpected response shape',
      );
    }
    return decoded;
  }

  bool _hasErrorId(Object? errors, String id) {
    if (errors is! List) return false;
    return errors.any((error) {
      if (error is! Map<String, dynamic>) return false;
      final message = error['message'];
      return message is Map<String, dynamic> && message['id'] == id;
    });
  }

  static String _buildUserAgent({
    required String appName,
    required String appVersion,
    required String contact,
  }) {
    // Open Food Facts' required format is `AppName/Version (ContactEmail)`.
    // Without a configured contact the parenthetical is omitted entirely
    // rather than filled with a placeholder — see `core/config/env.dart`'s
    // `offContact`.
    final trimmed = contact.trim();
    final base = '$appName/$appVersion';
    return trimmed.isEmpty ? base : '$base ($trimmed)';
  }
}
