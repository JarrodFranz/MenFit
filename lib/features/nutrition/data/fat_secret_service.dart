import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:menfit_app/core/errors/app_exception.dart';
import 'package:menfit_app/features/nutrition/data/fat_secret_mapper.dart';
import 'package:menfit_app/features/nutrition/domain/barcode.dart';
import 'package:menfit_app/features/nutrition/domain/food.dart';
import 'package:menfit_app/features/nutrition/domain/food_data_provider.dart';
import 'package:menfit_app/features/nutrition/domain/food_search_region.dart';
import 'package:menfit_app/features/nutrition/domain/provider_food.dart';

/// [FoodDataProvider] backed by the shared FatSecret proxy.
///
/// No request carries `region` (or `language`): the account is Premier
/// Free, whose dataset is US English only, and `region` on v5 filters
/// results, so a non-US region could return nothing. The search scope's
/// region still applies to Open Food Facts (`knowledge/domain/nutrition.md`).
///
/// [apiBaseUrl] is required and is always the app's FatSecret proxy
/// (`Env.fatSecretProxyUrl`); the app never talks to FatSecret directly,
/// because the client secret lives only on the proxy.
class FatSecretService implements FoodDataProvider {
  FatSecretService({
    required this.dio,
    required this.apiBaseUrl,
    this.proxyApiKey,
    this.mapper = const FatSecretMapper(),
  });

  final Dio dio;
  final String apiBaseUrl;
  final String? proxyApiKey;
  final FatSecretMapper mapper;

  static const ValidationException _invalidCode = ValidationException(
    message: 'The scanned code is not a recognised product barcode.',
  );

  static const ValidationException _invalidPagination = ValidationException(
    message: 'Page numbers count from 1, and page size must be positive.',
  );

  @override
  FoodSource get foodSource => FoodSource.fatSecret;

  @override
  String get attributionName => 'FatSecret';

  @override
  String get attributionUrl => 'https://www.fatsecret.com';

  /// FatSecret's search page for [barcode], or its home page when there is
  /// no barcode to search for — a record reached by its `food_id` from a
  /// search hit has none, and a search for nothing is not a product page.
  @override
  Uri productPageUrl(String barcode) {
    final code = barcode.trim();
    if (code.isEmpty) return Uri.parse(attributionUrl);
    return Uri.parse(
      'https://www.fatsecret.com/calories-nutrition/search?q='
      '${Uri.encodeComponent(code)}',
    );
  }

  @override
  FoodDataProvider providerFor(FoodSource source) => this;

  @override
  bool get supportsTextSearch => true;

  @override
  Future<List<ProviderFoodSummary>> search(
    String query, {
    int page = 1,
    int pageSize = 20,
    FoodSearchScope scope = FoodSearchScope.anywhereInEnglish,
  }) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return const [];
    if (page < 1 || pageSize < 1) throw _invalidPagination;

    // `foods.search.v5` (2026-10-02): every hit carries structured
    // servings - the same shape as `food.get.v5` - so nothing is parsed out
    // of a `food_description` string any more. `flag_default_serving` marks
    // the serving FatSecret considers the default, which the record parser
    // uses as a tie-break (`fat_secret_food_record.dart`).
    final queryParams = <String, dynamic>{
      'method': 'foods.search.v5',
      'search_expression': trimmed,
      'format': 'json',
      'page_number': (page - 1).toString(),
      'max_results': pageSize.toString(),
      'flag_default_serving': 'true',
    };

    // No `region` (2026-10-02). The account is Premier Free, whose dataset
    // is US-only, and on v5 `region` *filters* results: an Australian user
    // asking for `AU` could get nothing at all, and an empty answer is not
    // a network error, so `FallbackFoodDataProvider` would never ask Open
    // Food Facts instead. [scope] still drives Open Food Facts' region.
    final body = await _postApi(queryParams);
    _checkApiError(body);

    return mapper.parseSearchHits(body);
  }

  @override
  Future<ProviderFood?> findByBarcode(
    String barcode, {
    FoodSearchScope scope = FoodSearchScope.anywhereInEnglish,
  }) async {
    final code = barcode.trim();
    if (code.isEmpty) throw _invalidCode;

    // Only a GTIN-shaped code is a barcode (8, 12, 13, 14 digits). Anything
    // else is not a barcode FatSecret could know, which is an authoritative
    // miss here (the composite then asks the backup) — never a `food_id`.
    // Treating non-barcodes as ids is how a search hit's id ended up looked
    // up, and shown, as a barcode (B23); search hits go through
    // [fetchDetails] instead.
    final isDigitsOnly = RegExp(r'^\d+$').hasMatch(code);
    final isBarcodeCandidate =
        isDigitsOnly &&
        (code.length == 12 ||
            code.length == 13 ||
            code.length == 14 ||
            (code.length == 8 && Barcode.tryParse(code) != null));
    if (!isBarcodeCandidate) return null;

    final gtin13 = (code.length == 14 && code.startsWith('0'))
        ? code.substring(1)
        : code.padLeft(13, '0');
    var food = await _findByGtin13(gtin13, barcode: code);

    // An 8-digit barcode can be an EAN-8 (padded with 5 leading zeros) or a
    // zero-suppressed UPC-E whose expanded 13-digit GTIN-13 is different.
    // When the padded EAN-8 misses on FatSecret, retry the expanded UPC-E.
    if (food == null && code.length == 8) {
      final upcE = Barcode.tryParse(code, scannedAs: BarcodeSymbology.upcE);
      if (upcE != null && upcE.digits != gtin13) {
        food = await _findByGtin13(upcE.digits, barcode: code);
      }
    }
    return food;
  }

  /// Fetches the hit's record with `food.get.v5` by its `food_id` — the
  /// path a search hit always takes. `foods.search` states no barcode, so
  /// the result carries none either ([ProviderFood.barcode] `null`).
  @override
  Future<ProviderFood?> fetchDetails(
    ProviderFoodSummary hit, {
    FoodSearchScope scope = FoodSearchScope.anywhereInEnglish,
  }) async {
    final foodId = hit.providerFoodId.trim();
    if (foodId.isEmpty) throw _invalidCode;
    return _getFood(foodId, barcode: hit.barcode);
  }

  /// `food.get.v5` for [foodId]. [barcode] is the real GTIN the record was
  /// reached by, if any — the only thing that may become
  /// [ProviderFood.barcode].
  Future<ProviderFood?> _getFood(
    String foodId, {
    required String? barcode,
  }) async {
    final detailParams = <String, dynamic>{
      'method': 'food.get.v5',
      'food_id': foodId,
      'format': 'json',
    };

    final detailBody = await _postApi(detailParams);
    if (_isFoodNotFoundError(detailBody)) {
      return null;
    }
    _checkApiError(detailBody);

    return mapper.parseFoodDetail(
      detailBody,
      fallbackFoodId: foodId,
      resolvedBarcode: barcode,
    );
  }

  /// `food.find_id_for_barcode.v2` for [gtin13]: the **whole** food record
  /// in one call (v1 answered an id that had to be chained into
  /// `food.get.v5`).
  ///
  /// [barcode] is the code the user scanned or typed, which becomes
  /// [ProviderFood.barcode] so the saved food is found locally by the next
  /// scan of the same packet.
  Future<ProviderFood?> _findByGtin13(
    String gtin13, {
    required String barcode,
  }) async {
    final barcodeLookupParams = <String, dynamic>{
      'method': 'food.find_id_for_barcode.v2',
      'barcode': gtin13,
      'format': 'json',
    };

    // A `NetworkException` here propagates rather than being swallowed:
    // FatSecret being unreachable is a provider outage, not a "no such
    // barcode" answer, and `FallbackFoodDataProvider` needs the real
    // exception to know to try Open Food Facts instead of being told
    // (wrongly) that FatSecret authoritatively has nothing.
    final barcodeBody = await _postApi(barcodeLookupParams);
    if (_isBarcodeNotFoundError(barcodeBody) ||
        _isBarcodeScopeUnavailable(barcodeBody)) {
      // FatSecret answered and has nothing for this barcode (or cannot
      // answer barcodes at all on this account): an authoritative null,
      // which `FallbackFoodDataProvider` turns into a backup lookup
      // WITHOUT marking the primary degraded.
      return null;
    }
    _checkApiError(barcodeBody);
    return mapper.parseFoodDetail(barcodeBody, resolvedBarcode: barcode);
  }

  Future<Map<String, dynamic>> _postApi(
    Map<String, dynamic> params, {
    CancelToken? cancelToken,
  }) async {
    try {
      final headers = <String, String>{};
      if (proxyApiKey != null && proxyApiKey!.isNotEmpty) {
        headers['X-FemFit-Key'] = proxyApiKey!;
      }

      final response = await dio.post<dynamic>(
        apiBaseUrl,
        data: params,
        cancelToken: cancelToken,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: headers,
        ),
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        return data;
      } else if (data is String) {
        // A `FormatException` from a malformed body is caught below; this
        // guards the other failure mode — well-formed JSON that isn't an
        // object (an array, a string, a number) — which an unguarded `as`
        // cast would let escape as a raw `TypeError` instead of the
        // `NetworkException` this interface promises.
        final decoded = jsonDecode(data);
        if (decoded is! Map<String, dynamic>) {
          throw const NetworkException(
            message: 'Unexpected food provider response.',
          );
        }
        return decoded;
      } else {
        throw const NetworkException(
          message: 'Unexpected food provider response.',
        );
      }
    } on DioException catch (e) {
      throw NetworkException(
        message: 'Failed to communicate with food provider.',
        cause: e,
      );
    } on FormatException catch (e) {
      throw NetworkException(
        message: 'Could not parse response from food provider.',
        cause: e,
      );
    }
  }

  void _checkApiError(Map<String, dynamic> body) {
    final error = body['error'];
    if (error is Map<String, dynamic>) {
      final message = error['message']?.toString() ?? '';
      if (message.toLowerCase().contains('invalid ip address')) {
        throw NetworkException(
          message:
              'FatSecret IP restriction error: your IP is not whitelisted.',
          cause: error,
        );
      }
      throw NetworkException(
        message: 'Food provider returned an error response.',
        cause: error,
      );
    }
  }

  /// FatSecret's error code for `food.find_id_for_barcode` genuinely having
  /// no product under the barcode asked for — "No food item detected".
  ///
  /// Confirmed against FatSecret's published error-codes guide
  /// (platform.fatsecret.com/docs/guides/error-codes) and the
  /// `food.find_id_for_barcode` reference page, both checked 2026-09-21: 211
  /// is the only code in FatSecret's table that means "we looked, and there
  /// is no such barcode". Every other code — including **21**, "Invalid IP
  /// address detected", which this method wrongly read as a barcode miss for
  /// four days during the 2026-09-17 outage, and **5**, "Invalid consumer
  /// key" — names a real failure and must reach [_checkApiError] instead of
  /// being swallowed here.
  static const int _barcodeNotFoundCode = 211;

  /// FatSecret's "Missing scope" error code. The proxy requests
  /// `premier barcode`, so code 14 only occurs while the proxy is in its
  /// temporary `basic` fallback: `food.find_id_for_barcode` needs the
  /// `barcode` scope, and without it FatSecret answers every barcode lookup
  /// with code 14 (observed in production 2026-09-22). That
  /// is a capability limit, not an outage: FatSecret is answering, it just
  /// has no barcode data to offer this app. Reading it as a failure made
  /// every barcode scan in build 0.2.0+13 show the false "our main food
  /// database isn't responding" notice.
  static const int _missingScopeCode = 14;

  /// Whether [body] says FatSecret will not answer barcode lookups for this
  /// account at all (see [_missingScopeCode]). Search is unaffected, so the
  /// caller treats this exactly like a barcode miss.
  bool _isBarcodeScopeUnavailable(Map<String, dynamic> body) {
    final error = body['error'];
    if (error is! Map<String, dynamic>) return false;
    final message = error['message']?.toString().toLowerCase() ?? '';
    return error['code'] == _missingScopeCode ||
        message.contains('missing scope');
  }

  /// Whether [body] (a `food.find_id_for_barcode.v2` response) is a genuine
  /// "no such barcode" answer, as opposed to any other error FatSecret
  /// happens to return with the same HTTP 200 status.
  ///
  /// Only [_barcodeNotFoundCode] and a literal barcode-shaped message
  /// (kept as a defensive fallback - it cannot collide with an auth/IP
  /// message's own wording) count as "not found" when an `error` object is
  /// present; every other error reaches [_checkApiError] instead of being
  /// read as a miss. Absent an error, a response with no `food` object is a
  /// miss too (v1 answered a miss with `food_id: 0`, which carries no
  /// `food` either).
  bool _isBarcodeNotFoundError(Map<String, dynamic> body) {
    final error = body['error'];
    if (error is Map<String, dynamic>) {
      final code = error['code'];
      final message = error['message']?.toString().toLowerCase() ?? '';
      return code == _barcodeNotFoundCode ||
          message.contains('no food item detected') ||
          message.contains('barcode not found');
    }
    return body['food'] is! Map<String, dynamic>;
  }

  /// Whether [body] (a `food.get.v5` response) is a genuine "no such food"
  /// answer.
  ///
  /// A miss is either FatSecret's parameter error **106 "Invalid ID"** —
  /// its answer for a `food_id` it does not have, which proves it is
  /// answering — or a response with neither an `error` object nor a `food`
  /// key. Every other `error` code documented for this endpoint is a real
  /// failure (auth, invalid IP, a rate limit) and reaches [_checkApiError],
  /// which throws. (Before 2026-09-21, codes `1` — "An unknown error
  /// occurred" — and `21` — "Invalid IP address detected" — were both
  /// misread as "food not found" here, which is how a four-day FatSecret
  /// outage with revoked credentials went unnoticed: every lookup silently
  /// fell back to Open Food Facts instead of degrading.)
  bool _isFoodNotFoundError(Map<String, dynamic> body) {
    final error = body['error'];
    if (error is Map<String, dynamic>) {
      return error['code'] == _invalidIdCode;
    }
    return body['food'] == null;
  }

  /// FatSecret parameter error "Invalid ID" — the answer for an unknown
  /// `food_id` (platform.fatsecret.com/docs/guides/error-codes).
  static const int _invalidIdCode = 106;
}
