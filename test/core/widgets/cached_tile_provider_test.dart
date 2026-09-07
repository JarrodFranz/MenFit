import 'dart:typed_data';

import 'package:flutter/painting.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/widgets/cached_tile_provider.dart';
import 'package:menfit_app/features/routes/data/tile_storage_stub.dart';

void main() {
  group('CachedTileProvider', () {
    late MemoryTileStorage storage;
    late CachedTileProvider provider;

    setUp(() {
      storage = MemoryTileStorage();
      provider = CachedTileProvider(storage: storage);
    });

    test('serves cached image when tile exists in storage', () async {
      // Seed a tile
      final tileBytes = Uint8List.fromList([1, 2, 3, 4]);
      await storage.saveTile(14, 100, 200, tileBytes);

      const coords = TileCoordinates(100, 200, 14);
      final options = TileLayer(
        urlTemplate: 'https://tiles.example.com/{z}/{x}/{y}.png',
      );

      final image = provider.getImage(coords, options);
      expect(image, isA<MemoryImage>());
      final memoryImage = image as MemoryImage;
      expect(memoryImage.bytes, tileBytes);
    });

    test('falls back to NetworkImage when tile is not in storage', () {
      const coords = TileCoordinates(101, 201, 14);
      final options = TileLayer(
        urlTemplate: 'https://tiles.example.com/{z}/{x}/{y}.png',
      );

      final image = provider.getImage(coords, options);
      expect(image, isA<NetworkImage>());
      final networkImage = image as NetworkImage;
      expect(networkImage.url, 'https://tiles.example.com/14/101/201.png');
    });
  });
}
