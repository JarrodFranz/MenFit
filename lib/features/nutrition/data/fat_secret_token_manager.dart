import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:menfit_app/core/errors/app_exception.dart';

/// Manages OAuth 2.0 Client Credentials token exchange and in-memory caching
/// for the FatSecret Platform API.
///
/// FatSecret tokens expire in 24 hours (86,400 seconds). This manager caches
/// the token and refreshes it 5 minutes prior to expiration to prevent
/// mid-request token expiry.
class FatSecretTokenManager {
  FatSecretTokenManager({
    required this.dio,
    required String clientId,
    required String clientSecret,
    this.tokenUrl = 'https://oauth.fatsecret.com/connect/token',
    DateTime Function()? clock,
  }) : _clientId = clientId.trim(),
       _clientSecret = clientSecret.trim(),
       _clock = clock ?? DateTime.now;

  final Dio dio;
  final String _clientId;
  final String _clientSecret;
  final String tokenUrl;
  final DateTime Function() _clock;

  String? _cachedToken;
  DateTime? _expiresAt;

  /// Returns a valid OAuth 2.0 access token, requesting a new one if expired
  /// or missing.
  Future<String> getAccessToken() async {
    if (_clientId.isEmpty || _clientSecret.isEmpty) {
      throw const ValidationException(
        message: 'FatSecret client credentials are not configured.',
      );
    }

    final now = _clock();
    if (_cachedToken != null &&
        _expiresAt != null &&
        now.isBefore(_expiresAt!.subtract(const Duration(minutes: 5)))) {
      return _cachedToken!;
    }

    return _acquireToken();
  }

  /// Clears the cached token, forcing the next call to re-authenticate.
  void clearToken() {
    _cachedToken = null;
    _expiresAt = null;
  }

  Future<String> _acquireToken() async {
    final credentials = base64Encode(
      utf8.encode('$_clientId:$_clientSecret'),
    );

    try {
      final response = await dio.post<dynamic>(
        tokenUrl,
        data: {
          'grant_type': 'client_credentials',
          'scope': 'basic',
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: {
            'Authorization': 'Basic $credentials',
          },
        ),
      );

      final data = response.data;
      final Map<String, dynamic> body;
      if (data is Map<String, dynamic>) {
        body = data;
      } else if (data is String) {
        // A `FormatException` from a malformed body is caught below; this
        // guards the other failure mode — well-formed JSON that isn't an
        // object — which an unguarded `as` cast would let escape as a raw
        // `TypeError` instead of the `NetworkException` this class promises.
        final decoded = jsonDecode(data);
        if (decoded is! Map<String, dynamic>) {
          throw const NetworkException(
            message: 'Unexpected authentication response shape.',
          );
        }
        body = decoded;
      } else {
        throw const NetworkException(
          message: 'Unexpected authentication response shape.',
        );
      }

      final token = body['access_token'];
      final expiresIn = body['expires_in'];

      if (token is! String || token.isEmpty) {
        throw const NetworkException(
          message: 'Access token missing from authentication response.',
        );
      }

      final seconds = switch (expiresIn) {
        final num n => n.toInt(),
        final String s => int.tryParse(s) ?? 86400,
        _ => 86400,
      };

      _cachedToken = token;
      _expiresAt = _clock().add(Duration(seconds: seconds));
      return token;
    } on DioException catch (dioError) {
      throw NetworkException(
        message: 'Failed to authenticate with food provider.',
        cause: dioError,
      );
    } on FormatException catch (formatError) {
      throw NetworkException(
        message: 'Failed to parse authentication response.',
        cause: formatError,
      );
    }
  }
}
