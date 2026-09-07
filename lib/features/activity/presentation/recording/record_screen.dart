import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/app/router/routes.dart';
import 'package:menfit_app/core/domain/units.dart';
import 'package:menfit_app/core/platform/location/location_adapter.dart';
import 'package:menfit_app/core/platform/location/location_providers.dart';
import 'package:menfit_app/core/platform/wearables/ble_heart_rate_adapter.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/activity/activity_providers.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/activity/domain/milestone_evaluator.dart';
import 'package:menfit_app/features/activity/domain/pace_format.dart';
import 'package:menfit_app/features/activity/presentation/recording/audio_cues_settings_sheet.dart';
import 'package:menfit_app/features/activity/presentation/recording/recording_controller.dart';
import 'package:menfit_app/features/activity/presentation/widgets/live_recording_map.dart';
import 'package:menfit_app/features/activity/presentation/widgets/workout_celebration_dialog.dart';
import 'package:menfit_app/features/routes/domain/elevation_format.dart';
import 'package:menfit_app/features/routes/domain/saved_route.dart';
import 'package:menfit_app/features/routes/routes_providers.dart';
import 'package:menfit_app/features/safety/presentation/widgets/safety_warning_dialog.dart';
import 'package:menfit_app/features/safety/safety_providers.dart';
import 'package:menfit_app/features/wearables/ble_providers.dart';
import 'package:menfit_app/features/wearables/presentation/ble_sensor_sheet.dart';

/// Full-screen GPS recording flow: pick a type and start, watch live stats
/// while recording, then finish (saves) or discard.
///
/// Reached at `/activity/record`, deliberately OUTSIDE the main navigation
/// shell (same pattern as `/onboarding` — see `flutter_patterns.md`): no
/// bottom nav/rail chrome while recording, and [PopScope] blocks the back
/// gesture once a recording is in progress so it can't be swiped away by
/// accident.
///
/// This widget deliberately does **not** override
/// `didChangeAppLifecycleState` to tear down the fix subscription on
/// `hidden`/`paused` — the generic guidance in `app-lifecycle.md` ("stop
/// streams on pause") does not apply here. Recording is designed to keep
/// running with the screen off/backgrounded (Android foreground-service
/// notification, iOS `allowBackgroundLocationUpdates` — ADR 008); the
/// subscription lives on `RecordingController`, a `keepAlive` provider, and
/// is only ever cancelled by [RecordingController.finish] or
/// [RecordingController.discard].
class RecordScreen extends ConsumerStatefulWidget {
  const RecordScreen({this.routeId, super.key});

  /// The saved route being followed, when reached via
  /// `/activity/record?route-id=...` (see `RouteSuggestScreen`'s "Start
  /// now" / `RouteDetailScreen`'s start button). Shown as a "Following"
  /// chip on the pre-start view and stamped onto the finished activity; no
  /// live route overlay during recording yet (deferred).
  final String? routeId;

  @override
  ConsumerState<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends ConsumerState<RecordScreen> {
  ActivityType _selectedType = ActivityType.run;
  String? _activeRouteId;

  @override
  void initState() {
    super.initState();
    _activeRouteId = widget.routeId;
    // Re-entering `/activity/record` (e.g. via back-navigation after a
    // previous recording finished) must always start clean - a lingering
    // `saved`/`discarded` state from the last recording would otherwise
    // leave stale stats/ids around until the next `start()` call resets
    // them itself. Deferred to a post-frame callback since `reset()` calls
    // `notifyListeners` (via the Riverpod state setter), which isn't legal
    // synchronously during `initState`/build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final lifecycle = ref.read(recordingControllerProvider).lifecycle;
      if (lifecycle == RecordingLifecycle.saved ||
          lifecycle == RecordingLifecycle.discarded) {
        ref.read(recordingControllerProvider.notifier).reset();
      }
    });
  }

  @override
  void didUpdateWidget(RecordScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.routeId != oldWidget.routeId) {
      _activeRouteId = widget.routeId;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(recordingControllerProvider);
    final controller = ref.read(recordingControllerProvider.notifier);
    final unitSystem =
        ref.watch(activityUnitSystemProvider).value ?? UnitSystem.metric;
    final capabilities = ref.read(locationAdapterProvider).capabilities;

    final followedRoute = _activeRouteId == null
        ? null
        : ref.watch(routeByIdProvider(_activeRouteId!)).value;

    ref.listen(recordingControllerProvider, (previous, next) {
      final justSaved =
          next.lifecycle == RecordingLifecycle.saved &&
          previous?.lifecycle != RecordingLifecycle.saved;
      if (justSaved && next.savedActivityId != null) {
        final activityId = next.savedActivityId!;
        final activityRepo = ref.read(activityRepositoryProvider);
        final priorRecords = ref.read(personalRecordsProvider).value;

        unawaited(() async {
          final activity = await activityRepo.getActivity(activityId);
          if (activity != null && context.mounted) {
            final milestones = const MilestoneEvaluator()
                .evaluateCardioMilestones(
                  newActivity: activity,
                  priorRecords: priorRecords,
                );
            await WorkoutCelebrationDialog.show(
              context,
              activity: activity,
              milestones: milestones,
              onViewDetails: () {
                ActivityDetailRouteData(activityId).go(context);
              },
              onDone: () {
                const ActivityRouteData().go(context);
              },
            );
          } else if (context.mounted) {
            ActivityDetailRouteData(activityId).go(context);
          }
        }());
        return;
      }
      final justDiscarded =
          next.lifecycle == RecordingLifecycle.discarded &&
          previous?.lifecycle != RecordingLifecycle.discarded;
      if (justDiscarded) {
        const ActivityRouteData().go(context);
      }

      final safetyNotifier = ref.read(safetyMonitorControllerProvider.notifier);
      final contacts = ref.read(trustedContactsControllerProvider);
      final safetyPrefs = ref.read(safetyPreferencesControllerProvider);
      final isSafetyEnabled =
          contacts.isNotEmpty &&
          (safetyPrefs.checkinTimerEnabled ||
              safetyPrefs.inactivityAlertEnabled);

      if (next.lifecycle == RecordingLifecycle.recording &&
          previous?.lifecycle != RecordingLifecycle.recording) {
        if (isSafetyEnabled) {
          safetyNotifier.arm();
        }
      } else if (next.lifecycle == RecordingLifecycle.saved ||
          next.lifecycle == RecordingLifecycle.discarded) {
        safetyNotifier.disarm();
      }

      if (isSafetyEnabled) {
        if (next.latestFix != null && next.latestFix != previous?.latestFix) {
          safetyNotifier.updateLocation(next.latestFix!);
        }

        if (next.elapsedTime != previous?.elapsedTime) {
          safetyNotifier.evaluateTimers();
        }
      }
    });

    ref.listen(safetyMonitorControllerProvider, (previous, next) {
      final contacts = ref.read(trustedContactsControllerProvider);
      if (contacts.isNotEmpty &&
          next.isWarningActive &&
          !(previous?.isWarningActive ?? false)) {
        unawaited(showSafetyWarningDialog(context));
      }
    });

    final isPreStart = state.lifecycle == RecordingLifecycle.idle;
    final isSaveFailed = state.lifecycle == RecordingLifecycle.saveFailed;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        const ActivityRouteData().go(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            isPreStart
                ? 'Record'
                : (state.activityType != null
                      ? 'Recording ${state.activityType!.label}'
                      : 'Recording'),
          ),
          leading: IconButton(
            key: const Key('recordCloseAction'),
            icon: Icon(isPreStart ? Icons.close : Icons.arrow_back),
            tooltip: isPreStart ? 'Close' : 'Minimize to background',
            onPressed: () => const ActivityRouteData().go(context),
          ),
          actions: [
            if (!isPreStart)
              IconButton(
                key: const Key('recordEmergencySosAction'),
                icon: Icon(
                  Icons.sos,
                  color: Theme.of(context).colorScheme.error,
                ),
                tooltip: 'Emergency SOS',
                onPressed: () {
                  unawaited(
                    ref
                        .read(safetyMonitorControllerProvider.notifier)
                        .triggerSos(),
                  );
                },
              ),
            IconButton(
              key: const Key('recordAudioCuesAction'),
              icon: const Icon(Icons.volume_up_outlined),
              tooltip: 'Audio coaching cues',
              onPressed: () => AudioCuesSettingsSheet.show(context),
            ),
          ],
        ),
        body: SafeArea(
          child: isPreStart
              ? _PreStartView(
                  selectedType: _selectedType,
                  state: state,
                  capabilities: capabilities,
                  followedRoute: followedRoute,
                  unitSystem: unitSystem,
                  onTypeChanged: (type) => setState(() => _selectedType = type),
                  onClearRoute: () => setState(() => _activeRouteId = null),
                  onSuggestRoute: () => unawaited(
                    RouteSuggestRouteData(type: _selectedType.toStorage())
                        .push<void>(context),
                  ),
                  onSavedRoutes: () => unawaited(
                    const ActivityRoutesRouteData().push<void>(context),
                  ),
                  onStart: () =>
                      controller.start(_selectedType, routeId: _activeRouteId),
                )
              : isSaveFailed
              ? _SaveFailedView(state: state, controller: controller)
              : _RecordingView(
                  state: state,
                  unitSystem: unitSystem,
                  controller: controller,
                  routeId: _activeRouteId ?? state.routeId,
                ),
        ),
      ),
    );
  }
}

class _PreStartView extends ConsumerWidget {
  const _PreStartView({
    required this.selectedType,
    required this.state,
    required this.capabilities,
    required this.followedRoute,
    required this.unitSystem,
    required this.onTypeChanged,
    required this.onClearRoute,
    required this.onSuggestRoute,
    required this.onSavedRoutes,
    required this.onStart,
  });

  final ActivityType selectedType;
  final RecordingControllerState state;
  final LocationCapabilities capabilities;
  final SavedRoute? followedRoute;
  final UnitSystem unitSystem;
  final ValueChanged<ActivityType> onTypeChanged;
  final VoidCallback onClearRoute;
  final VoidCallback onSuggestRoute;
  final VoidCallback onSavedRoutes;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final bleConnection = ref.watch(bleConnectionControllerProvider);
    final isHrConnected = bleConnection.status == BleConnectionStatus.connected;
    final hrBpm = bleConnection.currentBpm;
    final hrDevice = bleConnection.deviceName ?? 'HR Sensor';
    final hrStatusText = hrBpm != null ? '$hrBpm bpm' : 'Ready';
    final hrButtonLabel = isHrConnected
        ? '$hrDevice: $hrStatusText'
        : 'Heart Rate Sensor';
    final isBusy =
        state.lifecycle == RecordingLifecycle.requestingPermission ||
        state.lifecycle == RecordingLifecycle.waitingForSignal;

    return Center(
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: tokens.contentMaxWidth),
          child: Padding(
            padding: EdgeInsets.all(tokens.spacingLg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (followedRoute != null) ...[
                  Container(
                    padding: EdgeInsets.all(tokens.spacingMd),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withValues(
                        alpha: 0.35,
                      ),
                      borderRadius: BorderRadius.circular(tokens.radiusMd),
                      border: Border.all(
                        color: colorScheme.primary.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.route, color: colorScheme.primary),
                            SizedBox(width: tokens.spacingSm),
                            Expanded(
                              child: Text(
                                'Following: ${followedRoute!.name}',
                                style: textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, size: 20),
                              tooltip: 'Clear route',
                              onPressed: onClearRoute,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Builder(
                          builder: (context) {
                            final dist = formatDistance(
                              followedRoute!.distanceMeters,
                              unitSystem,
                            );
                            return Text(
                              '$dist · Target planned route overlay',
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: tokens.spacingMd),
                ],
                Text('Activity Type', style: textTheme.titleMedium),
                SizedBox(height: tokens.spacingSm),
                SegmentedButton<ActivityType>(
                  segments: const [
                    ButtonSegment(
                      value: ActivityType.run,
                      label: Text('Run'),
                      icon: Icon(Icons.directions_run),
                    ),
                    ButtonSegment(
                      value: ActivityType.walk,
                      label: Text('Walk'),
                      icon: Icon(Icons.directions_walk),
                    ),
                    ButtonSegment(
                      value: ActivityType.hike,
                      label: Text('Hike'),
                      icon: Icon(Icons.terrain),
                    ),
                    ButtonSegment(
                      value: ActivityType.ride,
                      label: Text('Ride'),
                      icon: Icon(Icons.directions_bike),
                    ),
                  ],
                  selected: {selectedType},
                  onSelectionChanged: (selection) =>
                      onTypeChanged(selection.first),
                ),
                SizedBox(height: tokens.spacingLg),
                Text('Route Options', style: textTheme.titleMedium),
                SizedBox(height: tokens.spacingSm),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onSuggestRoute,
                        icon: const Icon(Icons.alt_route, size: 18),
                        label: const Text('Suggest Route'),
                      ),
                    ),
                    SizedBox(width: tokens.spacingSm),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onSavedRoutes,
                        icon: const Icon(Icons.bookmark_border, size: 18),
                        label: const Text('Saved Routes'),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: tokens.spacingSm),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        key: const Key('recordAudioCuesButton'),
                        onPressed: () => AudioCuesSettingsSheet.show(context),
                        icon: const Icon(Icons.record_voice_over, size: 18),
                        label: const Text(
                          'Audio Coaching Cues',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    SizedBox(width: tokens.spacingSm),
                    Expanded(
                      child: OutlinedButton.icon(
                        key: const Key('recordBleSensorButton'),
                        onPressed: () => BleSensorSheet.show(context),
                        icon: Icon(
                          isHrConnected
                              ? Icons.favorite
                              : Icons.monitor_heart_outlined,
                          color: isHrConnected ? Colors.redAccent : null,
                          size: 18,
                        ),
                        label: Text(
                          hrButtonLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: tokens.spacingMd),
                const _PreStartSafetyCard(),
                SizedBox(height: tokens.spacingLg),
                if (!capabilities.canRecordActivities)
                  _InfoCard(
                    icon: Icons.info_outline,
                    text:
                        capabilities.reason ??
                        'Recording is not available on this device.',
                  )
                else ...[
                  const _InfoCard(
                    icon: Icons.location_on_outlined,
                    text:
                        "We'll use your location to trace your route while "
                        "you record. It's only ever shared if you choose to "
                        'share this activity, and you can stop at any time.',
                  ),
                  SizedBox(height: tokens.spacingLg),
                  if (state.permissionResult != null) ...[
                    Text(
                      _permissionMessage(state.permissionResult!),
                      style: textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    SizedBox(height: tokens.spacingMd),
                  ],
                  if (state.error != null) ...[
                    Text(
                      state.error!,
                      style: textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    SizedBox(height: tokens.spacingMd),
                  ],
                  FilledButton.icon(
                    onPressed: isBusy ? null : onStart,
                    icon: isBusy
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.play_arrow),
                    label: Text(
                      isBusy ? _busyLabel(state.lifecycle) : 'Start recording',
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _busyLabel(RecordingLifecycle lifecycle) => switch (lifecycle) {
    RecordingLifecycle.requestingPermission => 'Requesting permission…',
    RecordingLifecycle.waitingForSignal => 'Waiting for GPS signal…',
    _ => 'Starting…',
  };

  String _permissionMessage(LocationPermissionResult result) =>
      switch (result) {
        LocationPermissionResult.denied =>
          'Location permission is needed to record a route. Try again to grant '
              'access.',
        LocationPermissionResult.deniedForever =>
          'Location permission was denied. Enable it for this app in your '
              'device settings to record.',
        LocationPermissionResult.servicesDisabled =>
          'Turn on location services on your device to record.',
        LocationPermissionResult.granted => '',
      };
}

class _PreStartSafetyCard extends ConsumerWidget {
  const _PreStartSafetyCard();

  static const _durations = [30, 45, 60, 90];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final prefs = ref.watch(safetyPreferencesControllerProvider);
    final controller = ref.read(safetyPreferencesControllerProvider.notifier);
    final contacts = ref.watch(trustedContactsControllerProvider);

    return Container(
      padding: EdgeInsets.all(tokens.spacingMd),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(tokens.radiusMd),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.health_and_safety_outlined,
                color: colorScheme.primary,
                size: 20,
              ),
              SizedBox(width: tokens.spacingSm),
              Expanded(
                child: Text(
                  'Safety Check-in Timer',
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Switch(
                value: prefs.checkinTimerEnabled,
                onChanged: (enabled) {
                  unawaited(controller.toggleCheckinTimer(enabled: enabled));
                },
              ),
            ],
          ),
          if (prefs.checkinTimerEnabled) ...[
            SizedBox(height: tokens.spacingXs),
            Text(
              'Estimated Duration · Alert if overdue',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: tokens.spacingSm),
            Wrap(
              spacing: tokens.spacingSm,
              children: _durations.map((mins) {
                final isSelected = prefs.defaultExpectedMinutes == mins;
                return ChoiceChip(
                  label: Text('${mins}m'),
                  selected: isSelected,
                  onSelected: (_) {
                    unawaited(controller.setDefaultDuration(mins));
                  },
                );
              }).toList(),
            ),
          ],
          if (contacts.isNotEmpty) ...[
            SizedBox(height: tokens.spacingXs),
            Text(
              '${contacts.length} emergency contact'
              '${contacts.length == 1 ? '' : 's'} configured',
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return Container(
      padding: EdgeInsets.all(tokens.spacingMd),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(tokens.radiusMd),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.onSurfaceVariant),
          SizedBox(width: tokens.spacingSm),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

class _RecordingView extends ConsumerStatefulWidget {
  const _RecordingView({
    required this.state,
    required this.unitSystem,
    required this.controller,
    this.routeId,
  });

  final RecordingControllerState state;
  final UnitSystem unitSystem;
  final RecordingController controller;
  final String? routeId;

  @override
  ConsumerState<_RecordingView> createState() => _RecordingViewState();
}

class _RecordingViewState extends ConsumerState<_RecordingView> {
  bool _showMap = true;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final state = widget.state;
    final unitSystem = widget.unitSystem;
    final controller = widget.controller;
    final liveHeartRate = ref.watch(currentLiveHeartRateProvider);

    final isManuallyPaused = state.lifecycle == RecordingLifecycle.paused;
    final isAutoPaused = state.lifecycle == RecordingLifecycle.autoPaused;
    final isSaving = state.lifecycle == RecordingLifecycle.saving;
    final isWaitingForSignal =
        state.lifecycle == RecordingLifecycle.waitingForSignal;
    // Nothing to save yet (no fix accepted) - Finish stays disabled until
    // there's at least one sample, including while waiting for the first
    // GPS fix. Discard remains available throughout regardless.
    final canFinish = !isSaving && state.sampleCount > 0;

    final activeRouteId = widget.routeId ?? state.routeId;
    final followedRoute = activeRouteId == null
        ? null
        : ref.watch(routeByIdProvider(activeRouteId)).value;

    return Padding(
      padding: EdgeInsets.all(tokens.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isWaitingForSignal)
            const _StatusBanner(
              icon: Icons.satellite_alt_outlined,
              label: 'Waiting for GPS signal…',
            )
          else if (state.showForgottenEndPrompt && !isSaving)
            _ForgottenEndBanner(
              activityType: state.activityType,
              onFinish: controller.finish,
              onDismiss: controller.dismissForgottenEndPrompt,
            )
          else if (isAutoPaused)
            const _StatusBanner(
              icon: Icons.pause_circle_outline,
              label: 'Auto-paused — resumes when you start moving',
            ),
          if (followedRoute != null) ...[
            SizedBox(height: tokens.spacingSm),
            _RouteProgressCard(
              route: followedRoute,
              currentDistanceMeters: state.distanceMeters,
              unitSystem: unitSystem,
            ),
          ],
          SizedBox(height: tokens.spacingSm),
          if (_showMap)
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(tokens.radiusMd),
                child: LiveRecordingMap(
                  currentFix: state.latestFix,
                  trackPoints: state.trackPoints,
                  plannedRoutePoints: followedRoute?.points,
                  isAutoPaused: isAutoPaused,
                ),
              ),
            )
          else
            const Spacer(),
          SizedBox(height: tokens.spacingSm),
          Container(
            padding: EdgeInsets.symmetric(
              vertical: tokens.spacingSm,
              horizontal: tokens.spacingMd,
            ),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(tokens.radiusMd),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      key: const Key('recordAudioMuteToggle'),
                      icon: Icon(
                        state.isAudioMuted ? Icons.volume_off : Icons.volume_up,
                        size: 22,
                        color: state.isAudioMuted
                            ? colorScheme.error
                            : colorScheme.onSurfaceVariant,
                      ),
                      tooltip: state.isAudioMuted
                          ? 'Unmute audio coaching cues'
                          : 'Mute audio coaching cues',
                      onPressed: controller.toggleAudioMute,
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            formatDuration(state.elapsedTime),
                            textAlign: TextAlign.center,
                            style:
                                (_showMap
                                        ? textTheme.headlineMedium
                                        : textTheme.displayLarge)
                                    ?.tabularFigures,
                          ),
                          Text(
                            'Elapsed time',
                            textAlign: TextAlign.center,
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _showMap ? Icons.view_headline : Icons.map_outlined,
                        size: 22,
                      ),
                      tooltip: _showMap
                          ? 'Switch to Large Numbers view'
                          : 'Switch to Live Map view',
                      onPressed: () => setState(() => _showMap = !_showMap),
                    ),
                  ],
                ),
                SizedBox(height: tokens.spacingSm),
                Row(
                  children: [
                    Expanded(
                      child: _StatColumn(
                        label: 'Distance',
                        value: formatDistance(state.distanceMeters, unitSystem),
                      ),
                    ),
                    Expanded(
                      child: _StatColumn(
                        label: 'Moving time',
                        value: formatDuration(state.movingTime),
                      ),
                    ),
                    Expanded(
                      child: _StatColumn(
                        label: 'Pace',
                        value: formatPace(
                          state.currentPaceSecondsPerKm,
                          unitSystem,
                        ),
                      ),
                    ),
                    if (liveHeartRate != null)
                      Expanded(
                        child: _StatColumn(
                          label: 'Heart rate',
                          value: '$liveHeartRate bpm',
                        ),
                      ),
                    if (state.elevationGainMeters != null &&
                        state.elevationGainMeters! > 0)
                      Expanded(
                        child: _StatColumn(
                          label: 'Elevation',
                          value:
                              '+${formatElevation(
                                state.elevationGainMeters!,
                                unitSystem,
                              )}',
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          if (!_showMap) const Spacer(),
          if (state.error != null) ...[
            SizedBox(height: tokens.spacingSm),
            Text(
              state.error!,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.error,
              ),
            ),
          ],
          SizedBox(height: tokens.spacingSm),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isSaving
                      ? null
                      : (isManuallyPaused
                            ? controller.resume
                            : controller.pause),
                  icon: Icon(
                    isManuallyPaused ? Icons.play_arrow : Icons.pause,
                  ),
                  label: Text(isManuallyPaused ? 'Resume' : 'Pause'),
                ),
              ),
              SizedBox(width: tokens.spacingMd),
              Expanded(
                child: FilledButton.icon(
                  onPressed: canFinish
                      ? () => _confirmFinish(context, controller)
                      : null,
                  icon: isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check),
                  label: const Text('Finish'),
                ),
              ),
            ],
          ),
          SizedBox(height: tokens.spacingXs),
          Center(
            child: TextButton(
              onPressed: isSaving
                  ? null
                  : () => _confirmDiscard(context, controller),
              child: Text(
                'Discard',
                style: TextStyle(color: colorScheme.error),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmFinish(
    BuildContext context,
    RecordingController controller,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Finish recording?'),
        content: const Text('This saves the activity to your history.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Finish'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await controller.finish();
    }
  }
}

class _RouteProgressCard extends StatelessWidget {
  const _RouteProgressCard({
    required this.route,
    required this.currentDistanceMeters,
    required this.unitSystem,
  });

  final SavedRoute route;
  final double currentDistanceMeters;
  final UnitSystem unitSystem;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final routeDist = route.distanceMeters;
    final progress = routeDist > 0
        ? (currentDistanceMeters / routeDist).clamp(0.0, 1.0)
        : 0.0;
    final percent = (progress * 100).toInt();
    final formattedCurrent = formatDistance(currentDistanceMeters, unitSystem);
    final formattedTotal = formatDistance(routeDist, unitSystem);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.spacingMd,
        vertical: tokens.spacingSm,
      ),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(tokens.radiusSm),
        border: Border.all(
          color: colorScheme.secondary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.route_outlined,
                size: 16,
                color: colorScheme.secondary,
              ),
              SizedBox(width: tokens.spacingXs),
              Expanded(
                child: Text(
                  'Route: ${route.name}',
                  style: textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '$formattedCurrent / $formattedTotal ($percent%)',
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSecondaryContainer,
                ),
              ),
            ],
          ),
          SizedBox(height: tokens.spacingXs),
          ClipRRect(
            borderRadius: BorderRadius.circular(tokens.radiusSm),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: colorScheme.surface,
              color: colorScheme.secondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Shown when [RecordingController.finish] recorded the session but
/// persisting it failed (`RecordingLifecycle.saveFailed`). The session is
/// already finished at this point — resume is impossible — so only Retry
/// and Discard are offered; the built activity/samples are held by the
/// controller until one of them is chosen.
class _SaveFailedView extends StatelessWidget {
  const _SaveFailedView({required this.state, required this.controller});

  final RecordingControllerState state;
  final RecordingController controller;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: tokens.contentMaxWidth),
          child: Padding(
            padding: EdgeInsets.all(tokens.spacingLg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Theme.of(context).colorScheme.error,
                ),
                SizedBox(height: tokens.spacingMd),
                Text(
                  "Couldn't save your activity",
                  textAlign: TextAlign.center,
                  style: textTheme.titleMedium,
                ),
                if (state.error != null) ...[
                  SizedBox(height: tokens.spacingSm),
                  Text(
                    state.error!,
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
                SizedBox(height: tokens.spacingLg),
                FilledButton.icon(
                  onPressed: controller.retrySave,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry save'),
                ),
                SizedBox(height: tokens.spacingSm),
                TextButton(
                  onPressed: () => _confirmDiscard(context, controller),
                  child: Text(
                    'Discard',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> _confirmDiscard(
  BuildContext context,
  RecordingController controller,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Discard this recording?'),
      content: const Text('Nothing will be saved. This cannot be undone.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(dialogContext).colorScheme.error,
            foregroundColor: Theme.of(dialogContext).colorScheme.onError,
          ),
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text('Discard'),
        ),
      ],
    ),
  );
  if (confirmed == true) {
    await controller.discard();
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(tokens.spacingSm),
      decoration: BoxDecoration(
        color: tokens.warning.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(tokens.radiusSm),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: tokens.warning, size: 18),
          SizedBox(width: tokens.spacingSm),
          // Flexible (not a fixed-width Text) so a long label wraps onto a
          // second line on a narrow phone instead of overflowing the Row -
          // seen at 400dp width with the auto-pause label.
          Flexible(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(color: tokens.warning),
            ),
          ),
        ],
      ),
    );
  }
}

/// "Looks like you've stopped" prompt, shown once
/// [RecordingControllerState.showForgottenEndPrompt] goes true - i.e. the
/// session has been auto-paused for 10+ minutes, the forgotten-end
/// detection this recording feature exists for. Reuses [_StatusBanner]'s
/// warning visual language but adds two inline actions, since this banner
/// asks for a decision rather than just informing.
///
/// [onFinish] calls [RecordingController.finish] directly, skipping the
/// separate "Finish recording?" [AlertDialog] the primary Finish button
/// shows via `_confirmFinish` - this banner, appearing only after 10
/// minutes of stillness, already IS that confirmation context.
class _ForgottenEndBanner extends StatelessWidget {
  const _ForgottenEndBanner({
    required this.activityType,
    required this.onFinish,
    required this.onDismiss,
  });

  final ActivityType? activityType;
  final VoidCallback onFinish;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    // Falls back to "run" if a prompt somehow renders with no activity type
    // set (shouldn't happen once recording has started) rather than
    // crashing on a null label.
    final word = (activityType ?? ActivityType.run).label.toLowerCase();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(tokens.spacingSm),
      decoration: BoxDecoration(
        color: tokens.warning.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(tokens.radiusSm),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.pause_circle_outline,
                color: tokens.warning,
                size: 18,
              ),
              SizedBox(width: tokens.spacingSm),
              Expanded(
                child: Text(
                  "Looks like you've stopped — finish your $word?",
                  style: TextStyle(color: tokens.warning),
                ),
              ),
            ],
          ),
          SizedBox(height: tokens.spacingSm),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: onDismiss,
                  child: const Text("I'm still going"),
                ),
              ),
              SizedBox(width: tokens.spacingSm),
              Expanded(
                child: FilledButton(
                  onPressed: onFinish,
                  child: const Text('Finish'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // titleLarge (not headlineSmall) + ellipsis fallback: three of
        // these share a Row on a ~360-400dp phone, and the longest values
        // ("16:40 /km", "1:02:45") need to fit one of three roughly-equal
        // columns without overflowing.
        Text(
          value,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textTheme.titleLarge?.tabularFigures,
        ),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
