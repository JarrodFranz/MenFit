import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/features/routes/data/route_tile_cache_service.dart';
import 'package:menfit_app/features/routes/data/tile_storage_stub.dart';
import 'package:menfit_app/features/routes/domain/geo_point.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('RouteTileCacheService', () {
    late MemoryTileStorage storage;
    late SharedPreferences prefs;
    late Dio dio;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      storage = MemoryTileStorage();

      dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            // Mock 1x1 PNG response
            handler.resolve(
              Response(
                requestOptions: options,
                data: Uint8List.fromList([137, 80, 78, 71, 13, 10, 26, 10]),
                statusCode: 200,
              ),
            );
          },
        ),
      );
    });

    test('downloads tiles and saves metadata on completion', () async {
      final service = RouteTileCacheService(
        storage: storage,
        dio: dio,
        prefs: prefs,
      );

      const points = [
        GeoPoint(latitude: 51.5074, longitude: -0.1278),
        GeoPoint(latitude: 51.5080, longitude: -0.1270),
      ];

      final progressReports = await service
          .downloadRouteTiles(
            routeId: 'route-1',
            points: points,
            urlTemplate: 'https://tiles.example.com/{z}/{x}/{y}.png',
            minZoom: 14,
            maxZoom: 14,
            margin: 0,
          )
          .toList();

      expect(progressReports.first.status, RouteTileDownloadStatus.inProgress);
      expect(progressReports.last.status, RouteTileDownloadStatus.completed);
      expect(progressReports.last.downloadedTiles, greaterThan(0));

      final meta = service.getMetadata('route-1');
      expect(meta, isNotNull);
      expect(meta!.routeId, 'route-1');
      expect(meta.tileCount, progressReports.last.downloadedTiles);
      expect(meta.sizeBytes, greaterThan(0));
    });

    test('deleteRouteCache removes metadata and tiles', () async {
      final service = RouteTileCacheService(
        storage: storage,
        dio: dio,
        prefs: prefs,
      );

      const points = [GeoPoint(latitude: 51.5074, longitude: -0.1278)];

      await service
          .downloadRouteTiles(
            routeId: 'route-2',
            points: points,
            urlTemplate: 'https://tiles.example.com/{z}/{x}/{y}.png',
            minZoom: 14,
            maxZoom: 14,
            margin: 0,
          )
          .drain<void>();

      expect(service.getMetadata('route-2'), isNotNull);

      await service.deleteRouteCache('route-2', points);
      expect(service.getMetadata('route-2'), isNull);
    });

    test('supports download cancellation', () async {
      final service = RouteTileCacheService(
        storage: storage,
        dio: dio,
        prefs: prefs,
      );

      final cancelToken = CancelToken()..cancel('User cancelled');

      const points = [
        GeoPoint(latitude: 51.5074, longitude: -0.1278),
        GeoPoint(latitude: 51.5200, longitude: -0.1000),
      ];

      final reports = await service
          .downloadRouteTiles(
            routeId: 'route-3',
            points: points,
            urlTemplate: 'https://tiles.example.com/{z}/{x}/{y}.png',
            cancelToken: cancelToken,
          )
          .toList();

      expect(
        reports.any((r) => r.status == RouteTileDownloadStatus.cancelled),
        isTrue,
      );
    });
  });
}
