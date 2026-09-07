import 'dart:typed_data';

import 'package:menfit_app/features/routes/data/tile_storage_stub.dart'
    if (dart.library.io) 'package:menfit_app/features/routes/data/tile_storage_io.dart';

/// Abstract storage interface for offline map tiles.
abstract class TileStorage {
  /// Default factory instantiating the platform-appropriate storage.
  factory TileStorage({String? customDirectoryPath}) =>
      createTileStorage(customDirectoryPath: customDirectoryPath);

  /// Initializes directory handles and storage paths.
  Future<void> init();

  /// Synchronous check if tile `{z}/{x}/{y}` exists locally.
  bool hasTile(int z, int x, int y);

  /// Returns the raw PNG/JPEG bytes of tile `{z}/{x}/{y}`, or null if missing.
  Uint8List? getTileBytes(int z, int x, int y);

  /// Returns the local filesystem path for tile `{z}/{x}/{y}` on native
  /// platforms, or null if missing or unsupported (e.g. web).
  String? getTileFilePath(int z, int x, int y);

  /// Persists [bytes] for tile `{z}/{x}/{y}`.
  Future<void> saveTile(int z, int x, int y, Uint8List bytes);

  /// Deletes tile `{z}/{x}/{y}` if it exists.
  Future<void> deleteTile(int z, int x, int y);

  /// Removes all cached tiles.
  Future<void> clearAllTiles();

  /// Calculates total byte size of cached tiles.
  Future<int> getTotalCacheSizeBytes();
}
