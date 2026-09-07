import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/features/achievements/achievements_providers.dart';
import 'package:menfit_app/features/achievements/domain/award_diff.dart';
import 'package:menfit_app/features/achievements/domain/badge_award.dart';
import 'package:menfit_app/features/achievements/domain/badge_catalogue.dart';
import 'package:menfit_app/features/achievements/domain/badge_definition.dart';
import 'package:menfit_app/features/achievements/domain/badge_progress.dart';
import 'package:menfit_app/features/achievements/domain/badge_progress_engine.dart';
import 'package:menfit_app/features/achievements/domain/badge_tier.dart';
import 'package:menfit_app/features/achievements/presentation/achievements_copy.dart';
import 'package:menfit_app/features/achievements/presentation/achievements_screen.dart';
import 'package:menfit_app/features/achievements/presentation/badge_display.dart';
import 'package:menfit_app/features/achievements/presentation/widgets/badge_celebration_dialog.dart';
import 'package:menfit_app/features/achievements/presentation/widgets/badge_tile.dart';

import '../weight/weight_test_vocabulary.dart' show flushDriftTimers;
import 'achievements_test_vocabulary.dart';
import 'award_detector_test.dart' show FakeAwardRepository;

/// The instant every seeded award is recorded at. Midday UTC so the local
/// calendar day is 1 September on every timezone this suite plausibly runs
/// in — a 07:00 UTC stamp would read as 31 August somewhere west.
final DateTime _awardedAt = DateTime.utc(2026, 9, 1, 12);
const String _awardedAtLabel = 'Earned 1 Sep 2026';

/// The whole catalogue evaluated against hand-written metrics — the real
/// engine, so a "12 km to Silver" assertion is testing the presentation and
/// not a hand-faked [BadgeProgress] that agrees with it by construction.
List<BadgeProgress> _progressFor({
  Map<BadgeMetric, double> metrics = const {},
  Set<BadgeCondition> conditions = const {},
}) {
  return [
    for (final definition in badgeCatalogue)
      evaluateBadge(
        definition: definition,
        metrics: metrics,
        conditions: conditions,
      ),
  ];
}

/// A [BadgeTile] by badge id.
Finder _tile(String badgeId) => find.byKey(Key('badgeTile_$badgeId'));

/// Text inside one badge's tile — the same string can legitimately appear
/// on several badges ("2 sessions to Bronze"), so assertions are scoped.
Finder _textIn(String badgeId, String text) =>
    find.descendant(of: _tile(badgeId), matching: find.text(text));

void main() {
  late FakeAwardRepository repository;

  setUp(() {
    repository = FakeAwardRepository();
  });

  /// Pre-records everything [progress] already earns, so the screen's
  /// detector finds nothing new and no celebration covers the case. Tests
  /// that are *about* detection skip this.
  void seedEarnedAwards(List<BadgeProgress> progress) {
    var sequence = 0;
    repository.awards.addAll(
      newlyEarnedAwards(
        progress: progress,
        existingAwards: const [],
        awardedAt: _awardedAt,
        generateId: () => 'award-${sequence++}',
      ),
    );
  }

  Future<void> pumpScreen(
    WidgetTester tester, {
    required List<BadgeProgress> progress,
    bool seedAwards = true,
  }) async {
    // Registered here rather than per test so no test can forget it: the
    // screen mounts autoDispose providers that, unoverridden, sit over
    // Drift `watch` queries whose cleanup timers would otherwise still be
    // pending at teardown (see `weight_test_vocabulary.dart`).
    addTearDown(() => flushDriftTimers(tester));
    if (seedAwards) seedEarnedAwards(progress);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          awardRepositoryProvider.overrideWithValue(repository),
          badgeProgressProvider.overrideWith((ref) async => progress),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const AchievementsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('the trophy case', () {
    testWidgets('shows every badge in the catalogue, in category sections', (
      tester,
    ) async {
      await pumpScreen(tester, progress: _progressFor());

      expect(find.byType(BadgeTile), findsNWidgets(badgeCatalogue.length));
      expect(
        badgeCatalogue,
        hasLength(41),
        reason:
            'a pinned count, so adding a badge is a deliberate act '
            'rather than something that slips in unnoticed',
      );
      for (final definition in badgeCatalogue) {
        expect(
          _textIn(definition.id, definition.title),
          findsOneWidget,
          reason: '${definition.id} is missing from the case',
        );
      }
      for (final category in BadgeCategory.values) {
        expect(
          find.text(category.label),
          findsOneWidget,
          reason: 'no section heading for ${category.name}',
        );
      }

      await flushDriftTimers(tester);
    });

    testWidgets('a new user sees the whole catalogue at zero, with Bronze as '
        'the next rung and nothing asked of them', (tester) async {
      await pumpScreen(tester, progress: _progressFor());

      expect(find.text(trophyCaseEmptyLine), findsOneWidget);
      expect(find.text(trophyCaseInviteLine), findsNothing);

      final tiered = badgeCatalogue.where(
        (definition) => definition.kind == BadgeKind.tiered,
      );
      for (final definition in tiered) {
        final bar = tester.widget<LinearProgressIndicator>(
          find.descendant(
            of: _tile(definition.id),
            matching: find.byType(LinearProgressIndicator),
          ),
        );
        expect(bar.value, 0, reason: '${definition.id} starts part-way up');
        expect(
          find.descendant(
            of: _tile(definition.id),
            matching: find.textContaining('to Bronze'),
          ),
          findsOneWidget,
          reason: '${definition.id} does not offer Bronze',
        );
      }

      // Every one-off is present and quietly pending - no checklist, no
      // "locked", no count of what is missing.
      expect(
        find.text(oneOffPendingLabel),
        findsNWidgets(
          badgeCatalogue
              .where((definition) => definition.kind == BadgeKind.oneOff)
              .length,
        ),
      );
      expect(find.text(oneOffEarnedLabel), findsNothing);

      await flushDriftTimers(tester);
    });

    testWidgets('an earned badge leads with its tier and an earned one-off '
        'with its marker', (tester) async {
      await pumpScreen(
        tester,
        progress: _progressFor(
          metrics: {BadgeMetric.lifetimeRunDistanceMetres: 88000},
          conditions: {BadgeCondition.firstActivityLogged},
        ),
      );

      expect(_textIn('run_distance', 'Bronze'), findsOneWidget);
      expect(_textIn('first_activity', oneOffEarnedLabel), findsOneWidget);
      // Unearned neighbours are still fully present and still inviting.
      expect(
        _textIn('first_five_k_effort', oneOffPendingLabel),
        findsOneWidget,
      );
      expect(_textIn('ride_distance', '50 km to Bronze'), findsOneWidget);
      expect(find.text(earnedCountLine(2)), findsOneWidget);
      expect(find.text(highestTierLine(BadgeTier.bronze)), findsOneWidget);

      await flushDriftTimers(tester);
    });

    testWidgets('converts canonical units into the ones they read', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        progress: _progressFor(
          metrics: {
            // Bronze at 25 km, Silver at 100 km: 12 km of running to go.
            BadgeMetric.lifetimeRunDistanceMetres: 88000,
            // Bronze at 60 minutes, Silver at 300: two hours to go.
            BadgeMetric.mindfulMinutes: 180,
            // Bronze at 5 sessions.
            BadgeMetric.lifetimeSessionCount: 3,
            // Bronze at 10,000 kg.
            BadgeMetric.lifetimeStrengthVolumeKg: 2500,
          },
        ),
      );

      expect(_textIn('run_distance', '12 km to Silver'), findsOneWidget);
      expect(_textIn('run_distance', '88 km so far'), findsOneWidget);
      expect(_textIn('mindful_minutes', '2 hours to Silver'), findsOneWidget);
      expect(
        _textIn('sessions_logged', '2 sessions to Bronze'),
        findsOneWidget,
      );
      expect(
        _textIn('strength_volume', '7,500 kg to Bronze'),
        findsOneWidget,
      );

      await flushDriftTimers(tester);
    });

    testWidgets('the bar runs from the rung held to the rung ahead', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        progress: _progressFor(
          metrics: {BadgeMetric.lifetimeRunDistanceMetres: 88000},
        ),
      );

      final bar = tester.widget<LinearProgressIndicator>(
        find.descendant(
          of: _tile('run_distance'),
          matching: find.byType(LinearProgressIndicator),
        ),
      );
      // (88 - 25) / (100 - 25) km.
      expect(bar.value, closeTo(0.84, 0.0001));
      // The sentence is the bar's LABEL. Its `semanticsValue` is left to
      // the framework's own percentage, because a progress-bar semantics
      // node validates its value as a number - a sentence there throws for
      // every user running a screen reader (and did, before this was
      // moved: `_semanticsProgressBar` in Flutter's `semantics.dart`).
      expect(bar.semanticsLabel, 'The Road So Far. 12 km to Silver');
      expect(bar.semanticsValue, isNull);

      await flushDriftTimers(tester);
    });

    testWidgets('carries the ladder past Diamond in roman numerals', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        progress: _progressFor(
          metrics: {
            // Diamond I at 2,500 km; Diamond II a further 1,500 km on.
            BadgeMetric.lifetimeRunDistanceMetres: 2600000,
            // Diamond II reached exactly, so Diamond III is next.
            BadgeMetric.lifetimeRideDistanceMetres: 13000000,
          },
        ),
      );

      expect(_textIn('run_distance', 'Diamond'), findsOneWidget);
      expect(
        _textIn('run_distance', '1,400 km to Diamond II'),
        findsOneWidget,
      );
      expect(_textIn('ride_distance', 'Diamond II'), findsOneWidget);
      expect(
        _textIn('ride_distance', '5,000 km to Diamond III'),
        findsOneWidget,
      );
      expect(
        find.text(highestTierLine(BadgeTier.diamond(2))),
        findsOneWidget,
      );

      await flushDriftTimers(tester);
    });

    testWidgets('lays out on a phone and on a desktop window alike', (
      tester,
    ) async {
      addTearDown(() {
        tester.view
          ..resetPhysicalSize()
          ..resetDevicePixelRatio();
      });

      for (final size in [const Size(400, 900), const Size(1400, 1000)]) {
        tester.view
          ..physicalSize = size
          ..devicePixelRatio = 1;

        await pumpScreen(
          tester,
          progress: _progressFor(
            metrics: {
              // The longest pair of lines the tile can produce: a
              // five-figure kilometre count opposite a roman-numeral tier.
              BadgeMetric.lifetimeRideDistanceMetres: 13000000,
              BadgeMetric.lifetimeStrengthVolumeKg: 250000,
            },
          ),
        );

        expect(
          tester.takeException(),
          isNull,
          reason: 'the trophy case overflows at ${size.width}px',
        );
        expect(find.byType(BadgeTile), findsNWidgets(badgeCatalogue.length));
        await flushDriftTimers(tester);
        repository.awards.clear();
      }
    });

    testWidgets('tapping an earned badge shows when each rung was reached', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        progress: _progressFor(
          metrics: {BadgeMetric.lifetimeRunDistanceMetres: 120000},
        ),
      );

      expect(find.text(_awardedAtLabel), findsNothing);

      await tester.ensureVisible(_tile('run_distance'));
      await tester.pumpAndSettle();
      await tester.tap(_tile('run_distance'));
      await tester.pumpAndSettle();

      // Silver was reached, so Bronze and Silver are both in the ladder.
      expect(_textIn('run_distance', 'Bronze'), findsOneWidget);
      expect(_textIn('run_distance', 'Silver'), findsNWidgets(2));
      expect(
        _textIn('run_distance', _awardedAtLabel),
        findsNWidgets(2),
      );

      await flushDriftTimers(tester);
    });
  });

  group('a badge already awarded', () {
    testWidgets('keeps its rung when the data later reads lower', (
      tester,
    ) async {
      // Silver was awarded and recorded. The data now reads 30 km, which is
      // only Bronze - the shape of a real regression, e.g. the cycle-pausing
      // toggle changing which days count as protected. The award stands.
      repository.awards.addAll([
        BadgeAward(
          id: 'a1',
          badgeId: 'run_distance',
          awardedAt: _awardedAt,
          tier: BadgeTier.bronze,
        ),
        BadgeAward(
          id: 'a2',
          badgeId: 'run_distance',
          awardedAt: _awardedAt,
          tier: BadgeTier.silver,
        ),
      ]);

      await pumpScreen(
        tester,
        seedAwards: false,
        progress: _progressFor(
          metrics: {BadgeMetric.lifetimeRunDistanceMetres: 30000},
        ),
      );

      expect(_textIn('run_distance', 'Silver'), findsOneWidget);
      expect(_textIn('run_distance', 'Bronze'), findsNothing);
      // The next rung on offer is the one above the tier they Hold...
      expect(_textIn('run_distance', '370 km to Gold'), findsOneWidget);
      // ...and the bar under it is honest about how far off that is.
      final bar = tester.widget<LinearProgressIndicator>(
        find.descendant(
          of: _tile('run_distance'),
          matching: find.byType(LinearProgressIndicator),
        ),
      );
      expect(bar.value, 0);
      expect(_textIn('run_distance', '30 km so far'), findsOneWidget);

      await flushDriftTimers(tester);
    });

    testWidgets('is counted by the header, which the Progress card matches', (
      tester,
    ) async {
      repository.awards.addAll([
        BadgeAward(
          id: 'a1',
          badgeId: 'run_distance',
          awardedAt: _awardedAt,
          tier: BadgeTier.silver,
        ),
        BadgeAward(
          id: 'a2',
          badgeId: 'first_activity',
          awardedAt: _awardedAt,
        ),
      ]);

      await pumpScreen(tester, seedAwards: false, progress: _progressFor());

      // Two badges held, nothing at all earned by the current data - the
      // header would have said "nothing in the case yet" before the merge,
      // while the Progress card counted two.
      expect(find.text(earnedCountLine(2)), findsOneWidget);
      expect(find.text(trophyCaseEmptyLine), findsNothing);
      expect(find.text(highestTierLine(BadgeTier.silver)), findsOneWidget);
      expect(
        earnedBadgeCount(awards: repository.awards),
        2,
        reason: "the Progress card's number is the same computation",
      );

      await flushDriftTimers(tester);
    });

    testWidgets('opens its ladder, with the dates each rung was recorded', (
      tester,
    ) async {
      repository.awards.addAll([
        BadgeAward(
          id: 'a1',
          badgeId: 'run_distance',
          awardedAt: _awardedAt,
          tier: BadgeTier.bronze,
        ),
        BadgeAward(
          id: 'a2',
          badgeId: 'run_distance',
          awardedAt: _awardedAt,
          tier: BadgeTier.silver,
        ),
      ]);

      await pumpScreen(tester, seedAwards: false, progress: _progressFor());

      await tester.ensureVisible(_tile('run_distance'));
      await tester.pumpAndSettle();
      await tester.tap(_tile('run_distance'));
      await tester.pumpAndSettle();

      expect(_textIn('run_distance', _awardedAtLabel), findsNWidgets(2));

      await flushDriftTimers(tester);
    });

    testWidgets('a one-off they hold stays earned', (tester) async {
      repository.awards.add(
        BadgeAward(
          id: 'a1',
          badgeId: 'first_activity',
          awardedAt: _awardedAt,
        ),
      );

      await pumpScreen(tester, seedAwards: false, progress: _progressFor());

      expect(_textIn('first_activity', oneOffEarnedLabel), findsOneWidget);
      expect(_textIn('first_activity', oneOffPendingLabel), findsNothing);

      await flushDriftTimers(tester);
    });
  });

  group('detection on open', () {
    testWidgets('records a newly-earned badge and celebrates it once', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        seedAwards: false,
        progress: _progressFor(
          conditions: {BadgeCondition.firstActivityLogged},
        ),
      );

      expect(repository.awards, hasLength(1));
      expect(repository.awards.single.badgeId, 'first_activity');

      expect(find.byKey(const Key('badgeCelebrationDialog')), findsOneWidget);
      expect(find.text(newBadgeCelebrationTitle), findsOneWidget);
      expect(find.text(newBadgeAffirmation), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const Key('badgeCelebrationDialog')),
          matching: find.text('First One Logged'),
        ),
        findsOneWidget,
      );

      await tester.tap(find.text(celebrationDismissLabel));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('badgeCelebrationDialog')), findsNothing);

      await flushDriftTimers(tester);
    });

    testWidgets('more than three crossings arrive as one summary, not a '
        'queue of modals', (tester) async {
      await pumpScreen(
        tester,
        seedAwards: false,
        progress: _progressFor(
          // Gold on the running ladder is three rungs at once, and the
          // first session is a fourth award.
          metrics: {BadgeMetric.lifetimeRunDistanceMetres: 450000},
          conditions: {BadgeCondition.firstActivityLogged},
        ),
      );

      expect(repository.awards, hasLength(4));
      expect(find.byKey(const Key('badgeCelebrationDialog')), findsOneWidget);
      expect(find.text(catchUpCelebrationTitle(4)), findsOneWidget);
      expect(find.text(catchUpAffirmation), findsOneWidget);
      expect(find.text(newBadgeCelebrationTitle), findsNothing);
      expect(find.text(newBadgesCelebrationTitle), findsNothing);

      await flushDriftTimers(tester);
    });

    testWidgets('says nothing when everything is already held', (tester) async {
      await pumpScreen(
        tester,
        progress: _progressFor(
          metrics: {BadgeMetric.lifetimeRunDistanceMetres: 450000},
        ),
      );

      expect(find.byKey(const Key('badgeCelebrationDialog')), findsNothing);

      await flushDriftTimers(tester);
    });

    testWidgets('a detector that cannot read leaves the case alone', (
      tester,
    ) async {
      addTearDown(() => flushDriftTimers(tester));
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            awardRepositoryProvider.overrideWithValue(repository),
            badgeProgressProvider.overrideWith(
              (ref) => Future<List<BadgeProgress>>.error(
                StateError('no history'),
              ),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.light(),
            home: const AchievementsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byKey(const Key('badgeCelebrationDialog')), findsNothing);
      expect(repository.awards, isEmpty);

      await flushDriftTimers(tester);
    });
  });

  group('the forbidden-vocabulary sweep', () {
    /// Every string a user can currently read or hear: the visible text,
    /// the tooltips, and the semantics the screen reader is handed for the
    /// progress bars (which are not `Text` and were the half most likely
    /// to drift).
    List<(String, String)> readableCopy(WidgetTester tester) {
      return [
        for (final widget in tester.widgetList<Text>(find.byType(Text)))
          if (widget.data != null) ('a Text widget', widget.data!),
        for (final widget in tester.widgetList<Tooltip>(find.byType(Tooltip)))
          if (widget.message != null) ('a Tooltip', widget.message!),
        for (final widget in tester.widgetList<Semantics>(
          find.byType(Semantics),
        )) ...[
          if (widget.properties.label case final label?)
            ('a semantics label', label),
          if (widget.properties.value case final value?)
            ('a semantics value', value),
        ],
      ];
    }

    void expectClean(WidgetTester tester, {required String where}) {
      final rendered = readableCopy(tester);
      expect(rendered, isNotEmpty, reason: 'nothing was swept in $where');
      for (final (source, text) in rendered) {
        expectNoForbiddenAchievementVocabulary(
          text,
          source: '$source in $where',
        );
      }
    }

    testWidgets('across an empty case', (tester) async {
      await pumpScreen(tester, progress: _progressFor());

      expectClean(tester, where: 'the empty trophy case');

      await flushDriftTimers(tester);
    });

    testWidgets('across a case with earned and unearned badges, expanded', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        progress: _progressFor(
          metrics: {
            BadgeMetric.lifetimeRunDistanceMetres: 120000,
            BadgeMetric.mindfulMinutes: 180,
          },
          conditions: {BadgeCondition.firstActivityLogged},
        ),
      );

      expectClean(tester, where: 'the trophy case');

      await tester.ensureVisible(_tile('run_distance'));
      await tester.pumpAndSettle();
      await tester.tap(_tile('run_distance'));
      await tester.pumpAndSettle();

      expectClean(tester, where: 'an expanded badge');

      await flushDriftTimers(tester);
    });

    testWidgets('across the celebration', (tester) async {
      await pumpScreen(
        tester,
        seedAwards: false,
        progress: _progressFor(
          metrics: {BadgeMetric.lifetimeRunDistanceMetres: 450000},
          conditions: {BadgeCondition.firstActivityLogged},
        ),
      );

      expect(find.byKey(const Key('badgeCelebrationDialog')), findsOneWidget);
      expectClean(tester, where: 'the badge celebration');

      await flushDriftTimers(tester);
    });
  });

  testWidgets('a celebration built with nothing to celebrate renders nothing', (
    tester,
  ) async {
    // `show()` declines to open one, but the widget is public and its
    // headline picks the highest rung with `reduce` - which throws on an
    // empty list rather than simply having nothing to say.
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: BadgeCelebrationDialog(badges: [])),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('badgeCelebrationDialog')), findsNothing);
  });
}
