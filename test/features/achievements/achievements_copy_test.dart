import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/features/achievements/domain/badge_definition.dart';
import 'package:menfit_app/features/achievements/domain/badge_tier.dart';
import 'package:menfit_app/features/achievements/presentation/achievements_copy.dart';

import 'achievements_test_vocabulary.dart';

void main() {
  group('formatting an amount still to go', () {
    test(
      'turns metres into kilometres, keeping a decimal while it matters',
      () {
        expect(formatRemainingAmount(12000, BadgeMetricUnit.metres), '12 km');
        expect(
          formatRemainingAmount(1400000, BadgeMetricUnit.metres),
          '1,400 km',
        );
        expect(formatRemainingAmount(2500, BadgeMetricUnit.metres), '2.5 km');
        expect(formatRemainingAmount(0, BadgeMetricUnit.metres), '0 km');
      },
    );

    test('turns minutes into hours once there is an hour to turn', () {
      expect(formatRemainingAmount(45, BadgeMetricUnit.minutes), '45 minutes');
      expect(formatRemainingAmount(1, BadgeMetricUnit.minutes), '1 minute');
      expect(formatRemainingAmount(120, BadgeMetricUnit.minutes), '2 hours');
      expect(formatRemainingAmount(60, BadgeMetricUnit.minutes), '1 hour');
      expect(formatRemainingAmount(150, BadgeMetricUnit.minutes), '2.5 hours');
    });

    test('leaves climbing in metres, which is how climbing is spoken', () {
      // Deliberately *not* the metres case: 15,000 m of climbing shown as
      // "15 km" is arithmetically true and completely unreadable.
      expect(
        formatRemainingAmount(15000, BadgeMetricUnit.ascentMetres),
        '15,000 m',
      );
      expect(
        formatRemainingAmount(940.5, BadgeMetricUnit.ascentMetres),
        '941 m',
      );
      expect(formatEarnedAmount(940.5, BadgeMetricUnit.ascentMetres), '940 m');
      expect(formatEarnedAmount(0, BadgeMetricUnit.ascentMetres), '0 m');
    });

    test(
      'groups kilograms, which run to six figures on the tonnage ladder',
      () {
        expect(
          formatRemainingAmount(7500, BadgeMetricUnit.kilograms),
          '7,500 kg',
        );
      },
    );

    test('counts stay counts, and singulars stay singular', () {
      expect(formatRemainingAmount(2, BadgeMetricUnit.sessions), '2 sessions');
      expect(formatRemainingAmount(1, BadgeMetricUnit.sessions), '1 session');
      expect(formatRemainingAmount(7, BadgeMetricUnit.days), '7 days');
      expect(formatRemainingAmount(4, BadgeMetricUnit.weeks), '4 weeks');
      expect(formatRemainingAmount(1, BadgeMetricUnit.months), '1 month');
    });

    test('never rounds an ask down, which would promise a rung early', () {
      // 11.6 km left is shown as 12: above the ten-kilometre mark the
      // display is whole kilometres, and the only safe direction to move
      // that last digit is up. Reading "11 km to Silver" and then not
      // tiering at 11 km is the failure this rule exists to prevent;
      // arriving 400 m earlier than the label said is not a failure.
      expect(formatRemainingAmount(11600, BadgeMetricUnit.metres), '12 km');
      expect(formatRemainingAmount(10400, BadgeMetricUnit.metres), '11 km');
      // Below ten kilometres the decimal survives, and rounds the same way.
      expect(formatRemainingAmount(2510, BadgeMetricUnit.metres), '2.6 km');
      expect(formatRemainingAmount(0.4, BadgeMetricUnit.sessions), '1 session');
      expect(
        formatRemainingAmount(7000.5, BadgeMetricUnit.kilograms),
        '7,001 kg',
      );
    });
  });

  group('formatting an amount already done', () {
    test('never rounds a total up, which would credit her with distance she '
        'has not covered', () {
      expect(formatEarnedAmount(11600, BadgeMetricUnit.metres), '11 km');
      expect(formatEarnedAmount(87600, BadgeMetricUnit.metres), '87 km');
      expect(formatEarnedAmount(2599, BadgeMetricUnit.metres), '2.5 km');
      expect(formatEarnedAmount(0.9, BadgeMetricUnit.sessions), '0 sessions');
      expect(formatEarnedAmount(7999, BadgeMetricUnit.kilograms), '7,999 kg');
      expect(formatEarnedAmount(179, BadgeMetricUnit.minutes), '2.9 hours');
    });

    test('an exact total reads exactly, in either direction', () {
      expect(formatEarnedAmount(88000, BadgeMetricUnit.metres), '88 km');
      expect(formatRemainingAmount(88000, BadgeMetricUnit.metres), '88 km');
      expect(formatEarnedAmount(120, BadgeMetricUnit.minutes), '2 hours');
      expect(formatEarnedAmount(5, BadgeMetricUnit.sessions), '5 sessions');
    });
  });

  group('the summary lines', () {
    test('count up, and never count what is missing', () {
      expect(earnedCountLine(1), '1 badge earned');
      expect(earnedCountLine(7), '7 badges earned');
      expect(earnedCountLine(0), trophyCaseEmptyLine);
      // No completion framing anywhere: nothing says "of 23", and nothing
      // is a percentage.
      expect(earnedCountLine(7), isNot(contains('23')));
      expect(earnedCountLine(7), isNot(contains('%')));
    });

    test('name the highest rung reached', () {
      expect(highestTierLine(BadgeTier.gold), 'Highest tier so far: Gold');
      expect(
        highestTierLine(BadgeTier.diamond(3)),
        'Highest tier so far: Diamond III',
      );
    });
  });

  test('every constant string in this file is celebration, not demand', () {
    final strings = <String, String>{
      'achievementsScreenTitle': achievementsScreenTitle,
      'achievementsSectionTitle': achievementsSectionTitle,
      'achievementsSectionOpenLabel': achievementsSectionOpenLabel,
      'trophyCaseTitle': trophyCaseTitle,
      'trophyCaseEmptyLine': trophyCaseEmptyLine,
      'trophyCaseInviteLine': trophyCaseInviteLine,
      'oneOffPendingLabel': oneOffPendingLabel,
      'oneOffEarnedLabel': oneOffEarnedLabel,
      'newBadgeCelebrationTitle': newBadgeCelebrationTitle,
      'newBadgesCelebrationTitle': newBadgesCelebrationTitle,
      'newBadgeAffirmation': newBadgeAffirmation,
      'catchUpAffirmation': catchUpAffirmation,
      'celebrationDismissLabel': celebrationDismissLabel,
      'catchUpCelebrationTitle': catchUpCelebrationTitle(12),
      'earnedCountLine': earnedCountLine(3),
      'highestTierLine': highestTierLine(BadgeTier.platinum),
      'awardedOnLine': awardedOnLine(DateTime.utc(2026, 9, 1, 12)),
    };

    for (final entry in strings.entries) {
      expectNoForbiddenAchievementVocabulary(
        entry.value,
        source: 'achievements_copy.dart#${entry.key}',
      );
    }
  });
}
