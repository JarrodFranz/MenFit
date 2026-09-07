import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:menfit_app/features/routes/data/tile_storage.dart';

/// A [TileProvider] that prioritizes on-device cached map tiles before
/// falling back to [NetworkImage].
class CachedTileProvider extends TileProvider {
  CachedTileProvider({required this.storage});

  final TileStorage storage;

  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) {
    final z = coordinates.z;
    final x = coordinates.x;
    final y = coordinates.y;

    if (storage.hasTile(z, x, y)) {
      if (!kIsWeb) {
        final path = storage.getTileFilePath(z, x, y);
        if (path != null) {
          return FileImage(File(path));
        }
      }
      final bytes = storage.getTileBytes(z, x, y);
      if (bytes != null) {
        return MemoryImage(bytes);
      }
    }

    final url = getTileUrl(coordinates, options);
    return NetworkImage(url);
  }
}
