import 'package:flutter/material.dart';
import 'package:menfit_app/app/router/routes.dart';
import 'package:menfit_app/core/theme/breakpoints.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/home/presentation/widgets/home_card_layout.dart';
import 'package:menfit_app/features/home/presentation/widgets/home_welcome_header.dart';
import 'package:menfit_app/features/home/presentation/widgets/macros_today_card.dart';
import 'package:menfit_app/features/home/presentation/widgets/progress_summary_card.dart';
import 'package:menfit_app/features/home/presentation/widgets/recent_achievement_card.dart';
import 'package:menfit_app/features/home/presentation/widgets/streak_card.dart';
import 'package:menfit_app/features/home/presentation/widgets/today_overview_card.dart';
import 'package:menfit_app/features/home/presentation/widgets/water_quick_add_card.dart';
import 'package:menfit_app/features/insights/insights_widgets.dart';
import 'package:menfit_app/features/recaps/recaps_widgets.dart';
import 'package:menfit_app/features/steps/steps_widgets.dart';
import 'package:menfit_app/features/wellbeing/wellbeing_widgets.dart';

/// The dashboard: today's essentials, and nothing that is already a tab.
///
/// **What this screen is for** (`knowledge/product/feature_ideas.md`'s
/// "Home dashboard shipped rules"): steps, water, macros, this week's
/// volume, the most recent badge, and a plain "today" summary — the numbers
/// a user opens the app to glance at. It deliberately no longer carries
/// launcher tiles for Nutrition, Cycle, Progress, the strength tracker or
/// GPS recording: every one of those is a nav-bar destination or one tap
/// inside a card here, and a tile that duplicates a tab is a second, worse
/// route to the same place.
///
/// The banner and the prompt above the cards stay because neither is a
/// destination: [StreakCard] reports on today's protection (and, when
/// today is protected, opens the Today sheet), and [CheckinCard] removes
/// itself once today's check-in is logged or dismissed.
///
/// Nothing on this screen names a cycle phase — see
/// `domain/home_today_overview.dart` for the ruling that binds it.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('MenFit'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => const SettingsRouteData().go(context),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Measured on the window, not on the capped content box: the
            // cap below is what decides how wide a column may be, so asking
            // the capped box whether two columns fit would always answer no.
            final twoColumn = WindowSize.fromWidth(
              constraints.maxWidth,
            ).isAtLeastMedium;
            // One column stays at the comfortable reading width; two get
            // that width each, plus the gutter between them. `contentMaxWidth`
            // keeps its single meaning — how wide one column of content may
            // get — rather than gaining a second, wider one.
            final maxWidth = twoColumn
                ? tokens.contentMaxWidth * 2 + tokens.spacingMd
                : tokens.contentMaxWidth;

            return Align(
              // `Align(topCenter)`, never `Center` — that would centre the
              // scroll view vertically too.
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(tokens.spacingMd),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Decides whether a "Your Cycle in Motion" recap is
                      // due and, if so, navigates to it - renders nothing
                      // itself.
                      const RecapTriggerListener(),
                      const HomeWelcomeHeader(),
                      SizedBox(height: tokens.spacingMd),
                      const StreakCard(),
                      const CheckinCard(),
                      SizedBox(height: tokens.spacingSm),
                      HomeCardLayout(
                        twoColumn: twoColumn,
                        cards: const [
                          StepsRingCard(),
                          WaterQuickAddCard(),
                          MacrosTodayCard(),
                          ProgressSummaryCard(),
                          RecentAchievementCard(),
                          TodayOverviewCard(),
                        ],
                      ),
                      SizedBox(height: tokens.spacingMd),
                      // "What your data shows" - at most one discovery here
                      // (Progress shows the full set). Renders nothing,
                      // spacing included, until the engine finds a pattern.
                      const InsightDiscoverySection(maxInsights: 1),
                      SizedBox(height: tokens.spacingLg),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
