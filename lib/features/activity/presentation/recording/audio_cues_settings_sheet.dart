import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/core/domain/units.dart';
import 'package:menfit_app/core/platform/speech/speech_providers.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/core/widgets/app_bottom_sheet.dart';
import 'package:menfit_app/features/activity/activity_providers.dart';
import 'package:menfit_app/features/activity/domain/audio_coaching/audio_coaching_settings.dart';
import 'package:menfit_app/features/activity/presentation/recording/audio_coaching_controller.dart';

/// Modal sheet for configuring live audio coaching cues during GPS recordings.
class AudioCuesSettingsSheet extends ConsumerWidget {
  const AudioCuesSettingsSheet({super.key});

  /// Shows the audio cues settings bottom sheet.
  static Future<void> show(BuildContext context) {
    return showAppBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AudioCuesSettingsSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppTokens>()!;
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final settings = ref.watch(audioCoachingControllerProvider);
    final controller = ref.read(audioCoachingControllerProvider.notifier);
    final unitSystem =
        ref.watch(activityUnitSystemProvider).value ?? UnitSystem.metric;
    final isMetric = unitSystem == UnitSystem.metric;
    final unitLabel = isMetric ? 'km' : 'mi';

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
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: tokens.spacingMd,
                  vertical: tokens.spacingSm,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.record_voice_over_rounded,
                          color: colorScheme.primary,
                        ),
                        SizedBox(width: tokens.spacingSm),
                        Text(
                          'Audio Coaching Cues',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(tokens.spacingMd),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Master Enable Switch
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Live Audio Cues'),
                        subtitle: const Text(
                          'Hear spoken splits, pace, and status changes '
                          'during outdoor workouts.',
                        ),
                        value: settings.enabled,
                        onChanged: (enabled) => unawaited(
                          controller.toggleEnabled(enabled: enabled),
                        ),
                      ),
                      if (settings.enabled) ...[
                        const Divider(height: 24),

                        // Sound Mode (Voice & Chime / Voice / Chime)
                        Text(
                          'Sound Mode',
                          style: textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: tokens.spacingSm),
                        SegmentedButton<AudioCueMode>(
                          segments: [
                            for (final mode in AudioCueMode.values)
                              ButtonSegment(
                                value: mode,
                                label: Text(mode.label),
                              ),
                          ],
                          selected: {settings.cueMode},
                          onSelectionChanged: (selected) => unawaited(
                            controller.setCueMode(selected.first),
                          ),
                        ),
                        SizedBox(height: tokens.spacingMd),

                        // Interval selection
                        Text(
                          'Announcement Interval',
                          style: textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: tokens.spacingSm),
                        Wrap(
                          spacing: tokens.spacingSm,
                          children: [
                            ChoiceChip(
                              label: Text(
                                isMetric ? 'Every 500 m' : 'Every 0.5 mi',
                              ),
                              selected:
                                  settings.splitIntervalMeters ==
                                  (isMetric ? 500.0 : 804.672),
                              onSelected: (selected) {
                                unawaited(
                                  controller.setSplitIntervalMeters(
                                    selected
                                        ? (isMetric ? 500.0 : 804.672)
                                        : null,
                                  ),
                                );
                              },
                            ),
                            ChoiceChip(
                              label: Text('Every 1 $unitLabel (Default)'),
                              selected:
                                  settings.splitIntervalMeters == null ||
                                  settings.splitIntervalMeters ==
                                      (isMetric ? 1000.0 : 1609.344),
                              onSelected: (_) {
                                unawaited(
                                  controller.setSplitIntervalMeters(null),
                                );
                              },
                            ),
                            ChoiceChip(
                              label: Text(
                                isMetric ? 'Every 2 km' : 'Every 2 mi',
                              ),
                              selected:
                                  settings.splitIntervalMeters ==
                                  (isMetric ? 2000.0 : 3218.688),
                              onSelected: (selected) {
                                unawaited(
                                  controller.setSplitIntervalMeters(
                                    selected
                                        ? (isMetric ? 2000.0 : 3218.688)
                                        : null,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: tokens.spacingMd),

                        // Detail Toggles
                        Text(
                          'Included Announcements',
                          style: textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Split Announcements'),
                          subtitle: const Text(
                            'Spoken time and pace updates every interval.',
                          ),
                          value: settings.announceSplits,
                          onChanged: (val) => unawaited(
                            controller.setAnnounceSplits(announce: val),
                          ),
                        ),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Split Pace'),
                          subtitle: Text(
                            'Announce average pace per $unitLabel '
                            'for each interval.',
                          ),
                          value: settings.announcePace,
                          onChanged: (val) => unawaited(
                            controller.setAnnouncePace(announce: val),
                          ),
                        ),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Workout Status Changes'),
                          subtitle: const Text(
                            'Announce when recording starts, pauses, '
                            'auto-pauses, and resumes.',
                          ),
                          value: settings.announceStatusChanges,
                          onChanged: (val) => unawaited(
                            controller.setAnnounceStatusChanges(announce: val),
                          ),
                        ),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Distance Milestones'),
                          subtitle: const Text(
                            'Celebrate reaching 5 km, 10 km, '
                            'and half marathon distances.',
                          ),
                          value: settings.announceMilestones,
                          onChanged: (val) => unawaited(
                            controller.setAnnounceMilestones(announce: val),
                          ),
                        ),
                        SizedBox(height: tokens.spacingMd),

                        // Test Voice Button
                        Center(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.volume_up_rounded),
                            label: const Text('Test Voice'),
                            onPressed: () {
                              unawaited(
                                ref
                                    .read(speechAdapterProvider)
                                    .speak(
                                      'Split 1. 1 kilometer. '
                                      '5 minutes 12 seconds.',
                                    ),
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
