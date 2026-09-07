import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/core/widgets/map_tile_provider.dart';
import 'package:menfit_app/core/widgets/map_tile_settings.dart';
import 'package:menfit_app/features/routes/domain/geo_point.dart';
import 'package:menfit_app/features/routes/routes_providers.dart';

const _startZoom = 14.0;

/// The interactive start-point map of the route-suggest flow: tap to
/// drop/move the start marker; once suggestions exist, also draws the
/// selected suggestion's polyline and keeps the camera fitted to it.
///
/// Tiles go through `mapTileProviderProvider` (`core/widgets/`) so widget
/// tests can substitute a no-network fake, and attribution follows the OSM
/// usage policy — both per the `RouteMap` conventions
/// (`features/activity/presentation/widgets/route_map.dart`).
class SuggestMap extends ConsumerStatefulWidget {
  const SuggestMap({
    required this.start,
    required this.polyline,
    required this.onTap,
    this.startLabel,
    this.onMyLocation,
    this.isLocating = false,
    super.key,
  });

  /// The chosen start point, if any.
  final GeoPoint? start;

  /// Optional readable label or address of the start point.
  final String? startLabel;

  /// The selected suggestion's geometry, or `null` before results exist.
  final List<GeoPoint>? polyline;

  final ValueChanged<GeoPoint> onTap;

  final VoidCallback? onMyLocation;
  final bool isLocating;

  @override
  ConsumerState<SuggestMap> createState() => _SuggestMapState();
}

class _SuggestMapState extends ConsumerState<SuggestMap> {
  final MapController _mapController = MapController();

  @override
  void didUpdateWidget(SuggestMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    final polyline = widget.polyline;
    if (polyline != null &&
        polyline.isNotEmpty &&
        !identical(polyline, oldWidget.polyline)) {
      final tokens = Theme.of(context).extension<AppTokens>()!;
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: LatLngBounds.fromPoints([
            for (final point in polyline) _toLatLng(point),
          ]),
          padding: EdgeInsets.all(tokens.spacingLg),
          maxZoom: 17,
        ),
      );
      return;
    }
    final start = widget.start;
    if (start != null && start != oldWidget.start && polyline == null) {
      // A fresh start point recentres the map so the marker is visible.
      _mapController.move(_toLatLng(start), _startZoom);
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final tileProvider = ref.watch(mapTileProviderProvider);
    final tileUrl = ref.watch(mapTileUrlProvider);
    final attribution = ref.watch(mapTileAttributionProvider);
    final start = widget.start;
    final polyline = widget.polyline;
    final initialTarget = ref.watch(routeInitialMapTargetProvider);

    return ClipRRect(
      borderRadius: BorderRadius.circular(tokens.radiusMd),
      child: SizedBox(
        height: 250,
        child: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: start == null
                    ? LatLng(initialTarget.latitude, initialTarget.longitude)
                    : _toLatLng(start),
                initialZoom: start == null ? initialTarget.zoom : _startZoom,
                onTap: (tapPosition, latLng) => widget.onTap(
                  GeoPoint(
                    latitude: latLng.latitude,
                    longitude: latLng.longitude,
                  ),
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: tileUrl,
                  userAgentPackageName: 'com.femfit.app',
                  tileProvider: tileProvider,
                ),
                if (polyline != null && polyline.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: [
                          for (final point in polyline) _toLatLng(point),
                        ],
                        strokeWidth: 4,
                        color: colorScheme.primary,
                      ),
                    ],
                  ),
                if (start != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _toLatLng(start),
                        width: 36,
                        height: 36,
                        alignment: Alignment.topCenter,
                        child: Icon(
                          Icons.place,
                          size: 36,
                          color: colorScheme.error,
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

            // Top hint / start point label chip
            if (widget.startLabel != null || start != null)
              Positioned(
                top: tokens.spacingSm,
                left: tokens.spacingSm,
                right: tokens.spacingSm,
                child: IgnorePointer(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.surface.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(tokens.radiusSm),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.place,
                          size: 16,
                          color: colorScheme.error,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            widget.startLabel ??
                                '${start!.latitude.toStringAsFixed(4)}, '
                                    '${start.longitude.toStringAsFixed(4)}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Bottom Right "My Location" FAB
            if (widget.onMyLocation != null)
              Positioned(
                bottom: tokens.spacingSm,
                right: tokens.spacingSm,
                child: FloatingActionButton.small(
                  heroTag: 'suggest_map_my_location',
                  onPressed: widget.isLocating ? null : widget.onMyLocation,
                  backgroundColor: colorScheme.surface,
                  foregroundColor: colorScheme.primary,
                  elevation: 2,
                  child: widget.isLocating
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.my_location, size: 20),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

LatLng _toLatLng(GeoPoint point) => LatLng(point.latitude, point.longitude);
