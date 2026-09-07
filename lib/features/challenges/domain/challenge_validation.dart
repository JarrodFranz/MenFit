import 'dart:convert';

import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/challenges/domain/challenge.dart';
import 'package:menfit_app/features/challenges/domain/challenge_codes.dart';

/// The longest window a challenge may cover, both endpoints included.
///
/// A season, not a life sentence. Long enough for "100 km this quarter",
/// short enough that a challenge is something with an end — an open-ended
/// comparison with a friend is exactly the shape that stops being fun.
const int maxChallengeWindowDays = 92;

/// How far into the past a window may start, and how far into the future.
///
/// Wide, non-judgemental bounds in the same spirit as
/// `features/streaks/domain/recovery_validation.dart`'s range cap: they
/// exist to catch a mis-picked year in a date picker, not to rule on when
/// anyone is allowed to train.
const int maxChallengeStartPastDays = 365;
const int maxChallengeStartFutureDays = 365;

/// Target bounds, per kind, in the kind's own units.
///
/// Distance is counted in hundreds of metres, so the range is 1 km to
/// 1,000 km. Sessions run 1 to 500. Both ends are generous: the point is
/// to reject a slipped decimal point, never to tell anyone their goal is
/// too big or too small.
const int minDistanceTargetUnits = 10;
const int maxDistanceTargetUnits = 10000;
const int minSessionTargetUnits = 1;
const int maxSessionTargetUnits = 500;

// Copy note: no message here interpolates a date, a body metric, or
// anything health-derived (same S3 habit as
// `core/domain/local_date.dart#parse`). The numbers below are fixed
// constants, not user data.
const String _windowEndBeforeStartMessage =
    'Pick a last day that falls on or after the first day.';
const String _windowTooLongMessage =
    'A challenge can run for up to $maxChallengeWindowDays days.';
const String _windowStartTooFarPastMessage =
    'That start date is more than a year ago — check the year.';
const String _windowStartTooFarFutureMessage =
    'That start date is more than a year away — check the year.';
const String _distanceTargetMessage =
    'Pick a distance between 1 km and 1,000 km.';
const String _sessionTargetMessage =
    'Pick a number of sessions between $minSessionTargetUnits and '
    '$maxSessionTargetUnits.';
const String _displayNameEmptyMessage =
    'Pick a name to show your buddy — anything you like.';
const String _displayNameTooLongMessage =
    'That name is a little long for a challenge code — try a shorter one.';

/// Typed per-field validation result — same convention as
/// `features/streaks/domain/recovery_validation.dart` and
/// `features/wellbeing/domain/wellbeing_validation.dart`: an expected
/// outcome is a value, not an exception
/// (`knowledge/engineering/error_handling.md`).
class ChallengeValidation {
  const ChallengeValidation({
    this.windowError,
    this.targetError,
    this.displayNameError,
  });

  final String? windowError;
  final String? targetError;
  final String? displayNameError;

  bool get isValid =>
      windowError == null && targetError == null && displayNameError == null;
}

/// Validates everything a challenge needs before it can be created or
/// joined.
///
/// Note what is **not** validated: which activity types were chosen (an
/// empty set legitimately means "anything counts") and how ambitious the
/// target is relative to anything the user has done before. The app does
/// not have an opinion on whether a goal suits them.
ChallengeValidation validateChallenge({
  required ChallengeKind kind,
  required int targetUnits,
  required LocalDate windowStart,
  required LocalDate windowEnd,
  required String displayName,
  required LocalDate today,
}) {
  return ChallengeValidation(
    windowError: _windowError(windowStart, windowEnd, today),
    targetError: _targetError(kind, targetUnits),
    displayNameError: validateDisplayName(displayName),
  );
}

/// Validates a self-chosen display name on its own — the joiner picks theirs
/// without touching the challenge's other parameters, and the export
/// screen may let them change it later.
///
/// The byte bound is a real constraint of the wire format
/// ([maxDisplayNameBytes]), not a stylistic one, which is why it counts
/// UTF-8 bytes rather than characters: an emoji or an accented name costs
/// more than one byte, and a name that would be silently truncated in the
/// code is better rejected here where they can see it.
String? validateDisplayName(String displayName) {
  final trimmed = displayName.trim();
  if (trimmed.isEmpty) return _displayNameEmptyMessage;
  if (utf8.encode(trimmed).length > maxDisplayNameBytes) {
    return _displayNameTooLongMessage;
  }
  return null;
}

String? _windowError(LocalDate start, LocalDate end, LocalDate today) {
  if (end.isBefore(start)) return _windowEndBeforeStartMessage;
  // Inclusive length: a window whose endpoints are the same day is 1 day.
  if (start.difference(end) + 1 > maxChallengeWindowDays) {
    return _windowTooLongMessage;
  }
  final offsetFromToday = today.difference(start);
  if (offsetFromToday < -maxChallengeStartPastDays) {
    return _windowStartTooFarPastMessage;
  }
  if (offsetFromToday > maxChallengeStartFutureDays) {
    return _windowStartTooFarFutureMessage;
  }
  return null;
}

String? _targetError(ChallengeKind kind, int targetUnits) {
  return switch (kind) {
    ChallengeKind.totalDistance =>
      targetUnits < minDistanceTargetUnits ||
              targetUnits > maxDistanceTargetUnits
          ? _distanceTargetMessage
          : null,
    ChallengeKind.sessionCount =>
      targetUnits < minSessionTargetUnits || targetUnits > maxSessionTargetUnits
          ? _sessionTargetMessage
          : null,
  };
}
