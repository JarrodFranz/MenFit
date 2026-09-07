import 'dart:convert';
import 'dart:math';

import 'package:menfit_app/core/domain/entity_id.dart';
import 'package:menfit_app/core/platform/location/location_fix.dart';
import 'package:meta/meta.dart';

/// Status of an active or past live-tracking session.
enum LiveTrackingStatus {
  /// Session is actively recording and publishing location fixes.
  active('Active'),

  /// Runner has temporarily paused the workout.
  paused('Paused'),

  /// Workout has finished; link remains viewable for post-run verification.
  completed('Completed'),

  /// Validity window has expired.
  expired('Expired'),

  /// Link was explicitly revoked by the runner.
  cancelled('Cancelled');

  const LiveTrackingStatus(this.label);
  final String label;

  static LiveTrackingStatus fromString(String? value) {
    if (value == null) return LiveTrackingStatus.expired;
    return LiveTrackingStatus.values.firstWhere(
      (s) => s.name.toLowerCase() == value.toLowerCase(),
      orElse: () => LiveTrackingStatus.expired,
    );
  }
}

/// Cryptographically secure random token generator for unguessable
/// live-tracking URLs.
class LiveTrackingToken {
  LiveTrackingToken._();

  /// Generates a 128-bit (16-byte) cryptographically secure random token,
  /// encoded as a URL-safe Base64 string (22 characters).
  static String generate() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64Url.encode(bytes).replaceAll('=', '');
  }

  /// Validates that [token] meets minimum entropy requirements (at least 16
  /// URL-safe characters).
  static bool isValid(String? token) {
    if (token == null) return false;
    final trimmed = token.trim();
    if (trimmed.length < 16) return false;
    final urlSafeRegex = RegExp(r'^[A-Za-z0-9_-]+$');
    return urlSafeRegex.hasMatch(trimmed);
  }
}

/// A single location fix and device telemetry packet broadcasted during a live
/// tracking session.
@immutable
class LiveLocationPacket {
  const LiveLocationPacket({
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    this.speedMetersPerSecond,
    this.altitudeMeters,
    this.accuracyMeters,
    this.batteryPercentage,
    this.status = LiveTrackingStatus.active,
    this.isStationary = false,
  });

  factory LiveLocationPacket.fromLocationFix({
    required LocationFix fix,
    int? batteryPercentage,
    LiveTrackingStatus status = LiveTrackingStatus.active,
    bool isStationary = false,
  }) {
    return LiveLocationPacket(
      timestamp: fix.timestamp,
      latitude: fix.latitude,
      longitude: fix.longitude,
      speedMetersPerSecond: fix.speedMetersPerSecond,
      altitudeMeters: fix.elevationMeters,
      accuracyMeters: fix.horizontalAccuracyMeters,
      batteryPercentage: batteryPercentage,
      status: status,
      isStationary: isStationary,
    );
  }

  factory LiveLocationPacket.fromJson(Map<String, dynamic> json) {
    return LiveLocationPacket(
      timestamp: DateTime.parse(json['timestamp'] as String),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      speedMetersPerSecond: (json['speedMetersPerSecond'] as num?)?.toDouble(),
      altitudeMeters: (json['altitudeMeters'] as num?)?.toDouble(),
      accuracyMeters: (json['accuracyMeters'] as num?)?.toDouble(),
      batteryPercentage: json['batteryPercentage'] as int?,
      status: LiveTrackingStatus.fromString(json['status'] as String?),
      isStationary: json['isStationary'] as bool? ?? false,
    );
  }

  final DateTime timestamp;
  final double latitude;
  final double longitude;
  final double? speedMetersPerSecond;
  final double? altitudeMeters;
  final double? accuracyMeters;
  final int? batteryPercentage;
  final LiveTrackingStatus status;
  final bool isStationary;

  Map<String, dynamic> toJson() => {
    'timestamp': timestamp.toIso8601String(),
    'latitude': latitude,
    'longitude': longitude,
    if (speedMetersPerSecond != null)
      'speedMetersPerSecond': speedMetersPerSecond,
    if (altitudeMeters != null) 'altitudeMeters': altitudeMeters,
    if (accuracyMeters != null) 'accuracyMeters': accuracyMeters,
    if (batteryPercentage != null) 'batteryPercentage': batteryPercentage,
    'status': status.name,
    'isStationary': isStationary,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LiveLocationPacket &&
          runtimeType == other.runtimeType &&
          timestamp == other.timestamp &&
          latitude == other.latitude &&
          longitude == other.longitude &&
          speedMetersPerSecond == other.speedMetersPerSecond &&
          status == other.status &&
          isStationary == other.isStationary;

  @override
  int get hashCode => Object.hash(
    timestamp,
    latitude,
    longitude,
    speedMetersPerSecond,
    status,
    isStationary,
  );
}

/// Represents an ongoing or completed tokenized live-tracking session.
@immutable
class LiveTrackingSession {
  const LiveTrackingSession({
    required this.id,
    required this.token,
    required this.startedAt,
    required this.expiresAt,
    required this.userName,
    this.status = LiveTrackingStatus.active,
    this.lastPacket,
  });

  factory LiveTrackingSession.create({
    required String userName,
    Duration duration = const Duration(hours: 3),
    DateTime? now,
  }) {
    final start = now ?? DateTime.now();
    return LiveTrackingSession(
      id: EntityId.generate(),
      token: LiveTrackingToken.generate(),
      startedAt: start,
      expiresAt: start.add(duration),
      userName: userName.trim().isEmpty ? 'Runner' : userName.trim(),
    );
  }

  factory LiveTrackingSession.fromJson(Map<String, dynamic> json) {
    return LiveTrackingSession(
      id: json['id'] as String,
      token: json['token'] as String,
      startedAt: DateTime.parse(json['startedAt'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      userName: json['userName'] as String? ?? 'Runner',
      status: LiveTrackingStatus.fromString(json['status'] as String?),
      lastPacket: json['lastPacket'] != null
          ? LiveLocationPacket.fromJson(
              json['lastPacket'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  final String id;
  final String token;
  final DateTime startedAt;
  final DateTime expiresAt;
  final String userName;
  final LiveTrackingStatus status;
  final LiveLocationPacket? lastPacket;

  /// Checks whether this session has expired as of [now].
  bool isExpired([DateTime? now]) {
    if (status == LiveTrackingStatus.expired ||
        status == LiveTrackingStatus.cancelled) {
      return true;
    }
    final currentTime = now ?? DateTime.now();
    return currentTime.isAfter(expiresAt);
  }

  LiveTrackingSession copyWith({
    String? id,
    String? token,
    DateTime? startedAt,
    DateTime? expiresAt,
    String? userName,
    LiveTrackingStatus? status,
    LiveLocationPacket? lastPacket,
  }) {
    return LiveTrackingSession(
      id: id ?? this.id,
      token: token ?? this.token,
      startedAt: startedAt ?? this.startedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      userName: userName ?? this.userName,
      status: status ?? this.status,
      lastPacket: lastPacket ?? this.lastPacket,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'token': token,
    'startedAt': startedAt.toIso8601String(),
    'expiresAt': expiresAt.toIso8601String(),
    'userName': userName,
    'status': status.name,
    if (lastPacket != null) 'lastPacket': lastPacket!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LiveTrackingSession &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          token == other.token &&
          status == other.status &&
          lastPacket == other.lastPacket;

  @override
  int get hashCode => Object.hash(id, token, status, lastPacket);
}

/// Generates shareable, tokenized live-tracking URLs.
class LiveTrackingUrlBuilder {
  const LiveTrackingUrlBuilder({
    this.baseUrl = 'https://live.menfit.app/track',
  });

  /// The web endpoint hosting the standalone live watcher interface.
  final String baseUrl;

  /// Builds an expiring, tokenized live tracking URL.
  String buildUrl({
    required String token,
    String? runnerName,
  }) {
    final cleanBase = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;

    final queryParams = <String, String>{
      'token': token,
      if (runnerName != null && runnerName.trim().isNotEmpty)
        'runner': runnerName.trim(),
    };

    final query = queryParams.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');

    return '$cleanBase#$query';
  }

  /// Formats a complete safety invitation SMS ready for dispatch.
  String formatInvitationMessage({
    required String userName,
    required String liveTrackingUrl,
  }) {
    final effectiveName = userName.trim().isEmpty ? 'Runner' : userName.trim();
    return 'MenFit Safety: $effectiveName is starting an outdoor run and '
        'shared a live location tracking link with you: $liveTrackingUrl '
        '(Link expires 2 hours after the run ends).';
  }
}
