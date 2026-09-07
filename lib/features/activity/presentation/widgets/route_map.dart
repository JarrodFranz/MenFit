import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:menfit_app/core/theme/breakpoints.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/core/widgets/map_tile_provider.dart';
import 'package:menfit_app/core/widgets/map_tile_settings.dart';
import 'package:menfit_app/features/activity/domain/activity_sample.dart';

// The tile-provider seam (`mapTileProviderProvider`) moved to
// `core/widgets/map_tile_provider.dart` when the routes feature grew its
// own maps (ADR 007 forbids cross-feature presentation imports); this
// export keeps the many existing `route_map.dart` import sites (tests
// especially) working unchanged.
export 'package:menfit_app/core/widgets/map_tile_provider.dart';

/// The fixed map height for the given layout [width], shared between
/// [RouteMap] and the detail screen's loading/empty placeholders so
/// switching between states never causes a layout jump.
double routeMapHeight(double width) =>
    WindowSize.fromWidth(width).isAtLeastExpanded ? 360.0 : 280.0;

/// Renders the recorded route for a `recorded` activity: a polyline through
/// [samples]' GPS points, small start/end markers, and OSM attribution.
///
/// Callers must gate on [samples] being non-empty - this widget assumes at
/// least one point (see `activity_detail_screen.dart`, which shows a "No
/// route data" placeholder instead when there are none).
///
/// Known v1 limitation: standard OSM tiles are used in both light and dark
/// theme (no tile color filter/inversion) - accepted for v1 per
/// `knowledge/research/run_tracking_stack.md#map-tiles`; revisit only if a
/// dark-friendly tile source arrives via the (deferred) production tile
/// provider swap.
class RouteMap extends ConsumerWidget {
  const RouteMap({required this.samples, super.key});

  final List<ActivitySample> samples;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    assert(samples.isNotEmpty, 'RouteMap requires at least one sample');
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final tileProvider = ref.watch(mapTileProviderProvider);
    final tileUrl = ref.watch(mapTileUrlProvider);
    final attribution = ref.watch(mapTileAttributionProvider);

    final points = [
      for (final sample in samples) LatLng(sample.latitude, sample.longitude),
    ];
    final bounds = LatLngBounds.fromPoints(points);

    return LayoutBuilder(
      builder: (context, constraints) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(tokens.radiusMd),
          child: SizedBox(
            height: routeMapHeight(constraints.maxWidth),
            child: FlutterMap(
              options: MapOptions(
                initialCameraFit: CameraFit.bounds(
                  bounds: bounds,
                  padding: EdgeInsets.all(tokens.spacingLg),
                  // A degenerate (single-point) bounds would otherwise
                  // resolve to an unbounded zoom - cap it at a sensible
                  // street-level maximum.
                  maxZoom: 18,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: tileUrl,
                  userAgentPackageName: 'com.femfit.app',
                  tileProvider: tileProvider,
                ),
                PolylineLayer(
                  // `Polyline.strokeCap` already defaults to
                  // `StrokeCap.round` ("rounded caps" per spec).
                  polylines: [
                    Polyline(
                      points: points,
                      strokeWidth: 4,
                      color: colorScheme.primary,
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: points.first,
                      width: 16,
                      height: 16,
                      child: _EndpointDot(color: tokens.success),
                    ),
                    Marker(
                      point: points.last,
                      width: 16,
                      height: 16,
                      child: _EndpointDot(color: colorScheme.error),
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

/// A small filled circle marking the route's start or end point.
class _EndpointDot extends StatelessWidget {
  const _EndpointDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).colorScheme.surface,
          width: 2,
        ),
      ),
    );
  }
}
