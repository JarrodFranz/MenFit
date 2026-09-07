import 'dart:math' as math;

import 'package:menfit_app/core/domain/entity_id.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/activity/domain/activity_sample.dart';
import 'package:menfit_app/features/activity/domain/workout_details.dart';
import 'package:xml/xml.dart';

/// Result of parsing an exported Garmin / GPS activity file (GPX or TCX).
class ImportedActivity {
  const ImportedActivity({
    required this.activity,
    required this.samples,
  });

  final Activity activity;
  final List<ActivitySample> samples;
}

/// Parses activity files (.gpx, .tcx) exported from Garmin Connect or
/// other GPS watches.
class ActivityFileImporter {
  const ActivityFileImporter();

  /// Parses GPX or TCX string content into an [ImportedActivity].
  /// Throws [FormatException] if invalid or contains no track points.
  ImportedActivity parseXmlString(
    String content, {
    String? fallbackTitle,
  }) {
    final document = XmlDocument.parse(content);
    final rootName = document.rootElement.name.local.toLowerCase();

    if (rootName == 'gpx') {
      return _parseGpx(document, fallbackTitle: fallbackTitle);
    } else if (rootName == 'trainingcenterdatabase') {
      return _parseTcx(document, fallbackTitle: fallbackTitle);
    } else {
      throw const FormatException(
        'Unsupported activity format. Expected GPX or TCX file.',
      );
    }
  }

  ImportedActivity _parseGpx(
    XmlDocument doc, {
    String? fallbackTitle,
  }) {
    final gpx = doc.rootElement;
    final trk = gpx.findAllElements('trk').firstOrNull ?? gpx;

    final nameElement = trk.findElements('name').firstOrNull;
    final title = nameElement?.innerText.trim().isNotEmpty == true
        ? nameElement!.innerText.trim()
        : (fallbackTitle ?? 'Imported Garmin Activity');

    final typeElement = trk.findElements('type').firstOrNull;
    final activityType = _mapActivityType(typeElement?.innerText);

    final trackpoints = gpx.findAllElements('trkpt').toList();
    if (trackpoints.isEmpty) {
      throw const FormatException('GPX file contains no GPS trackpoints.');
    }

    return _buildFromTrackpoints(
      trackpoints: trackpoints,
      title: title,
      activityType: activityType,
      getLat: (el) => double.tryParse(el.getAttribute('lat') ?? ''),
      getLon: (el) => double.tryParse(el.getAttribute('lon') ?? ''),
      getEle: (el) =>
          double.tryParse(el.findElements('ele').firstOrNull?.innerText ?? ''),
      getTime: (el) {
        final timeStr = el.findElements('time').firstOrNull?.innerText;
        return timeStr != null ? DateTime.tryParse(timeStr)?.toUtc() : null;
      },
      getHeartRate: (el) {
        final hrEl =
            el.findAllElements('gpxtpx:hr').firstOrNull ??
            el.findAllElements('hr').firstOrNull;
        return hrEl != null ? int.tryParse(hrEl.innerText.trim()) : null;
      },
      getCadence: (el) {
        final cadEl =
            el.findAllElements('gpxtpx:cad').firstOrNull ??
            el.findAllElements('cad').firstOrNull;
        return cadEl != null ? int.tryParse(cadEl.innerText.trim()) : null;
      },
    );
  }

  ImportedActivity _parseTcx(
    XmlDocument doc, {
    String? fallbackTitle,
  }) {
    final activityEl = doc.findAllElements('Activity').firstOrNull;
    final sportAttr = activityEl?.getAttribute('Sport');
    final activityType = _mapActivityType(sportAttr);

    final trackpoints = doc.findAllElements('Trackpoint').toList();
    if (trackpoints.isEmpty) {
      throw const FormatException('TCX file contains no GPS trackpoints.');
    }

    final title = fallbackTitle ?? 'Imported Garmin Activity';

    return _buildFromTrackpoints(
      trackpoints: trackpoints,
      title: title,
      activityType: activityType,
      getLat: (el) {
        final pos = el.findElements('Position').firstOrNull;
        final latStr = pos
            ?.findElements('LatitudeDegrees')
            .firstOrNull
            ?.innerText;
        return latStr != null ? double.tryParse(latStr) : null;
      },
      getLon: (el) {
        final pos = el.findElements('Position').firstOrNull;
        final lonStr = pos
            ?.findElements('LongitudeDegrees')
            .firstOrNull
            ?.innerText;
        return lonStr != null ? double.tryParse(lonStr) : null;
      },
      getEle: (el) {
        final eleStr = el.findElements('AltitudeMeters').firstOrNull?.innerText;
        return eleStr != null ? double.tryParse(eleStr) : null;
      },
      getTime: (el) {
        final timeStr = el.findElements('Time').firstOrNull?.innerText;
        return timeStr != null ? DateTime.tryParse(timeStr)?.toUtc() : null;
      },
      getHeartRate: (el) {
        final hrEl =
            el.findAllElements('HeartRateBpm').firstOrNull ??
            el.findAllElements('hr').firstOrNull;
        if (hrEl != null) {
          final val =
              hrEl.findElements('Value').firstOrNull?.innerText ??
              hrEl.innerText;
          return int.tryParse(val.trim());
        }
        return null;
      },
      getCadence: (el) {
        final cadEl = el.findAllElements('Cadence').firstOrNull;
        return cadEl != null ? int.tryParse(cadEl.innerText.trim()) : null;
      },
    );
  }

  ImportedActivity _buildFromTrackpoints<T>({
    required List<T> trackpoints,
    required String title,
    required ActivityType activityType,
    required double? Function(T) getLat,
    required double? Function(T) getLon,
    required double? Function(T) getEle,
    required DateTime? Function(T) getTime,
    int? Function(T)? getHeartRate,
    int? Function(T)? getCadence,
  }) {
    final activityId = EntityId.generate();
    final samples = <ActivitySample>[];

    double totalDistanceMeters = 0;
    double totalElevationGainMeters = 0;
    double? lastLat;
    double? lastLon;
    double? lastEle;

    DateTime? startedAt;
    DateTime? endedAt;

    for (final pt in trackpoints) {
      final lat = getLat(pt);
      final lon = getLon(pt);
      if (lat == null || lon == null) continue;

      final time = getTime(pt) ?? DateTime.now().toUtc();
      startedAt ??= time;
      endedAt = time;

      final ele = getEle(pt);
      final hr = getHeartRate?.call(pt);

      if (lastLat != null && lastLon != null) {
        final dist = _haversineDistance(lastLat, lastLon, lat, lon);
        totalDistanceMeters += dist;

        if (lastEle != null && ele != null && ele > lastEle) {
          totalElevationGainMeters += ele - lastEle;
        }
      }

      samples.add(
        ActivitySample(
          id: EntityId.generate(),
          activityId: activityId,
          timestamp: time,
          latitude: lat,
          longitude: lon,
          elevationMeters: ele,
          heartRate: hr,
        ),
      );

      lastLat = lat;
      lastLon = lon;
      lastEle = ele;
    }

    if (samples.isEmpty) {
      throw const FormatException('No valid GPS coordinates found in file.');
    }

    final start = startedAt ?? DateTime.now().toUtc();
    final end = endedAt ?? start;
    final elapsed = end.difference(start);
    final moving = elapsed > Duration.zero
        ? elapsed
        : const Duration(minutes: 1);

    int? avgHeartRate;
    final hrValues = samples.map((s) => s.heartRate).whereType<int>().toList();
    if (hrValues.isNotEmpty) {
      final sum = hrValues.reduce((a, b) => a + b);
      avgHeartRate = (sum / hrValues.length).round();
    }

    int? avgCadence;
    if (getCadence != null) {
      final cadValues = trackpoints
          .map((pt) => getCadence(pt))
          .whereType<int>()
          .toList();
      if (cadValues.isNotEmpty) {
        final sum = cadValues.reduce((a, b) => a + b);
        avgCadence = (sum / cadValues.length).round();
      }
    }

    final workoutDetails = (avgCadence != null || avgHeartRate != null)
        ? WearableWorkoutDetails(
            wearableSource: 'Garmin File Import',
            avgCadence: avgCadence,
          )
        : null;

    final activity = Activity(
      id: activityId,
      activityType: activityType,
      title: title,
      startedAt: start,
      movingTime: moving,
      elapsedTime: elapsed > Duration.zero ? elapsed : moving,
      distanceMeters: totalDistanceMeters,
      elevationGainMeters: totalElevationGainMeters > 0
          ? totalElevationGainMeters
          : null,
      avgHeartRate: avgHeartRate,
      workoutDetails: workoutDetails,
      source: ActivitySource.recorded,
      createdAt: DateTime.now().toUtc(),
      updatedAt: DateTime.now().toUtc(),
    );

    return ImportedActivity(
      activity: activity,
      samples: samples,
    );
  }

  ActivityType _mapActivityType(String? typeStr) {
    if (typeStr == null) return ActivityType.run;
    final lower = typeStr.toLowerCase();
    if (lower.contains('cycl') ||
        lower.contains('bike') ||
        lower.contains('biking') ||
        lower.contains('ride')) {
      return ActivityType.ride;
    }
    if (lower.contains('walk')) {
      return ActivityType.walk;
    }
    if (lower.contains('hike') || lower.contains('hiking')) {
      return ActivityType.hike;
    }
    return ActivityType.run;
  }

  static double _haversineDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const r = 6371000.0; // Earth radius in meters
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return r * c;
  }

  static double _toRadians(double degrees) => degrees * math.pi / 180.0;
}
