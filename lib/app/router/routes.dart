import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/widgets/adaptive_scaffold.dart';
import 'package:menfit_app/features/achievements/presentation/achievements_screen.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/activity/presentation/activity_detail_screen.dart';
import 'package:menfit_app/features/activity/presentation/activity_screen.dart';
import 'package:menfit_app/features/activity/presentation/hub/exercise_hub_screen.dart';
import 'package:menfit_app/features/activity/presentation/manual_entry_screen.dart';
import 'package:menfit_app/features/activity/presentation/recording/hiit_tracker_screen.dart';
import 'package:menfit_app/features/activity/presentation/recording/mindful_tracker_screen.dart';
import 'package:menfit_app/features/activity/presentation/recording/record_screen.dart';
import 'package:menfit_app/features/activity/presentation/recording/strength_tracker_screen.dart';
import 'package:menfit_app/features/activity/presentation/recording/swim_tracker_screen.dart';
import 'package:menfit_app/features/activity/presentation/recording/yoga_sequence_runner_screen.dart';
import 'package:menfit_app/features/challenges/presentation/challenge_detail_screen.dart';
import 'package:menfit_app/features/challenges/presentation/challenges_screen.dart';
import 'package:menfit_app/features/challenges/presentation/create_challenge_screen.dart';
import 'package:menfit_app/features/challenges/presentation/join_challenge_screen.dart';
import 'package:menfit_app/features/home/presentation/home_screen.dart';
import 'package:menfit_app/features/nutrition/domain/meal_type.dart';
import 'package:menfit_app/features/nutrition/presentation/food_form_screen.dart';
import 'package:menfit_app/features/nutrition/presentation/food_form_seed.dart';
import 'package:menfit_app/features/nutrition/presentation/food_search_screen.dart';
import 'package:menfit_app/features/nutrition/presentation/manage_foods_screen.dart';
import 'package:menfit_app/features/nutrition/presentation/nutrition_goals_screen.dart';
import 'package:menfit_app/features/nutrition/presentation/nutrition_screen.dart';
import 'package:menfit_app/features/onboarding/presentation/onboarding_screen.dart';
import 'package:menfit_app/features/profile/presentation/profile_screen.dart';
import 'package:menfit_app/features/progress/presentation/progress_screen.dart';
import 'package:menfit_app/features/recaps/domain/month_recap.dart';
import 'package:menfit_app/features/recaps/presentation/recap_story_screen.dart';
import 'package:menfit_app/features/routes/domain/geo_point.dart';
import 'package:menfit_app/features/routes/presentation/route_detail_screen.dart';
import 'package:menfit_app/features/routes/presentation/route_suggest_screen.dart';
import 'package:menfit_app/features/routes/presentation/routes_screen.dart';
import 'package:menfit_app/features/safety/presentation/safety_settings_screen.dart';
import 'package:menfit_app/features/settings/presentation/accessibility_settings_screen.dart';
import 'package:menfit_app/features/settings/presentation/settings_screen.dart';
import 'package:menfit_app/features/steps/presentation/steps_screen.dart';
import 'package:menfit_app/features/wearables/presentation/wearables_screen.dart';
import 'package:menfit_app/features/weight/presentation/weight_screen.dart';
import 'package:menfit_app/features/wellbeing/presentation/wellbeing_screen.dart';

part 'routes.g.dart';

/// The one-time onboarding flow. Deliberately outside
/// [AppShellRouteData]'s [StatefulShellRoute] - see
/// `app/router/router.dart` for the redirect that sends users here until
/// onboarding completes.
@TypedGoRoute<OnboardingRouteData>(path: '/onboarding')
class OnboardingRouteData extends GoRouteData with $OnboardingRouteData {
  const OnboardingRouteData();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const OnboardingScreen();
  }
}

/// GPS recording flow (`RecordScreen`). Deliberately outside
/// [AppShellRouteData]'s [StatefulShellRoute] - no nav chrome while
/// recording, same reasoning as [OnboardingRouteData].
@TypedGoRoute<ActivityRecordRouteData>(path: '/activity/record')
class ActivityRecordRouteData extends GoRouteData
    with $ActivityRecordRouteData {
  const ActivityRecordRouteData({this.routeId});

  /// Optional saved route to follow (query parameter,
  /// `/activity/record?route-id=...`): the record screen shows a
  /// "Following" chip and the finished activity stores the link.
  final String? routeId;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return RecordScreen(routeId: routeId);
  }
}

/// Live Strength workout tracker.
@TypedGoRoute<StrengthTrackerRouteData>(path: '/activity/track/strength')
class StrengthTrackerRouteData extends GoRouteData
    with $StrengthTrackerRouteData {
  const StrengthTrackerRouteData();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const StrengthTrackerScreen();
  }
}

/// Live HIIT interval tracker.
@TypedGoRoute<HiitTrackerRouteData>(path: '/activity/track/hiit')
class HiitTrackerRouteData extends GoRouteData with $HiitTrackerRouteData {
  const HiitTrackerRouteData({this.work, this.rest, this.rounds});

  final int? work;
  final int? rest;
  final int? rounds;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return HiitTrackerScreen(
      workSeconds: work ?? 40,
      restSeconds: rest ?? 20,
      totalRounds: rounds ?? 8,
    );
  }
}

/// Live Mindful (Yoga / Pilates) tracker.
@TypedGoRoute<MindfulTrackerRouteData>(path: '/activity/track/mindful')
class MindfulTrackerRouteData extends GoRouteData
    with $MindfulTrackerRouteData {
  const MindfulTrackerRouteData({this.type});

  final String? type;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    final activityType = type == 'pilates'
        ? ActivityType.pilates
        : ActivityType.yoga;
    return MindfulTrackerScreen(initialType: activityType);
  }
}

/// Guided run of one saved yoga sequence (ADR 014).
///
/// Outside [AppShellRouteData]'s [StatefulShellRoute] like every other
/// tracker: a practice with the phone on the mat wants the whole screen,
/// and the active-workout banner is what brings them back to it.
@TypedGoRoute<YogaSequenceRunnerRouteData>(
  path: '/activity/track/yoga-sequence/:sequenceId',
)
class YogaSequenceRunnerRouteData extends GoRouteData
    with $YogaSequenceRunnerRouteData {
  const YogaSequenceRunnerRouteData({required this.sequenceId});

  final String sequenceId;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return YogaSequenceRunnerScreen(sequenceId: sequenceId);
  }
}

/// Live Swimming workout tracker.
@TypedGoRoute<SwimTrackerRouteData>(path: '/activity/track/swim')
class SwimTrackerRouteData extends GoRouteData with $SwimTrackerRouteData {
  const SwimTrackerRouteData();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const SwimTrackerScreen();
  }
}

/// `/activity/routes` - the saved-routes list.
@TypedGoRoute<ActivityRoutesRouteData>(
  path: '/activity/routes',
  routes: [
    TypedGoRoute<RouteSuggestRouteData>(path: 'suggest'),
    TypedGoRoute<RouteDetailRouteData>(path: ':routeId'),
  ],
)
class ActivityRoutesRouteData extends GoRouteData
    with $ActivityRoutesRouteData {
  const ActivityRoutesRouteData();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const RoutesScreen();
  }
}

/// `/activity/routes/suggest` - the "show me routes" flow.
class RouteSuggestRouteData extends GoRouteData with $RouteSuggestRouteData {
  const RouteSuggestRouteData({
    this.type,
    this.distance,
    this.lat,
    this.lng,
    this.address,
  });

  final String? type;
  final String? distance;
  final double? lat;
  final double? lng;
  final String? address;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return RouteSuggestScreen(
      initialActivityType: type != null
          ? ActivityType.fromStorage(type!)
          : null,
      initialDistance: distance,
      initialStartPoint: lat != null && lng != null
          ? GeoPoint(latitude: lat!, longitude: lng!)
          : null,
      initialStartAddress: address,
    );
  }
}

/// `/activity/routes/:routeId` - a single saved route's detail view.
class RouteDetailRouteData extends GoRouteData with $RouteDetailRouteData {
  const RouteDetailRouteData(this.routeId);

  final String routeId;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return RouteDetailScreen(routeId: routeId);
  }
}

/// The monthly recap story (Task 1.3, `TASKS_TO_DO.md`). Deliberately
/// outside [AppShellRouteData]'s [StatefulShellRoute] - no nav chrome for a
/// full-screen immersive story, same reasoning as
/// [ActivityRecordRouteData]. **Must stay root-level**: nesting a
/// full-screen route pushed from Home under a shell branch previously
/// caused a `GlobalKey<NavigatorState>#root` duplication crash for Saved
/// Routes / Route Suggest - this route follows the same fixed pattern.
///
/// [$extra] carries the already-built [MonthRecap] (from
/// `features/recaps/recaps_providers.dart#recapForPeriodProvider`) rather
/// than a period the screen re-fetches itself - both callers
/// (`recaps/presentation/widgets/recap_trigger_listener.dart`'s automatic
/// trigger, and the Progress screen's recap history section) already have
/// it in hand, and re-fetching here would just repeat the same
/// activity/water/nutrition/check-in scan a second time. Like
/// [NutritionNewFoodRouteData]'s seed, this makes the route **deliberately
/// not deep-linkable** - correct here too, since a rebuilt recap for an
/// arbitrary URL would have no caller-supplied period to build it from.
///
/// [$extra] is therefore **nullable**, exactly as [NutritionNewFoodRouteData]'s
/// seed is: go_router's `extra` is an in-memory object, so `/recap` typed
/// into a browser, deep-linked, or restored by a web reload arrives with
/// no recap at all. A non-nullable field made the generated
/// `state.extra as MonthRecap` throw during route build in precisely that
/// case; [redirect] now sends those arrivals to the Progress screen, where
/// the re-viewable recap history lives
/// (`recaps/presentation/widgets/recap_history_section.dart`) — he lands
/// on the list he can pick a recap from rather than a crash or a blank
/// screen.
@TypedGoRoute<RecapStoryRouteData>(path: '/recap')
class RecapStoryRouteData extends GoRouteData with $RecapStoryRouteData {
  const RecapStoryRouteData({this.$extra});

  /// The recap to tell the story of, or `null` when this location was
  /// reached without one (reload, deep link) — see the class dartdoc.
  ///
  /// The `$` name is go_router_builder's, not a style choice: it is the
  /// exact identifier the generator recognises as the non-URL `extra`
  /// payload.
  final MonthRecap? $extra;

  /// The one route-level redirect in the app. ADR 002 keeps redirect logic
  /// out of *screens*; this is not screen logic but the route's own
  /// precondition, and it lives in the same single route table ADR 002
  /// centralises on. It cannot be expressed in the app-level `redirect`
  /// (`app/router/router.dart`), which sees only the location and has no
  /// typed view of `extra`.
  @override
  String? redirect(BuildContext context, GoRouterState state) =>
      state.extra is MonthRecap ? null : const ProgressRouteData().location;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    final recap = $extra;
    // Unreachable: [redirect] turns a null-extra `/recap` away before any
    // build happens. Kept total rather than `!` so this degrades to an
    // empty frame instead of throwing if that ever stops being true.
    if (recap == null) return const SizedBox.shrink();
    return RecapStoryScreen(recap: recap);
  }
}

/// The weight history + trend screen (Task 2.2, `TASKS_TO_DO.md`), pushed
/// from the Progress screen's Weight section.
///
/// **Must stay root-level**, outside [AppShellRouteData]'s
/// [StatefulShellRoute], for the same reason as [RecapStoryRouteData]:
/// nesting a full-screen route pushed from a shell tab under a shell
/// branch previously caused a `GlobalKey<NavigatorState>#root` duplication
/// crash (Saved Routes / Route Suggest). Deep-linkable and stateless — it
/// takes no parameters and reads everything it shows from the weight
/// repository.
@TypedGoRoute<WeightRouteData>(path: '/weight')
class WeightRouteData extends GoRouteData with $WeightRouteData {
  const WeightRouteData();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const WeightScreen();
  }
}

/// The "My Achievements" trophy case (Task 1.8, `TASKS_TO_DO.md`), pushed
/// from the Progress screen's Achievements card.
///
/// **Must stay root-level**, outside [AppShellRouteData]'s
/// [StatefulShellRoute], for the same reason as [WeightRouteData] and
/// [RecapStoryRouteData]: nesting a full-screen route pushed from a shell
/// tab under a shell branch previously caused a
/// `GlobalKey<NavigatorState>#root` duplication crash (Saved Routes /
/// Route Suggest). Deep-linkable and stateless — it takes no parameters
/// and reads everything it shows from the achievements providers.
@TypedGoRoute<AchievementsRouteData>(path: '/achievements')
class AchievementsRouteData extends GoRouteData with $AchievementsRouteData {
  const AchievementsRouteData();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const AchievementsScreen();
  }
}

/// The daily-steps history (Week / Month), pushed from the home "At a
/// Glance" steps ring, the Progress screen's Daily Steps card, and the
/// Walking hub.
///
/// **Must stay root-level**, outside [AppShellRouteData]'s
/// [StatefulShellRoute], for the same reason as [WeightRouteData] and
/// [AchievementsRouteData]: nesting a full-screen route pushed from a shell
/// tab under a shell branch previously caused a
/// `GlobalKey<NavigatorState>#root` duplication crash (Saved Routes /
/// Route Suggest). It is pushed from three different branches (Home,
/// Activity and Home>Progress), which is exactly the case a branch-nested
/// route cannot serve.
///
/// Deep-linkable and stateless — it takes no parameters and reads
/// everything it shows from the steps providers.
@TypedGoRoute<StepsRouteData>(path: '/steps')
class StepsRouteData extends GoRouteData with $StepsRouteData {
  const StepsRouteData();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const StepsScreen();
  }
}

/// The buddy-challenge screens (Task 1.7, `TASKS_TO_DO.md`), pushed from
/// the Progress screen's Buddy challenges card.
///
/// **Must stay root-level**, outside [AppShellRouteData]'s
/// [StatefulShellRoute], for the same reason as [AchievementsRouteData]
/// and [WeightRouteData]: nesting a full-screen route pushed from a shell
/// tab under a shell branch previously caused a
/// `GlobalKey<NavigatorState>#root` duplication crash (Saved Routes /
/// Route Suggest).
///
/// `create` and `join` are listed before `:challengeId` because go_router
/// matches literal segments in list order — the same ordering constraint
/// (and the same reason) as [ActivityRouteData]'s `log`/`:id` pair.
@TypedGoRoute<ChallengesRouteData>(
  path: '/challenges',
  routes: [
    TypedGoRoute<CreateChallengeRouteData>(path: 'create'),
    TypedGoRoute<JoinChallengeRouteData>(path: 'join'),
    TypedGoRoute<ChallengeDetailRouteData>(path: ':challengeId'),
  ],
)
class ChallengesRouteData extends GoRouteData with $ChallengesRouteData {
  const ChallengesRouteData();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ChallengesScreen();
  }
}

/// `/challenges/create` — set a challenge up and get the code to send.
class CreateChallengeRouteData extends GoRouteData
    with $CreateChallengeRouteData {
  const CreateChallengeRouteData();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const CreateChallengeScreen();
  }
}

/// `/challenges/join` — paste a code and join the challenge it describes.
class JoinChallengeRouteData extends GoRouteData with $JoinChallengeRouteData {
  const JoinChallengeRouteData();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const JoinChallengeScreen();
  }
}

/// `/challenges/:challengeId` — one challenge in full.
///
/// The id is the base64url of the challenge's own defining bytes
/// (`features/challenges/domain/challenge_codes.dart`), which is
/// URL-safe by construction — no escaping needed in the path.
class ChallengeDetailRouteData extends GoRouteData
    with $ChallengeDetailRouteData {
  const ChallengeDetailRouteData(this.challengeId);

  final String challengeId;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return ChallengeDetailScreen(challengeId: challengeId);
  }
}

/// The single typed route table for the app: a five-tab
/// [StatefulShellRoute] (Home, Activity, Nutrition, Recovery,
/// Settings), each branch holding exactly one top-level route.
@TypedStatefulShellRoute<AppShellRouteData>(
  branches: [
    TypedStatefulShellBranch<HomeBranchData>(
      routes: [
        TypedGoRoute<HomeRouteData>(
          path: '/home',
          routes: [
            TypedGoRoute<ProgressRouteData>(path: 'progress'),
          ],
        ),
      ],
    ),
    TypedStatefulShellBranch<ActivityBranchData>(
      routes: [
        TypedGoRoute<ActivityRouteData>(
          path: '/activity',
          routes: [
            // Listed before `:id` - go_router matches literal segments in
            // list order, and `:id` would otherwise also match the literal
            // `log`/`routes` segments (binding them as `id`).
            TypedGoRoute<ActivityLogRouteData>(path: 'log'),
            TypedGoRoute<ExerciseHubRouteData>(path: 'hub/:type'),
            TypedGoRoute<ActivityDetailRouteData>(
              path: ':id',
              routes: [
                TypedGoRoute<ActivityDetailEditRouteData>(path: 'edit'),
              ],
            ),
          ],
        ),
      ],
    ),
    TypedStatefulShellBranch<NutritionBranchData>(
      routes: [
        TypedGoRoute<NutritionRouteData>(
          path: '/nutrition',
          routes: [
            TypedGoRoute<NutritionGoalsRouteData>(path: 'goals'),
            TypedGoRoute<NutritionManageFoodsRouteData>(path: 'foods'),
            TypedGoRoute<NutritionAddFoodRouteData>(
              path: 'add',
              routes: [
                TypedGoRoute<NutritionNewFoodRouteData>(path: 'food'),
              ],
            ),
          ],
        ),
      ],
    ),
    TypedStatefulShellBranch<WellbeingBranchData>(
      routes: [TypedGoRoute<WellbeingRouteData>(path: '/recovery')],
    ),
    TypedStatefulShellBranch<SettingsBranchData>(
      routes: [
        TypedGoRoute<SettingsRouteData>(
          path: '/settings',
          routes: [
            TypedGoRoute<SettingsProfileRouteData>(path: 'profile'),
            TypedGoRoute<SettingsAccessibilityRouteData>(path: 'accessibility'),
            TypedGoRoute<SettingsWearablesRouteData>(path: 'wearables'),
            TypedGoRoute<SettingsSafetyRouteData>(path: 'safety'),
          ],
        ),
      ],
    ),
  ],
)
class AppShellRouteData extends StatefulShellRouteData {
  const AppShellRouteData();

  static const List<AdaptiveDestination> destinations = [
    AdaptiveDestination(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      label: 'Home',
    ),
    // "Train", not "Activity": the tab leads with strength, and a barbell
    // says that where a running figure said the opposite. The route path
    // stays `/activity` - only the label and icon are the product's.
    AdaptiveDestination(
      icon: Icons.fitness_center_outlined,
      selectedIcon: Icons.fitness_center,
      label: 'Train',
    ),
    AdaptiveDestination(
      icon: Icons.restaurant_outlined,
      selectedIcon: Icons.restaurant,
      label: 'Nutrition',
    ),
    AdaptiveDestination(
      icon: Icons.self_improvement_outlined,
      selectedIcon: Icons.self_improvement,
      label: 'Recovery',
    ),
    AdaptiveDestination(
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
      label: 'Settings',
    ),
  ];

  @override
  Widget builder(
    BuildContext context,
    GoRouterState state,
    StatefulNavigationShell navigationShell,
  ) {
    return AppAdaptiveScaffold(
      navigationShell: navigationShell,
      destinations: destinations,
    );
  }
}

class HomeBranchData extends StatefulShellBranchData {
  const HomeBranchData();
}

class HomeRouteData extends GoRouteData with $HomeRouteData {
  const HomeRouteData();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const HomeScreen();
  }
}

/// `/home/progress` - weekly trends + personal records. Nested under the
/// home branch (rather than a top-level route) so the nav bar/rail stays
/// visible, same pattern as `/settings/profile`.
class ProgressRouteData extends GoRouteData with $ProgressRouteData {
  const ProgressRouteData();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ProgressScreen();
  }
}

class ActivityBranchData extends StatefulShellBranchData {
  const ActivityBranchData();
}

class ActivityRouteData extends GoRouteData with $ActivityRouteData {
  const ActivityRouteData();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ActivityScreen();
  }
}

/// `/activity/log` - the manual-entry form for a new activity.
class ActivityLogRouteData extends GoRouteData with $ActivityLogRouteData {
  const ActivityLogRouteData({this.type});

  final String? type;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return ManualEntryScreen(
      initialType: type != null ? ActivityType.fromStorage(type!) : null,
    );
  }
}

/// `/activity/hub/:type` - dedicated exercise hub for a specific activity type.
class ExerciseHubRouteData extends GoRouteData with $ExerciseHubRouteData {
  const ExerciseHubRouteData({required this.type});

  final String type;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return ExerciseHubScreen(
      type: ActivityType.fromStorage(type),
    );
  }
}

/// `/activity/:id` - a single activity's detail view.
class ActivityDetailRouteData extends GoRouteData
    with $ActivityDetailRouteData {
  const ActivityDetailRouteData(this.id);

  final String id;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return ActivityDetailScreen(activityId: id);
  }
}

/// `/activity/:id/edit` - the manual-entry form pre-filled for editing.
class ActivityDetailEditRouteData extends GoRouteData
    with $ActivityDetailEditRouteData {
  const ActivityDetailEditRouteData(this.id);

  final String id;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return ManualEntryScreen(editActivityId: id);
  }
}

class NutritionBranchData extends StatefulShellBranchData {
  const NutritionBranchData();
}

class NutritionRouteData extends GoRouteData with $NutritionRouteData {
  const NutritionRouteData();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const NutritionScreen();
  }
}

/// `/nutrition/goals` — daily targets, activity level, weight goal, and the
/// hide-calorie-numbers preference. Nested under the nutrition branch so the
/// nav bar/rail stays visible, same pattern as `/settings/profile`.
class NutritionGoalsRouteData extends GoRouteData
    with $NutritionGoalsRouteData {
  const NutritionGoalsRouteData();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const NutritionGoalsScreen();
  }
}

/// `/nutrition/foods` — the food catalogue: rename, correct or remove a food
/// definition.
///
/// Nested under the nutrition branch for the same reason `/nutrition/goals`
/// is: it belongs to this tab, and the nav bar/rail stays visible while the
/// user is in it. Carries no parameters, so it is genuinely deep-linkable —
/// unlike `/nutrition/add/food`, it names a place rather than a product.
class NutritionManageFoodsRouteData extends GoRouteData
    with $NutritionManageFoodsRouteData {
  const NutritionManageFoodsRouteData();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ManageFoodsScreen();
  }
}

/// `/nutrition/add` — the food picker, opened from a meal's "Add food"
/// action.
///
/// [day] and [meal] are query parameters rather than controller state so the
/// destination meal survives the push (and a browser reload on web). [day]
/// is an ISO `YYYY-MM-DD` string; anything unparseable falls back to today,
/// which is also what an absent value means. The diary refuses future days
/// (`domain/nutrition_validation.dart`), so a future [day] is clamped to
/// today rather than honoured.
class NutritionAddFoodRouteData extends GoRouteData
    with $NutritionAddFoodRouteData {
  const NutritionAddFoodRouteData({this.day, this.meal});

  final String? day;
  final MealType? meal;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return FoodSearchScreen(
      day: parseDiaryDay(day),
      meal: meal ?? MealType.snack,
    );
  }
}

/// `/nutrition/add/food` — the custom-food form, reached from the picker
/// when nothing matches, **and** the review-before-save screen for a food
/// that came from the food database. Pushed (not `go`n) so it can pop the
/// food it created straight back to the picker.
///
/// [$extra] carries the pre-fill. go_router's `extra` is an in-memory
/// object, not part of the URL, which makes this route **deliberately not
/// deep-linkable**: `/nutrition/add/food` typed into a browser, or restored
/// after a reload, arrives with no seed and renders the blank form — which
/// is the right fallback, since a seed is somebody else's data about one
/// specific product and has no business being reconstructible from a URL.
/// A seed that had to survive a reload would have to be URL-serialisable,
/// and putting a barcode in a query string is exactly what
/// `knowledge/engineering/security_and_privacy.md` forbids for S2 data.
class NutritionNewFoodRouteData extends GoRouteData
    with $NutritionNewFoodRouteData {
  const NutritionNewFoodRouteData({this.$extra});

  /// Pre-fill from a food-database lookup, or `null` for a blank form.
  ///
  /// The `$` name is go_router_builder's, not a style choice: it is the
  /// exact identifier the generator recognises as the non-URL `extra`
  /// payload.
  final FoodFormSeed? $extra;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return FoodFormScreen(seed: $extra);
  }
}

/// Reads a diary day out of a route parameter: today for `null`, an
/// unparseable value, or any day in the future.
///
/// Lives here rather than in a screen because it is route-parameter
/// decoding, and both nutrition sub-routes need the same reading.
LocalDate parseDiaryDay(String? value) {
  final today = LocalDate.today();
  if (value == null) return today;
  try {
    final parsed = LocalDate.parse(value);
    return parsed.isAfter(today) ? today : parsed;
  } on FormatException {
    return today;
  }
}

class WellbeingBranchData extends StatefulShellBranchData {
  const WellbeingBranchData();
}

/// `/recovery` - the check-in/flare history screen. Its own top-level
/// branch (promoted from the nested `/home/wellbeing` route) so it gets a
/// dedicated tab and back-stack, rather than living on top of Home's.
class WellbeingRouteData extends GoRouteData with $WellbeingRouteData {
  const WellbeingRouteData();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const WellbeingScreen();
  }
}

class SettingsBranchData extends StatefulShellBranchData {
  const SettingsBranchData();
}

class SettingsRouteData extends GoRouteData with $SettingsRouteData {
  const SettingsRouteData();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const SettingsScreen();
  }
}

/// Sub-route of `/settings` (`/settings/profile`) - stays inside the
/// settings branch's navigator stack, so the nav bar/rail remains visible,
/// unlike the top-level onboarding route.
class SettingsProfileRouteData extends GoRouteData
    with $SettingsProfileRouteData {
  const SettingsProfileRouteData();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ProfileScreen();
  }
}

/// Sub-route of `/settings` (`/settings/accessibility`) - allows
/// configuring color blindness, high contrast, text scaling, bold text,
/// motion, and haptics.
class SettingsAccessibilityRouteData extends GoRouteData
    with $SettingsAccessibilityRouteData {
  const SettingsAccessibilityRouteData();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const AccessibilitySettingsScreen();
  }
}

/// Sub-route of `/settings` (`/settings/wearables`) - allows managing
/// Garmin Connect auto-sync, Apple Watch / WearOS companion, and live HR sensors.
class SettingsWearablesRouteData extends GoRouteData
    with $SettingsWearablesRouteData {
  const SettingsWearablesRouteData();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const WearablesScreen();
  }
}

/// Sub-route of `/settings` (`/settings/safety`) - allows managing
/// trusted emergency contacts, check-in timer, and inactivity alerts.
class SettingsSafetyRouteData extends GoRouteData
    with $SettingsSafetyRouteData {
  const SettingsSafetyRouteData();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const SafetySettingsScreen();
  }
}
