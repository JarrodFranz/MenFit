import 'dart:async';

import 'package:flutter_riverpod/misc.dart';
import 'package:menfit_app/core/config/shared_preferences_provider.dart';
import 'package:menfit_app/core/platform/audio/audio_cue_providers.dart';
import 'package:menfit_app/core/platform/location/location_fix.dart';
import 'package:menfit_app/core/platform/sharing/sharing_providers.dart';
import 'package:menfit_app/features/activity/presentation/recording/recording_controller.dart';
import 'package:menfit_app/features/profile/profile_providers.dart';
import 'package:menfit_app/features/safety/data/local_live_tracking_service.dart';
import 'package:menfit_app/features/safety/data/safety_repository.dart';
import 'package:menfit_app/features/safety/domain/live_tracking.dart';
import 'package:menfit_app/features/safety/domain/live_tracking_service.dart';
import 'package:menfit_app/features/safety/domain/safety_checkin_engine.dart';
import 'package:menfit_app/features/safety/domain/safety_preferences.dart';
import 'package:menfit_app/features/safety/domain/trusted_contact.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'safety_providers.g.dart';

@Riverpod(keepAlive: true)
SafetyRepository safetyRepository(Ref ref) {
  try {
    final prefs = ref.watch(sharedPreferencesProvider);
    return LocalSafetyRepository(prefs);
  } on ProviderException catch (error) {
    if (error.exception is! UnimplementedError) rethrow;
    return const LocalSafetyRepository(null);
  }
}

@Riverpod(keepAlive: true)
SafetyCheckinEngine safetyCheckinEngine(Ref ref) {
  return const SafetyCheckinEngine();
}

@Riverpod(keepAlive: true)
LiveTrackingUrlBuilder liveTrackingUrlBuilder(Ref ref) {
  return const LiveTrackingUrlBuilder();
}

@Riverpod(keepAlive: true)
LiveTrackingService liveTrackingService(Ref ref) {
  final service = LocalLiveTrackingService();
  ref.onDispose(service.dispose);
  return service;
}

@Riverpod(keepAlive: true)
Stream<LiveTrackingSession?> activeLiveTrackingSession(Ref ref) {
  final service = ref.watch(liveTrackingServiceProvider);
  return service.watchSession();
}

@Riverpod(keepAlive: true)
class TrustedContactsController extends _$TrustedContactsController {
  @override
  List<TrustedContact> build() {
    final repo = ref.watch(safetyRepositoryProvider);
    return repo.getContacts();
  }

  Future<void> addContact(TrustedContact contact) async {
    final repo = ref.read(safetyRepositoryProvider);
    await repo.addContact(contact);
    ref.invalidateSelf();
  }

  Future<void> updateContact(TrustedContact contact) async {
    final repo = ref.read(safetyRepositoryProvider);
    await repo.updateContact(contact);
    ref.invalidateSelf();
  }

  Future<void> deleteContact(String contactId) async {
    final repo = ref.read(safetyRepositoryProvider);
    await repo.deleteContact(contactId);
    ref.invalidateSelf();
  }

  Future<void> setPrimary(String contactId) async {
    final repo = ref.read(safetyRepositoryProvider);
    await repo.setPrimaryContact(contactId);
    ref.invalidateSelf();
  }
}

@Riverpod(keepAlive: true)
class SafetyPreferencesController extends _$SafetyPreferencesController {
  @override
  SafetyPreferences build() {
    final repo = ref.watch(safetyRepositoryProvider);
    return repo.getPreferences();
  }

  Future<void> updatePreferences(SafetyPreferences preferences) async {
    final repo = ref.read(safetyRepositoryProvider);
    await repo.savePreferences(preferences);
    state = preferences;
  }

  Future<void> toggleCheckinTimer({required bool enabled}) async {
    await updatePreferences(state.copyWith(checkinTimerEnabled: enabled));
  }

  Future<void> setDefaultDuration(int minutes) async {
    await updatePreferences(state.copyWith(defaultExpectedMinutes: minutes));
  }

  Future<void> toggleInactivityAlert({required bool enabled}) async {
    await updatePreferences(state.copyWith(inactivityAlertEnabled: enabled));
  }

  Future<void> setInactivityThreshold(int minutes) async {
    await updatePreferences(
      state.copyWith(inactivityThresholdMinutes: minutes),
    );
  }

  Future<void> setWarningCountdown(int seconds) async {
    await updatePreferences(
      state.copyWith(warningCountdownSeconds: seconds),
    );
  }

  Future<void> setCustomMessage(String? message) async {
    await updatePreferences(
      state.copyWith(
        customMessage: message,
        clearCustomMessage: message == null || message.trim().isEmpty,
      ),
    );
  }
}

/// Real-time monitoring state during an active workout session.
class SafetyMonitorState {
  const SafetyMonitorState({
    this.isActive = false,
    this.expectedDuration,
    this.checkinDeadline,
    this.lastMovementAt,
    this.lastKnownFix,
    this.anchorFix,
    this.isWarningActive = false,
    this.warningReason,
    this.warningSecondsRemaining = 45,
    this.isSosDispatched = false,
    this.dispatchedMessage,
  });

  final bool isActive;
  final Duration? expectedDuration;
  final DateTime? checkinDeadline;
  final DateTime? lastMovementAt;
  final LocationFix? lastKnownFix;
  final LocationFix? anchorFix;
  final bool isWarningActive;
  final SafetyAlertReason? warningReason;
  final int warningSecondsRemaining;
  final bool isSosDispatched;
  final String? dispatchedMessage;

  SafetyMonitorState copyWith({
    bool? isActive,
    Duration? expectedDuration,
    DateTime? checkinDeadline,
    DateTime? lastMovementAt,
    LocationFix? lastKnownFix,
    LocationFix? anchorFix,
    bool? isWarningActive,
    SafetyAlertReason? warningReason,
    int? warningSecondsRemaining,
    bool? isSosDispatched,
    String? dispatchedMessage,
    bool clearWarningReason = false,
    bool clearDispatchedMessage = false,
  }) {
    return SafetyMonitorState(
      isActive: isActive ?? this.isActive,
      expectedDuration: expectedDuration ?? this.expectedDuration,
      checkinDeadline: checkinDeadline ?? this.checkinDeadline,
      lastMovementAt: lastMovementAt ?? this.lastMovementAt,
      lastKnownFix: lastKnownFix ?? this.lastKnownFix,
      anchorFix: anchorFix ?? this.anchorFix,
      isWarningActive: isWarningActive ?? this.isWarningActive,
      warningReason: clearWarningReason
          ? null
          : (warningReason ?? this.warningReason),
      warningSecondsRemaining:
          warningSecondsRemaining ?? this.warningSecondsRemaining,
      isSosDispatched: isSosDispatched ?? this.isSosDispatched,
      dispatchedMessage: clearDispatchedMessage
          ? null
          : (dispatchedMessage ?? this.dispatchedMessage),
    );
  }
}

@Riverpod(keepAlive: true)
class SafetyMonitorController extends _$SafetyMonitorController {
  @override
  SafetyMonitorState build() {
    return const SafetyMonitorState();
  }

  DateTime _now() {
    return ref.read(recordingClockProvider)();
  }

  /// Arms the safety monitor with the given or default [expectedDuration].
  void arm({Duration? expectedDuration}) {
    final prefs = ref.read(safetyPreferencesControllerProvider);
    final now = _now();

    final duration =
        expectedDuration ?? Duration(minutes: prefs.defaultExpectedMinutes);
    final deadline = prefs.checkinTimerEnabled ? now.add(duration) : null;

    state = SafetyMonitorState(
      isActive: true,
      expectedDuration: duration,
      checkinDeadline: deadline,
      lastMovementAt: now,
    );
  }

  /// Disarms and resets the safety monitor.
  void disarm() {
    state = const SafetyMonitorState();
  }

  /// Updates current location fix and verifies movement.
  void updateLocation(LocationFix fix) {
    if (!state.isActive) return;

    final engine = ref.read(safetyCheckinEngineProvider);
    final anchor = state.anchorFix ?? fix;

    final moved = engine.hasMoved(currentFix: fix, anchorFix: anchor);
    final now = _now();

    if (moved) {
      state = state.copyWith(
        lastMovementAt: now,
        anchorFix: fix,
        lastKnownFix: fix,
      );
    } else {
      state = state.copyWith(lastKnownFix: fix);
    }
  }

  /// Evaluates check-in deadlines and stationary periods against active
  /// preferences.
  void evaluateTimers([DateTime? currentTime]) {
    if (!state.isActive || state.isWarningActive || state.isSosDispatched) {
      return;
    }

    final prefs = ref.read(safetyPreferencesControllerProvider);
    final engine = ref.read(safetyCheckinEngineProvider);
    final now = currentTime ?? _now();

    // 1. Inactivity check
    if (prefs.inactivityAlertEnabled && state.lastMovementAt != null) {
      final inactive = engine.isInactivityTriggered(
        now: now,
        stationarySince: state.lastMovementAt,
        inactivityThreshold: Duration(
          minutes: prefs.inactivityThresholdMinutes,
        ),
      );

      if (inactive) {
        _startWarning(
          SafetyAlertReason.inactivity,
          prefs.warningCountdownSeconds,
        );
        return;
      }
    }

    // 2. Check-in timer deadline check
    if (prefs.checkinTimerEnabled && state.checkinDeadline != null) {
      final overdue = engine.isCheckinOverdue(
        now: now,
        deadline: state.checkinDeadline,
      );

      if (overdue) {
        _startWarning(
          SafetyAlertReason.checkinDeadline,
          prefs.warningCountdownSeconds,
        );
        return;
      }
    }
  }

  void _startWarning(SafetyAlertReason reason, int countdownSeconds) {
    unawaited(ref.read(audioCuePlayerProvider).playTransitionChime());
    state = state.copyWith(
      isWarningActive: true,
      warningReason: reason,
      warningSecondsRemaining: countdownSeconds,
    );
  }

  /// Advances warning countdown by one tick (1 second).
  Future<void> tickCountdown() async {
    if (!state.isWarningActive) return;

    final remaining = state.warningSecondsRemaining - 1;
    if (remaining <= 0) {
      await triggerSos(reason: state.warningReason);
    } else {
      state = state.copyWith(warningSecondsRemaining: remaining);
    }
  }

  /// User taps "I'm OK" to dismiss the warning.
  void dismissWarning() {
    final now = _now();
    final prefs = ref.read(safetyPreferencesControllerProvider);

    var newDeadline = state.checkinDeadline;
    if (state.warningReason == SafetyAlertReason.checkinDeadline) {
      newDeadline = now.add(const Duration(minutes: 15));
    }

    state = state.copyWith(
      isWarningActive: false,
      clearWarningReason: true,
      warningSecondsRemaining: prefs.warningCountdownSeconds,
      lastMovementAt: now,
      anchorFix: state.lastKnownFix,
      checkinDeadline: newDeadline,
    );
  }

  /// Extends check-in deadline by [extension].
  void extendDeadline(Duration extension) {
    final now = _now();
    final currentDeadline = state.checkinDeadline ?? now;
    final prefs = ref.read(safetyPreferencesControllerProvider);

    state = state.copyWith(
      checkinDeadline: currentDeadline.add(extension),
      isWarningActive: false,
      clearWarningReason: true,
      warningSecondsRemaining: prefs.warningCountdownSeconds,
      lastMovementAt: now,
    );
  }

  /// Triggers emergency dispatch via the OS share sheet.
  Future<String> triggerSos({SafetyAlertReason? reason}) async {
    final engine = ref.read(safetyCheckinEngineProvider);
    final prefs = ref.read(safetyPreferencesControllerProvider);
    final profile = await ref.read(profileRepositoryProvider).getProfile();
    final now = _now();

    final message = engine.generateEmergencyMessage(
      userName: profile?.displayName ?? 'Runner',
      timestamp: now,
      latitude: state.lastKnownFix?.latitude,
      longitude: state.lastKnownFix?.longitude,
      reason: reason ?? SafetyAlertReason.manualSos,
      customMessage: prefs.customMessage,
    );

    state = state.copyWith(
      isWarningActive: false,
      isSosDispatched: true,
      dispatchedMessage: message,
    );

    final sharing = ref.read(sharingAdapterProvider);
    unawaited(
      sharing.shareText(
        message,
        subject: 'FemFit Safety Alert',
      ),
    );

    return message;
  }
}
