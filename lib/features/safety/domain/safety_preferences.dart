import 'package:meta/meta.dart';

/// Preferences and configuration for safety check-ins and inactivity alerts.
@immutable
class SafetyPreferences {
  const SafetyPreferences({
    this.checkinTimerEnabled = true,
    this.defaultExpectedMinutes = 45,
    this.inactivityAlertEnabled = true,
    this.inactivityThresholdMinutes = 4,
    this.warningCountdownSeconds = 45,
    this.customMessage,
  });

  factory SafetyPreferences.fromJson(Map<String, dynamic> json) {
    return SafetyPreferences(
      checkinTimerEnabled: json['checkinTimerEnabled'] as bool? ?? true,
      defaultExpectedMinutes: json['defaultExpectedMinutes'] as int? ?? 45,
      inactivityAlertEnabled: json['inactivityAlertEnabled'] as bool? ?? true,
      inactivityThresholdMinutes:
          json['inactivityThresholdMinutes'] as int? ?? 4,
      warningCountdownSeconds: json['warningCountdownSeconds'] as int? ?? 45,
      customMessage: json['customMessage'] as String?,
    );
  }

  /// Whether to arm the check-in timer by default when starting an outdoor run.
  final bool checkinTimerEnabled;

  /// Default expected duration in minutes for an outdoor activity.
  final int defaultExpectedMinutes;

  /// Whether stationary/inactivity detection is active during GPS tracking.
  final bool inactivityAlertEnabled;

  /// How long the user can remain stationary (in minutes) before a check-in
  /// warning is raised.
  final int inactivityThresholdMinutes;

  /// Seconds to count down with audio/vibration before auto-triggering SOS
  /// dispatch.
  final int warningCountdownSeconds;

  /// Optional custom note or text to include in the emergency dispatch.
  final String? customMessage;

  SafetyPreferences copyWith({
    bool? checkinTimerEnabled,
    int? defaultExpectedMinutes,
    bool? inactivityAlertEnabled,
    int? inactivityThresholdMinutes,
    int? warningCountdownSeconds,
    String? customMessage,
    bool clearCustomMessage = false,
  }) {
    return SafetyPreferences(
      checkinTimerEnabled: checkinTimerEnabled ?? this.checkinTimerEnabled,
      defaultExpectedMinutes:
          defaultExpectedMinutes ?? this.defaultExpectedMinutes,
      inactivityAlertEnabled:
          inactivityAlertEnabled ?? this.inactivityAlertEnabled,
      inactivityThresholdMinutes:
          inactivityThresholdMinutes ?? this.inactivityThresholdMinutes,
      warningCountdownSeconds:
          warningCountdownSeconds ?? this.warningCountdownSeconds,
      customMessage: clearCustomMessage
          ? null
          : (customMessage ?? this.customMessage),
    );
  }

  Map<String, dynamic> toJson() => {
    'checkinTimerEnabled': checkinTimerEnabled,
    'defaultExpectedMinutes': defaultExpectedMinutes,
    'inactivityAlertEnabled': inactivityAlertEnabled,
    'inactivityThresholdMinutes': inactivityThresholdMinutes,
    'warningCountdownSeconds': warningCountdownSeconds,
    'customMessage': customMessage,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SafetyPreferences &&
          runtimeType == other.runtimeType &&
          checkinTimerEnabled == other.checkinTimerEnabled &&
          defaultExpectedMinutes == other.defaultExpectedMinutes &&
          inactivityAlertEnabled == other.inactivityAlertEnabled &&
          inactivityThresholdMinutes == other.inactivityThresholdMinutes &&
          warningCountdownSeconds == other.warningCountdownSeconds &&
          customMessage == other.customMessage;

  @override
  int get hashCode => Object.hash(
    checkinTimerEnabled,
    defaultExpectedMinutes,
    inactivityAlertEnabled,
    inactivityThresholdMinutes,
    warningCountdownSeconds,
    customMessage,
  );
}
