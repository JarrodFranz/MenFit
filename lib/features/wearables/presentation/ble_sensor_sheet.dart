import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/core/platform/wearables/ble_heart_rate_adapter.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/core/widgets/app_bottom_sheet.dart';
import 'package:menfit_app/features/wearables/ble_providers.dart';
import 'package:menfit_app/features/wearables/presentation/widgets/ble_sensor_card.dart';

/// Modal bottom sheet for scanning, connecting, and viewing telemetry from
/// Bluetooth heart rate monitors (Garmin, Polar, Wahoo, Apple Watch / WearOS).
class BleSensorSheet extends ConsumerWidget {
  const BleSensorSheet({super.key});

  /// Shows the heart rate sensor bottom sheet.
  static Future<void> show(BuildContext context) {
    return showAppBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const BleSensorSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppTokens>()!;
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final connectionState = ref.watch(bleConnectionControllerProvider);
    final isConnected = connectionState.status == BleConnectionStatus.connected;

    return Material(
      color: theme.scaffoldBackgroundColor,
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(tokens.radiusLg),
      ),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle
              Container(
                margin: EdgeInsets.only(top: tokens.spacingSm),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: EdgeInsets.fromLTRB(
                  tokens.spacingLg,
                  tokens.spacingSm,
                  tokens.spacingSm,
                  tokens.spacingXs,
                ),
                child: Row(
                  children: [
                    Icon(
                      isConnected
                          ? Icons.favorite
                          : Icons.monitor_heart_outlined,
                      color: isConnected ? Colors.redAccent : null,
                      size: 24,
                    ),
                    SizedBox(width: tokens.spacingSm),
                    Expanded(
                      child: Text(
                        'Heart Rate Sensors',
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      key: const Key('bleSensorSheetCloseButton'),
                      icon: const Icon(Icons.close),
                      tooltip: 'Close',
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Scrollable Sensor Management Content
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(tokens.spacingLg),
                  child: const BleSensorCard(showOuterCard: false),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
