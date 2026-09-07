import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/errors/app_exception.dart';
import 'package:menfit_app/features/nutrition/data/open_food_facts_service.dart';
import 'package:menfit_app/features/nutrition/domain/food_search_region.dart';
import 'package:menfit_app/features/nutrition/domain/provider_food.dart';

/// Scripted [HttpClientAdapter]: every request is recorded and the response
/// (or thrown [DioException]) comes from [onRequest]. NO real network I/O
/// anywhere in this file - dio never gets past this adapter.
class _ScriptedAdapter implements HttpClientAdapter {
  _ScriptedAdapter(this.onRequest);

  final Future<ResponseBody> Function(RequestOptions options) onRequest;

  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return onRequest(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _jsonResponse(String body, {int status = 200}) {
  return ResponseBody.fromString(
    body,
    status,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

/// Open Food Facts answers a global rate limit with an HTML error page, not
/// with JSON - the case that turns a naive client's `jsonDecode` into a
/// `FormatException`.
ResponseBody _htmlResponse(String body, {int status = 503}) {
  return ResponseBody.fromString(
    body,
    status,
    headers: {
      Headers.contentTypeHeader: ['text/html'],
    },
  );
}

const String _serviceUnavailableHtml =
    '<html><head><title>503 Service Unavailable</title></head> '
    '<body><h1>503 Service Unavailable</h1><hr><center>nginx</center> '
    '</body></html>';

const String _cheeriosCode = '0016000275270';

/// A live-shaped product record (Honey Nut Cheerios, captured 2026-08-27),
/// including the traps: `product_quantity`/`completeness` as ints, an empty
/// string where another API would use null, a kilojoule `energy_100g`
/// sitting next to the kcal keys, a comma-joined `brands` string, a
/// duplicated malformed `serving_size`, and a `serving_quantity_unit` of
/// "ml" on a dry breakfast cereal.
Map<String, dynamic> _cheeriosProduct() => {
  'code': _cheeriosCode,
  'product_name': 'Honey Nut Cheerios',
  'product_name_en': 'Honey Nut Cheerios',
  'generic_name': '',
  'brands': 'Cheerios,General Mills',
  'lang': 'en',
  'quantity': '',
  'product_quantity': 450,
  'serving_size': '3/4 cup (28 g) (28 g)',
  'serving_quantity': 28,
  'serving_quantity_unit': 'ml',
  'nutrition_data_per': 'serving',
  'no_nutrition_data': '',
  'completeness': 1,
  'states_tags': ['en:nutrition-facts-completed', 'en:photos-uploaded'],
  'nutriments': {
    'energy_100g': 1601,
    'energy-kcal_100g': 382,
    'energy-kcal_serving': 107,
    'proteins_100g': 7.14,
    'proteins_serving': 2,
    'carbohydrates_100g': 78.6,
    'carbohydrates_serving': 22,
    'fat_100g': 5.36,
    'fat_serving': 1.5,
    'iron_100g': 0.01607,
    'iron_serving': 0.0045,
    'salt_100g': 0.75,
    'sodium_100g': 0.3,
    'sugars_100g': 39.3,
  },
};

/// The API v3 envelope. `status` is a String, and BOTH "success" and
/// "success_with_warnings" mean found.
String _productEnvelope({
  Map<String, dynamic>? product,
  String status = 'success',
}) {
  return jsonEncode({
    'code': _cheeriosCode,
    'errors': <dynamic>[],
    'result': {'id': 'product_found', 'lc_name': 'en', 'name': 'Product found'},
    'status': status,
    'warnings': <dynamic>[],
    'product': product ?? _cheeriosProduct(),
  });
}

String _notFoundEnvelope(String code) {
  return jsonEncode({
    'code': code,
    'errors': <dynamic>[],
    'result': {
      'id': 'product_not_found',
      'lc_name': 'en',
      'name': 'Product not found',
    },
    'status': 'failure',
    'warnings': <dynamic>[],
  });
}

String _invalidCodeEnvelope(String code) {
  return jsonEncode({
    'code': code,
    'errors': [
      {
        'field': {'id': 'code', 'value': code},
        'impact': {'id': 'failure', 'lc_name': 'en', 'name': 'Failure'},
        'message': {'id': 'invalid_code', 'lc_name': 'en', 'name': 'Invalid'},
      },
    ],
    'result': {
      'id': 'product_not_found',
      'lc_name': 'en',
      'name': 'Product not found',
    },
    'status': 'failure',
    'warnings': <dynamic>[],
  });
}

/// A Search-a-licious response. `count` is a capped estimate paired with
/// `is_count_exact: false` - `page_count` is the only honest pagination
/// signal.
String _searchEnvelope({
  List<Map<String, dynamic>>? hits,
  int page = 1,
  int pageSize = 20,
  int pageCount = 1,
}) {
  return jsonEncode({
    'hits': hits ?? [_nutellaHit()],
    'aggregations': <String, dynamic>{},
    'page': page,
    'page_size': pageSize,
    'page_count': pageCount,
    'count': 10000,
    'is_count_exact': false,
    'timed_out': false,
    'took': 12,
    'warnings': null,
  });
}

/// A legacy CGI search response (`/cgi/search.pl` on the product API's own
/// host), shaped from a live probe on 2026-08-27. This is what a browser
/// gets, because Search-a-licious sends no CORS header.
///
/// Three differences from [_searchEnvelope] that the parser has to survive:
/// the array is **`products`**, not `hits`; `count` is present and exact
/// (680, not a capped estimate); and `page_count` counts the products on
/// this page rather than the pages in the result set. None of the three is
/// surfaced - callers page until a short page on both endpoints.
String _legacySearchEnvelope({
  List<Map<String, dynamic>>? products,
  int page = 1,
  int pageSize = 20,
  int count = 680,
}) {
  final entries = products ?? [_miloProduct()];
  return jsonEncode({
    'count': count,
    'page': page,
    'page_count': entries.length,
    'page_size': pageSize,
    'products': entries,
    'skip': (page - 1) * pageSize,
  });
}

/// A live-shaped legacy CGI result. Same record shape as a
/// Search-a-licious hit except for `brands`, which arrives here as the
/// product API's comma-joined String because the CGI endpoint shares that
/// serialiser.
Map<String, dynamic> _miloProduct() => {
  'code': '6111068000254',
  'product_name': 'Milo',
  'brands': 'Milo,Nestlé',
  'nutriments': {
    'carbohydrates_100g': 73.5,
    'energy_100g': 1650,
    'energy-kcal_100g': 394,
    'fat_100g': 8.5,
    'proteins_100g': 8.2,
    'salt_100g': 0.42,
    'sugars_100g': 45.6,
  },
};

/// A live-shaped search hit: exactly the seven indexed nutriments, all per
/// 100 g. No iron, no `_serving`, no completeness - and `brands` is a LIST
/// here while it is a comma-joined String on the product API.
Map<String, dynamic> _nutellaHit() => {
  'code': '3017620422003',
  'product_name': 'Nutella',
  'brands': ['Nutella', 'Ferrero'],
  'nutriments': {
    'carbohydrates_100g': 57.5,
    'energy-kcal_100g': 539,
    'fat_100g': 30.9,
    'proteins_100g': 6.3,
    'salt_100g': 0.107,
    'sodium_100g': 0.0428,
    'sugars_100g': 56.3,
  },
};

void main() {
  (OpenFoodFactsService, _ScriptedAdapter) buildService(
    Future<ResponseBody> Function(RequestOptions) onRequest, {
    String contact = '',
    bool supportsTextSearch = true,
    bool useLegacySearch = false,
  }) {
    final adapter = _ScriptedAdapter(onRequest);
    final dio = Dio()..httpClientAdapter = adapter;
    return (
      OpenFoodFactsService(
        dio: dio,
        contact: contact,
        supportsTextSearch: supportsTextSearch,
        useLegacySearch: useLegacySearch,
      ),
      adapter,
    );
  }

  /// The service as the composition surface builds it **in a browser**:
  /// `useLegacySearch: kIsWeb`. Barcode lookup is identical either way; only
  /// the search endpoint moves.
  (OpenFoodFactsService, _ScriptedAdapter) buildWebService(
    Future<ResponseBody> Function(RequestOptions) onRequest,
  ) {
    return buildService(onRequest, useLegacySearch: true);
  }

  (OpenFoodFactsService, _ScriptedAdapter) serviceReturning(
    String body, {
    int status = 200,
  }) {
    return buildService(
      (options) async => _jsonResponse(body, status: status),
    );
  }

  group('findByBarcode - the v3 envelope', () {
    for (final status in ['success', 'success_with_warnings']) {
      test('status "$status" means found', () async {
        final (service, _) = serviceReturning(
          _productEnvelope(status: status),
        );

        final food = await service.findByBarcode(_cheeriosCode);

        expect(food, isNotNull, reason: '"$status" is a found product');
        expect(food!.name, 'Honey Nut Cheerios');
      });
    }

    test(
      'requests API v3 with the trimmed field list and nothing else',
      () async {
        final (service, adapter) = serviceReturning(_productEnvelope());

        await service.findByBarcode(' $_cheeriosCode ');

        final request = adapter.requests.single;
        expect(request.method, 'GET');
        expect(
          request.uri.path,
          '/api/v3/product/$_cheeriosCode.json',
          reason: 'v2 is deprecated; the code is trimmed before it is used',
        );
        expect(request.uri.host, 'world.openfoodfacts.org');
        // Asserted as a whole map: an extra query parameter is how a user
        // identifier would accidentally end up on the wire.
        expect(request.queryParameters, {
          'fields':
              'code,product_name,product_name_en,generic_name,brands,lang,'
              'quantity,product_quantity,serving_size,serving_quantity,'
              'serving_quantity_unit,nutrition_data_per,no_nutrition_data,'
              'nutriments,completeness,states_tags',
        });
        expect(
          request.queryParameters.toString(),
          isNot(contains('image')),
          reason: 'product images are CC-BY-SA and we display none',
        );
      },
    );

    test('HTTP 404 with product_not_found is null, not an exception', () async {
      final (service, _) = serviceReturning(
        _notFoundEnvelope('0000000000000'),
        status: 404,
      );

      expect(await service.findByBarcode('0000000000000'), isNull);
    });

    test('HTTP 404 with invalid_code is a ValidationException, distinct '
        'from not-found', () async {
      final (service, _) = serviceReturning(
        _invalidCodeEnvelope('not-a-barcode'),
        status: 404,
      );

      await expectLater(
        service.findByBarcode('not-a-barcode'),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.userMessageKey,
            'userMessageKey',
            'error.nutrition.invalidBarcode',
          ),
        ),
      );
    });

    test('a blank barcode never reaches the network', () async {
      final (service, adapter) = buildService(
        (options) async => fail('must not hit the network'),
      );

      await expectLater(
        service.findByBarcode('   '),
        throwsA(isA<ValidationException>()),
      );
      expect(adapter.requests, isEmpty);
    });

    test('the barcode is keyed on the code the server echoed back, not the '
        'one we asked for', () async {
      final (service, _) = serviceReturning(_productEnvelope());

      // Server-side normalisation: an EAN-12 scan comes back zero-padded.
      final food = await service.findByBarcode('16000275270');

      expect(food!.barcode, _cheeriosCode);
    });
  });

  group('nutriment mapping', () {
    test('iron is converted from grams to milligrams (per serving)', () async {
      final (service, _) = serviceReturning(_productEnvelope());

      final food = await service.findByBarcode(_cheeriosCode);

      // iron_serving 0.0045 g -> 4.5 mg for a 28 g serving (live values).
      expect(food!.ironMg, closeTo(4.5, 1e-9));
      expect(food.hasIron, isTrue);
    });

    test('iron is converted from grams to milligrams (per 100 g)', () async {
      final product = _cheeriosProduct()
        ..remove('serving_size')
        ..remove('serving_quantity')
        ..['nutriments'] = {
          'energy-kcal_100g': 382,
          'proteins_100g': 7.14,
          'carbohydrates_100g': 78.6,
          'fat_100g': 5.36,
          'iron_100g': 0.01607,
        };
      final (service, _) = serviceReturning(
        _productEnvelope(product: product),
      );

      final food = await service.findByBarcode(_cheeriosCode);

      // iron_100g 0.01607 g -> 16.07 mg per 100 g (live value).
      expect(food!.ironMg, closeTo(16.07, 1e-9));
      expect(food.servingBasis, ServingBasis.per100g);
    });

    test('per-serving values are preferred over per-100 g ones', () async {
      final (service, _) = serviceReturning(_productEnvelope());

      final food = await service.findByBarcode(_cheeriosCode);

      expect(food!.servingBasis, ServingBasis.statedPerServing);
      expect(food.caloriesKcal, 107);
      expect(food.proteinGrams, 2);
      expect(food.carbsGrams, 22);
      expect(food.fatGrams, 1.5);
      expect(food.hasCompleteMacros, isTrue);
    });

    test('energy_100g is kilojoules: calories stay null when the kcal key '
        'is missing', () async {
      final product = _cheeriosProduct()
        ..['nutriments'] = {
          'energy_100g': 1601,
          'energy': 1601,
          'proteins_100g': 7.14,
        };
      final (service, _) = serviceReturning(
        _productEnvelope(product: product),
      );

      final food = await service.findByBarcode(_cheeriosCode);

      expect(
        food!.caloriesKcal,
        isNull,
        reason: '1601 kJ must never be reported as 1601 kcal',
      );
      // Protein still comes through, scaled to the 28 g serving this fixture
      // declares (7.14 g/100 g -> 1.9992 g/serving) - a missing energy key
      // must not take the rest of the nutriments down with it.
      expect(food.servingBasis, ServingBasis.derivedFromPer100g);
      expect(food.proteinGrams, closeTo(1.9992, 1e-9));
    });

    test('missing nutriments stay null - never zero', () async {
      final product = _cheeriosProduct()..['nutriments'] = <String, dynamic>{};
      final (service, _) = serviceReturning(
        _productEnvelope(product: product),
      );

      final food = await service.findByBarcode(_cheeriosCode);

      // A gap in a crowd-sourced database is not a claim about the food.
      expect(food!.caloriesKcal, isNull);
      expect(food.proteinGrams, isNull);
      expect(food.carbsGrams, isNull);
      expect(food.fatGrams, isNull);
      expect(food.ironMg, isNull);
      expect(food.hasCompleteMacros, isFalse);
      expect(food.hasIron, isFalse);
    });

    test(
      'the singular "protein_100g" key is not read (it does not exist)',
      () async {
        final product = _cheeriosProduct()
          ..['nutriments'] = {'protein_100g': 7.14};
        final (service, _) = serviceReturning(
          _productEnvelope(product: product),
        );

        final food = await service.findByBarcode(_cheeriosCode);

        expect(food!.proteinGrams, isNull);
      },
    );

    test('the raw _value/_unit pair is never used for arithmetic', () async {
      final product = _cheeriosProduct()
        ..['nutriments'] = {
          'iron_value': 4.5,
          'iron_unit': 'mg',
          'energy-kcal_value': 107,
        };
      final (service, _) = serviceReturning(
        _productEnvelope(product: product),
      );

      final food = await service.findByBarcode(_cheeriosCode);

      expect(food!.ironMg, isNull);
      expect(food.caloriesKcal, isNull);
    });
  });

  group('int-vs-double JSON numbers', () {
    test('completeness as an int (1) does not crash the cast', () async {
      final (service, _) = serviceReturning(_productEnvelope());

      final food = await service.findByBarcode(_cheeriosCode);

      expect(food!.completeness, 1.0);
    });

    test('completeness as a double (0.7875) parses too', () async {
      final product = _cheeriosProduct()
        ..['completeness'] = 0.7875
        ..['product_quantity'] = 368.543800625;
      final (service, _) = serviceReturning(
        _productEnvelope(product: product),
      );

      final food = await service.findByBarcode(_cheeriosCode);

      expect(food!.completeness, 0.7875);
    });
  });

  group('serving basis', () {
    test('statedPerServing keeps the provider serving text verbatim', () async {
      final (service, _) = serviceReturning(_productEnvelope());

      final food = await service.findByBarcode(_cheeriosCode);

      expect(food!.servingBasis, ServingBasis.statedPerServing);
      expect(
        food.servingDescription,
        '3/4 cup (28 g) (28 g)',
        reason: 'serving_size is displayed, never parsed or tidied',
      );
      expect(
        food.servingGrams,
        28,
        reason:
            'serving_quantity_unit says "ml" and is wrong; it is not '
            'consulted',
      );
    });

    test('derivedFromPer100g scales the per-100 g numbers by the serving '
        'weight', () async {
      final product = _cheeriosProduct()
        ..['serving_quantity'] = 50
        ..['serving_size'] = '50 g'
        ..['nutriments'] = {
          'energy-kcal_100g': 382,
          'proteins_100g': 7.14,
          'carbohydrates_100g': 78.6,
          'fat_100g': 5.36,
          'iron_100g': 0.01607,
        };
      final (service, _) = serviceReturning(
        _productEnvelope(product: product),
      );

      final food = await service.findByBarcode(_cheeriosCode);

      expect(food!.servingBasis, ServingBasis.derivedFromPer100g);
      expect(food.servingGrams, 50);
      expect(food.caloriesKcal, closeTo(191, 1e-9));
      expect(food.ironMg, closeTo(8.035, 1e-9));
    });

    test('per100g says so in the serving description', () async {
      final product = _cheeriosProduct()
        ..remove('serving_size')
        ..remove('serving_quantity')
        ..['nutriments'] = {'energy-kcal_100g': 382};
      final (service, _) = serviceReturning(
        _productEnvelope(product: product),
      );

      final food = await service.findByBarcode(_cheeriosCode);

      expect(food!.servingBasis, ServingBasis.per100g);
      expect(food.servingDescription, '100 g');
      expect(food.servingGrams, 100);
      expect(food.caloriesKcal, 382);
    });

    test('an absent serving_size falls back to the gram weight, not to a '
        'parsed guess', () async {
      final product = _cheeriosProduct()..remove('serving_size');
      final (service, _) = serviceReturning(
        _productEnvelope(product: product),
      );

      final food = await service.findByBarcode(_cheeriosCode);

      expect(food!.servingDescription, '28 g');
    });

    test('a record with no nutriments at all keeps the serving the provider '
        'did state', () async {
      final product = _cheeriosProduct()..['nutriments'] = <String, dynamic>{};
      final (service, _) = serviceReturning(
        _productEnvelope(product: product),
      );

      final food = await service.findByBarcode(_cheeriosCode);

      // serving_size and serving_quantity are still there. Falling back to
      // 100 g would throw away a weight the provider supplied and then tell
      // the user on the review screen that there was no serving size to
      // work from - and they would have to retype what was already known.
      expect(food!.servingGrams, 28);
      expect(food.servingDescription, '3/4 cup (28 g) (28 g)');
      expect(food.servingBasis, isNot(ServingBasis.per100g));
      // The numbers really are all absent, and stay absent.
      expect(food.caloriesKcal, isNull);
      expect(food.ironMg, isNull);
    });

    test('a record with neither nutriments nor a serving really is per '
        '100 g', () async {
      final product = _cheeriosProduct()
        ..remove('serving_size')
        ..remove('serving_quantity')
        ..['nutriments'] = <String, dynamic>{};
      final (service, _) = serviceReturning(
        _productEnvelope(product: product),
      );

      final food = await service.findByBarcode(_cheeriosCode);

      // Here the "no serving size to work from" line is simply true.
      expect(food!.servingBasis, ServingBasis.per100g);
      expect(food.servingDescription, '100 g');
      expect(food.servingGrams, 100);
    });

    test('an implausible serving weight is treated as absent', () async {
      final product = _cheeriosProduct()
        ..['serving_quantity'] = 999999
        ..remove('serving_size')
        ..['nutriments'] = {'energy-kcal_100g': 382};
      final (service, _) = serviceReturning(
        _productEnvelope(product: product),
      );

      final food = await service.findByBarcode(_cheeriosCode);

      expect(food!.servingBasis, ServingBasis.per100g);
      expect(food.servingGrams, 100);
    });
  });

  group('name, brand and quality signals', () {
    test('an empty product_name falls through to generic_name', () async {
      final product = _cheeriosProduct()
        ..['product_name_en'] = ''
        ..['product_name'] = '   '
        ..['generic_name'] = 'Toasted whole grain oat cereal';
      final (service, _) = serviceReturning(
        _productEnvelope(product: product),
      );

      final food = await service.findByBarcode(_cheeriosCode);

      expect(
        food!.name,
        'Toasted whole grain oat cereal',
        reason: 'empty strings stand in for nulls; ?? does not catch them',
      );
    });

    test('with no usable name at all, the barcode is the name', () async {
      final product = _cheeriosProduct()
        ..['product_name_en'] = ''
        ..['product_name'] = ''
        ..['generic_name'] = '';
      final (service, _) = serviceReturning(
        _productEnvelope(product: product),
      );

      final food = await service.findByBarcode(_cheeriosCode);

      expect(food!.name, _cheeriosCode);
    });

    test('product_name_en wins over product_name', () async {
      final product = _cheeriosProduct()
        ..['product_name'] = 'Cheerios Miel et Noix'
        ..['product_name_en'] = 'Honey Nut Cheerios';
      final (service, _) = serviceReturning(
        _productEnvelope(product: product),
      );

      final food = await service.findByBarcode(_cheeriosCode);

      expect(food!.name, 'Honey Nut Cheerios');
    });

    test('brands as a comma-joined String yields the primary brand', () async {
      final (service, _) = serviceReturning(_productEnvelope());

      final food = await service.findByBarcode(_cheeriosCode);

      expect(food!.brand, 'Cheerios');
      expect(food.displayName, 'Honey Nut Cheerios · Cheerios');
    });

    test('an empty brands string is no brand, not an empty one', () async {
      final product = _cheeriosProduct()..['brands'] = '';
      final (service, _) = serviceReturning(
        _productEnvelope(product: product),
      );

      final food = await service.findByBarcode(_cheeriosCode);

      expect(food!.brand, isNull);
      expect(food.displayName, 'Honey Nut Cheerios');
    });

    test('states_tags drives hasCompleteNutritionFacts', () async {
      final (service, _) = serviceReturning(_productEnvelope());
      final complete = await service.findByBarcode(_cheeriosCode);
      expect(complete!.hasCompleteNutritionFacts, isTrue);

      final product = _cheeriosProduct()
        ..['states_tags'] = ['en:nutrition-facts-to-be-completed'];
      final (other, _) = serviceReturning(
        _productEnvelope(product: product),
      );
      final incomplete = await other.findByBarcode(_cheeriosCode);
      expect(incomplete!.hasCompleteNutritionFacts, isFalse);
    });

    test('no_nutrition_data is the STRING "on", not a bool', () async {
      for (final raw in <Object>['on', true, '1']) {
        final product = _cheeriosProduct()..['no_nutrition_data'] = raw;
        final (service, _) = serviceReturning(
          _productEnvelope(product: product),
        );

        final food = await service.findByBarcode(_cheeriosCode);

        expect(food!.hasNoNutritionData, isTrue, reason: 'raw value: $raw');
      }

      final (service, _) = serviceReturning(_productEnvelope());
      final food = await service.findByBarcode(_cheeriosCode);
      expect(food!.hasNoNutritionData, isFalse);
    });
  });

  group('failures', () {
    test('HTTP 503 with an HTML body is a NetworkException, never a '
        'FormatException', () async {
      final (service, _) = buildService(
        (options) async => _htmlResponse(_serviceUnavailableHtml),
      );

      await expectLater(
        service.findByBarcode(_cheeriosCode),
        throwsA(
          isA<NetworkException>()
              .having(
                (e) => e.userMessageKey,
                'userMessageKey',
                'error.nutrition.foodDatabaseBusy',
              )
              .having((e) => e.message, 'message', contains('503')),
        ),
      );
    });

    test('HTTP 429 is surfaced as the same retryable condition', () async {
      final (service, _) = buildService(
        (options) async => _jsonResponse('{}', status: 429),
      );

      await expectLater(
        service.findByBarcode(_cheeriosCode),
        throwsA(
          isA<NetworkException>().having(
            (e) => e.userMessageKey,
            'userMessageKey',
            'error.nutrition.foodDatabaseBusy',
          ),
        ),
      );
    });

    test('a 200 with a non-JSON body is a NetworkException', () async {
      final (service, _) = buildService(
        (options) async => _htmlResponse(_serviceUnavailableHtml, status: 200),
      );

      await expectLater(
        service.findByBarcode(_cheeriosCode),
        throwsA(
          isA<NetworkException>().having(
            (e) => e.message,
            'message',
            'Food database returned a non-JSON response',
          ),
        ),
      );
    });

    test('truncated JSON is a NetworkException', () async {
      final (service, _) = serviceReturning('{"code": "001600027527');

      await expectLater(
        service.findByBarcode(_cheeriosCode),
        throwsA(isA<NetworkException>()),
      );
    });

    test(
      'a JSON array where an object belongs is a NetworkException',
      () async {
        final (service, _) = serviceReturning('[]');

        await expectLater(
          service.findByBarcode(_cheeriosCode),
          throwsA(isA<NetworkException>()),
        );
      },
    );

    test('an empty body is a NetworkException', () async {
      final (service, _) = serviceReturning('');

      await expectLater(
        service.findByBarcode(_cheeriosCode),
        throwsA(isA<NetworkException>()),
      );
    });

    test(
      'a body that is JSON but not a v3 envelope is a NetworkException',
      () async {
        final (service, _) = serviceReturning('{"hello": "world"}');

        await expectLater(
          service.findByBarcode(_cheeriosCode),
          throwsA(isA<NetworkException>()),
        );
      },
    );

    test('a timeout is a NetworkException with a static message', () async {
      final (service, _) = buildService(
        (options) async => throw DioException.connectionTimeout(
          requestOptions: options,
          timeout: const Duration(seconds: 10),
        ),
      );

      await expectLater(
        service.findByBarcode(_cheeriosCode),
        throwsA(
          isA<NetworkException>().having(
            (e) => e.message,
            'message',
            'Food database request timed out',
          ),
        ),
      );
    });

    test('an offline connection error is a NetworkException', () async {
      final (service, _) = buildService(
        (options) async => throw DioException.connectionError(
          requestOptions: options,
          reason: 'failed host lookup',
        ),
      );

      await expectLater(
        service.findByBarcode(_cheeriosCode),
        throwsA(isA<NetworkException>()),
      );
    });
  });

  group('privacy: no barcode or query in any exception message', () {
    // A test rather than a comment because this is exactly the kind of rule
    // that rots silently: a helpful "couldn't find 5449000000996" in an
    // error message is an S2 leak into every log sink that ever handles it
    // (`knowledge/engineering/security_and_privacy.md`).
    const barcode = '5449000000996';
    const query = 'chocolate digestives';

    final failures = <String, Future<ResponseBody> Function(RequestOptions)>{
      'HTTP 503 (HTML)': (options) async =>
          _htmlResponse(_serviceUnavailableHtml),
      'HTTP 500': (options) async => _jsonResponse('{}', status: 500),
      'HTTP 401': (options) async => _jsonResponse('{}', status: 401),
      'non-JSON 200': (options) async =>
          _htmlResponse('<html>$barcode $query</html>', status: 200),
      'unexpected shape': (options) async => _jsonResponse('{"a": 1}'),
      'timeout': (options) async => throw DioException.receiveTimeout(
        requestOptions: options,
        timeout: const Duration(seconds: 20),
      ),
      'invalid code': (options) async =>
          _jsonResponse(_invalidCodeEnvelope(barcode), status: 404),
    };

    void expectNoLeak(AppException error) {
      expect(error.message, isNot(contains(barcode)));
      expect(error.message, isNot(contains(query)));
      expect(error.toString(), isNot(contains(barcode)));
      expect(error.toString(), isNot(contains(query)));
    }

    for (final entry in failures.entries) {
      test('findByBarcode / ${entry.key}', () async {
        final (service, _) = buildService(entry.value);

        try {
          await service.findByBarcode(barcode);
          fail('expected a failure for ${entry.key}');
        } on AppException catch (e) {
          expectNoLeak(e);
        }
      });

      test('search / ${entry.key}', () async {
        final (service, _) = buildService(entry.value);

        try {
          await service.search(query);
          fail('expected a failure for ${entry.key}');
        } on AppException catch (e) {
          expectNoLeak(e);
        }
      });

      // The legacy CGI path puts the query in a *different* query
      // parameter (`search_terms`, not `q`) on a different host, so it is
      // its own chance to leak one into a message.
      test('search on the legacy CGI path / ${entry.key}', () async {
        final (service, _) = buildWebService(entry.value);

        try {
          await service.search(query);
          fail('expected a failure for ${entry.key}');
        } on AppException catch (e) {
          expectNoLeak(e);
        }
      });
    }
  });

  group('User-Agent', () {
    test('both User-Agent and X-User-Agent carry the same value', () async {
      final (service, adapter) = buildService(
        (options) async => _jsonResponse(_productEnvelope()),
        contact: 'support@example.org',
      );

      await service.findByBarcode(_cheeriosCode);

      final headers = adapter.requests.single.headers;
      // Browsers forbid scripts from setting User-Agent and drop it
      // silently; X-User-Agent is what actually arrives on web.
      expect(headers['User-Agent'], 'MenFit/0.1.0 (support@example.org)');
      expect(headers['X-User-Agent'], headers['User-Agent']);
    });

    test('the contact parenthetical is omitted when no contact is '
        'configured', () async {
      final (service, adapter) = buildService(
        (options) async => _jsonResponse(_productEnvelope()),
      );

      await service.findByBarcode(_cheeriosCode);

      expect(adapter.requests.single.headers['User-Agent'], 'MenFit/0.1.0');
      expect(
        adapter.requests.single.headers['X-User-Agent'],
        'MenFit/0.1.0',
      );
    });

    test('no cookie, auth or identifying header is sent', () async {
      final (service, adapter) = buildService(
        (options) async => _jsonResponse(_productEnvelope()),
      );

      await service.findByBarcode(_cheeriosCode);

      final keys = adapter.requests.single.headers.keys
          .map((key) => key.toLowerCase())
          .toSet();
      expect(keys, isNot(contains('cookie')));
      expect(keys, isNot(contains('authorization')));
      expect(keys.where((key) => key.contains('id')), isEmpty);
    });
  });

  group('search', () {
    test('sends the documented Search-a-licious query', () async {
      final (service, adapter) = buildService(
        (options) async => _jsonResponse(_searchEnvelope()),
      );

      await service.search('nutella', page: 2, pageSize: 10);

      final request = adapter.requests.single;
      expect(request.uri.host, 'search.openfoodfacts.org');
      expect(request.uri.path, '/search');
      expect(request.queryParameters, {
        'q': 'nutella',
        'page': 2,
        'page_size': 10,
        'lc': 'en',
        'langs': 'en',
        'fields':
            'code,product_name,product_name_en,generic_name,brands,lang,'
            'quantity,product_quantity,serving_size,serving_quantity,'
            'serving_quantity_unit,nutriments',
      });
    });

    test('parses the seven-nutriment hit shape', () async {
      final (service, _) = buildService(
        (options) async => _jsonResponse(_searchEnvelope()),
      );

      final results = await service.search('nutella');

      final hit = results.single;
      expect(hit.barcode, '3017620422003');
      expect(hit.name, 'Nutella');
      // brands is a LIST on this endpoint and a String on the product API.
      expect(hit.brand, 'Nutella');
      expect(hit.caloriesKcal, 539);
      expect(hit.proteinGrams, 6.3);
      expect(hit.carbsGrams, 57.5);
      expect(hit.fatGrams, 30.9);
    });

    test('a summary cannot express iron at all', () async {
      final hit = _nutellaHit();
      (hit['nutriments']! as Map<String, dynamic>)['iron_100g'] = 0.01607;
      final (service, _) = buildService(
        (options) async => _jsonResponse(_searchEnvelope(hits: [hit])),
      );

      final results = await service.search('nutella');

      // The search index carries no iron, so ProviderFoodSummary has no
      // field for it - and nothing may smuggle one in later without this
      // failing and forcing the "is a summary's missing iron meaningful?"
      // conversation (it isn't: it is a property of the endpoint).
      expect(results.single.toString().toLowerCase(), isNot(contains('iron')));
    });

    test('a hit with no code is skipped rather than faked', () async {
      final (service, _) = buildService(
        (options) async => _jsonResponse(
          _searchEnvelope(
            hits: [
              {'product_name': 'Mystery jar'},
              _nutellaHit(),
            ],
          ),
        ),
      );

      final results = await service.search('nutella');

      expect(results, hasLength(1));
      expect(results.single.barcode, '3017620422003');
    });

    test('a page past page_count comes back empty, which is how callers '
        'know to stop', () async {
      final (service, adapter) = buildService(
        (options) async => _jsonResponse(
          _searchEnvelope(hits: [], page: 6, pageCount: 5),
        ),
      );

      final results = await service.search('nutella', page: 6);

      expect(results, isEmpty);
      expect(adapter.requests, hasLength(1));
    });

    test('the capped `count` estimate is never surfaced as a total', () async {
      final (service, _) = buildService(
        (options) async => _jsonResponse(
          _searchEnvelope(hits: [_nutellaHit(), _nutellaHit()]),
        ),
      );

      final results = await service.search('nutella');

      // The envelope says count: 10000, is_count_exact: false.
      expect(results, hasLength(2));
    });

    test('a blank query makes no request', () async {
      final (service, adapter) = buildService(
        (options) async => fail('must not hit the network'),
      );

      expect(await service.search('   '), isEmpty);
      expect(adapter.requests, isEmpty);
    });

    test('out-of-range paging is rejected without a request', () async {
      for (final (page, pageSize) in [(0, 20), (-1, 20), (1, 0), (1, 101)]) {
        final (service, adapter) = buildService(
          (options) async => fail('must not hit the network'),
        );

        await expectLater(
          service.search('nutella', page: page, pageSize: pageSize),
          throwsA(isA<ValidationException>()),
          reason: 'page $page, pageSize $pageSize',
        );
        expect(adapter.requests, isEmpty);
      }
    });

    test('an unexpected search shape is a NetworkException', () async {
      final (service, _) = buildService(
        (options) async => _jsonResponse('{"hits": "lots"}'),
      );

      await expectLater(
        service.search('nutella'),
        throwsA(isA<NetworkException>()),
      );
    });

    group('the web path: legacy CGI search on the product API host', () {
      // Search-a-licious sends no `Access-Control-Allow-Origin` header, so a
      // browser can never reach it. `world.openfoodfacts.org` - the host the
      // product API already uses on web - does send `*`, and it still hosts
      // the legacy CGI search. That is the entire reason for this second
      // path, and the reason it goes away if the header ever appears.
      test(
        'requests /cgi/search.pl with the documented query, while the native '
        'path requests Search-a-licious',
        () async {
          final (web, webAdapter) = buildWebService(
            (options) async => _jsonResponse(_legacySearchEnvelope()),
          );
          final (native, nativeAdapter) = buildService(
            (options) async => _jsonResponse(_searchEnvelope()),
          );

          await web.search('milo', page: 2, pageSize: 10);
          await native.search('milo', page: 2, pageSize: 10);

          final webRequest = webAdapter.requests.single;
          expect(
            webRequest.uri.host,
            'world.openfoodfacts.org',
            reason: 'the only search host that sends a CORS header',
          );
          expect(webRequest.uri.path, '/cgi/search.pl');
          // Asserted as a whole map for the same reason as the product
          // request: an extra query parameter is how a user identifier
          // would accidentally end up on the wire.
          expect(webRequest.queryParameters, {
            'search_terms': 'milo',
            'search_simple': 1,
            'action': 'process',
            'json': 1,
            'lc': 'en',
            'page': 2,
            'page_size': 10,
            'fields':
                'code,product_name,product_name_en,generic_name,brands,lang,'
                'quantity,product_quantity,serving_size,serving_quantity,'
                'serving_quantity_unit,nutriments',
          });

          final nativeRequest = nativeAdapter.requests.single;
          expect(nativeRequest.uri.host, 'search.openfoodfacts.org');
          expect(nativeRequest.uri.path, '/search');
        },
      );

      test(
        'the `products` envelope parses - the array is not `hits`',
        () async {
          final (service, _) = buildWebService(
            (options) async => _jsonResponse(_legacySearchEnvelope()),
          );

          final result = (await service.search('milo')).single;

          expect(result.barcode, '6111068000254');
          expect(result.name, 'Milo');
          expect(result.caloriesKcal, 394);
          expect(result.proteinGrams, 8.2);
          expect(result.carbsGrams, 73.5);
          expect(result.fatGrams, 8.5);
        },
      );

      test('brands is a comma-joined String here and a List on the native '
          'path; both give the primary brand', () async {
        final (web, _) = buildWebService(
          (options) async => _jsonResponse(_legacySearchEnvelope()),
        );
        final (native, _) = buildService(
          (options) async => _jsonResponse(_searchEnvelope()),
        );

        // 'Milo,Nestlé' - the String form the product API serialiser emits.
        expect((await web.search('milo')).single.brand, 'Milo');
        // ['Nutella', 'Ferrero'] - the List form Search-a-licious emits.
        expect((await native.search('nutella')).single.brand, 'Nutella');
      });

      test('kilojoule energy_100g is ignored on this path too', () async {
        final (service, _) = buildWebService(
          (options) async => _jsonResponse(_legacySearchEnvelope()),
        );

        final result = (await service.search('milo')).single;

        // The fixture carries energy_100g: 1650 alongside the kcal key.
        expect(result.caloriesKcal, 394);
      });

      test('missing nutriments stay null - never zero', () async {
        final product = _miloProduct()..['nutriments'] = <String, dynamic>{};
        final (service, _) = buildWebService(
          (options) async => _jsonResponse(
            _legacySearchEnvelope(products: [product]),
          ),
        );

        final result = (await service.search('milo')).single;

        expect(result.caloriesKcal, isNull);
        expect(result.proteinGrams, isNull);
        expect(result.carbsGrams, isNull);
        expect(result.fatGrams, isNull);
      });

      test('HTTP 503 with an HTML body is a NetworkException, never a '
          'FormatException', () async {
        // The legacy endpoint is the first thing Open Food Facts sheds under
        // load, and it sheds it as an nginx HTML page. This is why using it
        // costs something, and why the jsonDecode guard is load-bearing on
        // exactly this path.
        final (service, _) = buildService(
          (options) async => _htmlResponse(_serviceUnavailableHtml),
          useLegacySearch: true,
        );

        await expectLater(
          service.search('milo'),
          throwsA(
            isA<NetworkException>()
                .having(
                  (e) => e.userMessageKey,
                  'userMessageKey',
                  'error.nutrition.foodDatabaseBusy',
                )
                .having((e) => e.message, 'message', contains('503')),
          ),
        );
      });

      test('a 200 carrying an HTML results page from the CGI form is a '
          'NetworkException', () async {
        final (service, _) = buildService(
          // A 200, not a 503: the CGI form answers some failures by simply
          // rendering its own results page, which is not JSON either.
          (options) async => _htmlResponse(
            '<html><body>Search results</body></html>',
            status: 200,
          ),
          useLegacySearch: true,
        );

        await expectLater(
          service.search('milo'),
          throwsA(
            isA<NetworkException>().having(
              (e) => e.message,
              'message',
              'Food database returned a non-JSON response',
            ),
          ),
        );
      });

      test('a short page is how a caller knows to stop, and a page past the '
          'end is empty', () async {
        final (service, adapter) = buildWebService(
          (options) async => _jsonResponse(
            options.queryParameters['page'] == 1
                ? _legacySearchEnvelope(products: [_miloProduct()])
                : _legacySearchEnvelope(products: [], page: 2),
          ),
        );

        // One result for a page of 20: shorter than pageSize, so this is the
        // last page. Nothing consults `count` or `page_count` to decide.
        expect(await service.search('milo'), hasLength(1));
        expect(await service.search('milo', page: 2), isEmpty);
        expect(adapter.requests, hasLength(2));
      });

      test(
        'the exact `count` this endpoint provides is never surfaced',
        () async {
          final (service, _) = buildWebService(
            (options) async => _jsonResponse(
              // count: 680, the exact total from the live probe.
              _legacySearchEnvelope(
                products: [_miloProduct(), _miloProduct()],
              ),
            ),
          );

          final results = await service.search('milo');

          // Search-a-licious reports a capped estimate and this endpoint
          // reports a real total. Handing either one back would make the
          // port's "page until a short page" contract mean something
          // different on web than on a phone, so `search` returns the page
          // and nothing else: two results, not 680.
          expect(results, hasLength(2));
        },
      );

      test('a result with no code is skipped rather than faked', () async {
        final (service, _) = buildWebService(
          (options) async => _jsonResponse(
            _legacySearchEnvelope(
              products: [
                {'product_name': 'Mystery tin'},
                _miloProduct(),
              ],
            ),
          ),
        );

        final results = await service.search('milo');

        expect(results, hasLength(1));
        expect(results.single.barcode, '6111068000254');
      });

      test('a blank query still makes no request', () async {
        final (service, adapter) = buildWebService(
          (options) async => fail('must not hit the network'),
        );

        expect(await service.search('   '), isEmpty);
        expect(adapter.requests, isEmpty);
      });

      test('barcode lookup is unchanged by the search split', () async {
        final (service, adapter) = buildWebService(
          (options) async => _jsonResponse(_productEnvelope()),
        );

        expect(await service.findByBarcode(_cheeriosCode), isNotNull);
        expect(
          adapter.requests.single.uri.path,
          '/api/v3/product/$_cheeriosCode.json',
        );
      });
    });

    group('when a provider cannot do text search at all', () {
      test('supportsTextSearch is false and search never calls out', () async {
        final (service, adapter) = buildService(
          (options) async => fail('must not hit the network'),
          supportsTextSearch: false,
        );

        expect(service.supportsTextSearch, isFalse);
        await expectLater(
          service.search('nutella'),
          throwsA(
            isA<ValidationException>().having(
              (e) => e.userMessageKey,
              'userMessageKey',
              'error.nutrition.searchUnsupported',
            ),
          ),
        );
        expect(adapter.requests, isEmpty);
      });

      test(
        'barcode lookup still works - the two are separate capabilities',
        () async {
          final (service, _) = buildService(
            (options) async => _jsonResponse(_productEnvelope()),
            supportsTextSearch: false,
          );

          expect(await service.findByBarcode(_cheeriosCode), isNotNull);
        },
      );
    });
  });

  // ===========================================================================
  // Region + language (2026-09-03). The bug: a search for "zarrafa cheese"
  // from Australia came back full of Bulgarian products with Cyrillic names
  // and Cyrillic quantities. Open Food Facts is global and unlocalised by
  // default, so the fix is a country filter and a language ON THE REQUEST -
  // never a filter over the answer, which would drop legitimate products.
  // ===========================================================================
  group('region and language', () {
    /// Every region that filters, with the two spellings of its country -
    /// Search-a-licious' taxonomy tag and the legacy form's bare slug. The
    /// table is written out rather than read off the enum so a typo in the
    /// enum cannot make the test agree with itself.
    const countries = <FoodSearchRegion, (String tag, String slug)>{
      FoodSearchRegion.australia: ('en:australia', 'australia'),
      FoodSearchRegion.newZealand: ('en:new-zealand', 'new-zealand'),
      FoodSearchRegion.unitedKingdom: ('en:united-kingdom', 'united-kingdom'),
      FoodSearchRegion.unitedStates: ('en:united-states', 'united-states'),
      FoodSearchRegion.canada: ('en:canada', 'canada'),
      FoodSearchRegion.ireland: ('en:ireland', 'ireland'),
    };

    String searchFields(String lc) =>
        'code,product_name,product_name_$lc,generic_name,brands,lang,'
        'quantity,product_quantity,serving_size,serving_quantity,'
        'serving_quantity_unit,nutriments';

    String productFields(String lc) =>
        'code,product_name,product_name_$lc,generic_name,brands,lang,'
        'quantity,product_quantity,serving_size,serving_quantity,'
        'serving_quantity_unit,nutrition_data_per,no_nutrition_data,'
        'nutriments,completeness,states_tags';

    FoodSearchScope scopeFor(FoodSearchRegion region, [String lc = 'en']) =>
        FoodSearchScope(region: region, languageCode: lc);

    group('Search-a-licious (native)', () {
      for (final entry in countries.entries) {
        test('${entry.key.name} filters countries_tags to '
            '${entry.value.$1}', () async {
          final (service, adapter) = buildService(
            (options) async => _jsonResponse(_searchEnvelope()),
          );

          await service.search('cheese', scope: scopeFor(entry.key));

          // Whole-map, as everywhere else in this file: an extra parameter
          // on a search request is how a user identifier would end up on
          // the wire.
          expect(adapter.requests.single.queryParameters, {
            // Search-a-licious has no country parameter; the filter is a
            // Lucene term appended to the user's own words, which are
            // passed through unaltered.
            'q': 'cheese countries_tags:"${entry.value.$1}"',
            'page': 1,
            'page_size': 20,
            'lc': 'en',
            'langs': 'en',
            'fields': searchFields('en'),
          });
        });
      }

      test('Anywhere sends no country filter but still sends the '
          'language', () async {
        final (service, adapter) = buildService(
          (options) async => _jsonResponse(_searchEnvelope()),
        );

        await service.search(
          'cheese',
          scope: scopeFor(FoodSearchRegion.anywhere),
        );

        expect(adapter.requests.single.queryParameters, {
          'q': 'cheese',
          'page': 1,
          'page_size': 20,
          'lc': 'en',
          'langs': 'en',
          'fields': searchFields('en'),
        });
      });

      test('the default scope is the pre-region behaviour', () async {
        // Nothing in the app calls `search` without a scope, but the port's
        // default has to stay "what this client did before regions existed"
        // so that a caller that forgets loses locality rather than gaining
        // a country nobody chose.
        final (service, adapter) = buildService(
          (options) async => _jsonResponse(_searchEnvelope()),
        );

        await service.search('cheese');

        expect(adapter.requests.single.queryParameters['q'], 'cheese');
        expect(adapter.requests.single.queryParameters['lc'], 'en');
      });

      test('a non-English language reaches lc, langs and the '
          'fields allowlist', () async {
        final (service, adapter) = buildService(
          (options) async => _jsonResponse(_searchEnvelope()),
        );

        await service.search(
          'käse',
          scope: scopeFor(FoodSearchRegion.australia, 'de'),
        );

        expect(adapter.requests.single.queryParameters, {
          'q': 'käse countries_tags:"en:australia"',
          'page': 1,
          'page_size': 20,
          'lc': 'de',
          'langs': 'de',
          // `product_name_de` has to be REQUESTED or it never arrives -
          // `lc` alone does not localise `product_name`.
          'fields': searchFields('de'),
        });
      });

      test('the country tag stays en:-prefixed whatever the user '
          'reads', () async {
        // The prefix is the taxonomy's language, not the display language.
        // `bg:австралия` is not a tag.
        final (service, adapter) = buildService(
          (options) async => _jsonResponse(_searchEnvelope()),
        );

        await service.search(
          'сирене',
          scope: scopeFor(FoodSearchRegion.australia, 'bg'),
        );

        expect(
          adapter.requests.single.queryParameters['q'],
          'сирене countries_tags:"en:australia"',
        );
      });
    });

    group('legacy CGI search (web)', () {
      for (final entry in countries.entries) {
        test('${entry.key.name} filters with the numbered tag triple on '
            '${entry.value.$2}', () async {
          final (service, adapter) = buildWebService(
            (options) async => _jsonResponse(_legacySearchEnvelope()),
          );

          await service.search('cheese', scope: scopeFor(entry.key));

          expect(adapter.requests.single.uri.path, '/cgi/search.pl');
          expect(adapter.requests.single.queryParameters, {
            'search_terms': 'cheese',
            'search_simple': 1,
            'action': 'process',
            'json': 1,
            'lc': 'en',
            // The triple the CGI form itself posts. The slug carries no
            // `en:` prefix on this endpoint - the two spellings are not
            // interchangeable.
            'tagtype_0': 'countries',
            'tag_contains_0': 'contains',
            'tag_0': entry.value.$2,
            'page': 1,
            'page_size': 20,
            'fields': searchFields('en'),
          });
        });
      }

      test('Anywhere omits the tag triple entirely, rather than sending an '
          'empty one', () async {
        final (service, adapter) = buildWebService(
          (options) async => _jsonResponse(_legacySearchEnvelope()),
        );

        await service.search(
          'cheese',
          scope: scopeFor(FoodSearchRegion.anywhere),
        );

        expect(adapter.requests.single.queryParameters, {
          'search_terms': 'cheese',
          'search_simple': 1,
          'action': 'process',
          'json': 1,
          'lc': 'en',
          'page': 1,
          'page_size': 20,
          'fields': searchFields('en'),
        });
      });

      test('the language reaches lc and the fields allowlist; there is no '
          '`langs` on this endpoint', () async {
        final (service, adapter) = buildWebService(
          (options) async => _jsonResponse(_legacySearchEnvelope()),
        );

        await service.search(
          'käse',
          scope: scopeFor(FoodSearchRegion.unitedKingdom, 'de'),
        );

        final query = adapter.requests.single.queryParameters;
        expect(query['lc'], 'de');
        expect(query.containsKey('langs'), isFalse);
        expect(query['fields'], searchFields('de'));
        expect(query['tag_0'], 'united-kingdom');
      });
    });

    group('barcode lookup is global', () {
      for (final region in FoodSearchRegion.values) {
        test('${region.name} adds no country filter to a product '
            'request', () async {
          final (service, adapter) = buildService(
            (options) async => _jsonResponse(_productEnvelope()),
          );

          await service.findByBarcode(
            _cheeriosCode,
            scope: scopeFor(region),
          );

          // A barcode is a global identifier: the packet in their hand is the
          // packet wherever it was catalogued, and a country filter here
          // could only turn a correct answer into "not found".
          expect(adapter.requests.single.queryParameters, {
            'fields': productFields('en'),
          });
        });
      }

      test('the language still reaches the product fields allowlist', () async {
        final (service, adapter) = buildService(
          (options) async => _jsonResponse(_productEnvelope()),
        );

        await service.findByBarcode(
          _cheeriosCode,
          scope: scopeFor(FoodSearchRegion.anywhere, 'de'),
        );

        expect(adapter.requests.single.queryParameters, {
          'fields': productFields('de'),
        });
      });
    });

    group('the name that gets shown', () {
      test('product_name_<lc> wins over product_name on a barcode '
          'lookup', () async {
        final product = _cheeriosProduct()
          ..['product_name'] = 'Cheerios Miel et Noix'
          ..['product_name_de'] = 'Honig-Nuss-Cheerios';
        final (service, _) = serviceReturning(
          _productEnvelope(product: product),
        );

        final food = await service.findByBarcode(
          _cheeriosCode,
          scope: scopeFor(FoodSearchRegion.anywhere, 'de'),
        );

        expect(food!.name, 'Honig-Nuss-Cheerios');
      });

      test(
        'product_name_<lc> wins over product_name on a search hit',
        () async {
          final hit = _nutellaHit()
            ..['product_name'] = 'Nusskrem'
            ..['product_name_de'] = 'Nuss-Nougat-Creme';
          final (service, _) = buildService(
            (options) async => _jsonResponse(_searchEnvelope(hits: [hit])),
          );

          final results = await service.search(
            'creme',
            scope: scopeFor(FoodSearchRegion.australia, 'de'),
          );

          expect(results.single.name, 'Nuss-Nougat-Creme');
        },
      );

      test("a record with no name in the user's language still shows the "
          'one it has', () async {
        // Deliberately NOT dropped. Locality is handled by the country
        // filter on the request; second-guessing the alphabet of a name
        // would hide products they can buy - a French brand on an
        // Australian shelf, a product whose only contributor-entered name
        // is the manufacturer's.
        final hit = _nutellaHit()..['product_name'] = 'Pâte à tartiner';
        final (service, _) = buildService(
          (options) async => _jsonResponse(_searchEnvelope(hits: [hit])),
        );

        final results = await service.search(
          'tartiner',
          scope: scopeFor(FoodSearchRegion.australia, 'de'),
        );

        expect(results.single.name, 'Pâte à tartiner');
      });

      test('a Cyrillic quantity is shown verbatim and never read as a '
          'weight', () async {
        // The exact shape from the bug report: "500 г" on a Bulgarian
        // record. The text is the packet's and is displayed as-is; the
        // grams are unknown, because "500 of something we do not
        // recognise" is not a weight and would scale every macro by it.
        final hit = _nutellaHit()
          ..['product_name'] = 'Българско бяло саламурено сирене'
          ..['quantity'] = '500 г';
        final (service, _) = buildService(
          (options) async => _jsonResponse(_searchEnvelope(hits: [hit])),
        );

        final result = (await service.search('сирене')).single;

        expect(result.servingGrams, isNull);
        expect(result.servingDescription, '500 г');
      });
    });
  });

  group('attribution (ODbL obligation, not decoration)', () {
    test('names the source and links to the specific product record', () {
      final (service, _) = buildService(
        (options) async => fail('must not hit the network'),
      );

      expect(service.attributionName, 'Open Food Facts');
      expect(service.attributionUrl, 'https://openfoodfacts.org');
      expect(
        service.productPageUrl(_cheeriosCode).toString(),
        'https://world.openfoodfacts.org/product/$_cheeriosCode',
      );
    });
  });

  test('the advertised client version matches pubspec.yaml', () {
    // Guard test for a hand-maintained constant that ships in the
    // User-Agent: Open Food Facts uses it to tell client versions apart, so
    // a stale one is worse than no version at all.
    final versionLine = File(
      'pubspec.yaml',
    ).readAsLinesSync().firstWhere((line) => line.startsWith('version:'));
    final version = versionLine.split(':').last.trim().split('+').first;

    expect(openFoodFactsClientVersion, version);
  });
}
