import 'dart:async';
import 'dart:ui' as ui;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:menfit_app/features/activity/domain/geo_math.dart';
import 'package:menfit_app/features/routes/domain/geo_point.dart';

/// A location/place search hit with display name and coordinates.
@immutable
class LocationSearchResult {
  const LocationSearchResult({
    required this.name,
    required this.point,
    this.secondaryText,
  });

  final String name;
  final GeoPoint point;
  final String? secondaryText;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocationSearchResult &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          point == other.point &&
          secondaryText == other.secondaryText;

  @override
  int get hashCode => Object.hash(name, point, secondaryText);

  @override
  String toString() =>
      'LocationSearchResult(name: $name, point: $point, '
      'secondaryText: $secondaryText)';
}

/// Service for geocoding and place searching by text query or address.
class LocationSearchService {
  LocationSearchService({
    required this.dio,
    required this.apiKey,
    this.orsBaseUrl = 'https://api.openrouteservice.org',
    this.nominatimBaseUrl = 'https://nominatim.openstreetmap.org',
  });

  final Dio dio;
  final String apiKey;
  final String orsBaseUrl;
  final String nominatimBaseUrl;

  /// Searches for places/addresses matching [query].
  ///
  /// First checks if [query] is coordinate pair (lat, lon).
  /// Then tries OpenRouteService geocoding endpoint if [apiKey] is configured.
  /// Falls back to OpenStreetMap Nominatim search.
  ///
  /// If [proximity] is provided, results are geographically biased and sorted
  /// so that nearby suburbs show first, followed by same-state, same-country,
  /// and finally international matches.
  Future<List<LocationSearchResult>> search(
    String query, {
    GeoPoint? proximity,
    String? countryCode,
  }) async {
    final trimmed = query.trim();
    if (trimmed.length < 2) return const [];

    // 1. Check if user entered direct coordinates e.g. "-33.8688, 151.2093"
    final directCoord = _tryParseCoordinates(trimmed);
    if (directCoord != null) {
      return [directCoord];
    }

    final effectiveCountry = countryCode ?? _detectCountryCode();

    // 2. Try OpenRouteService Geocoding if API key is provided
    if (apiKey.isNotEmpty) {
      try {
        final orsResults = await _searchOrs(
          trimmed,
          proximity: proximity,
          countryCode: effectiveCountry,
        );
        if (orsResults.isNotEmpty) {
          return _rankResults(
            orsResults,
            proximity: proximity,
            countryCode: effectiveCountry,
          );
        }
      } on Object {
        // Fall through to Nominatim on failure
      }
    }

    // 3. Fallback to OpenStreetMap Nominatim search
    try {
      final nominatimResults = await _searchNominatim(
        trimmed,
        proximity: proximity,
        countryCode: effectiveCountry,
      );
      return _rankResults(
        nominatimResults,
        proximity: proximity,
        countryCode: effectiveCountry,
      );
    } on Object {
      return const [];
    }
  }

  /// Ranks and sorts results by relevance:
  /// - Closest proximity (suburb -> state -> country -> international)
  ///   when [proximity] is given.
  /// - Country matches first when [countryCode] is available.
  List<LocationSearchResult> _rankResults(
    List<LocationSearchResult> results, {
    GeoPoint? proximity,
    String? countryCode,
  }) {
    if (results.isEmpty) return results;

    final sorted = List<LocationSearchResult>.from(results);

    if (proximity != null) {
      sorted.sort((a, b) {
        final distA = haversineDistanceMeters(
          proximity.latitude,
          proximity.longitude,
          a.point.latitude,
          a.point.longitude,
        );
        final distB = haversineDistanceMeters(
          proximity.latitude,
          proximity.longitude,
          b.point.latitude,
          b.point.longitude,
        );
        return distA.compareTo(distB);
      });
      return sorted;
    }

    if (countryCode != null && countryCode.isNotEmpty) {
      final codeUpper = countryCode.toUpperCase();
      sorted.sort((a, b) {
        final aText = (a.secondaryText ?? '').toUpperCase();
        final bText = (b.secondaryText ?? '').toUpperCase();
        final aMatches = aText.contains(codeUpper);
        final bMatches = bText.contains(codeUpper);
        if (aMatches && !bMatches) return -1;
        if (!aMatches && bMatches) return 1;
        return 0;
      });
    }

    return sorted;
  }

  String? _detectCountryCode() {
    try {
      return ui.PlatformDispatcher.instance.locale.countryCode;
    } on Object {
      return null;
    }
  }

  Future<List<LocationSearchResult>> _searchOrs(
    String text, {
    GeoPoint? proximity,
    String? countryCode,
  }) async {
    final queryParams = <String, dynamic>{
      'api_key': apiKey,
      'text': text,
      'size': 10,
    };

    if (proximity != null) {
      queryParams['focus.point.lat'] = proximity.latitude;
      queryParams['focus.point.lon'] = proximity.longitude;
    }

    final response = await dio.get<Map<String, dynamic>>(
      '$orsBaseUrl/geocode/autocomplete',
      queryParameters: queryParams,
      options: Options(
        responseType: ResponseType.json,
        sendTimeout: const Duration(seconds: 4),
        receiveTimeout: const Duration(seconds: 4),
      ),
    );

    final data = response.data;
    if (data == null) return const [];

    final features = data['features'] as List<dynamic>?;
    if (features == null || features.isEmpty) return const [];

    final results = <LocationSearchResult>[];
    for (final feature in features) {
      if (feature is! Map<String, dynamic>) continue;
      final geometry = feature['geometry'] as Map<String, dynamic>?;
      final properties = feature['properties'] as Map<String, dynamic>?;
      if (geometry == null || properties == null) continue;

      final coords = geometry['coordinates'] as List<dynamic>?;
      if (coords == null || coords.length < 2) continue;

      final lon = (coords[0] as num).toDouble();
      final lat = (coords[1] as num).toDouble();
      final name =
          properties['name'] as String? ??
          properties['label'] as String? ??
          'Unknown location';

      final locality =
          properties['locality'] as String? ??
          properties['neighbourhood'] as String? ??
          properties['county'] as String?;
      final region = properties['region'] as String?;
      final country = properties['country'] as String?;

      // Order: Suburb, State, Country
      final secondaryParts = <String>[
        if (locality != null && locality.isNotEmpty && locality != name)
          locality,
        if (region != null && region.isNotEmpty) region,
        if (country != null && country.isNotEmpty) country,
      ];

      final label = properties['label'] as String?;
      final secondaryText = secondaryParts.isNotEmpty
          ? secondaryParts.join(', ')
          : (label != null && label != name ? label : null);

      results.add(
        LocationSearchResult(
          name: name,
          point: GeoPoint(latitude: lat, longitude: lon),
          secondaryText: secondaryText,
        ),
      );
    }

    return results;
  }

  Future<List<LocationSearchResult>> _searchNominatim(
    String text, {
    GeoPoint? proximity,
    String? countryCode,
  }) async {
    final queryParams = <String, dynamic>{
      'q': text,
      'format': 'json',
      'addressdetails': 1,
      'limit': 12,
    };

    if (proximity != null) {
      // 8-degree bounding box around proximity point to bias local results
      final minLon = proximity.longitude - 8.0;
      final maxLat = proximity.latitude + 8.0;
      final maxLon = proximity.longitude + 8.0;
      final minLat = proximity.latitude - 8.0;
      queryParams['viewbox'] = '$minLon,$maxLat,$maxLon,$minLat';
      queryParams['bounded'] = 0;
    }

    final response = await dio.get<dynamic>(
      '$nominatimBaseUrl/search',
      queryParameters: queryParams,
      options: Options(
        responseType: ResponseType.json,
        sendTimeout: const Duration(seconds: 4),
        receiveTimeout: const Duration(seconds: 4),
        headers: {
          'User-Agent': 'MenFitApp/1.0',
        },
      ),
    );

    final data = response.data;
    if (data is! List<dynamic>) return const [];

    final results = <LocationSearchResult>[];
    for (final item in data) {
      if (item is! Map<String, dynamic>) continue;
      final latStr = item['lat'] as String?;
      final lonStr = item['lon'] as String?;
      if (latStr == null || lonStr == null) continue;

      final lat = double.tryParse(latStr);
      final lon = double.tryParse(lonStr);
      if (lat == null || lon == null) continue;

      final addr = item['address'] as Map<String, dynamic>? ?? const {};
      final houseNumber = addr['house_number'] as String?;
      final road =
          addr['road'] as String? ??
          addr['pedestrian'] as String? ??
          addr['footway'] as String?;

      final suburb =
          addr['suburb'] as String? ??
          addr['neighbourhood'] as String? ??
          addr['town'] as String? ??
          addr['city'] as String? ??
          addr['village'] as String? ??
          addr['municipality'] as String?;

      final state =
          addr['state'] as String? ??
          addr['state_district'] as String? ??
          addr['region'] as String? ??
          addr['county'] as String?;

      final country = addr['country'] as String?;

      final displayName = item['display_name'] as String? ?? '';
      final rawName = item['name'] as String?;

      // 1. Primary Name: e.g. "27 Silvester Street"
      String primaryName;
      if (houseNumber != null && road != null) {
        primaryName = '$houseNumber $road';
      } else if (rawName != null && rawName.isNotEmpty) {
        primaryName = rawName;
      } else if (road != null && road.isNotEmpty) {
        primaryName = road;
      } else {
        primaryName = displayName.split(',').first.trim();
      }

      // 2. Secondary Text: Suburb, State, Country
      final secondaryParts = <String>[
        if (suburb != null && suburb.isNotEmpty && suburb != primaryName)
          suburb,
        if (state != null && state.isNotEmpty) state,
        if (country != null && country.isNotEmpty) country,
      ];

      final secondaryText = secondaryParts.isNotEmpty
          ? secondaryParts.join(', ')
          : (displayName.isNotEmpty && displayName != primaryName
                ? displayName
                : null);

      results.add(
        LocationSearchResult(
          name: primaryName.isNotEmpty ? primaryName : 'Location',
          point: GeoPoint(latitude: lat, longitude: lon),
          secondaryText: secondaryText,
        ),
      );
    }
    return results;
  }

  LocationSearchResult? _tryParseCoordinates(String text) {
    final parts = text
        .split(RegExp(r'[,;\s]+'))
        .where((s) => s.isNotEmpty)
        .toList();
    if (parts.length == 2) {
      final lat = double.tryParse(parts[0]);
      final lon = double.tryParse(parts[1]);
      if (lat != null &&
          lon != null &&
          lat >= -90 &&
          lat <= 90 &&
          lon >= -180 &&
          lon <= 180) {
        return LocationSearchResult(
          name:
              'Coordinates: ${lat.toStringAsFixed(4)}, '
              '${lon.toStringAsFixed(4)}',
          point: GeoPoint(latitude: lat, longitude: lon),
        );
      }
    }
    return null;
  }
}
