import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/health/presentation/watch_vitals_controller.dart';

/// Latest watch readings from Health Connect / Apple Health, read on demand
/// and never stored.
class WatchVitalsCard extends ConsumerWidget {
  const WatchVitalsCard({super.key});

  static const unsupportedText =
      'Watch data needs Health Connect on Android or Apple Health on iPhone.';
  static const permissionText =
      'MenFit can read heart rate, resting heart rate, blood oxygen, sleep, '
      'heart-rate variability and respiratory rate from your watch; they are '
      'shown here only and stay on this device.';
  static const emptyText = 'No recent watch data.';
  static const errorText = 'Watch data could not be read.';
  static const caption =
      'From your watch via Health Connect / Apple Health. Not for medical use.';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final textTheme = Theme.of(context).textTheme;
    final vitals = ref.watch(watchVitalsControllerProvider);
    final controller = ref.read(watchVitalsControllerProvider.notifier);
    final unsupported = vitals.value?.status == WatchVitalsStatus.unsupported;

    final body = switch (vitals) {
      AsyncData(:final value) => switch (value.status) {
        WatchVitalsStatus.unsupported => const Text(unsupportedText),
        WatchVitalsStatus.needsPermission => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(permissionText),
            SizedBox(height: tokens.spacingSm),
            FilledButton(
              onPressed: controller.connect,
              child: const Text('Connect watch data'),
            ),
          ],
        ),
        WatchVitalsStatus.empty => const Text(emptyText),
        WatchVitalsStatus.data => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final row in watchVitalRows(value.snapshot!))
              _VitalRow(row: row),
          ],
        ),
      },
      AsyncError() => const Text(errorText),
      _ => const LinearProgressIndicator(),
    };

    return Card(
      child: Padding(
        padding: EdgeInsets.all(tokens.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('Watch data', style: textTheme.titleLarge),
                ),
                if (!unsupported)
                  IconButton(
                    tooltip: 'Refresh watch data',
                    icon: const Icon(Icons.refresh),
                    onPressed: vitals.isLoading ? null : controller.refresh,
                  ),
              ],
            ),
            SizedBox(height: tokens.spacingSm),
            body,
            if (!unsupported) ...[
              SizedBox(height: tokens.spacingSm),
              Text(caption, style: textTheme.bodySmall),
            ],
          ],
        ),
      ),
    );
  }
}

class _VitalRow extends StatelessWidget {
  const _VitalRow({required this.row});

  final WatchVitalRow row;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final textTheme = Theme.of(context).textTheme;
    final label = [row.label, row.value, row.detail, row.asOf].nonNulls;
    return Semantics(
      container: true,
      label: label.join(', '),
      excludeSemantics: true,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: tokens.spacingXs),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(row.label, style: textTheme.titleSmall),
            Text('${row.value} · ${row.asOf}', style: textTheme.bodyLarge),
            if (row.detail case final detail?)
              Text(detail, style: textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
