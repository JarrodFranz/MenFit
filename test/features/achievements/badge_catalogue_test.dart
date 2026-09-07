import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/features/achievements/domain/badge_catalogue.dart';
import 'package:menfit_app/features/achievements/domain/badge_definition.dart';
import 'package:menfit_app/features/achievements/domain/badge_tier.dart';

import 'achievements_test_vocabulary.dart';

/// Invariants the catalogue must hold whatever anybody adds to it.
///
/// The id test in particular is the load-bearing one: awards persist as
/// `(badgeId, tierKey)`, so a renamed or duplicated id silently takes a
/// badge away from everyone who earned it.
void main() {
  final tiered = badgeCatalogue
      .where((badge) => badge.kind == BadgeKind.tiered)
      .toList();
  final oneOffs = badgeCatalogue
      .where((badge) => badge.kind == BadgeKind.oneOff)
      .toList();

  group('catalogue shape', () {
    test('ids are unique', () {
      final ids = badgeCatalogue.map((badge) => badge.id).toList();
      expect(ids.toSet(), hasLength(ids.length));
    });

    test('ids are lower_snake_case, so they read as stable keys', () {
      for (final badge in badgeCatalogue) {
        expect(
          badge.id,
          matches(RegExp(r'^[a-z][a-z0-9_]*$')),
          reason: '${badge.id} is a persisted key, not display copy',
        );
      }
    });

    test('every id resolves through the lookup', () {
      for (final badge in badgeCatalogue) {
        expect(badgeDefinitionFor(badge.id), same(badge));
      }
      expect(badgeDefinitionFor('no_such_badge'), isNull);
    });

    test('titles and descriptions are non-empty', () {
      for (final badge in badgeCatalogue) {
        expect(badge.title.trim(), isNotEmpty, reason: badge.id);
        expect(badge.description.trim(), isNotEmpty, reason: badge.id);
      }
    });

    test('titles are unique, so no two badges read as the same award', () {
      final titles = badgeCatalogue.map((badge) => badge.title).toList();
      expect(titles.toSet(), hasLength(titles.length));
    });

    test('the catalogue holds both kinds in useful numbers', () {
      expect(tiered, hasLength(greaterThanOrEqualTo(10)));
      expect(oneOffs, hasLength(greaterThanOrEqualTo(8)));
      expect(tiered.length + oneOffs.length, badgeCatalogue.length);
    });

    test('every tiered badge carries a metric, a unit and a ladder', () {
      for (final badge in tiered) {
        expect(badge.metric, isNotNull, reason: badge.id);
        expect(badge.unit, isNotNull, reason: badge.id);
        expect(badge.ladder, isNotNull, reason: badge.id);
        expect(badge.condition, isNull, reason: badge.id);
      }
    });

    test('every one-off carries a condition and no ladder', () {
      for (final badge in oneOffs) {
        expect(badge.condition, isNotNull, reason: badge.id);
        expect(badge.metric, isNull, reason: badge.id);
        expect(badge.ladder, isNull, reason: badge.id);
      }
    });

    test('no metric backs two tiered badges', () {
      final metrics = tiered.map((badge) => badge.metric).toList();
      expect(metrics.toSet(), hasLength(metrics.length));
    });

    test('no condition backs two one-off badges', () {
      final conditions = oneOffs.map((badge) => badge.condition).toList();
      expect(conditions.toSet(), hasLength(conditions.length));
    });
  });

  group('ladders', () {
    test('named thresholds are strictly increasing and positive', () {
      for (final badge in tiered) {
        final thresholds = badge.ladder!.namedThresholds;
        expect(thresholds, hasLength(BadgeTier.namedTiers.length));
        expect(thresholds.first, greaterThan(0), reason: badge.id);
        for (var i = 1; i < thresholds.length; i++) {
          expect(
            thresholds[i],
            greaterThan(thresholds[i - 1]),
            reason: '${badge.id}: tier $i is not above tier ${i - 1}',
          );
        }
      }
    });

    test('thresholdFor agrees with the named list for the named tiers', () {
      for (final badge in tiered) {
        final ladder = badge.ladder!;
        for (var i = 0; i < BadgeTier.namedTiers.length; i++) {
          expect(
            ladder.thresholdFor(BadgeTier.namedTiers[i]),
            ladder.namedThresholds[i],
            reason: badge.id,
          );
        }
      }
    });

    test('the diamond rule keeps rising for ten levels', () {
      for (final badge in tiered) {
        final ladder = badge.ladder!;
        // Level 1 must be the Diamond threshold itself, not a shifted one.
        expect(
          ladder.thresholdFor(BadgeTier.diamond(1)),
          ladder.diamond,
          reason: badge.id,
        );
        var previous = ladder.diamond;
        for (var level = 2; level <= 10; level++) {
          final value = ladder.thresholdFor(BadgeTier.diamond(level));
          expect(
            value,
            greaterThan(previous),
            reason: '${badge.id}: Diamond $level did not rise',
          );
          previous = value;
        }
      }
    });

    test('bronze is reachable and diamond is a long way past platinum', () {
      for (final badge in tiered) {
        final ladder = badge.ladder!;
        expect(
          ladder.diamond,
          greaterThanOrEqualTo(ladder.platinum * 1.3),
          reason:
              '${badge.id}: Diamond should be a genuinely long haul past '
              'Platinum, not a rounding of it',
        );
      }
    });
  });

  group('copy', () {
    test('no badge string uses forbidden vocabulary', () {
      for (final badge in badgeCatalogue) {
        expectNoForbiddenAchievementVocabulary(
          badge.title,
          source: '${badge.id}.title',
        );
        expectNoForbiddenAchievementVocabulary(
          badge.description,
          source: '${badge.id}.description',
        );
      }
    });

    test('no category or tier label uses forbidden vocabulary', () {
      for (final category in BadgeCategory.values) {
        expectNoForbiddenAchievementVocabulary(
          category.label,
          source: 'BadgeCategory.${category.name}',
        );
      }
      for (var rank = 0; rank < 4; rank++) {
        expectNoForbiddenAchievementVocabulary(
          BadgeTier.namedTiers[rank].label,
          source: 'tier $rank',
        );
      }
      for (var level = 1; level <= 5; level++) {
        expectNoForbiddenAchievementVocabulary(
          BadgeTier.diamond(level).label,
          source: 'diamond $level',
        );
      }
    });

    test('no badge is about body weight, in any category', () {
      // Rule 5 of the catalogue, pinned so a future "weigh-in streak" idea
      // fails here rather than in review.
      for (final badge in badgeCatalogue) {
        expect(
          '${badge.id} ${badge.title} ${badge.description}'.toLowerCase(),
          isNot(contains('weigh')),
          reason:
              '${badge.id}: attaching a reward to stepping on a scale '
              'manufactures the compulsion the weight feature avoids '
              '(knowledge/domain/womens_health.md)',
        );
      }
    });
  });
}
