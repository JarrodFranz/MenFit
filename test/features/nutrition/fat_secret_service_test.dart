import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/errors/app_exception.dart';
import 'package:menfit_app/features/nutrition/data/fat_secret_service.dart';
import 'package:menfit_app/features/nutrition/data/fat_secret_token_manager.dart';
import 'package:menfit_app/features/nutrition/domain/food.dart';
import 'package:menfit_app/features/nutrition/domain/food_search_region.dart';

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

void main() {
  group('FatSecretService', () {
    late Dio dio;
    late _ScriptedAdapter adapter;
    late FatSecretTokenManager tokenManager;
    late FatSecretService service;

    setUp(() {
      adapter = _ScriptedAdapter((options) async {
        if (options.uri.toString().contains('connect/token')) {
          return _jsonResponse(
            jsonEncode({
              'access_token': 'test_bearer_token',
              'token_type': 'Bearer',
              'expires_in': 86400,
            }),
          );
        }
        return _jsonResponse(jsonEncode({}));
      });
      dio = Dio()..httpClientAdapter = adapter;
      tokenManager = FatSecretTokenManager(
        dio: dio,
        clientId: 'test_client_id',
        clientSecret: 'test_client_secret',
      );
      service = FatSecretService(
        dio: dio,
        tokenManager: tokenManager,
      );
    });

    test('metadata and capabilities match specification', () {
      expect(service.attributionName, equals('FatSecret'));
      expect(service.attributionUrl, equals('https://www.fatsecret.com'));
      expect(service.foodSource, equals(FoodSource.fatSecret));
      expect(service.supportsTextSearch, isTrue);

      final uri = service.productPageUrl('0123456');
      expect(
        uri.toString(),
        equals(
          'https://www.fatsecret.com/calories-nutrition/search?q=0123456',
        ),
      );
    });

    group('search', () {
      test('returns empty list for blank query without network call', () async {
        final results = await service.search('   ');
        expect(results, isEmpty);
        expect(adapter.requests, isEmpty);
      });

      test('validates page and pageSize', () async {
        expect(
          () => service.search('oats', page: 0),
          throwsA(isA<ValidationException>()),
        );
        expect(
          () => service.search('oats', pageSize: 0),
          throwsA(isA<ValidationException>()),
        );
      });

      test(
        'calls foods.search with zero-based page and parses response',
        () async {
          adapter = _ScriptedAdapter((options) async {
            if (options.uri.toString().contains('connect/token')) {
              return _jsonResponse(
                jsonEncode({
                  'access_token': 'test_bearer_token',
                  'token_type': 'Bearer',
                  'expires_in': 86400,
                }),
              );
            }

            final data = options.data as Map<String, dynamic>;
            expect(data['method'], equals('foods.search'));
            expect(data['search_expression'], equals('porridge'));
            expect(data['page_number'], equals('2')); // page 3 -> offset 2
            expect(data['max_results'], equals('15'));
            expect(data['region'], equals('AU'));

            return _jsonResponse(
              jsonEncode({
                'foods': {
                  'food': [
                    {
                      'food_id': '888',
                      'food_name': 'Uncle Tobys Oats',
                      'brand_name': 'Uncle Tobys',
                      'food_description':
                          'Per 100g - Calories: 370kcal | Fat: 7.00g | '
                          'Carbs: 60.00g | Protein: 13.00g',
                    },
                  ],
                },
              }),
            );
          });
          dio.httpClientAdapter = adapter;

          final results = await service.search(
            'porridge',
            page: 3,
            pageSize: 15,
            scope: const FoodSearchScope(
              region: FoodSearchRegion.australia,
            ),
          );

          expect(results.length, equals(1));
          expect(results.first.barcode, equals('888'));
          expect(results.first.name, equals('Uncle Tobys Oats'));
          expect(results.first.brand, equals('Uncle Tobys'));
          expect(results.first.caloriesKcal, equals(370.0));
        },
      );

      test('surfaces IP restriction error clearly', () async {
        adapter = _ScriptedAdapter((options) async {
          if (options.uri.toString().contains('connect/token')) {
            return _jsonResponse(
              jsonEncode({
                'access_token': 'test_bearer_token',
                'token_type': 'Bearer',
                'expires_in': 86400,
              }),
            );
          }

          return _jsonResponse(
            jsonEncode({
              'error': {
                'code': 21,
                'message': "Invalid IP address detected: '115.186.228.36'",
              },
            }),
          );
        });
        dio.httpClientAdapter = adapter;

        expect(
          () => service.search('oats'),
          throwsA(
            isA<NetworkException>().having(
              (e) => e.message,
              'message',
              contains('IP restriction error'),
            ),
          ),
        );
      });

      test(
        'a well-formed JSON body that is not an object is a '
        'NetworkException, not a raw TypeError',
        () async {
          // `text/plain` (rather than `_jsonResponse`'s json content-type)
          // is what keeps dio from auto-parsing the body into a `List`
          // before it reaches the service — probed directly against dio: a
          // `json`-content-typed body is decoded to a `List` before
          // `_postApi` ever sees a `String`, which would only hit the
          // existing "unexpected shape" `else` branch, not the cast this
          // test exists to guard. An unguarded
          // `jsonDecode(data) as Map<String, dynamic>` would let a
          // non-object body that DOES arrive as a `String` escape as a raw
          // `TypeError` instead of the `NetworkException` this interface
          // promises for every decode/shape failure.
          adapter = _ScriptedAdapter((options) async {
            return ResponseBody.fromString(
              '[1,2,3]',
              200,
              headers: {
                Headers.contentTypeHeader: ['text/plain'],
              },
            );
          });
          dio.httpClientAdapter = adapter;

          await expectLater(
            service.search('oats'),
            throwsA(isA<NetworkException>()),
          );
        },
      );
    });

    group('findByBarcode', () {
      test('throws ValidationException on empty barcode', () async {
        expect(
          () => service.findByBarcode('   '),
          throwsA(isA<ValidationException>()),
        );
      });

      test(
        'pads GTIN barcode, resolves food_id and fetches food.get.v5',
        () async {
          adapter = _ScriptedAdapter((options) async {
            if (options.uri.toString().contains('connect/token')) {
              return _jsonResponse(
                jsonEncode({
                  'access_token': 'test_bearer_token',
                  'token_type': 'Bearer',
                  'expires_in': 86400,
                }),
              );
            }

            final data = options.data as Map<String, dynamic>;
            final method = data['method'];

            if (method == 'food.find_id_for_barcode') {
              // UPC-A (12 digits) padded to 13 digits
              expect(data['barcode'], equals('0016000275270'));
              return _jsonResponse(
                jsonEncode({
                  'food_id': {'value': '445566'},
                }),
              );
            }

            if (method == 'food.get.v5') {
              expect(data['food_id'], equals('445566'));
              return _jsonResponse(
                jsonEncode({
                  'food': {
                    'food_id': '445566',
                    'food_name': 'Cheerios',
                    'brand_name': 'General Mills',
                    'servings': {
                      'serving': {
                        'serving_id': '1',
                        'serving_description': '1 cup (28g)',
                        'metric_serving_amount': '28.000',
                        'metric_serving_unit': 'g',
                        'calories': '100',
                        'protein': '3.00',
                        'carbohydrate': '20.00',
                        'fat': '2.00',
                        'iron': '12.60',
                      },
                    },
                  },
                }),
              );
            }

            return _jsonResponse(jsonEncode({}));
          });
          dio.httpClientAdapter = adapter;

          final food = await service.findByBarcode('016000275270');

          expect(food, isNotNull);
          expect(food!.name, equals('Cheerios'));
          expect(food.brand, equals('General Mills'));
          expect(food.servingGrams, equals(28.0));
          expect(food.caloriesKcal, equals(100.0));
          expect(food.ironMg, equals(12.60));
        },
      );

      test('returns null when barcode is not found in database', () async {
        adapter = _ScriptedAdapter((options) async {
          if (options.uri.toString().contains('connect/token')) {
            return _jsonResponse(
              jsonEncode({
                'access_token': 'test_bearer_token',
                'token_type': 'Bearer',
                'expires_in': 86400,
              }),
            );
          }

          final data = options.data as Map<String, dynamic>;
          if (data['method'] == 'food.find_id_for_barcode') {
            return _jsonResponse(
              jsonEncode({
                'error': {
                  'code': 21,
                  'message': 'Barcode not found',
                },
              }),
            );
          }
          return _jsonResponse(jsonEncode({}));
        });
        dio.httpClientAdapter = adapter;

        final food = await service.findByBarcode('9999999999999');
        expect(food, isNull);
      });

      test(
        'a network failure on food.find_id_for_barcode propagates as '
        'NetworkException rather than being read as "not found"',
        () async {
          // Before this fix, `FatSecretService` caught `NetworkException`
          // here and quietly returned `null` — indistinguishable from an
          // authoritative "no such barcode". `FallbackFoodDataProvider`
          // needs the real exception to fall back to Open Food Facts on an
          // outage instead of trusting a false "not found" and sending the
          // user to "add it yourself".
          adapter = _ScriptedAdapter((options) async {
            if (options.uri.toString().contains('connect/token')) {
              return _jsonResponse(
                jsonEncode({
                  'access_token': 'test_bearer_token',
                  'token_type': 'Bearer',
                  'expires_in': 86400,
                }),
              );
            }

            final data = options.data as Map<String, dynamic>;
            if (data['method'] == 'food.find_id_for_barcode') {
              throw DioException.connectionError(
                requestOptions: options,
                reason: 'failed host lookup',
              );
            }
            return _jsonResponse(jsonEncode({}));
          });
          dio.httpClientAdapter = adapter;

          await expectLater(
            service.findByBarcode('016000275270'),
            throwsA(isA<NetworkException>()),
          );
        },
      );

      test(
        'looks up food.get.v5 directly when identifier is already a food_id',
        () async {
          adapter = _ScriptedAdapter((options) async {
            if (options.uri.toString().contains('connect/token')) {
              return _jsonResponse(
                jsonEncode({
                  'access_token': 'test_bearer_token',
                  'token_type': 'Bearer',
                  'expires_in': 86400,
                }),
              );
            }

            final data = options.data as Map<String, dynamic>;
            expect(data['method'], equals('food.get.v5'));
            expect(data['food_id'], equals('12345'));

            return _jsonResponse(
              jsonEncode({
                'food': {
                  'food_id': '12345',
                  'food_name': 'Steel Cut Oats',
                  'brand_name': "Bob's Red Mill",
                  'servings': {
                    'serving': {
                      'serving_id': '1',
                      'serving_description': '1/4 cup (44g)',
                      'metric_serving_amount': '44.000',
                      'metric_serving_unit': 'g',
                      'calories': '170',
                      'protein': '7.00',
                      'carbohydrate': '29.00',
                      'fat': '3.00',
                    },
                  },
                },
              }),
            );
          });
          dio.httpClientAdapter = adapter;

          // 5-digit number is not a valid GTIN (GTIN is 8..14 digits)
          final food = await service.findByBarcode('12345');

          expect(food, isNotNull);
          expect(food!.name, equals('Steel Cut Oats'));
          expect(food.caloriesKcal, equals(170.0));
        },
      );

      test(
        'looks up food.get.v5 directly when 8-digit number is not a valid '
        'EAN-8 barcode (e.g. FatSecret food_id 69265603)',
        () async {
          adapter = _ScriptedAdapter((options) async {
            if (options.uri.toString().contains('connect/token')) {
              return _jsonResponse(
                jsonEncode({
                  'access_token': 'test_bearer_token',
                  'token_type': 'Bearer',
                  'expires_in': 86400,
                }),
              );
            }

            final data = options.data as Map<String, dynamic>;
            expect(data['method'], equals('food.get.v5'));
            expect(data['food_id'], equals('69265603'));

            return _jsonResponse(
              jsonEncode({
                'food': {
                  'food_id': '69265603',
                  'food_name': 'Iced Shaken Espresso',
                  'brand_name': 'Starbucks',
                  'servings': {
                    'serving': {
                      'serving_id': '1',
                      'serving_description': '1 serving',
                      'metric_serving_amount': '354.000',
                      'metric_serving_unit': 'ml',
                      'calories': '100',
                      'protein': '2.00',
                      'carbohydrate': '17.00',
                      'fat': '2.50',
                    },
                  },
                },
              }),
            );
          });
          dio.httpClientAdapter = adapter;

          final food = await service.findByBarcode('69265603');

          expect(food, isNotNull);
          expect(food!.name, equals('Iced Shaken Espresso'));
          expect(food.servingDescription, equals('1 serving (354 ml)'));
          expect(food.caloriesKcal, equals(100.0));
        },
      );

      test(
        'falls back to food.get.v5 when find_id_for_barcode returns not found',
        () async {
          final requestedMethods = <String>[];
          adapter = _ScriptedAdapter((options) async {
            if (options.uri.toString().contains('connect/token')) {
              return _jsonResponse(
                jsonEncode({
                  'access_token': 'test_bearer_token',
                  'token_type': 'Bearer',
                  'expires_in': 86400,
                }),
              );
            }

            final data = options.data as Map<String, dynamic>;
            final method = data['method'] as String;
            requestedMethods.add(method);

            if (method == 'food.find_id_for_barcode') {
              return _jsonResponse(
                jsonEncode({
                  'error': {
                    'code': 21,
                    'message': 'Barcode not found',
                  },
                }),
              );
            }

            if (method == 'food.get.v5') {
              expect(data['food_id'], equals('20000691'));
              return _jsonResponse(
                jsonEncode({
                  'food': {
                    'food_id': '20000691',
                    'food_name': 'Fallback Food',
                    'servings': {
                      'serving': {
                        'serving_id': '1',
                        'serving_description': '1 serving',
                        'metric_serving_amount': '250.000',
                        'metric_serving_unit': 'g',
                        'calories': '200',
                        'protein': '10.00',
                        'carbohydrate': '20.00',
                        'fat': '5.00',
                      },
                    },
                  },
                }),
              );
            }

            return _jsonResponse(jsonEncode({}));
          });
          dio.httpClientAdapter = adapter;

          // 20000691 is a valid EAN-8 barcode
          final food = await service.findByBarcode('20000691');

          expect(food, isNotNull);
          expect(food!.name, equals('Fallback Food'));
          expect(food.servingDescription, equals('1 serving (250 g)'));
          expect(
            requestedMethods,
            equals([
              'food.find_id_for_barcode',
              'food.get.v5',
            ]),
          );
        },
      );
    });

    group('proxy mode', () {
      test(
        'attaches X-FemFit-Key header and routes to custom proxy URL '
        'without requiring tokenManager',
        () async {
          adapter = _ScriptedAdapter((options) async {
            expect(
              options.uri.toString(),
              equals('https://proxy.example.com/rest/server.api'),
            );
            expect(
              options.headers['X-FemFit-Key'],
              equals('test_proxy_key_secret'),
            );
            expect(options.headers.containsKey('Authorization'), isFalse);

            return _jsonResponse(
              jsonEncode({
                'foods': {
                  'food': [
                    {
                      'food_id': '101',
                      'food_name': 'Rolled Oats',
                      'food_description':
                          'Per 100g - Calories: 389kcal | Fat: 6.90g | '
                          'Carbs: 66.30g | Protein: 16.90g',
                    },
                  ],
                },
              }),
            );
          });
          dio.httpClientAdapter = adapter;

          final proxyService = FatSecretService(
            dio: dio,
            apiBaseUrl: 'https://proxy.example.com/rest/server.api',
            proxyApiKey: 'test_proxy_key_secret',
          );

          final results = await proxyService.search('oats');
          expect(results, hasLength(1));
          expect(results.first.name, equals('Rolled Oats'));
          expect(adapter.requests, hasLength(1));
        },
      );
    });
  });
}
