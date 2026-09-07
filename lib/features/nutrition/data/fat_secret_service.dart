import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:menfit_app/core/errors/app_exception.dart';
import 'package:menfit_app/features/nutrition/data/fat_secret_mapper.dart';
import 'package:menfit_app/features/nutrition/data/fat_secret_token_manager.dart';
import 'package:menfit_app/features/nutrition/domain/barcode.dart';
import 'package:menfit_app/features/nutrition/domain/food.dart';
import 'package:menfit_app/features/nutrition/domain/food_data_provider.dart';
import 'package:menfit_app/features/nutrition/domain/food_search_region.dart';
import 'package:menfit_app/features/nutrition/domain/provider_food.dart';

/// [FoodDataProvider] backed by FatSecret Platform REST API.
class FatSecretService implements FoodDataProvider {
  FatSecretService({
    required this.dio,
    this.tokenManager,
    this.apiBaseUrl = defaultApiBaseUrl,
    this.proxyApiKey,
    this.mapper = const FatSecretMapper(),
  });

  static const String defaultApiBaseUrl =
      'https://platform.fatsecret.com/rest/server.api';

  final Dio dio;
  final FatSecretTokenManager? tokenManager;
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

  @override
  Uri productPageUrl(String barcode) => Uri.parse(
    'https://www.fatsecret.com/calories-nutrition/search?q='
    '${Uri.encodeComponent(barcode.trim())}',
  );

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

    final token = await tokenManager?.getAccessToken();
    final queryParams = <String, dynamic>{
      'method': 'foods.search',
      'search_expression': trimmed,
      'format': 'json',
      'page_number': (page - 1).toString(),
      'max_results': pageSize.toString(),
    };

    final regionCode = _regionCodeFor(scope.region);
    if (regionCode != null) {
      queryParams['region'] = regionCode;
    }

    final body = await _postApi(queryParams, token: token);
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

    final token = await tokenManager?.getAccessToken();

    String? foodId;
    // Check if input looks like a GTIN barcode (8, 12, 13, 14 digits)
    final isDigitsOnly = RegExp(r'^\d+$').hasMatch(code);
    final isBarcodeCandidate =
        isDigitsOnly &&
        (code.length == 12 ||
            code.length == 13 ||
            code.length == 14 ||
            (code.length == 8 && Barcode.tryParse(code) != null));

    if (isBarcodeCandidate) {
      final gtin13 = code.padLeft(13, '0');
      final barcodeLookupParams = <String, dynamic>{
        'method': 'food.find_id_for_barcode',
        'barcode': gtin13,
        'format': 'json',
      };

      // A `NetworkException` here propagates rather than being swallowed:
      // FatSecret being unreachable is a provider outage, not a "no such
      // barcode" answer, and `FallbackFoodDataProvider` needs the real
      // exception to know to try Open Food Facts instead of being told
      // (wrongly) that FatSecret authoritatively has nothing.
      final barcodeBody = await _postApi(barcodeLookupParams, token: token);
      if (!_isBarcodeNotFoundError(barcodeBody)) {
        _checkApiError(barcodeBody);
        foodId = mapper.parseBarcodeToFoodId(barcodeBody);
      }
    }

    // If barcode lookup was not attempted (e.g. food_id) or barcode was not
    // found in FatSecret, try food_id directly (search hits store food_id in
    // barcode).
    foodId ??= code;

    if (foodId.isEmpty) {
      return null;
    }

    final detailParams = <String, dynamic>{
      'method': 'food.get.v5',
      'food_id': foodId,
      'format': 'json',
    };

    final detailBody = await _postApi(detailParams, token: token);
    if (_isFoodNotFoundError(detailBody)) {
      return null;
    }
    _checkApiError(detailBody);

    return mapper.parseFoodDetail(detailBody, fallbackBarcode: code);
  }

  Future<Map<String, dynamic>> _postApi(
    Map<String, dynamic> params, {
    String? token,
  }) async {
    try {
      final headers = <String, String>{};
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
      if (proxyApiKey != null && proxyApiKey!.isNotEmpty) {
        headers['X-MenFit-Key'] = proxyApiKey!;
      }

      final response = await dio.post<dynamic>(
        apiBaseUrl,
        data: params,
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

  bool _isBarcodeNotFoundError(Map<String, dynamic> body) {
    final error = body['error'];
    if (error is Map<String, dynamic>) {
      final code = error['code'];
      final message = error['message']?.toString().toLowerCase() ?? '';
      if (code == 21 ||
          message.contains('barcode not found') ||
          message.contains('invalid barcode')) {
        return true;
      }
    }
    final foodId = body['food_id'];
    if (foodId == null || foodId == '0' || foodId == '') return true;
    return false;
  }

  bool _isFoodNotFoundError(Map<String, dynamic> body) {
    final error = body['error'];
    if (error is Map<String, dynamic>) {
      final code = error['code'];
      final message = error['message']?.toString().toLowerCase() ?? '';
      if (code == 1 ||
          code == 21 ||
          message.contains('food not found') ||
          message.contains('invalid food id')) {
        return true;
      }
    }
    return body['food'] == null;
  }

  String? _regionCodeFor(FoodSearchRegion region) {
    return switch (region) {
      FoodSearchRegion.australia => 'AU',
      FoodSearchRegion.newZealand => 'NZ',
      FoodSearchRegion.unitedKingdom => 'GB',
      FoodSearchRegion.unitedStates => 'US',
      FoodSearchRegion.canada => 'CA',
      FoodSearchRegion.ireland => 'IE',
      FoodSearchRegion.anywhere => null,
    };
  }
}
