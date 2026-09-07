import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/app/router/routes.dart';
import 'package:menfit_app/core/platform/location/location_adapter.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/activity/presentation/manual_entry_controller.dart';
import 'package:menfit_app/features/activity/presentation/recording/hiit_tracker_controller.dart';
import 'package:menfit_app/features/activity/presentation/recording/mindful_tracker_controller.dart';
import 'package:menfit_app/features/activity/presentation/recording/strength_cycle_launcher_sheet.dart';
import 'package:menfit_app/features/activity/presentation/recording/swim_tracker_controller.dart';

/// Primary action launchers for live tracking and manual logging.
class HubActionButtons extends ConsumerWidget {
  const HubActionButtons({
    required this.type,
    required this.capabilities,
    super.key,
  });

  final ActivityType type;
  final LocationCapabilities capabilities;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens =
        Theme.of(context).extension<AppTokens>() ?? AppTokens.light();

    if (type == ActivityType.other) {
      return SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: () {
            ref
                .read(manualEntryControllerProvider.notifier)
                .setInitialType(type);
            unawaited(
              ActivityLogRouteData(type: type.toStorage()).push<void>(
                context,
              ),
            );
          },
          icon: const Icon(Icons.edit_note_outlined),
          label: const Text('Log Activity'),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: () => _startLiveWorkout(context, ref),
            icon: const Icon(Icons.play_arrow),
            label: Text(_liveButtonLabel(type)),
          ),
        ),
        SizedBox(width: tokens.spacingSm),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              ref
                  .read(manualEntryControllerProvider.notifier)
                  .setInitialType(type);
              unawaited(
                ActivityLogRouteData(type: type.toStorage()).push<void>(
                  context,
                ),
              );
            },
            icon: const Icon(Icons.edit_note_outlined),
            // Same wording as the Activity screen's pair, and the same
            // route: two names for one action read as two actions.
            label: const Text('Log Previous'),
          ),
        ),
      ],
    );
  }

  String _liveButtonLabel(ActivityType type) => switch (type) {
    ActivityType.strength => 'Strength Tracker',
    ActivityType.hiit => 'HIIT Timer',
    ActivityType.swim => 'Swim Tracker',
    ActivityType.yoga || ActivityType.pilates => 'Flow Timer',
    ActivityType.other => 'Log Activity',
    _ => 'Record GPS',
  };

  void _startLiveWorkout(BuildContext context, WidgetRef ref) {
    switch (type) {
      case ActivityType.strength:
        unawaited(StrengthCycleLauncherSheet.show(context));
      case ActivityType.hiit:
        ref.read(hiitTrackerControllerProvider.notifier).startWorkoutIfNeeded();
        unawaited(const HiitTrackerRouteData().push<void>(context));
      case ActivityType.swim:
        ref.read(swimTrackerControllerProvider.notifier).startWorkoutIfNeeded();
        unawaited(const SwimTrackerRouteData().push<void>(context));
      case ActivityType.yoga:
      case ActivityType.pilates:
        ref
            .read(mindfulTrackerControllerProvider.notifier)
            .startSessionIfNeeded(type);
        unawaited(
          MindfulTrackerRouteData(
            type: type == ActivityType.pilates ? 'pilates' : 'yoga',
          ).push<void>(context),
        );
      case ActivityType.run:
      case ActivityType.walk:
      case ActivityType.hike:
      case ActivityType.ride:
        unawaited(const ActivityRecordRouteData().push<void>(context));
      case ActivityType.other:
        ref.read(manualEntryControllerProvider.notifier).setInitialType(type);
        unawaited(
          ActivityLogRouteData(type: type.toStorage()).push<void>(context),
        );
    }
  }
}
