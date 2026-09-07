import 'package:menfit_app/core/domain/units.dart';

/// Pure formatting helpers for activity stats. Canonical storage is always
/// metric; these functions convert only at the point of display (see
/// `knowledge/engineering/coding_standards.md`).

/// Kilometres per mile, reused from [UnitConversions] rather than
/// duplicating the constant — [UnitConversions.miToKm] of `1` is exactly
/// that ratio.
final double _kmPerMile = UnitConversions.miToKm(1);

/// Formats a pace of [secondsPerKm] as `"m:ss /km"` (or `"m:ss /mi"` when
/// [unitSystem] is imperial, converting the pace accordingly).
///
/// `null`, non-finite, zero, or negative input renders as a dashed
/// placeholder rather than a misleading `"0:00"` — pace is undefined
/// without a positive distance (see `Activity.avgPaceSecondsPerKm` in
/// `activity.dart`).
String formatPace(double? secondsPerKm, UnitSystem unitSystem) {
  final unitLabel = unitSystem == UnitSystem.imperial ? '/mi' : '/km';
  if (secondsPerKm == null || !secondsPerKm.isFinite || secondsPerKm <= 0) {
    return '--:-- $unitLabel';
  }

  final secondsPerUnit = unitSystem == UnitSystem.imperial
      ? secondsPerKm * _kmPerMile
      : secondsPerKm;
  final totalSeconds = secondsPerUnit.round();
  final minutes = totalSeconds ~/ 60;
  final seconds = totalSeconds % 60;
  return '$minutes:${seconds.toString().padLeft(2, '0')} $unitLabel';
}

/// Formats a distance of [meters] as `"5.03 km"` (or `"3.13 mi"` when
/// [unitSystem] is imperial), rounded to two decimal places.
///
/// Non-finite or negative input is treated as zero rather than surfacing a
/// broken string.
String formatDistance(double meters, UnitSystem unitSystem) {
  final safeMeters = meters.isFinite && meters > 0 ? meters : 0.0;
  final km = safeMeters / 1000;
  if (unitSystem == UnitSystem.imperial) {
    return '${UnitConversions.kmToMi(km).toStringAsFixed(2)} mi';
  }
  return '${km.toStringAsFixed(2)} km';
}

/// Formats [duration] as `"m:ss"` (minutes zero-padded to at least two
/// digits, e.g. `"05:03"`, `"47:12"`), or `"h:mm:ss"` once it reaches an
/// hour (e.g. `"1:02:45"` — the hour component itself isn't zero-padded).
///
/// A negative [duration] is treated as its absolute value; there's no
/// meaningful negative activity duration to render.
String formatDuration(Duration duration) {
  final totalSeconds = duration.inSeconds.abs();
  final hours = totalSeconds ~/ 3600;
  final minutes = (totalSeconds % 3600) ~/ 60;
  final seconds = totalSeconds % 60;
  final secondsPart = seconds.toString().padLeft(2, '0');

  if (hours > 0) {
    final minutesPart = minutes.toString().padLeft(2, '0');
    return '$hours:$minutesPart:$secondsPart';
  }
  return '${minutes.toString().padLeft(2, '0')}:$secondsPart';
}
