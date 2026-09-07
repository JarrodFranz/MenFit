import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:menfit_app/core/theme/breakpoints.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/core/widgets/map_tile_provider.dart';
import 'package:menfit_app/core/widgets/map_tile_settings.dart';
import 'package:menfit_app/features/routes/domain/geo_point.dart';

/// Renders a saved route's geometry: a polyline through [points], a
/// start/finish marker (round trips start where they end), and OSM
/// attribution — the routes-feature sibling of `RouteMap`
/// (`features/activity/presentation/widgets/route_map.dart`), which ADR
/// 007 forbids importing across features. Same conventions: injectable
/// tile provider (`core/widgets/map_tile_provider.dart`) and a fixed
/// per-breakpoint height so surrounding layout never jumps.
///
/// Callers must gate on [points] being non-empty.
class RoutePolylineMap extends ConsumerWidget {
  const RoutePolylineMap({required this.points, super.key});

  final List<GeoPoint> points;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    assert(points.isNotEmpty, 'RoutePolylineMap requires at least one point');
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final tileProvider = ref.watch(mapTileProviderProvider);
    final tileUrl = ref.watch(mapTileUrlProvider);
    final attribution = ref.watch(mapTileAttributionProvider);

    final latLngs = [
      for (final point in points) LatLng(point.latitude, point.longitude),
    ];
    final bounds = LatLngBounds.fromPoints(latLngs);

    return LayoutBuilder(
      builder: (context, constraints) {
        final height =
            WindowSize.fromWidth(
              constraints.maxWidth,
            ).isAtLeastExpanded
            ? 360.0
            : 280.0;
        return ClipRRect(
          borderRadius: BorderRadius.circular(tokens.radiusMd),
          child: SizedBox(
            height: height,
            child: FlutterMap(
              options: MapOptions(
                initialCameraFit: CameraFit.bounds(
                  bounds: bounds,
                  padding: EdgeInsets.all(tokens.spacingLg),
                  // A degenerate (single-point) bounds would otherwise
                  // resolve to an unbounded zoom.
                  maxZoom: 18,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: tileUrl,
                  userAgentPackageName: 'com.menfit.app',
                  tileProvider: tileProvider,
                ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: latLngs,
                      strokeWidth: 4,
                      color: colorScheme.primary,
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: latLngs.first,
                      width: 16,
                      height: 16,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: tokens.success,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colorScheme.surface,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                RichAttributionWidget(
                  attributions: [
                    TextSourceAttribution(attribution),
                  ],
                  showFlutterMapAttribution: false,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
