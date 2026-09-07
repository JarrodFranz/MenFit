import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/core/platform/wearables/ble_heart_rate_adapter.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/wearables/ble_providers.dart';

/// Reusable card or embedded column allowing users to scan for, connect to,
/// and view telemetry from Bluetooth SIG Heart Rate Service (0x180D) sensors.
class BleSensorCard extends ConsumerWidget {
  const BleSensorCard({
    super.key,
    this.showOuterCard = true,
  });

  /// When `true`, wraps the content in a Material 3 outlined [Card].
  /// When `false`, renders the inner column directly (for modal sheets).
  final bool showOuterCard;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final scanningState = ref.watch(bleScanningControllerProvider);
    final connectionState = ref.watch(bleConnectionControllerProvider);
    final isConnected = connectionState.status == BleConnectionStatus.connected;
    final isConnecting =
        connectionState.status == BleConnectionStatus.connecting;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(tokens.spacingSm),
              decoration: BoxDecoration(
                color: isConnected
                    ? colorScheme.primaryContainer
                    : colorScheme.tertiaryContainer,
                borderRadius: BorderRadius.circular(tokens.radiusSm),
              ),
              child: Icon(
                isConnected ? Icons.favorite : Icons.monitor_heart_outlined,
                color: isConnected
                    ? colorScheme.primary
                    : colorScheme.onTertiaryContainer,
                size: 24,
              ),
            ),
            SizedBox(width: tokens.spacingSm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Optical HR & BLE Sensors',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    isConnected
                        ? (connectionState.deviceName ?? 'Connected Sensor')
                        : 'Bluetooth SIG GATT 0x180D Heart Rate Service',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: tokens.spacingSm,
                vertical: tokens.spacingXs,
              ),
              decoration: BoxDecoration(
                color: isConnected
                    ? colorScheme.primaryContainer
                    : (isConnecting
                          ? colorScheme.secondaryContainer
                          : (scanningState.isScanning
                                ? colorScheme.tertiaryContainer
                                : colorScheme.surfaceContainerHighest)),
                borderRadius: BorderRadius.circular(tokens.radiusSm),
              ),
              child: Text(
                isConnected
                    ? 'Connected'
                    : (isConnecting
                          ? 'Connecting…'
                          : (scanningState.isScanning
                                ? 'Scanning…'
                                : 'Disconnected')),
                style: textTheme.labelSmall?.copyWith(
                  color: isConnected
                      ? colorScheme.onPrimaryContainer
                      : (isConnecting
                            ? colorScheme.onSecondaryContainer
                            : (scanningState.isScanning
                                  ? colorScheme.onTertiaryContainer
                                  : colorScheme.onSurfaceVariant)),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: tokens.spacingSm),
        if (isConnected) ...[
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(tokens.spacingMd),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.5,
              ),
              borderRadius: BorderRadius.circular(tokens.radiusSm),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.favorite,
                  color: Colors.redAccent,
                  size: 36,
                ),
                SizedBox(width: tokens.spacingMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            connectionState.currentBpm != null
                                ? '${connectionState.currentBpm}'
                                : '--',
                            style: textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: tokens.spacingXs),
                          Text(
                            'bpm',
                            style: textTheme.titleMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        connectionState.contactSupported
                            ? (connectionState.contactDetected
                                  ? 'Skin contact detected'
                                  : 'Sensor not on skin')
                            : 'Live optical HR streaming',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.bluetooth_disabled, size: 16),
                  label: const Text('Disconnect'),
                  onPressed: () => ref
                      .read(bleConnectionControllerProvider.notifier)
                      .disconnect(),
                ),
              ],
            ),
          ),
        ] else ...[
          Text(
            'Directly stream heart rate into your runs from Garmin watches '
            '(enable "Broadcast Heart Rate" in Garmin settings), Polar '
            'straps, Wahoo, or optical armbands.',
            style: textTheme.bodyMedium,
          ),
          if (scanningState.errorMessage != null) ...[
            SizedBox(height: tokens.spacingSm),
            Text(
              scanningState.errorMessage!,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.error,
              ),
            ),
          ],
          if (connectionState.errorMessage != null) ...[
            SizedBox(height: tokens.spacingSm),
            Text(
              connectionState.errorMessage!,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.error,
              ),
            ),
          ],
          SizedBox(height: tokens.spacingMd),
          SizedBox(
            width: double.infinity,
            child: scanningState.isScanning
                ? FilledButton.tonalIcon(
                    icon: const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    label: const Text('Stop Scanning'),
                    onPressed: () => ref
                        .read(bleScanningControllerProvider.notifier)
                        .stopScan(),
                  )
                : FilledButton.tonalIcon(
                    icon: const Icon(Icons.bluetooth_searching),
                    label: const Text('Scan for Heart Rate Sensors'),
                    onPressed: () => ref
                        .read(bleScanningControllerProvider.notifier)
                        .startScan(),
                  ),
          ),
          if (scanningState.isScanning &&
              scanningState.discoveredDevices.isEmpty) ...[
            SizedBox(height: tokens.spacingSm),
            Center(
              child: Text(
                'Searching for nearby sensors…\n'
                'Make sure "Broadcast Heart Rate" is on.',
                textAlign: TextAlign.center,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
          if (scanningState.discoveredDevices.isNotEmpty) ...[
            SizedBox(height: tokens.spacingMd),
            Text(
              'Discovered Sensors',
              style: textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: tokens.spacingXs),
            ...scanningState.discoveredDevices.map((device) {
              return Container(
                margin: EdgeInsets.only(top: tokens.spacingXs),
                padding: EdgeInsets.all(tokens.spacingSm),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(tokens.radiusSm),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.watch_outlined,
                      color: colorScheme.primary,
                      size: 20,
                    ),
                    SizedBox(width: tokens.spacingSm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            device.name.isNotEmpty
                                ? device.name
                                : 'Heart Rate Sensor',
                            style: textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${device.id} • ${device.rssi} dBm',
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    FilledButton.tonal(
                      onPressed: isConnecting
                          ? null
                          : () => ref
                                .read(
                                  bleConnectionControllerProvider.notifier,
                                )
                                .connect(device.id),
                      child: Text(
                        isConnecting ? 'Connecting…' : 'Connect',
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ],
    );

    if (!showOuterCard) {
      return content;
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radiusMd),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: EdgeInsets.all(tokens.spacingMd),
        child: content,
      ),
    );
  }
}
