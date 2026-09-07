import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/features/nutrition/presentation/online_food_search_controller.dart';
import 'package:menfit_app/features/nutrition/presentation/widgets/online_food_results.dart';

/// The picker's `Showing <Region> results · Change` caption.
///
/// It exists so an empty online result set is **explainable**. Before the
/// 2026-09-03 region filter the online region could only be too broad; now
/// it can also be too narrow, and a user who is told nothing would read
/// "Nothing under those words at Open Food Facts" as a fact about the
/// database rather than about a setting she never chose.
void main() {
  Future<void> pumpSection(
    WidgetTester tester, {
    required String regionLabel,
    required VoidCallback onChangeRegion,
    bool supportsTextSearch = true,
    OnlineFoodSearchState state = const OnlineFoodSearchState(),
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: SingleChildScrollView(
            child: OnlineFoodSection(
              supportsTextSearch: supportsTextSearch,
              attributionName: 'Open Food Facts',
              attributionUrl: 'https://openfoodfacts.org',
              regionLabel: regionLabel,
              state: state,
              hideCalorieNumbers: false,
              busy: false,
              onSearch: () {},
              onLoadMore: () {},
              onPick: (_) {},
              onChangeRegion: onChangeRegion,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('names the region before a search has been run', (tester) async {
    await pumpSection(
      tester,
      regionLabel: 'Australia',
      onChangeRegion: () {},
    );

    // Before, not only after: someone who knows the search is confined to
    // one country can widen it before spending one of a documented
    // 10-per-minute budget.
    expect(find.textContaining('Showing Australia results'), findsOneWidget);
    expect(find.byKey(const Key('onlineRegionChangeButton')), findsOneWidget);
  });

  testWidgets('still names it beside an empty result set', (tester) async {
    await pumpSection(
      tester,
      regionLabel: 'Australia',
      onChangeRegion: () {},
      state: const OnlineFoodSearchState(hasSearched: true, query: 'zarrafa'),
    );

    expect(find.textContaining('Showing Australia results'), findsOneWidget);
    expect(
      find.textContaining('Nothing under those words'),
      findsOneWidget,
    );
  });

  testWidgets('"Anywhere" says so rather than saying nothing', (tester) async {
    await pumpSection(
      tester,
      regionLabel: 'Anywhere',
      onChangeRegion: () {},
    );

    expect(find.textContaining('Showing Anywhere results'), findsOneWidget);
  });

  testWidgets('Change is a real button and calls back', (tester) async {
    var taps = 0;
    await pumpSection(
      tester,
      regionLabel: 'Australia',
      onChangeRegion: () => taps++,
    );

    await tester.tap(find.byKey(const Key('onlineRegionChangeButton')));
    await tester.pump();

    expect(taps, 1);
  });

  testWidgets('there is no caption where the provider cannot search at '
      'all', (tester) async {
    // Nothing to change: the region governs a search this provider does not
    // offer, so the caption would send the user to a setting that would not
    // help her.
    await pumpSection(
      tester,
      regionLabel: 'Australia',
      onChangeRegion: () {},
      supportsTextSearch: false,
    );

    expect(find.textContaining('Showing Australia results'), findsNothing);
    expect(find.byKey(const Key('onlineRegionChangeButton')), findsNothing);
  });
}
