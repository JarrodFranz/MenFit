import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:menfit_app/core/config/env.dart';
import 'package:menfit_app/core/platform/location/location_fix.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/core/widgets/map_tile_provider.dart';
import 'package:menfit_app/features/routes/domain/geo_point.dart';

/// Live interactive map shown while recording an activity.
///
/// Displays:
/// 1. The target route polyline (when following a saved route).
/// 2. The live recorded breadcrumb path.
/// 3. The current user location marker.
/// 4. Auto-center following with a manual pan detector and recenter button.
class LiveRecordingMap extends ConsumerStatefulWidget {
  const LiveRecordingMap({
    required this.currentFix,
    required this.trackPoints,
    this.plannedRoutePoints,
    this.isAutoPaused = false,
    super.key,
  });

  final LocationFix? currentFix;
  final List<LocationFix> trackPoints;
  final List<GeoPoint>? plannedRoutePoints;
  final bool isAutoPaused;

  @override
  ConsumerState<LiveRecordingMap> createState() => _LiveRecordingMapState();
}

class _LiveRecordingMapState extends ConsumerState<LiveRecordingMap> {
  late final MapController _mapController;
  bool _isFollowing = true;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void didUpdateWidget(LiveRecordingMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isFollowing && widget.currentFix != null) {
      final fix = widget.currentFix!;
      final newCenter = LatLng(fix.latitude, fix.longitude);
      _mapController.move(newCenter, _mapController.camera.zoom);
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _recenter() {
    setState(() => _isFollowing = true);
    if (widget.currentFix != null) {
      final fix = widget.currentFix!;
      _mapController.move(LatLng(fix.latitude, fix.longitude), 16.5);
    } else if (widget.plannedRoutePoints != null &&
        widget.plannedRoutePoints!.isNotEmpty) {
      final first = widget.plannedRoutePoints!.first;
      _mapController.move(LatLng(first.latitude, first.longitude), 15);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final tileProvider = ref.watch(mapTileProviderProvider);

    final trackLatLngs = [
      for (final fix in widget.trackPoints) LatLng(fix.latitude, fix.longitude),
    ];

    final plannedLatLngs = [
      if (widget.plannedRoutePoints != null)
        for (final pt in widget.plannedRoutePoints!)
          LatLng(pt.latitude, pt.longitude),
    ];

    final LatLng initialCenter;
    final double initialZoom;

    if (widget.currentFix != null) {
      initialCenter = LatLng(
        widget.currentFix!.latitude,
        widget.currentFix!.longitude,
      );
      initialZoom = 16;
    } else if (plannedLatLngs.isNotEmpty) {
      initialCenter = plannedLatLngs.first;
      initialZoom = 15;
    } else {
      // Default fallback coordinates before first fix
      initialCenter = const LatLng(0, 0);
      initialZoom = 3;
    }

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: initialCenter,
            initialZoom: initialZoom,
            onPositionChanged: (position, hasGesture) {
              if (hasGesture && _isFollowing) {
                setState(() => _isFollowing = false);
              }
            },
          ),
          children: [
            TileLayer(
              urlTemplate: AppEnv.instance.mapTileUrl,
              userAgentPackageName: 'com.menfit.app',
              tileProvider: tileProvider,
            ),
            if (plannedLatLngs.isNotEmpty)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: plannedLatLngs,
                    strokeWidth: 5,
                    color: colorScheme.secondary.withValues(alpha: 0.65),
                  ),
                ],
              ),
            if (trackLatLngs.isNotEmpty)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: trackLatLngs,
                    strokeWidth: 4.5,
                    color: colorScheme.primary,
                  ),
                ],
              ),
            MarkerLayer(
              markers: [
                if (plannedLatLngs.isNotEmpty)
                  Marker(
                    point: plannedLatLngs.first,
                    width: 14,
                    height: 14,
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
                if (widget.currentFix != null)
                  Marker(
                    point: LatLng(
                      widget.currentFix!.latitude,
                      widget.currentFix!.longitude,
                    ),
                    width: 28,
                    height: 28,
                    child: _LiveLocationDot(
                      isAutoPaused: widget.isAutoPaused,
                    ),
                  ),
              ],
            ),
            const RichAttributionWidget(
              attributions: [
                TextSourceAttribution(
                  'Google Maps, OpenStreetMap contributors',
                ),
              ],
              showFlutterMapAttribution: false,
            ),
          ],
        ),
        // Floating map overlay controls
        Positioned(
          bottom: tokens.spacingMd,
          right: tokens.spacingMd,
          child: FloatingActionButton.small(
            heroTag: 'recenterMapFab',
            key: const Key('recenterMapFab'),
            onPressed: _recenter,
            backgroundColor: _isFollowing
                ? colorScheme.primary
                : colorScheme.surfaceContainerHighest,
            foregroundColor: _isFollowing
                ? colorScheme.onPrimary
                : colorScheme.onSurfaceVariant,
            tooltip: _isFollowing ? 'Tracking location' : 'Recenter location',
            child: Icon(
              _isFollowing ? Icons.my_location : Icons.location_searching,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }
}

class _LiveLocationDot extends StatelessWidget {
  const _LiveLocationDot({required this.isAutoPaused});

  final bool isAutoPaused;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final dotColor = isAutoPaused ? tokens.warning : colorScheme.primary;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer halo
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: dotColor.withValues(alpha: 0.25),
          ),
        ),
        // Inner solid core
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: dotColor,
            border: Border.all(color: colorScheme.surface, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
