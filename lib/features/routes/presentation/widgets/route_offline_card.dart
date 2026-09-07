import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/routes/data/route_tile_cache_service.dart';
import 'package:menfit_app/features/routes/domain/route_tile_calculator.dart';
import 'package:menfit_app/features/routes/domain/saved_route.dart';
import 'package:menfit_app/features/routes/route_cache_providers.dart';

/// Card managing offline map tile downloads along a saved route.
class RouteOfflineCard extends ConsumerWidget {
  const RouteOfflineCard({required this.route, super.key});

  final SavedRoute route;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final metadata = ref.watch(routeCacheMetadataProvider(route.id));
    final downloads = ref.watch(routeTileDownloadControllerProvider);
    final activeDownload = downloads[route.id];

    final isDownloading =
        activeDownload?.status == RouteTileDownloadStatus.inProgress;
    final isCached = metadata != null && !isDownloading;

    return Container(
      padding: EdgeInsets.all(tokens.spacingMd),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(tokens.radiusMd),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCached ? Icons.offline_pin : Icons.cloud_download_outlined,
                color: isCached ? tokens.success : colorScheme.primary,
                size: 22,
              ),
              SizedBox(width: tokens.spacingSm),
              Expanded(
                child: Text(
                  isCached ? 'Offline map ready' : 'Offline trail map',
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (isCached)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: tokens.spacingSm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: tokens.success.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(tokens.radiusSm),
                  ),
                  child: Text(
                    'Cached',
                    style: textTheme.labelSmall?.copyWith(
                      color: tokens.success,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: tokens.spacingXs),
          Text(
            isCached
                ? 'Stored on-device for navigation in low-reception zones.'
                : 'Cache map tiles along this route before heading '
                      'onto trails.',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: tokens.spacingMd),
          if (isDownloading && activeDownload != null) ...[
            LinearProgressIndicator(
              value: activeDownload.fraction,
              borderRadius: BorderRadius.circular(tokens.radiusSm),
            ),
            SizedBox(height: tokens.spacingXs),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: tokens.spacingSm,
              runSpacing: tokens.spacingXs,
              children: [
                Text(
                  'Downloading ${activeDownload.downloadedTiles} of '
                  '${activeDownload.totalTiles} tiles '
                  '(${(activeDownload.fraction * 100).toStringAsFixed(0)}%)',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                TextButton(
                  onPressed: () => ref
                      .read(routeTileDownloadControllerProvider.notifier)
                      .cancelDownload(route.id),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ] else if (isCached) ...[
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: tokens.spacingSm,
              runSpacing: tokens.spacingXs,
              children: [
                Text(
                  '${metadata.tileCount} tiles · '
                  '${(metadata.sizeBytes / (1024 * 1024)).toStringAsFixed(1)}'
                  ' MB',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.refresh, size: 20),
                      tooltip: 'Refresh tiles',
                      onPressed: () => _startDownload(ref),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      tooltip: 'Clear cache',
                      onPressed: () => _clearCache(ref),
                    ),
                  ],
                ),
              ],
            ),
          ] else ...[
            _NotCachedActions(
              route: route,
              onDownload: () => _startDownload(ref),
            ),
          ],
        ],
      ),
    );
  }

  void _startDownload(WidgetRef ref) {
    if (route.points.isEmpty) return;
    unawaited(
      ref
          .read(routeTileDownloadControllerProvider.notifier)
          .startDownload(routeId: route.id, points: route.points),
    );
  }

  void _clearCache(WidgetRef ref) {
    unawaited(
      ref
          .read(routeTileDownloadControllerProvider.notifier)
          .deleteCache(routeId: route.id, points: route.points),
    );
  }
}

class _NotCachedActions extends StatelessWidget {
  const _NotCachedActions({
    required this.route,
    required this.onDownload,
  });

  final SavedRoute route;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final estimatedTiles = RouteTileCalculator.computeRouteCorridorTiles(
      route.points,
    ).length;
    final estimatedMb =
        (RouteTileCalculator.estimateSizeBytes(estimatedTiles) / (1024 * 1024))
            .toStringAsFixed(1);

    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: tokens.spacingSm,
      runSpacing: tokens.spacingSm,
      children: [
        Text(
          '~$estimatedMb MB ($estimatedTiles tiles)',
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        FilledButton.tonalIcon(
          onPressed: route.points.isEmpty ? null : onDownload,
          icon: const Icon(Icons.download, size: 18),
          label: const Text('Download for offline'),
          style: FilledButton.styleFrom(
            padding: EdgeInsets.symmetric(
              horizontal: tokens.spacingMd,
              vertical: tokens.spacingXs,
            ),
          ),
        ),
      ],
    );
  }
}
