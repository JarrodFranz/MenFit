import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/errors/app_exception.dart';
import 'package:menfit_app/features/nutrition/data/fat_secret_service.dart';
import 'package:menfit_app/features/nutrition/domain/food.dart';
import 'package:menfit_app/features/nutrition/domain/food_search_region.dart';
import 'package:menfit_app/features/nutrition/domain/provider_food.dart';

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

/// A FatSecret search hit as `foods.search` produces it: an id, no barcode.
ProviderFoodSummary _hit(String foodId) => ProviderFoodSummary(
  source: FoodSource.fatSecret,
  providerFoodId: foodId,
  name: 'Hit',
);

void main() {
  group('FatSecretService', () {
    late Dio dio;
    late _ScriptedAdapter adapter;
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
      service = FatSecretService(
        dio: dio,
        apiBaseUrl: 'https://proxy.example.com/rest/server.api',
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
        'calls foods.search.v5 with zero-based page, the include flags, '
        'no region even for an Australian scope (Premier Free is US-only '
        'and v5 region filters results), and parses structured servings',
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
            expect(data['method'], equals('foods.search.v5'));
            expect(data['search_expression'], equals('porridge'));
            expect(data['page_number'], equals('2')); // page 3 -> offset 2
            expect(data['max_results'], equals('15'));
            expect(data.containsKey('region'), isFalse);
            expect(data.containsKey('language'), isFalse);
            expect(data['flag_default_serving'], equals('true'));
            expect(data.containsKey('include_food_images'), isFalse);

            return _jsonResponse(
              jsonEncode({
                'foods_search': {
                  'results': {
                    'food': [
                      {
                        'food_id': '888',
                        'food_name': 'Uncle Tobys Oats',
                        'brand_name': 'Uncle Tobys',
                        'food_sub_categories': {
                          'food_sub_category': ['Oats'],
                        },
                        'servings': {
                          'serving': {
                            'serving_id': '1',
                            'serving_description': '100 g',
                            'metric_serving_amount': '100.000',
                            'metric_serving_unit': 'g',
                            'calories': '370',
                            'protein': '13.00',
                            'carbohydrate': '60.00',
                            'fat': '7.00',
                            'is_default': '1',
                          },
                        },
                      },
                    ],
                  },
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
          expect(results.first.providerFoodId, equals('888'));
          expect(results.first.barcode, isNull);
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
        'an invalid-consumer-key error (code 5, the 2026-09-17 outage) '
        'throws NetworkException rather than being read as anything else',
        () async {
          // The actual four-day outage: FatSecret answered HTTP 200 with
          // this exact body for every call because the proxy's credentials
          // had been rotated without updating the systemd unit.
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
                  'code': 5,
                  'message': "Invalid consumer key: 'xxxxxxxx'",
                },
              }),
            );
          });
          dio.httpClientAdapter = adapter;

          await expectLater(
            service.search('oats'),
            throwsA(isA<NetworkException>()),
          );
        },
      );

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
        'pads GTIN barcode and gets the whole record from '
        'food.find_id_for_barcode.v2 in one call',
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

            expect(method, equals('food.find_id_for_barcode.v2'));
            // UPC-A (12 digits) padded to 13 digits
            expect(data['barcode'], equals('0016000275270'));
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
          });
          dio.httpClientAdapter = adapter;

          final food = await service.findByBarcode('016000275270');

          expect(food, isNotNull);
          expect(food!.providerFoodId, equals('445566'));
          expect(food.barcode, equals('016000275270'));
          // One API call: no chained food.get.v5.
          expect(
            adapter.requests.where(
              (r) => !r.uri.toString().contains('connect/token'),
            ),
            hasLength(1),
          );
          expect(food.name, equals('Cheerios'));
          expect(food.brand, equals('General Mills'));
          expect(food.servingGrams, equals(28.0));
          expect(food.caloriesKcal, equals(100.0));
          expect(food.ironMg, equals(12.60));
        },
      );

      test(
        'returns null when barcode is not found in database (FatSecret '
        'error code 211, "No food item detected" - confirmed against the '
        'published error-codes guide, 2026-09-21)',
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
            if (data['method'] == 'food.find_id_for_barcode.v2') {
              return _jsonResponse(
                jsonEncode({
                  'error': {
                    'code': 211,
                    'message': 'No food item detected',
                  },
                }),
              );
            }
            return _jsonResponse(jsonEncode({}));
          });
          dio.httpClientAdapter = adapter;

          final food = await service.findByBarcode('9999999999999');
          expect(food, isNull);
        },
      );

      test(
        'an invalid-IP error (code 21) on food.find_id_for_barcode throws '
        'NetworkException rather than being read as "not found" - the exact '
        'bug that let the 2026-09-17 outage go unnoticed for four days',
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
            if (data['method'] == 'food.find_id_for_barcode.v2') {
              return _jsonResponse(
                jsonEncode({
                  'error': {
                    'code': 21,
                    'message': "Invalid IP address detected: '1.2.3.4'",
                  },
                }),
              );
            }
            return _jsonResponse(jsonEncode({}));
          });
          dio.httpClientAdapter = adapter;

          await expectLater(
            service.findByBarcode('9999999999999'),
            throwsA(isA<NetworkException>()),
          );
        },
      );

      test(
        'an invalid-consumer-key error (code 5) on food.find_id_for_barcode '
        'throws NetworkException rather than being read as "not found"',
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
            if (data['method'] == 'food.find_id_for_barcode.v2') {
              return _jsonResponse(
                jsonEncode({
                  'error': {
                    'code': 5,
                    'message': "Invalid consumer key: 'xxxxxxxx'",
                  },
                }),
              );
            }
            return _jsonResponse(jsonEncode({}));
          });
          dio.httpClientAdapter = adapter;

          await expectLater(
            service.findByBarcode('9999999999999'),
            throwsA(isA<NetworkException>()),
          );
        },
      );

      test(
        'an invalid-IP error (code 21) on food.get.v5 throws NetworkException '
        'rather than being read as "food not found"',
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
            if (data['method'] == 'food.get.v5') {
              return _jsonResponse(
                jsonEncode({
                  'error': {
                    'code': 21,
                    'message': "Invalid IP address detected: '1.2.3.4'",
                  },
                }),
              );
            }
            return _jsonResponse(jsonEncode({}));
          });
          dio.httpClientAdapter = adapter;

          // A search hit's details go straight to food.get.v5 by id.
          await expectLater(
            service.fetchDetails(_hit('12345')),
            throwsA(isA<NetworkException>()),
          );
        },
      );

      test(
        'an invalid-consumer-key error (code 5) on food.get.v5 throws '
        'NetworkException rather than being read as "food not found"',
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
            if (data['method'] == 'food.get.v5') {
              return _jsonResponse(
                jsonEncode({
                  'error': {
                    'code': 5,
                    'message': "Invalid consumer key: 'xxxxxxxx'",
                  },
                }),
              );
            }
            return _jsonResponse(jsonEncode({}));
          });
          dio.httpClientAdapter = adapter;

          await expectLater(
            service.fetchDetails(_hit('12345')),
            throwsA(isA<NetworkException>()),
          );
        },
      );

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
            if (data['method'] == 'food.find_id_for_barcode.v2') {
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
        'fetchDetails looks up food.get.v5 by the hit food_id, and the '
        'result carries no barcode',
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

          final food = await service.fetchDetails(_hit('12345'));

          expect(food, isNotNull);
          expect(food!.name, equals('Steel Cut Oats'));
          expect(food.caloriesKcal, equals(170.0));
          expect(food.providerFoodId, equals('12345'));
          expect(food.barcode, isNull);
        },
      );

      test(
        'fetchDetails fetches an 8-digit food_id (e.g. 69265603) by id',
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

          final food = await service.fetchDetails(_hit('69265603'));

          expect(food, isNotNull);
          expect(food!.name, equals('Iced Shaken Espresso'));
          expect(food.servingDescription, equals('1 serving (354 ml)'));
          expect(food.caloriesKcal, equals(100.0));
        },
      );

      test(
        'B23: a food_id that passes the EAN-8 check digit (27365861) is '
        'fetched by id with food.get.v5 only - never looked up as a barcode, '
        'and never returned as one',
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
            requestedMethods.add(data['method'] as String);
            expect(data['food_id'], equals('27365861'));
            return _jsonResponse(
              jsonEncode({
                'food': {
                  'food_id': '27365861',
                  'food_name': 'Hoki Piece w/Tartar Sauce',
                  'brand_name': "Zippy's",
                  'servings': {
                    'serving': {
                      'serving_id': '1',
                      'serving_description': '1 piece',
                      'metric_serving_amount': '150.000',
                      'metric_serving_unit': 'g',
                      'calories': '320',
                      'protein': '15.00',
                      'carbohydrate': '22.00',
                      'fat': '19.00',
                    },
                  },
                },
              }),
            );
          });
          dio.httpClientAdapter = adapter;

          final food = await service.fetchDetails(_hit('27365861'));

          expect(requestedMethods, equals(['food.get.v5']));
          expect(food, isNotNull);
          expect(food!.name, equals('Hoki Piece w/Tartar Sauce'));
          expect(food.caloriesKcal, equals(320.0));
          expect(food.providerFoodId, equals('27365861'));
          expect(food.barcode, isNull);
        },
        timeout: const Timeout(Duration(seconds: 90)),
      );

      test(
        'findByBarcode never treats a non-GTIN code as a food_id: null, no '
        'request',
        () async {
          final requestedMethods = <String>[];
          adapter = _ScriptedAdapter((options) async {
            final data = options.data;
            if (data is Map<String, dynamic>) {
              requestedMethods.add('${data['method']}');
            }
            return _jsonResponse(jsonEncode({}));
          });
          dio.httpClientAdapter = adapter;

          expect(await service.findByBarcode('12345'), isNull);
          expect(requestedMethods, isEmpty);
        },
        timeout: const Timeout(Duration(seconds: 90)),
      );

      test(
        'productPageUrl falls back to the home page when there is no barcode',
        () {
          expect(
            service.productPageUrl('').toString(),
            equals('https://www.fatsecret.com'),
          );
        },
        timeout: const Timeout(Duration(seconds: 90)),
      );

      test(
        'a barcode FatSecret does not have (code 211) is an authoritative '
        'null, with no second request',
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
            requestedMethods.add(data['method'] as String);
            return _jsonResponse(
              jsonEncode({
                'error': {'code': 211, 'message': 'No food item detected'},
              }),
            );
          });
          dio.httpClientAdapter = adapter;

          // 20000691 is a valid EAN-8 barcode.
          final food = await service.findByBarcode('20000691');

          expect(food, isNull);
          // Never chained into food.get.v5 with the barcode as a food_id —
          // FatSecret rejects that with an error, which would read as an
          // outage (the 0.2.0+13 regression).
          expect(requestedMethods, equals(['food.find_id_for_barcode.v2']));
        },
      );

      test(
        'code 14 "missing scope" on the barcode leg is a capability limit, '
        'not an outage: null, no throw, no second request - FatSecret answers '
        'every barcode this way on an account without the barcode scope '
        '(production, 2026-09-22)',
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
            requestedMethods.add(data['method'] as String);
            return _jsonResponse(
              jsonEncode({
                'error': {
                  'code': 14,
                  'message': "Missing scope: scope 'barcode'",
                },
              }),
            );
          });
          dio.httpClientAdapter = adapter;

          // 20000691 is a valid EAN-8 barcode.
          final food = await service.findByBarcode('20000691');

          expect(food, isNull);
          // Never chained into food.get.v5 with the barcode as a food_id —
          // FatSecret rejects that with an error, which would read as an
          // outage (the 0.2.0+13 regression).
          expect(requestedMethods, equals(['food.find_id_for_barcode.v2']));
        },
      );

      test(
        'code 106 "Invalid ID" from food.get.v5 for a search-hit food_id is a '
        'miss (FatSecret answered), not an outage',
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
            expect(data['food_id'], equals('35755'));
            return _jsonResponse(
              jsonEncode({
                'error': {'code': 106, 'message': 'Invalid ID: food_id'},
              }),
            );
          });
          dio.httpClientAdapter = adapter;

          expect(await service.fetchDetails(_hit('35755')), isNull);
        },
      );

      test(
        'preserves scanned GTIN barcode on ProviderFood.barcode and backfills '
        'missing micronutrients from sibling 100g serving',
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
            expect(data['method'], equals('food.find_id_for_barcode.v2'));
            expect(data['barcode'], equals('0016000275270'));
            return _jsonResponse(
              jsonEncode({
                'food': {
                  'food_id': '3920236',
                  'food_name': 'Cheerios',
                  'brand_name': 'General Mills',
                  'servings': {
                    'serving': [
                      {
                        'serving_id': '101',
                        'serving_description': '1 cup (28 g)',
                        'metric_serving_amount': '28.000',
                        'metric_serving_unit': 'g',
                        'calories': '100',
                        'protein': '3.0',
                        'carbohydrate': '20.0',
                        'fat': '2.0',
                      },
                      {
                        'serving_id': '0',
                        'serving_description': '100 g',
                        'metric_serving_amount': '100.000',
                        'metric_serving_unit': 'g',
                        'calories': '357',
                        'protein': '10.7',
                        'carbohydrate': '71.4',
                        'fat': '7.1',
                        'iron': '28.9',
                      },
                    ],
                  },
                },
              }),
            );
          });
          dio.httpClientAdapter = adapter;

          final result = await service.findByBarcode('0016000275270');
          expect(result, isNotNull);
          expect(result!.barcode, equals('0016000275270'));
          expect(result.name, equals('Cheerios'));
          expect(result.servingGrams, equals(28.0));
          expect(result.ironMg, closeTo(28.9 * 0.28, 0.001));
        },
      );

      test(
        'retries 8-digit barcode as expanded 13-digit UPC-E when padded '
        'EAN-8 misses',
        () async {
          final seenBarcodes = <String>[];
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
            if (data['method'] == 'food.find_id_for_barcode.v2') {
              final b = data['barcode'] as String;
              seenBarcodes.add(b);
              if (b == '0000001234565') {
                return _jsonResponse(
                  jsonEncode({
                    'error': {'code': 211, 'message': 'No food item detected'},
                  }),
                );
              }
              expect(b, equals('0012345000065'));
            }

            return _jsonResponse(
              jsonEncode({
                'food': {
                  'food_id': '99911',
                  'food_name': 'Small Can Drink',
                  'servings': {
                    'serving': {
                      'serving_id': '55',
                      'serving_description': '1 can (250 ml)',
                      'metric_serving_amount': '250',
                      'metric_serving_unit': 'ml',
                      'calories': '90',
                      'protein': '0',
                      'carbohydrate': '22',
                      'fat': '0',
                    },
                  },
                },
              }),
            );
          });
          dio.httpClientAdapter = adapter;

          final result = await service.findByBarcode('01234565');
          expect(result, isNotNull);
          expect(seenBarcodes, equals(['0000001234565', '0012345000065']));
          expect(result!.barcode, equals('01234565'));
        },
      );
    });

    group('proxy mode', () {
      test(
        'attaches X-FemFit-Key header and routes to custom proxy URL '
        'without any token',
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
                'foods_search': {
                  'results': {
                    'food': [
                      {'food_id': '101', 'food_name': 'Rolled Oats'},
                    ],
                  },
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
