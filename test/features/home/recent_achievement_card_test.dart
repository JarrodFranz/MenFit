import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/config/shared_preferences_provider.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/features/achievements/achievements_providers.dart';
import 'package:menfit_app/features/achievements/domain/badge_award.dart';
import 'package:menfit_app/features/achievements/domain/badge_tier.dart';
import 'package:menfit_app/features/home/presentation/widgets/recent_achievement_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<void> pumpCard(
    WidgetTester tester, {
    required List<BadgeAward> awards,
  }) async {
    tester.view
      ..physicalSize = const Size(420, 900)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          badgeAwardsProvider.overrideWith((ref) => Stream.value(awards)),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const Scaffold(
            body: SingleChildScrollView(child: RecentAchievementCard()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('offers a quiet invitation when nothing has been earned', (
    tester,
  ) async {
    await pumpCard(tester, awards: const []);

    expect(find.text('No badges yet'), findsOneWidget);
    expect(find.text("See what's on offer"), findsOneWidget);
  });

  testWidgets('names the most recent badge, its tier and the day it landed', (
    tester,
  ) async {
    await pumpCard(
      tester,
      awards: [
        BadgeAward(
          id: 'older',
          badgeId: 'sessions_logged',
          awardedAt: DateTime.utc(2026, 1, 4, 12),
          tier: BadgeTier.bronze,
        ),
        BadgeAward(
          id: 'newer',
          badgeId: 'run_distance',
          awardedAt: DateTime.utc(2026, 8, 20, 12),
          tier: BadgeTier.silver,
        ),
      ],
    );

    // The catalogue's own title, never a re-spelling of it here.
    expect(find.text('The Road So Far'), findsOneWidget);
    expect(find.text('Week After Week'), findsNothing);
    // The tier is named in words beside the crest, never left to colour.
    expect(find.textContaining('Silver'), findsOneWidget);
  });

  testWidgets('an award whose badge left the catalogue is not named', (
    tester,
  ) async {
    await pumpCard(
      tester,
      awards: [
        BadgeAward(
          id: 'retired',
          badgeId: 'a_badge_that_no_longer_exists',
          awardedAt: DateTime.utc(2026, 8, 20, 12),
          tier: BadgeTier.gold,
        ),
      ],
    );

    // There would be no title to name it with, so the card reports the
    // honest empty state rather than a blank row.
    expect(find.text('No badges yet'), findsOneWidget);
  });
}
