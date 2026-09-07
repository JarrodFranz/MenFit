import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/config/shared_preferences_provider.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/cycle/domain/cycle_prediction_engine.dart';
import 'package:menfit_app/features/recaps/domain/cycle_recap.dart';
import 'package:menfit_app/features/recaps/domain/recap_period.dart';
import 'package:menfit_app/features/recaps/domain/recap_pr_highlight.dart';
import 'package:menfit_app/features/recaps/presentation/recap_story_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// July 2026 — 31 days, labelled "Your July".
final RecapPeriod _july = RecapPeriod.forMonth(LocalDate(2026, 7, 1));

/// A recap with something for every slide: opener, movement, strength,
/// mindful, PR showcase, hydration/fueling, wellbeing, closing.
CycleRecap _fullRecap({CyclePhase? phase = CyclePhase.follicular}) =>
    CycleRecap(
      period: _july,
      sessionCount: 12,
      consistencyRatio: 12 / 31,
      distanceByType: const {
        ActivityType.run: 42000,
        ActivityType.walk: 8000,
      },
      totalDistanceMeters: 50000,
      totalTonnageKg: 3450,
      mindfulMinutes: 90,
      hydrationConsistencyRatio: 0.75,
      fuelingConsistencyRatio: 0.5,
      topPrs: [
        RecapPrHighlight(
          type: RecapPrType.bestEffort,
          label: '5 km best effort',
          valueLabel: '24:12',
          achievedAt: DateTime.utc(2026, 7, 12),
          phase: phase,
        ),
      ],
      wellbeingObservation:
          'On the days you logged better sleep, your energy check-ins '
          'tended to be higher too.',
    );

/// A recap whose optional metrics are all absent — only the opener and the
/// closing affirmation should survive (Task 1.3's "never render a zero").
CycleRecap _sparseRecap() =>
    CycleRecap(period: _july, sessionCount: 4, consistencyRatio: 4 / 31);

/// A yoga/Pilates-only period: mindful minutes and nothing else. The
/// figure used to be computed and then shown only as a footnote of the
/// strength slide, so a recap like this one never showed it at all.
CycleRecap _mindfulOnlyRecap({int mindfulMinutes = 90}) => CycleRecap(
  period: _july,
  sessionCount: 5,
  consistencyRatio: 5 / 31,
  mindfulMinutes: mindfulMinutes,
);

Future<void> _pumpStory(
  WidgetTester tester,
  CycleRecap recap, {
  bool reduceMotion = false,
}) async {
  SharedPreferences.setMockInitialValues({
    if (reduceMotion) 'accessibility_reduce_motion': true,
  });
  final preferences = await SharedPreferences.getInstance();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
      child: MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => RecapStoryScreen(recap: recap),
                ),
              ),
              child: const Text('open recap'),
            ),
          ),
        ),
      ),
    ),
  );

  await tester.tap(find.text('open recap'));
  await tester.pumpAndSettle();
}

/// How many story segments are filled — the segmented progress bar has one
/// [LinearProgressIndicator] per slide, filled up to and including the
/// current one, so this doubles as a read of the current slide index.
int _filledSegments(WidgetTester tester) => tester
    .widgetList<LinearProgressIndicator>(find.byType(LinearProgressIndicator))
    .where((indicator) => indicator.value == 1.0)
    .length;

int _slideCount(WidgetTester tester) => tester
    .widgetList<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator),
    )
    .length;

/// Taps the right two-thirds of an 800x600 test window (advance).
Future<void> _tapForward(WidgetTester tester) =>
    tester.tapAt(const Offset(600, 300));

/// Taps the left third (go back).
Future<void> _tapBack(WidgetTester tester) =>
    tester.tapAt(const Offset(80, 300));

void main() {
  group('RecapStoryScreen slides', () {
    testWidgets('renders one segment per slide and opens on the period '
        'label', (tester) async {
      await _pumpStory(tester, _fullRecap());

      expect(_slideCount(tester), 8);
      expect(_filledSegments(tester), 1);
      expect(find.text('Your July'), findsOneWidget);
      expect(find.textContaining('12 of 31 days'), findsOneWidget);
    });

    testWidgets('skips every slide the recap has nothing for', (tester) async {
      await _pumpStory(tester, _sparseRecap());

      // Opener + closing affirmation only.
      expect(_slideCount(tester), 2);
      expect(find.text('Total distance moved'), findsNothing);
      expect(find.text('Strength moved'), findsNothing);
      expect(find.text('Mindful movement'), findsNothing);
      expect(find.text('Personal records set'), findsNothing);
      expect(find.text('Fueling & hydration'), findsNothing);
      expect(find.text('A gentle observation'), findsNothing);
    });

    testWidgets('never renders a manufactured zero for an absent metric', (
      tester,
    ) async {
      await _pumpStory(tester, _sparseRecap());

      for (var i = 0; i < 2; i++) {
        expect(find.textContaining('0 km'), findsNothing);
        expect(find.textContaining('0 kg'), findsNothing);
        expect(find.textContaining('0%'), findsNothing);
        await _tapForward(tester);
        await tester.pumpAndSettle();
      }
    });

    testWidgets('walks forward and back through the slides', (tester) async {
      await _pumpStory(tester, _fullRecap());

      await _tapForward(tester);
      await tester.pumpAndSettle();
      expect(_filledSegments(tester), 2);
      expect(find.text('Total distance moved'), findsOneWidget);

      await _tapForward(tester);
      await tester.pumpAndSettle();
      expect(_filledSegments(tester), 3);
      expect(find.text('Strength moved'), findsOneWidget);

      await _tapForward(tester);
      await tester.pumpAndSettle();
      expect(_filledSegments(tester), 4);
      expect(find.text('Mindful movement'), findsOneWidget);

      await _tapBack(tester);
      await tester.pumpAndSettle();
      expect(_filledSegments(tester), 3);
      expect(find.text('Strength moved'), findsOneWidget);
    });

    testWidgets('shows the PR phase context on the showcase slide', (
      tester,
    ) async {
      await _pumpStory(tester, _fullRecap());

      for (var i = 0; i < 4; i++) {
        await _tapForward(tester);
        await tester.pumpAndSettle();
      }

      expect(find.text('Personal records set'), findsOneWidget);
      expect(find.text('24:12'), findsOneWidget);
      expect(find.text('5 km best effort · Follicular phase'), findsOneWidget);
    });

    testWidgets('renders a CyclePhase.none PR without a phase suffix', (
      tester,
    ) async {
      // `none` is the prediction engine's "no phase known", not a fifth
      // phase; the providers keep it out of the phase map, and the slide
      // must not render "None phase" if one ever reaches it anyway.
      await _pumpStory(tester, _fullRecap(phase: CyclePhase.none));

      for (var i = 0; i < 4; i++) {
        await _tapForward(tester);
        await tester.pumpAndSettle();
      }

      expect(find.text('5 km best effort'), findsOneWidget);
      expect(find.textContaining('None'), findsNothing);
    });

    testWidgets('a first slide left tap stays put rather than dismissing', (
      tester,
    ) async {
      await _pumpStory(tester, _fullRecap());

      await _tapBack(tester);
      await tester.pumpAndSettle();

      expect(find.byType(RecapStoryScreen), findsOneWidget);
      expect(_filledSegments(tester), 1);
    });
  });

  group('RecapStoryScreen mindful minutes', () {
    testWidgets('a yoga-only period still gets its minutes shown', (
      tester,
    ) async {
      await _pumpStory(tester, _mindfulOnlyRecap());

      // Opener + mindful + closing. There is no strength slide to hang a
      // footnote on, which is exactly the case that used to compute the
      // figure and then drop it.
      expect(_slideCount(tester), 3);

      await _tapForward(tester);
      await tester.pumpAndSettle();

      expect(find.text('Mindful movement'), findsOneWidget);
      expect(find.text('1h 30m'), findsOneWidget);
      expect(find.text('on the mat this period'), findsOneWidget);
    });

    testWidgets('formats a sub-hour total as minutes', (tester) async {
      await _pumpStory(tester, _mindfulOnlyRecap(mindfulMinutes: 45));

      await _tapForward(tester);
      await tester.pumpAndSettle();

      expect(find.text('45 min'), findsOneWidget);
    });

    testWidgets('keeps the strength slide footnote when there is tonnage '
        'too', (tester) async {
      await _pumpStory(tester, _fullRecap());

      for (var i = 0; i < 2; i++) {
        await _tapForward(tester);
        await tester.pumpAndSettle();
      }

      expect(find.text('Strength moved'), findsOneWidget);
      expect(
        find.text('1h 30m of mindful movement, too'),
        findsOneWidget,
      );
    });

    testWidgets('skips the slide entirely when no mindful time was '
        'logged', (tester) async {
      await _pumpStory(tester, _sparseRecap());

      expect(find.text('Mindful movement'), findsNothing);
      expect(_slideCount(tester), 2);
    });
  });

  group('RecapStoryScreen dismissal', () {
    testWidgets('closes on the close button', (tester) async {
      await _pumpStory(tester, _fullRecap());

      await tester.tap(find.byTooltip('Close'));
      await tester.pumpAndSettle();

      expect(find.byType(RecapStoryScreen), findsNothing);
    });

    testWidgets('closes on a downward swipe', (tester) async {
      await _pumpStory(tester, _fullRecap());

      await tester.fling(find.byType(PageView), const Offset(0, 300), 1000);
      await tester.pumpAndSettle();

      expect(find.byType(RecapStoryScreen), findsNothing);
    });

    testWidgets('closes when advancing past the last slide', (tester) async {
      await _pumpStory(tester, _sparseRecap());

      await _tapForward(tester);
      await tester.pumpAndSettle();
      expect(find.byType(RecapStoryScreen), findsOneWidget);

      await _tapForward(tester);
      await tester.pumpAndSettle();
      expect(find.byType(RecapStoryScreen), findsNothing);
    });
  });

  group('RecapStoryScreen reduce motion', () {
    testWidgets('animates the page turn by default', (tester) async {
      await _pumpStory(tester, _fullRecap());

      await _tapForward(tester);
      // A single frame into a 250 ms animation: the page has not landed,
      // so the story is still reporting the first slide.
      await tester.pump();
      expect(_filledSegments(tester), 1);

      await tester.pumpAndSettle();
      expect(_filledSegments(tester), 2);
    });

    testWidgets('jumps instantly when Reduce Motion is on', (tester) async {
      await _pumpStory(tester, _fullRecap(), reduceMotion: true);

      await _tapForward(tester);
      await tester.pump();
      expect(_filledSegments(tester), 2);
    });
  });
}
