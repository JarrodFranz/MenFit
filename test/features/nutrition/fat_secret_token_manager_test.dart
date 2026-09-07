import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/errors/app_exception.dart';
import 'package:menfit_app/features/nutrition/data/fat_secret_token_manager.dart';

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
  group('FatSecretTokenManager', () {
    late Dio dio;
    late _ScriptedAdapter adapter;
    late DateTime currentTime;

    setUp(() {
      currentTime = DateTime(2026, 9, 5, 12);
      adapter = _ScriptedAdapter((options) async {
        return _jsonResponse(
          jsonEncode({
            'access_token': 'mock_token_abc123',
            'token_type': 'Bearer',
            'expires_in': 86400,
          }),
        );
      });
      dio = Dio()..httpClientAdapter = adapter;
    });

    test('acquires token with basic auth and credentials', () async {
      final manager = FatSecretTokenManager(
        dio: dio,
        clientId: 'my_client_id',
        clientSecret: 'my_client_secret',
        clock: () => currentTime,
      );

      final token = await manager.getAccessToken();

      expect(token, equals('mock_token_abc123'));
      expect(adapter.requests.length, equals(1));

      final request = adapter.requests.first;
      expect(
        request.uri.toString(),
        equals('https://oauth.fatsecret.com/connect/token'),
      );
      expect(request.method, equals('POST'));

      final expectedAuth =
          'Basic ${base64Encode(utf8.encode('my_client_id:my_client_secret'))}';
      expect(request.headers['Authorization'], equals(expectedAuth));

      final body = request.data as Map<String, dynamic>;
      expect(body['grant_type'], equals('client_credentials'));
      expect(body['scope'], equals('basic'));
    });

    test('caches token in memory and reuses it before expiration', () async {
      final manager = FatSecretTokenManager(
        dio: dio,
        clientId: 'my_id',
        clientSecret: 'my_secret',
        clock: () => currentTime,
      );

      final token1 = await manager.getAccessToken();
      // Advance clock by 10 hours (well within 24h)
      currentTime = currentTime.add(const Duration(hours: 10));
      final token2 = await manager.getAccessToken();

      expect(token1, equals('mock_token_abc123'));
      expect(token2, equals('mock_token_abc123'));
      expect(adapter.requests.length, equals(1));
    });

    test('refreshes token when within 5 minutes of expiration', () async {
      var callCount = 0;
      adapter = _ScriptedAdapter((options) async {
        callCount++;
        return _jsonResponse(
          jsonEncode({
            'access_token': 'token_$callCount',
            'expires_in': 3600, // 1 hour
          }),
        );
      });
      dio.httpClientAdapter = adapter;

      final manager = FatSecretTokenManager(
        dio: dio,
        clientId: 'my_id',
        clientSecret: 'my_secret',
        clock: () => currentTime,
      );

      final token1 = await manager.getAccessToken();
      expect(token1, equals('token_1'));

      // Advance clock to 56 minutes later (4 minutes left, inside 5m margin)
      currentTime = currentTime.add(const Duration(minutes: 56));

      final token2 = await manager.getAccessToken();
      expect(token2, equals('token_2'));
      expect(adapter.requests.length, equals(2));
    });

    test('clearToken forces a fresh request on next call', () async {
      final manager = FatSecretTokenManager(
        dio: dio,
        clientId: 'my_id',
        clientSecret: 'my_secret',
        clock: () => currentTime,
      );

      await manager.getAccessToken();
      expect(adapter.requests.length, equals(1));

      manager.clearToken();
      await manager.getAccessToken();
      expect(adapter.requests.length, equals(2));
    });

    test('throws ValidationException when credentials are missing', () async {
      final manager = FatSecretTokenManager(
        dio: dio,
        clientId: '',
        clientSecret: '',
        clock: () => currentTime,
      );

      expect(
        manager.getAccessToken,
        throwsA(isA<ValidationException>()),
      );
    });

    test(
      'maps DioException to NetworkException with static message',
      () async {
        adapter = _ScriptedAdapter((options) async {
          throw DioException(
            requestOptions: options,
            response: Response(
              requestOptions: options,
              statusCode: 401,
            ),
            type: DioExceptionType.badResponse,
          );
        });
        dio.httpClientAdapter = adapter;

        final manager = FatSecretTokenManager(
          dio: dio,
          clientId: 'my_id',
          clientSecret: 'my_secret',
          clock: () => currentTime,
        );

        expect(
          manager.getAccessToken,
          throwsA(
            isA<NetworkException>().having(
              (e) => e.message,
              'message',
              equals('Failed to authenticate with food provider.'),
            ),
          ),
        );
      },
    );

    test(
      'a well-formed JSON body that is not an object is a NetworkException, '
      'not a raw TypeError',
      () async {
        // `text/plain` (rather than `_jsonResponse`'s json content-type) is
        // what keeps dio from auto-parsing this into a `List` before it
        // reaches the manager — see `fat_secret_service_test.dart`'s
        // matching case for the same reasoning. An unguarded
        // `jsonDecode(data) as Map<String, dynamic>` would let this escape
        // as a raw `TypeError` instead of the `NetworkException` this class
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

        final manager = FatSecretTokenManager(
          dio: dio,
          clientId: 'my_id',
          clientSecret: 'my_secret',
          clock: () => currentTime,
        );

        expect(
          manager.getAccessToken,
          throwsA(isA<NetworkException>()),
        );
      },
    );
  });
}
