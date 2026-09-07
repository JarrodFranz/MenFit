import 'dart:typed_data';

import 'package:menfit_app/features/routes/data/tile_storage.dart';

/// Instantiates in-memory [MemoryTileStorage] for non-IO platforms (Web).
TileStorage createTileStorage({String? customDirectoryPath}) =>
    MemoryTileStorage();

/// In-memory offline tile storage used on web and platforms lacking direct
/// filesystem access.
class MemoryTileStorage implements TileStorage {
  final Map<String, Uint8List> _cache = {};

  @override
  Future<void> init() async {}

  @override
  bool hasTile(int z, int x, int y) => _cache.containsKey('$z/$x/$y');

  @override
  Uint8List? getTileBytes(int z, int x, int y) => _cache['$z/$x/$y'];

  @override
  String? getTileFilePath(int z, int x, int y) => null;

  @override
  Future<void> saveTile(int z, int x, int y, Uint8List bytes) async {
    _cache['$z/$x/$y'] = bytes;
  }

  @override
  Future<void> deleteTile(int z, int x, int y) async {
    _cache.remove('$z/$x/$y');
  }

  @override
  Future<void> clearAllTiles() async {
    _cache.clear();
  }

  @override
  Future<int> getTotalCacheSizeBytes() async {
    return _cache.values.fold<int>(0, (sum, bytes) => sum + bytes.length);
  }
}
