import 'dart:convert';

import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/challenges/domain/challenge.dart';
import 'package:menfit_app/features/challenges/domain/challenge_codes.dart';

/// Shared fixtures for the `challenges` tests.
///
/// Every default here is a realistic challenge — "100 km of running
/// through September" and "12 strength sessions in September" — so a
/// length-budget or round-trip assertion is measuring something someone
/// would actually send.

/// September 2026: a 30-day window, the shape most of these tests use.
final LocalDate septemberStart = LocalDate(2026, 9, 1);
final LocalDate septemberEnd = LocalDate(2026, 9, 30);

ChallengeBlueprint distanceBlueprint({
  Set<ActivityType> activityTypes = const {ActivityType.run},
  int targetUnits = 1000, // 100 km
  LocalDate? windowStart,
  LocalDate? windowEnd,
  int salt = 0x5BE30C8A,
}) {
  return challengeBlueprintFrom(
    kind: ChallengeKind.totalDistance,
    activityTypes: activityTypes,
    targetUnits: targetUnits,
    windowStart: windowStart ?? septemberStart,
    windowEnd: windowEnd ?? septemberEnd,
    salt: salt,
  );
}

ChallengeBlueprint sessionBlueprint({
  Set<ActivityType> activityTypes = const {ActivityType.strength},
  int targetUnits = 12,
  LocalDate? windowStart,
  LocalDate? windowEnd,
  int salt = 0x0A1B2C3D,
}) {
  return challengeBlueprintFrom(
    kind: ChallengeKind.sessionCount,
    activityTypes: activityTypes,
    targetUnits: targetUnits,
    windowStart: windowStart ?? septemberStart,
    windowEnd: windowEnd ?? septemberEnd,
    salt: salt,
  );
}

/// This device's author tag in the fixtures — what `challengeFrom` stamps
/// on a challenge and therefore what her own exported progress codes
/// carry.
const int selfAuthorTag = 0x11223344;

/// The buddy device's author tag: any value that is not [selfAuthorTag].
/// A progress code carrying this one is hers, and imports normally; one
/// carrying [selfAuthorTag] is the user's own coming back
/// (`application/challenge_code_service.dart#importProgressCode`).
const int buddyAuthorTag = 0xA9B8C7D6;

Challenge challengeFrom(
  ChallengeBlueprint blueprint, {
  String selfDisplayName = 'Alex',
  ChallengeOrigin origin = ChallengeOrigin.created,
  DateTime? createdAt,
  ChallengeBuddySnapshot? buddy,
  int authorTag = selfAuthorTag,
}) {
  return Challenge(
    blueprint: blueprint,
    selfDisplayName: selfDisplayName,
    origin: origin,
    authorTag: authorTag,
    createdAt: createdAt ?? DateTime.utc(2026, 8, 30, 9),
    buddy: buddy,
  );
}

/// A progress code as the buddy's device would write it: her tag, not
/// ours. The default in every presentation test, because "a code arriving
/// from the other phone" is the ordinary case.
String buddyProgressCode({
  required String challengeId,
  required String displayName,
  required double progressPercent,
  required LocalDate asOf,
  int authorTag = buddyAuthorTag,
}) {
  return encodeProgressCode(
    challengeId: challengeId,
    displayName: displayName,
    progressPercent: progressPercent,
    asOf: asOf,
    authorTag: authorTag,
  );
}

/// One logged activity, positioned by calendar day rather than by instant
/// — the engine reads local days, so a fixture that says "the 3rd" should
/// say it in the same terms.
Activity activityOn(
  LocalDate day, {
  String? id,
  ActivityType type = ActivityType.run,
  double distanceMeters = 2500,
  int hour = 9,
}) {
  final startedAt = DateTime(day.year, day.month, day.day, hour);
  return Activity(
    id: id ?? 'a-${day.toIso()}-$hour-${type.name}',
    activityType: type,
    title: 'Session',
    startedAt: startedAt,
    movingTime: const Duration(minutes: 30),
    elapsedTime: const Duration(minutes: 30),
    distanceMeters: distanceMeters,
    source: ActivitySource.manual,
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
  );
}

/// Every day in the inclusive range — protected-day fixtures read better
/// as "the 5th to the 9th" than as five literals.
Set<LocalDate> daysFrom(LocalDate first, LocalDate last) {
  return {
    for (var day = first; !day.isAfter(last); day = day.addDays(1)) day,
  };
}

/// base64url without padding, matching what the codes themselves use.
/// Only needed by tests that hand-build a payload the real encoder cannot
/// produce (a future activity type, an unknown challenge kind).
String base64UrlNoPadding(List<int> bytes) =>
    base64Url.encode(bytes).replaceAll('=', '');
