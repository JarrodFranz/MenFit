import 'package:flutter/material.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/core/widgets/app_bottom_sheet.dart';

/// Shows a guided dialog explaining how to connect Garmin devices to FemFit
/// via Google Health Connect (Android) or Apple Health (iOS).
Future<void> showGarminConnectDialog(BuildContext context) {
  return showAppBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => const GarminConnectSheet(),
  );
}

class GarminConnectSheet extends StatelessWidget {
  const GarminConnectSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: tokens.spacingLg,
        right: tokens.spacingLg,
        top: tokens.spacingLg,
        // Nav-bar inset is added once by `showAppBottomSheet`.
        bottom: tokens.spacingLg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          SizedBox(height: tokens.spacingMd),
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(tokens.spacingSm),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(tokens.radiusSm),
                ),
                child: Icon(
                  Icons.watch_outlined,
                  color: colorScheme.onPrimaryContainer,
                  size: 28,
                ),
              ),
              SizedBox(width: tokens.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Garmin Connect Sync',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Auto-sync steps, active calories & workouts',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: tokens.spacingLg),
          Text(
            'How to connect your Garmin watch:',
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: tokens.spacingSm),
          const _StepItem(
            stepNumber: '1',
            title: 'Open the Garmin Connect app',
            description:
                'Launch the official Garmin Connect app on your phone.',
          ),
          const _StepItem(
            stepNumber: '2',
            title: 'Navigate to Connected Apps',
            description: 'Tap More (•••) > Settings > Connected Apps.',
          ),
          const _StepItem(
            stepNumber: '3',
            title: 'Link Health Connect / Apple Health',
            description:
                'Select Health Connect (Android) or Apple Health (iOS) and '
                'enable Steps, Active Calories, and Workouts permissions.',
          ),
          const _StepItem(
            stepNumber: '4',
            title: 'Enable Sync in FemFit',
            description:
                'Turn on "Sync Fitness Device" in FemFit Settings to '
                'automatically receive all Garmin metrics.',
          ),
          SizedBox(height: tokens.spacingMd),
          Card(
            color: colorScheme.surfaceContainerHighest,
            elevation: 0,
            child: Padding(
              padding: EdgeInsets.all(tokens.spacingMd),
              child: Row(
                children: [
                  Icon(
                    Icons.file_upload_outlined,
                    color: colorScheme.primary,
                    size: 20,
                  ),
                  SizedBox(width: tokens.spacingSm),
                  Expanded(
                    child: Text(
                      'You can also import exported .gpx and .tcx activity '
                      'files directly in the Activity tab.',
                      style: textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: tokens.spacingLg),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Got it'),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  const _StepItem({
    required this.stepNumber,
    required this.title,
    required this.description,
  });

  final String stepNumber;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(bottom: tokens.spacingMd),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: colorScheme.secondaryContainer,
            child: Text(
              stepNumber,
              style: textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSecondaryContainer,
              ),
            ),
          ),
          SizedBox(width: tokens.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: tokens.spacingXs),
                Text(
                  description,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
