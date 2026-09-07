import 'package:intl/intl.dart';
import 'package:menfit_app/core/platform/location/location_fix.dart';
import 'package:menfit_app/features/activity/domain/geo_math.dart';

/// Reason why a safety alert or SOS dispatch was triggered.
enum SafetyAlertReason {
  /// User has been stationary for longer than the inactivity threshold.
  inactivity,

  /// Estimated return time / check-in timer has elapsed.
  checkinDeadline,

  /// User manually triggered an emergency SOS from the app.
  manualSos;

  String get displayTitle {
    switch (this) {
      case SafetyAlertReason.inactivity:
        return 'Inactivity Alert';
      case SafetyAlertReason.checkinDeadline:
        return 'Check-in Overdue';
      case SafetyAlertReason.manualSos:
        return 'Emergency SOS';
    }
  }
}

/// Pure-Dart logic for inactivity detection, timer evaluation, and emergency
/// alert message generation.
class SafetyCheckinEngine {
  const SafetyCheckinEngine({
    this.speedThresholdMps = 0.4,
    this.movementRadiusMeters = 15.0,
  });

  /// Speed in m/s below which a fix may be considered stationary.
  /// 0.4 m/s is ~1.44 km/h (well below a walking pace).
  final double speedThresholdMps;

  /// Distance threshold in meters to absorb GPS drift while stationary.
  final double movementRadiusMeters;

  /// Formats a Google Maps URL from latitude and longitude.
  static String formatMapsUrl(double latitude, double longitude) {
    return 'https://maps.google.com/?q=$latitude,$longitude';
  }

  /// Determines whether a fix indicates meaningful movement relative to
  /// [anchorFix].
  bool hasMoved({
    required LocationFix currentFix,
    required LocationFix anchorFix,
  }) {
    if (currentFix.speedMetersPerSecond != null &&
        currentFix.speedMetersPerSecond! > speedThresholdMps) {
      return true;
    }

    final distance = haversineDistanceMeters(
      anchorFix.latitude,
      anchorFix.longitude,
      currentFix.latitude,
      currentFix.longitude,
    );

    return distance >= movementRadiusMeters;
  }

  /// Checks whether an ongoing stationary duration has met or exceeded the
  /// [inactivityThreshold].
  bool isInactivityTriggered({
    required DateTime now,
    required DateTime? stationarySince,
    required Duration inactivityThreshold,
  }) {
    if (stationarySince == null) return false;
    return now.difference(stationarySince) >= inactivityThreshold;
  }

  /// Checks whether the check-in timer deadline has passed.
  bool isCheckinOverdue({
    required DateTime now,
    required DateTime? deadline,
  }) {
    if (deadline == null) return false;
    return now.isAfter(deadline);
  }

  /// Generates a standardized, clear emergency message ready for dispatch via
  /// SMS or OS share sheet.
  String generateEmergencyMessage({
    required String userName,
    required DateTime timestamp,
    double? latitude,
    double? longitude,
    SafetyAlertReason reason = SafetyAlertReason.inactivity,
    String? customMessage,
    String? liveTrackingUrl,
  }) {
    final effectiveName = userName.trim().isEmpty ? 'Runner' : userName.trim();
    final timeStr = DateFormat.jm().format(timestamp);

    final String header;
    final String reasonText;
    switch (reason) {
      case SafetyAlertReason.inactivity:
        header = 'FemFit Safety Alert:';
        reasonText =
            '$effectiveName has stopped moving during an outdoor run at '
            '$timeStr and has not responded to safety checks.';
      case SafetyAlertReason.checkinDeadline:
        header = 'FemFit Safety Alert:';
        reasonText =
            '$effectiveName has not checked in from an outdoor run by '
            '$timeStr and has not responded to safety checks.';
      case SafetyAlertReason.manualSos:
        header = 'FemFit Emergency SOS:';
        reasonText =
            '$effectiveName triggered an emergency alert during an outdoor '
            'run at $timeStr.';
    }

    final locationText = (latitude != null && longitude != null)
        ? 'Last known location: ${formatMapsUrl(latitude, longitude)}'
        : 'Last known location: GPS signal unavailable.';

    final buffer = StringBuffer()
      ..writeln(header)
      ..writeln(reasonText)
      ..write(locationText);

    if (liveTrackingUrl != null && liveTrackingUrl.trim().isNotEmpty) {
      buffer
        ..writeln()
        ..write('Live tracking: ${liveTrackingUrl.trim()}');
    }

    if (customMessage != null && customMessage.trim().isNotEmpty) {
      buffer
        ..writeln()
        ..writeln()
        ..write('Note: ${customMessage.trim()}');
    }

    return buffer.toString();
  }
}
