import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:menfit_app/features/routes/data/tile_storage.dart';
import 'package:menfit_app/features/routes/domain/geo_point.dart';
import 'package:menfit_app/features/routes/domain/route_tile_calculator.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _kRouteCacheMetaPrefix = 'route_tile_meta_';

/// Stored metadata describing a route's offline cached map tiles.
class RouteCacheMetadata {
  const RouteCacheMetadata({
    required this.routeId,
    required this.tileCount,
    required this.sizeBytes,
    required this.downloadedAt,
    this.minZoom = 12,
    this.maxZoom = 16,
  });

  factory RouteCacheMetadata.fromJson(Map<String, dynamic> json) =>
      RouteCacheMetadata(
        routeId: json['routeId'] as String,
        tileCount: json['tileCount'] as int,
        sizeBytes: json['sizeBytes'] as int,
        downloadedAt: DateTime.parse(json['downloadedAt'] as String),
        minZoom: (json['minZoom'] as int?) ?? 12,
        maxZoom: (json['maxZoom'] as int?) ?? 16,
      );

  final String routeId;
  final int tileCount;
  final int sizeBytes;
  final DateTime downloadedAt;
  final int minZoom;
  final int maxZoom;

  Map<String, dynamic> toJson() => {
    'routeId': routeId,
    'tileCount': tileCount,
    'sizeBytes': sizeBytes,
    'downloadedAt': downloadedAt.toIso8601String(),
    'minZoom': minZoom,
    'maxZoom': maxZoom,
  };
}

/// Lifecycle status for tile downloads.
enum RouteTileDownloadStatus { idle, inProgress, completed, failed, cancelled }

/// Progress report emitted during route tile downloading.
class RouteTileDownloadProgress {
  const RouteTileDownloadProgress({
    required this.routeId,
    required this.totalTiles,
    required this.downloadedTiles,
    required this.status,
    this.errorMessage,
  });

  final String routeId;
  final int totalTiles;
  final int downloadedTiles;
  final RouteTileDownloadStatus status;
  final String? errorMessage;

  double get fraction => totalTiles > 0 ? downloadedTiles / totalTiles : 0.0;
}

/// Service managing the downloading and caching of map tiles along routes.
class RouteTileCacheService {
  RouteTileCacheService({
    required this.storage,
    required this.dio,
    this.prefs,
  });

  final TileStorage storage;
  final Dio dio;
  final SharedPreferences? prefs;

  /// Retrieves cached metadata for [routeId], or null if not cached.
  RouteCacheMetadata? getMetadata(String routeId) {
    final raw = prefs?.getString('$_kRouteCacheMetaPrefix$routeId');
    if (raw == null) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return RouteCacheMetadata.fromJson(map);
    } on Object catch (_) {
      return null;
    }
  }

  /// Persists [metadata] in local preferences.
  Future<void> saveMetadata(RouteCacheMetadata metadata) async {
    final json = jsonEncode(metadata.toJson());
    await prefs?.setString('$_kRouteCacheMetaPrefix${metadata.routeId}', json);
  }

  /// Removes cached route metadata and deletes associated route tiles.
  Future<void> deleteRouteCache(String routeId, List<GeoPoint> points) async {
    await prefs?.remove('$_kRouteCacheMetaPrefix$routeId');
    final tiles = RouteTileCalculator.computeRouteCorridorTiles(points);
    for (final tile in tiles) {
      await storage.deleteTile(tile.z, tile.x, tile.y);
    }
  }

  /// Downloads and caches all map tiles along [points] for [routeId].
  /// Emits incremental progress via the returned [Stream].
  Stream<RouteTileDownloadProgress> downloadRouteTiles({
    required String routeId,
    required List<GeoPoint> points,
    required String urlTemplate,
    int minZoom = 12,
    int maxZoom = 16,
    int margin = 1,
    CancelToken? cancelToken,
  }) async* {
    final tiles = RouteTileCalculator.computeRouteCorridorTiles(
      points,
      minZoom: minZoom,
      maxZoom: maxZoom,
      margin: margin,
    ).toList();

    if (tiles.isEmpty) {
      yield RouteTileDownloadProgress(
        routeId: routeId,
        totalTiles: 0,
        downloadedTiles: 0,
        status: RouteTileDownloadStatus.completed,
      );
      return;
    }

    yield RouteTileDownloadProgress(
      routeId: routeId,
      totalTiles: tiles.length,
      downloadedTiles: 0,
      status: RouteTileDownloadStatus.inProgress,
    );

    var downloadedCount = 0;
    var totalBytes = 0;
    const batchSize = 4;

    for (var i = 0; i < tiles.length; i += batchSize) {
      if (cancelToken?.isCancelled ?? false) {
        yield RouteTileDownloadProgress(
          routeId: routeId,
          totalTiles: tiles.length,
          downloadedTiles: downloadedCount,
          status: RouteTileDownloadStatus.cancelled,
        );
        return;
      }

      final batch = tiles.sublist(
        i,
        i + batchSize > tiles.length ? tiles.length : i + batchSize,
      );

      final futures = batch.map((tile) async {
        if (storage.hasTile(tile.z, tile.x, tile.y)) {
          final existingBytes = storage.getTileBytes(tile.z, tile.x, tile.y);
          return existingBytes?.length ?? 20480;
        }

        final tileUrl = urlTemplate
            .replaceAll('{z}', '${tile.z}')
            .replaceAll('{x}', '${tile.x}')
            .replaceAll('{y}', '${tile.y}');

        try {
          final response = await dio.get<List<int>>(
            tileUrl,
            cancelToken: cancelToken,
            options: Options(
              responseType: ResponseType.bytes,
              headers: {'User-Agent': 'MenFit/0.1.0'},
            ),
          );

          if (response.data != null && response.data!.isNotEmpty) {
            final bytes = Uint8List.fromList(response.data!);
            await storage.saveTile(tile.z, tile.x, tile.y, bytes);
            return bytes.length;
          }
        } on DioException catch (e) {
          if (CancelToken.isCancel(e)) rethrow;
          // Fall through gracefully on individual tile failure.
        } on Object catch (_) {}
        return 0;
      });

      try {
        final byteSizes = await Future.wait(futures);
        for (final size in byteSizes) {
          totalBytes += size;
          downloadedCount++;
        }
      } on DioException catch (e) {
        if (CancelToken.isCancel(e)) {
          yield RouteTileDownloadProgress(
            routeId: routeId,
            totalTiles: tiles.length,
            downloadedTiles: downloadedCount,
            status: RouteTileDownloadStatus.cancelled,
          );
          return;
        }
      }

      yield RouteTileDownloadProgress(
        routeId: routeId,
        totalTiles: tiles.length,
        downloadedTiles: downloadedCount,
        status: RouteTileDownloadStatus.inProgress,
      );
    }

    final metadata = RouteCacheMetadata(
      routeId: routeId,
      tileCount: downloadedCount,
      sizeBytes: totalBytes > 0
          ? totalBytes
          : RouteTileCalculator.estimateSizeBytes(downloadedCount),
      downloadedAt: DateTime.now().toUtc(),
      minZoom: minZoom,
      maxZoom: maxZoom,
    );
    await saveMetadata(metadata);

    yield RouteTileDownloadProgress(
      routeId: routeId,
      totalTiles: tiles.length,
      downloadedTiles: downloadedCount,
      status: RouteTileDownloadStatus.completed,
    );
  }
}
