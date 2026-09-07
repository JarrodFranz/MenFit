import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/platform/sharing/share_feedback.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/challenges/domain/challenge.dart';
import 'package:menfit_app/features/challenges/domain/challenge_codes.dart';
import 'package:menfit_app/features/challenges/domain/challenge_validation.dart';
import 'package:menfit_app/features/challenges/presentation/challenges_copy.dart';

import 'challenge_fixtures.dart';
import 'challenges_test_vocabulary.dart';

/// Copy gate plus the unit conversion the whole feature rests on.
///
/// The vocabulary itself lives in `challenges_test_vocabulary.dart`,
/// shared with the widget-level sweeps so the gates cannot drift apart —
/// the mistake `weight_test_vocabulary.dart` records having already been
/// made once.
void main() {
  final distance = distanceBlueprint();
  final sessions = sessionBlueprint();

  group('the forbidden-vocabulary gate', () {
    final allCopy = <String, String>{
      'screenTitle': challengesScreenTitle,
      'sectionTitle': challengesSectionTitle,
      'sectionOpen': challengesSectionOpenLabel,
      'start': startChallengeLabel,
      'join': joinChallengeLabel,
      'activeHeading': activeChallengesHeading,
      'finishedHeading': finishedChallengesHeading,
      'empty': challengesEmptyLine,
      'count.one': activeChallengeCountLine(1),
      'count.many': activeChallengeCountLine(4),
      'target.distance': challengeTargetLine(distance),
      'target.sessions': challengeTargetLine(sessions),
      'activity.any': challengeActivityLine(const {}),
      'activity.one': challengeActivityLine(const {ActivityType.run}),
      'activity.many': challengeActivityLine(const {
        ActivityType.run,
        ActivityType.ride,
        ActivityType.swim,
      }),
      'window': challengeWindowLine(septemberStart, septemberEnd),
      'day': challengeDayLabel(septemberStart),
      'origin.created': originLine(ChallengeOrigin.created),
      'origin.joined': originLine(ChallengeOrigin.joined),
      'selfLabel': selfLabel,
      'percent': formatPercent(112.4),
      'asOf': buddyAsOfLine(septemberStart),
      'buddyCardLine': buddyCardLine('Sam', 48, septemberStart),
      'semantics.self': selfProgressSemanticsLabel(62),
      'semantics.buddy': buddyProgressSemanticsLabel('Sam', 104),
      'selfReached': selfReachedLine,
      'buddyReached': buddyReachedLine('Sam'),
      'bothTitle': bothReachedTitle,
      'bothLine': bothReachedLine,
      'fairness': fairnessNote,
      'createTitle': createChallengeTitle,
      'kindField': kindFieldLabel,
      'kindDistance': kindDistanceLabel,
      'kindSessions': kindSessionsLabel,
      'activityField': activityTypesFieldLabel,
      'activityHelper': activityTypesHelper,
      'distanceField': distanceFieldLabel,
      'sessionsField': sessionsFieldLabel,
      'windowField': windowFieldLabel,
      'windowPick': windowPickLabel,
      'windowHelp': windowPickHelpText,
      'nameField': displayNameFieldLabel,
      'nameHelper': displayNameHelper,
      'createSubmit': createSubmitLabel,
      'createdTitle': challengeCreatedTitle,
      'createdLine': challengeCreatedLine,
      'challengeCodePrivacy': challengeCodePrivacyNote,
      'copyCode': copyCodeLabel,
      'shareCode': shareCodeLabel,
      'codeCopied': codeCopiedMessage,
      'done': doneLabel,
      'joinTitle': joinChallengeTitle,
      'joinCodeField': joinCodeFieldLabel,
      'joinCodeHelper': joinCodeHelper,
      'joinSubmit': joinSubmitLabel,
      'joined': joinedMessage,
      'alreadyJoined': alreadyJoinedMessage,
      'preview': joinCodePreviewLine(distance),
      'detailTitle': challengeDetailTitle,
      'buddyHeading': buddySectionHeading,
      'buddyEmpty': buddyEmptyLine,
      'pasteBuddy': pasteBuddyCodeLabel,
      'buddyCodeField': buddyCodeFieldLabel,
      'buddyCodeHelper': buddyCodeHelper,
      'importBuddy': importBuddyCodeLabel,
      'buddyImported': buddyImportedMessage('Sam'),
      'buddyNotNewer': buddyNotNewerMessage,
      'buddyOwnCode': buddyOwnCodeMessage,
      'buddyUnknown': buddyUnknownChallengeMessage,
      'shareProgress': shareProgressLabel,
      'progressCodeTitle': progressCodeTitle,
      'progressCodeLine': progressCodeLine,
      'progressCodePrivacy': progressCodePrivacyNote,
      'leaveLabel': leaveChallengeLabel,
      'leaveTitle': leaveChallengeTitle,
      'leaveBody': leaveChallengeBody,
      'leaveConfirm': leaveChallengeConfirmLabel,
      'leaveCancel': leaveChallengeCancelLabel,
      'leftMessage': leftChallengeMessage,
      'challengeGone': challengeGoneLine,
      'challengeGoneBack': challengeGoneBackLabel,
      'celebrationTitle': celebrationSheetTitle,
      'celebrationFormat': celebrationCardFormatLabel,
      'celebrationStory': celebrationStoryLabel,
      'celebrationSquare': celebrationSquareLabel,
      'celebrationOpen': celebrationOpenLabel,
      'celebrationShare': celebrationShareLabel,
      'celebrationSystemShare': celebrationSystemShareLabel,
      'celebrationCopied': celebrationCopiedMessage,
      'celebrationFooter': celebrationCardFooter,
      'celebrationNames': celebrationNamesLine('Alex', 'Sam'),
      'celebrationText': celebrationShareText(
        selfDisplayName: 'Alex',
        buddyDisplayName: 'Sam',
        blueprint: distance,
      ),
      for (final rejection in CodeRejection.values)
        'joinRejection.${rejection.name}': joinCodeRejectionMessage(rejection),
      for (final rejection in CodeRejection.values)
        'progressRejection.${rejection.name}': progressCodeRejectionMessage(
          rejection,
        ),
    };

    test('the shared share-outcome snackbars clear the gate too', () {
      // These live in core (`core/platform/sharing/share_feedback.dart`)
      // because all four sharing surfaces show them, but they appear on
      // challenge screens, so they are held to the challenge list like
      // anything else rendered there.
      for (final message in shareOutcomeMessages) {
        expectNoForbiddenChallengeVocabulary(
          message,
          source: 'share_feedback.dart#$message',
        );
      }
    });

    test('no challenge string implies a ranking or names a cycle', () {
      for (final entry in allCopy.entries) {
        expectNoForbiddenChallengeVocabulary(
          entry.value,
          source: 'challenges_copy.dart#${entry.key}',
        );
      }
    });

    test('every validation message clears the same gate', () {
      final today = LocalDate(2026, 9, 1);
      final messages = <String, String>{};
      void add(String key, String? message) {
        if (message != null) messages[key] = message;
      }

      ChallengeValidation validate({
        ChallengeKind kind = ChallengeKind.totalDistance,
        int targetUnits = 1000,
        LocalDate? start,
        LocalDate? end,
        String displayName = 'Alex',
      }) {
        return validateChallenge(
          kind: kind,
          targetUnits: targetUnits,
          windowStart: start ?? today,
          windowEnd: end ?? today.addDays(29),
          displayName: displayName,
          today: today,
        );
      }

      add('endBeforeStart', validate(end: today.addDays(-1)).windowError);
      add('tooLong', validate(end: today.addDays(200)).windowError);
      add(
        'tooFarPast',
        validate(
          start: today.addDays(-400),
          end: today.addDays(-390),
        ).windowError,
      );
      add(
        'tooFarFuture',
        validate(
          start: today.addDays(400),
          end: today.addDays(410),
        ).windowError,
      );
      add('distanceTarget', validate(targetUnits: 0).targetError);
      add(
        'sessionTarget',
        validate(kind: ChallengeKind.sessionCount, targetUnits: 0).targetError,
      );
      add('nameEmpty', validateDisplayName('  '));
      add('nameTooLong', validateDisplayName('x' * 40));

      expect(messages, hasLength(8));
      for (final entry in messages.entries) {
        expectNoForbiddenChallengeVocabulary(
          entry.value,
          source: 'challenge_validation.dart#${entry.key}',
        );
      }
    });
  });

  group('the kilometre conversion', () {
    test('round-trips a whole-kilometre target', () {
      expect(distanceUnitsFromKm(100), 1000);
      expect(formatTargetDistance(1000), '100 km');
      expect(formatTargetDistanceValue(1000), '100');
    });

    test('keeps the tenth of a kilometre the stored unit can hold', () {
      expect(distanceUnitsFromKm(42.2), 422);
      expect(formatTargetDistance(422), '42.2 km');
      expect(formatTargetDistanceValue(422), '42.2');
    });

    test('rounds a finer figure to the nearest stored unit', () {
      // 100 m is the resolution of the wire format, so 5.06 km is 5.1 km
      // on both devices or the two people are not in the same challenge.
      expect(distanceUnitsFromKm(5.06), 51);
      expect(distanceUnitsFromKm(5.04), 50);
    });

    test('the domain bounds correspond to 1 km and 1,000 km', () {
      expect(distanceUnitsFromKm(1), minDistanceTargetUnits);
      expect(distanceUnitsFromKm(1000), maxDistanceTargetUnits);
    });

    test('parses commas as decimal separators, blanks as null', () {
      expect(parseDistanceInput('42,2'), 42.2);
      expect(parseDistanceInput('  '), isNull);
      expect(parseDistanceInput('ten'), isNaN);
      expect(parseSessionInput('12'), 12);
      expect(parseSessionInput(''), isNull);
      expect(parseSessionInput('12.5'), isNaN);
    });
  });

  group('progress formatting', () {
    test('renders a percentage over 100 matter-of-factly', () {
      expect(formatPercent(112.9), '112%');
      expect(formatPercent(100), '100%');
    });

    test('floors rather than rounds, so nothing is overstated', () {
      expect(formatPercent(99.9), '99%');
      expect(formatPercent(0), '0%');
    });

    test('the buddy card line says whose goal the figure is against', () {
      expect(
        buddyCardLine('Sam', 48, LocalDate(2026, 9, 12)),
        'Sam: 48% of their own goal · as of 12 Sep',
      );
    });

    test('the leave dialog restates no number of any kind', () {
      // A confirm dialog is not a place for a target, a percentage or a
      // date - least of all on the way out of a challenge.
      for (final text in [leaveChallengeTitle, leaveChallengeBody]) {
        expect(text, isNot(matches(RegExp(r'\d'))));
      }
    });
  });

  group('describing a challenge', () {
    test('an empty activity set reads as "anything", not as nothing', () {
      expect(challengeActivityLine(const {}), anyActivityLabel);
    });

    test('activity types read in the frozen wire order', () {
      expect(
        challengeActivityLine(const {ActivityType.swim, ActivityType.run}),
        'Run and Swim',
      );
    });

    test('a window inside one year names the year once', () {
      expect(
        challengeWindowLine(septemberStart, septemberEnd),
        '1 Sep – 30 Sep 2026',
      );
    });

    test('a window crossing new year names both years', () {
      expect(
        challengeWindowLine(LocalDate(2026, 12, 28), LocalDate(2027, 1, 5)),
        '28 Dec 2026 – 5 Jan 2027',
      );
    });

    test('a session challenge counts sessions, a distance one kilometres', () {
      expect(
        challengeTargetLine(sessionBlueprint(targetUnits: 1)),
        '1 session',
      );
      expect(challengeTargetLine(sessions), '12 sessions');
      expect(challengeTargetLine(distance), '100 km');
    });
  });
}
