import 'package:menfit_app/core/platform/location/geolocator_location_adapter.dart';
import 'package:menfit_app/core/platform/location/location_adapter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'location_providers.g.dart';

/// The app's single [LocationAdapter] instance.
@Riverpod(keepAlive: true)
LocationAdapter locationAdapter(Ref ref) {
  return const GeolocatorLocationAdapter();
}
