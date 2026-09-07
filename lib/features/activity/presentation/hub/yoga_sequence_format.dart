import 'package:menfit_app/features/activity/domain/yoga_sequence.dart';

/// `mm:ss` for a sequence's length, minutes never rolling over into hours.
///
/// A practice is minutes long, and "1:05:00" next to "05:30" in the same
/// list reads as a different unit at a glance. 90 minutes shows as "90:00".
String formatSequenceClock(Duration duration) {
  final seconds = duration.inSeconds;
  final minutes = seconds ~/ 60;
  final remainder = seconds % 60;
  return '${minutes.toString().padLeft(2, '0')}:'
      '${remainder.toString().padLeft(2, '0')}';
}

/// The one-line summary under a sequence's name: `N poses · mm:ss`.
String sequenceSummaryLine(YogaSequence sequence) {
  final count = sequence.poseCount;
  final noun = count == 1 ? 'pose' : 'poses';
  return '$count $noun · ${formatSequenceClock(sequence.totalDuration)}';
}
