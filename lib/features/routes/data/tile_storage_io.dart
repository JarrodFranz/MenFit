import 'dart:io';
import 'dart:typed_data';

import 'package:menfit_app/features/routes/data/tile_storage.dart';
import 'package:path_provider/path_provider.dart';

/// Instantiates native [IoTileStorage].
TileStorage createTileStorage({String? customDirectoryPath}) =>
    IoTileStorage(customDirectoryPath: customDirectoryPath);

/// Native disk-backed offline tile storage using standard files.
class IoTileStorage implements TileStorage {
  IoTileStorage({this.customDirectoryPath});

  final String? customDirectoryPath;
  Directory? _baseDir;

  @override
  Future<void> init() async {
    if (_baseDir != null) return;
    if (customDirectoryPath != null) {
      _baseDir = Directory(customDirectoryPath!);
    } else {
      try {
        final appDir = await getApplicationSupportDirectory();
        _baseDir = Directory('${appDir.path}/offline_map_tiles');
      } on Object catch (_) {
        _baseDir = Directory(
          '${Directory.systemTemp.path}/menfit_offline_map_tiles',
        );
      }
    }
    if (!_baseDir!.existsSync()) {
      await _baseDir!.create(recursive: true);
    }
  }

  File _fileForTile(int z, int x, int y) {
    assert(_baseDir != null, 'TileStorage must be initialized before use');
    return File('${_baseDir!.path}/$z/$x/$y.png');
  }

  @override
  bool hasTile(int z, int x, int y) {
    if (_baseDir == null) return false;
    return _fileForTile(z, x, y).existsSync();
  }

  @override
  Uint8List? getTileBytes(int z, int x, int y) {
    if (_baseDir == null) return null;
    final file = _fileForTile(z, x, y);
    if (!file.existsSync()) return null;
    try {
      return file.readAsBytesSync();
    } on Object catch (_) {
      return null;
    }
  }

  @override
  String? getTileFilePath(int z, int x, int y) {
    if (_baseDir == null) return null;
    final file = _fileForTile(z, x, y);
    if (!file.existsSync()) return null;
    return file.path;
  }

  @override
  Future<void> saveTile(int z, int x, int y, Uint8List bytes) async {
    await init();
    final file = _fileForTile(z, x, y);
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes, flush: true);
  }

  @override
  Future<void> deleteTile(int z, int x, int y) async {
    if (_baseDir == null) return;
    final file = _fileForTile(z, x, y);
    if (file.existsSync()) {
      await file.delete();
    }
  }

  @override
  Future<void> clearAllTiles() async {
    if (_baseDir == null) return;
    if (_baseDir!.existsSync()) {
      await _baseDir!.delete(recursive: true);
      await _baseDir!.create(recursive: true);
    }
  }

  @override
  Future<int> getTotalCacheSizeBytes() async {
    if (_baseDir == null || !_baseDir!.existsSync()) return 0;
    var total = 0;
    try {
      await for (final entity in _baseDir!.list(
        recursive: true,
        followLinks: false,
      )) {
        if (entity is File) {
          total += await entity.length();
        }
      }
    } on Object catch (_) {}
    return total;
  }
}
