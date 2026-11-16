// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
  $onboardingRouteData,
  $activityRecordRouteData,
  $strengthTrackerRouteData,
  $hiitTrackerRouteData,
  $mindfulTrackerRouteData,
  $yogaSequenceRunnerRouteData,
  $swimTrackerRouteData,
  $activityRoutesRouteData,
  $recapStoryRouteData,
  $weightRouteData,
  $achievementsRouteData,
  $stepsRouteData,
  $challengesRouteData,
  $appShellRouteData,
];

RouteBase get $onboardingRouteData => GoRouteData.$route(
  path: '/onboarding',
  hasOverriddenOnExit: false,
  factory: $OnboardingRouteData._fromState,
);

mixin $OnboardingRouteData on GoRouteData {
  static OnboardingRouteData _fromState(GoRouterState state) =>
      const OnboardingRouteData();

  @override
  String get location => GoRouteData.$location('/onboarding');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $activityRecordRouteData => GoRouteData.$route(
  path: '/activity/record',
  hasOverriddenOnExit: false,
  factory: $ActivityRecordRouteData._fromState,
);

mixin $ActivityRecordRouteData on GoRouteData {
  static ActivityRecordRouteData _fromState(GoRouterState state) =>
      ActivityRecordRouteData(routeId: state.uri.queryParameters['route-id']);

  ActivityRecordRouteData get _self => this as ActivityRecordRouteData;

  @override
  String get location => GoRouteData.$location(
    '/activity/record',
    queryParams: {if (_self.routeId != null) 'route-id': _self.routeId},
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $strengthTrackerRouteData => GoRouteData.$route(
  path: '/activity/track/strength',
  hasOverriddenOnExit: false,
  factory: $StrengthTrackerRouteData._fromState,
);

mixin $StrengthTrackerRouteData on GoRouteData {
  static StrengthTrackerRouteData _fromState(GoRouterState state) =>
      const StrengthTrackerRouteData();

  @override
  String get location => GoRouteData.$location('/activity/track/strength');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $hiitTrackerRouteData => GoRouteData.$route(
  path: '/activity/track/hiit',
  hasOverriddenOnExit: false,
  factory: $HiitTrackerRouteData._fromState,
);

mixin $HiitTrackerRouteData on GoRouteData {
  static HiitTrackerRouteData _fromState(
    GoRouterState state,
  ) => HiitTrackerRouteData(
    work: _$convertMapValue('work', state.uri.queryParameters, int.tryParse),
    rest: _$convertMapValue('rest', state.uri.queryParameters, int.tryParse),
    rounds: _$convertMapValue(
      'rounds',
      state.uri.queryParameters,
      int.tryParse,
    ),
  );

  HiitTrackerRouteData get _self => this as HiitTrackerRouteData;

  @override
  String get location => GoRouteData.$location(
    '/activity/track/hiit',
    queryParams: {
      if (_self.work != null) 'work': _self.work!.toString(),
      if (_self.rest != null) 'rest': _self.rest!.toString(),
      if (_self.rounds != null) 'rounds': _self.rounds!.toString(),
    },
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

T? _$convertMapValue<T>(
  String key,
  Map<String, String> map,
  T? Function(String) converter,
) {
  final value = map[key];
  return value == null ? null : converter(value);
}

RouteBase get $mindfulTrackerRouteData => GoRouteData.$route(
  path: '/activity/track/mindful',
  hasOverriddenOnExit: false,
  factory: $MindfulTrackerRouteData._fromState,
);

mixin $MindfulTrackerRouteData on GoRouteData {
  static MindfulTrackerRouteData _fromState(GoRouterState state) =>
      MindfulTrackerRouteData(type: state.uri.queryParameters['type']);

  MindfulTrackerRouteData get _self => this as MindfulTrackerRouteData;

  @override
  String get location => GoRouteData.$location(
    '/activity/track/mindful',
    queryParams: {if (_self.type != null) 'type': _self.type},
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $yogaSequenceRunnerRouteData => GoRouteData.$route(
  path: '/activity/track/yoga-sequence/:sequenceId',
  hasOverriddenOnExit: false,
  factory: $YogaSequenceRunnerRouteData._fromState,
);

mixin $YogaSequenceRunnerRouteData on GoRouteData {
  static YogaSequenceRunnerRouteData _fromState(GoRouterState state) =>
      YogaSequenceRunnerRouteData(
        sequenceId: state.pathParameters['sequenceId']!,
      );

  YogaSequenceRunnerRouteData get _self => this as YogaSequenceRunnerRouteData;

  @override
  String get location => GoRouteData.$location(
    '/activity/track/yoga-sequence/${Uri.encodeComponent(_self.sequenceId)}',
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $swimTrackerRouteData => GoRouteData.$route(
  path: '/activity/track/swim',
  hasOverriddenOnExit: false,
  factory: $SwimTrackerRouteData._fromState,
);

mixin $SwimTrackerRouteData on GoRouteData {
  static SwimTrackerRouteData _fromState(GoRouterState state) =>
      const SwimTrackerRouteData();

  @override
  String get location => GoRouteData.$location('/activity/track/swim');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $activityRoutesRouteData => GoRouteData.$route(
  path: '/activity/routes',
  hasOverriddenOnExit: false,
  factory: $ActivityRoutesRouteData._fromState,
  routes: [
    GoRouteData.$route(
      path: 'suggest',
      hasOverriddenOnExit: false,
      factory: $RouteSuggestRouteData._fromState,
    ),
    GoRouteData.$route(
      path: ':routeId',
      hasOverriddenOnExit: false,
      factory: $RouteDetailRouteData._fromState,
    ),
  ],
);

mixin $ActivityRoutesRouteData on GoRouteData {
  static ActivityRoutesRouteData _fromState(GoRouterState state) =>
      const ActivityRoutesRouteData();

  @override
  String get location => GoRouteData.$location('/activity/routes');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $RouteSuggestRouteData on GoRouteData {
  static RouteSuggestRouteData _fromState(
    GoRouterState state,
  ) => RouteSuggestRouteData(
    type: state.uri.queryParameters['type'],
    distance: state.uri.queryParameters['distance'],
    lat: _$convertMapValue('lat', state.uri.queryParameters, double.tryParse),
    lng: _$convertMapValue('lng', state.uri.queryParameters, double.tryParse),
    address: state.uri.queryParameters['address'],
  );

  RouteSuggestRouteData get _self => this as RouteSuggestRouteData;

  @override
  String get location => GoRouteData.$location(
    '/activity/routes/suggest',
    queryParams: {
      if (_self.type != null) 'type': _self.type,
      if (_self.distance != null) 'distance': _self.distance,
      if (_self.lat != null) 'lat': _self.lat!.toString(),
      if (_self.lng != null) 'lng': _self.lng!.toString(),
      if (_self.address != null) 'address': _self.address,
    },
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $RouteDetailRouteData on GoRouteData {
  static RouteDetailRouteData _fromState(GoRouterState state) =>
      RouteDetailRouteData(state.pathParameters['routeId']!);

  RouteDetailRouteData get _self => this as RouteDetailRouteData;

  @override
  String get location => GoRouteData.$location(
    '/activity/routes/${Uri.encodeComponent(_self.routeId)}',
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $recapStoryRouteData => GoRouteData.$route(
  path: '/recap',
  hasOverriddenOnExit: false,
  factory: $RecapStoryRouteData._fromState,
);

mixin $RecapStoryRouteData on GoRouteData {
  static RecapStoryRouteData _fromState(GoRouterState state) =>
      RecapStoryRouteData($extra: state.extra as MonthRecap?);

  RecapStoryRouteData get _self => this as RecapStoryRouteData;

  @override
  String get location => GoRouteData.$location('/recap');

  @override
  void go(BuildContext context) => context.go(location, extra: _self.$extra);

  @override
  Future<T?> push<T>(BuildContext context) =>
      context.push<T>(location, extra: _self.$extra);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location, extra: _self.$extra);

  @override
  void replace(BuildContext context) =>
      context.replace(location, extra: _self.$extra);
}

RouteBase get $weightRouteData => GoRouteData.$route(
  path: '/weight',
  hasOverriddenOnExit: false,
  factory: $WeightRouteData._fromState,
);

mixin $WeightRouteData on GoRouteData {
  static WeightRouteData _fromState(GoRouterState state) =>
      const WeightRouteData();

  @override
  String get location => GoRouteData.$location('/weight');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $achievementsRouteData => GoRouteData.$route(
  path: '/achievements',
  hasOverriddenOnExit: false,
  factory: $AchievementsRouteData._fromState,
);

mixin $AchievementsRouteData on GoRouteData {
  static AchievementsRouteData _fromState(GoRouterState state) =>
      const AchievementsRouteData();

  @override
  String get location => GoRouteData.$location('/achievements');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $stepsRouteData => GoRouteData.$route(
  path: '/steps',
  hasOverriddenOnExit: false,
  factory: $StepsRouteData._fromState,
);

mixin $StepsRouteData on GoRouteData {
  static StepsRouteData _fromState(GoRouterState state) =>
      const StepsRouteData();

  @override
  String get location => GoRouteData.$location('/steps');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $challengesRouteData => GoRouteData.$route(
  path: '/challenges',
  hasOverriddenOnExit: false,
  factory: $ChallengesRouteData._fromState,
  routes: [
    GoRouteData.$route(
      path: 'create',
      hasOverriddenOnExit: false,
      factory: $CreateChallengeRouteData._fromState,
    ),
    GoRouteData.$route(
      path: 'join',
      hasOverriddenOnExit: false,
      factory: $JoinChallengeRouteData._fromState,
    ),
    GoRouteData.$route(
      path: ':challengeId',
      hasOverriddenOnExit: false,
      factory: $ChallengeDetailRouteData._fromState,
    ),
  ],
);

mixin $ChallengesRouteData on GoRouteData {
  static ChallengesRouteData _fromState(GoRouterState state) =>
      const ChallengesRouteData();

  @override
  String get location => GoRouteData.$location('/challenges');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $CreateChallengeRouteData on GoRouteData {
  static CreateChallengeRouteData _fromState(GoRouterState state) =>
      const CreateChallengeRouteData();

  @override
  String get location => GoRouteData.$location('/challenges/create');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $JoinChallengeRouteData on GoRouteData {
  static JoinChallengeRouteData _fromState(GoRouterState state) =>
      const JoinChallengeRouteData();

  @override
  String get location => GoRouteData.$location('/challenges/join');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $ChallengeDetailRouteData on GoRouteData {
  static ChallengeDetailRouteData _fromState(GoRouterState state) =>
      ChallengeDetailRouteData(state.pathParameters['challengeId']!);

  ChallengeDetailRouteData get _self => this as ChallengeDetailRouteData;

  @override
  String get location => GoRouteData.$location(
    '/challenges/${Uri.encodeComponent(_self.challengeId)}',
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $appShellRouteData => StatefulShellRouteData.$route(
  factory: $AppShellRouteDataExtension._fromState,
  branches: [
    StatefulShellBranchData.$branch(
      routes: [
        GoRouteData.$route(
          path: '/home',
          hasOverriddenOnExit: false,
          factory: $HomeRouteData._fromState,
          routes: [
            GoRouteData.$route(
              path: 'progress',
              hasOverriddenOnExit: false,
              factory: $ProgressRouteData._fromState,
            ),
            GoRouteData.$route(
              path: 'settings',
              hasOverriddenOnExit: false,
              factory: $SettingsRouteData._fromState,
              routes: [
                GoRouteData.$route(
                  path: 'profile',
                  hasOverriddenOnExit: false,
                  factory: $SettingsProfileRouteData._fromState,
                ),
                GoRouteData.$route(
                  path: 'accessibility',
                  hasOverriddenOnExit: false,
                  factory: $SettingsAccessibilityRouteData._fromState,
                ),
                GoRouteData.$route(
                  path: 'wearables',
                  hasOverriddenOnExit: false,
                  factory: $SettingsWearablesRouteData._fromState,
                ),
                GoRouteData.$route(
                  path: 'safety',
                  hasOverriddenOnExit: false,
                  factory: $SettingsSafetyRouteData._fromState,
                ),
              ],
            ),
          ],
        ),
      ],
    ),
    StatefulShellBranchData.$branch(
      routes: [
        GoRouteData.$route(
          path: '/activity',
          hasOverriddenOnExit: false,
          factory: $ActivityRouteData._fromState,
          routes: [
            GoRouteData.$route(
              path: 'log',
              hasOverriddenOnExit: false,
              factory: $ActivityLogRouteData._fromState,
            ),
            GoRouteData.$route(
              path: 'hub/:type',
              hasOverriddenOnExit: false,
              factory: $ExerciseHubRouteData._fromState,
            ),
            GoRouteData.$route(
              path: ':id',
              hasOverriddenOnExit: false,
              factory: $ActivityDetailRouteData._fromState,
              routes: [
                GoRouteData.$route(
                  path: 'edit',
                  hasOverriddenOnExit: false,
                  factory: $ActivityDetailEditRouteData._fromState,
                ),
              ],
            ),
          ],
        ),
      ],
    ),
    StatefulShellBranchData.$branch(
      routes: [
        GoRouteData.$route(
          path: '/nutrition',
          hasOverriddenOnExit: false,
          factory: $NutritionRouteData._fromState,
          routes: [
            GoRouteData.$route(
              path: 'goals',
              hasOverriddenOnExit: false,
              factory: $NutritionGoalsRouteData._fromState,
            ),
            GoRouteData.$route(
              path: 'foods',
              hasOverriddenOnExit: false,
              factory: $NutritionManageFoodsRouteData._fromState,
            ),
            GoRouteData.$route(
              path: 'add',
              hasOverriddenOnExit: false,
              factory: $NutritionAddFoodRouteData._fromState,
              routes: [
                GoRouteData.$route(
                  path: 'food',
                  hasOverriddenOnExit: false,
                  factory: $NutritionNewFoodRouteData._fromState,
                ),
              ],
            ),
          ],
        ),
      ],
    ),
    StatefulShellBranchData.$branch(
      routes: [
        GoRouteData.$route(
          path: '/keto',
          hasOverriddenOnExit: false,
          factory: $KetoRouteData._fromState,
        ),
      ],
    ),
    StatefulShellBranchData.$branch(
      routes: [
        GoRouteData.$route(
          path: '/health',
          hasOverriddenOnExit: false,
          factory: $HealthRouteData._fromState,
        ),
      ],
    ),
    StatefulShellBranchData.$branch(
      routes: [
        GoRouteData.$route(
          path: '/recovery',
          hasOverriddenOnExit: false,
          factory: $WellbeingRouteData._fromState,
        ),
      ],
    ),
  ],
);

extension $AppShellRouteDataExtension on AppShellRouteData {
  static AppShellRouteData _fromState(GoRouterState state) =>
      const AppShellRouteData();
}

mixin $HomeRouteData on GoRouteData {
  static HomeRouteData _fromState(GoRouterState state) => const HomeRouteData();

  @override
  String get location => GoRouteData.$location('/home');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $ProgressRouteData on GoRouteData {
  static ProgressRouteData _fromState(GoRouterState state) =>
      const ProgressRouteData();

  @override
  String get location => GoRouteData.$location('/home/progress');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $SettingsRouteData on GoRouteData {
  static SettingsRouteData _fromState(GoRouterState state) =>
      const SettingsRouteData();

  @override
  String get location => GoRouteData.$location('/home/settings');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $SettingsProfileRouteData on GoRouteData {
  static SettingsProfileRouteData _fromState(GoRouterState state) =>
      const SettingsProfileRouteData();

  @override
  String get location => GoRouteData.$location('/home/settings/profile');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $SettingsAccessibilityRouteData on GoRouteData {
  static SettingsAccessibilityRouteData _fromState(GoRouterState state) =>
      const SettingsAccessibilityRouteData();

  @override
  String get location => GoRouteData.$location('/home/settings/accessibility');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $SettingsWearablesRouteData on GoRouteData {
  static SettingsWearablesRouteData _fromState(GoRouterState state) =>
      const SettingsWearablesRouteData();

  @override
  String get location => GoRouteData.$location('/home/settings/wearables');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $SettingsSafetyRouteData on GoRouteData {
  static SettingsSafetyRouteData _fromState(GoRouterState state) =>
      const SettingsSafetyRouteData();

  @override
  String get location => GoRouteData.$location('/home/settings/safety');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $ActivityRouteData on GoRouteData {
  static ActivityRouteData _fromState(GoRouterState state) =>
      const ActivityRouteData();

  @override
  String get location => GoRouteData.$location('/activity');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $ActivityLogRouteData on GoRouteData {
  static ActivityLogRouteData _fromState(GoRouterState state) =>
      ActivityLogRouteData(type: state.uri.queryParameters['type']);

  ActivityLogRouteData get _self => this as ActivityLogRouteData;

  @override
  String get location => GoRouteData.$location(
    '/activity/log',
    queryParams: {if (_self.type != null) 'type': _self.type},
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $ExerciseHubRouteData on GoRouteData {
  static ExerciseHubRouteData _fromState(GoRouterState state) =>
      ExerciseHubRouteData(type: state.pathParameters['type']!);

  ExerciseHubRouteData get _self => this as ExerciseHubRouteData;

  @override
  String get location =>
      GoRouteData.$location('/activity/hub/${Uri.encodeComponent(_self.type)}');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $ActivityDetailRouteData on GoRouteData {
  static ActivityDetailRouteData _fromState(GoRouterState state) =>
      ActivityDetailRouteData(state.pathParameters['id']!);

  ActivityDetailRouteData get _self => this as ActivityDetailRouteData;

  @override
  String get location =>
      GoRouteData.$location('/activity/${Uri.encodeComponent(_self.id)}');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $ActivityDetailEditRouteData on GoRouteData {
  static ActivityDetailEditRouteData _fromState(GoRouterState state) =>
      ActivityDetailEditRouteData(state.pathParameters['id']!);

  ActivityDetailEditRouteData get _self => this as ActivityDetailEditRouteData;

  @override
  String get location =>
      GoRouteData.$location('/activity/${Uri.encodeComponent(_self.id)}/edit');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $NutritionRouteData on GoRouteData {
  static NutritionRouteData _fromState(GoRouterState state) =>
      const NutritionRouteData();

  @override
  String get location => GoRouteData.$location('/nutrition');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $NutritionGoalsRouteData on GoRouteData {
  static NutritionGoalsRouteData _fromState(GoRouterState state) =>
      const NutritionGoalsRouteData();

  @override
  String get location => GoRouteData.$location('/nutrition/goals');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $NutritionManageFoodsRouteData on GoRouteData {
  static NutritionManageFoodsRouteData _fromState(GoRouterState state) =>
      const NutritionManageFoodsRouteData();

  @override
  String get location => GoRouteData.$location('/nutrition/foods');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $NutritionAddFoodRouteData on GoRouteData {
  static NutritionAddFoodRouteData _fromState(GoRouterState state) =>
      NutritionAddFoodRouteData(
        day: state.uri.queryParameters['day'],
        meal: _$convertMapValue(
          'meal',
          state.uri.queryParameters,
          _$MealTypeEnumMap._$fromName,
        ),
      );

  NutritionAddFoodRouteData get _self => this as NutritionAddFoodRouteData;

  @override
  String get location => GoRouteData.$location(
    '/nutrition/add',
    queryParams: {
      if (_self.day != null) 'day': _self.day,
      if (_self.meal != null) 'meal': _$MealTypeEnumMap[_self.meal!],
    },
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

const _$MealTypeEnumMap = {
  MealType.breakfast: 'breakfast',
  MealType.lunch: 'lunch',
  MealType.dinner: 'dinner',
  MealType.snack: 'snack',
};

mixin $NutritionNewFoodRouteData on GoRouteData {
  static NutritionNewFoodRouteData _fromState(GoRouterState state) =>
      NutritionNewFoodRouteData($extra: state.extra as FoodFormSeed?);

  NutritionNewFoodRouteData get _self => this as NutritionNewFoodRouteData;

  @override
  String get location => GoRouteData.$location('/nutrition/add/food');

  @override
  void go(BuildContext context) => context.go(location, extra: _self.$extra);

  @override
  Future<T?> push<T>(BuildContext context) =>
      context.push<T>(location, extra: _self.$extra);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location, extra: _self.$extra);

  @override
  void replace(BuildContext context) =>
      context.replace(location, extra: _self.$extra);
}

mixin $KetoRouteData on GoRouteData {
  static KetoRouteData _fromState(GoRouterState state) => const KetoRouteData();

  @override
  String get location => GoRouteData.$location('/keto');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $HealthRouteData on GoRouteData {
  static HealthRouteData _fromState(GoRouterState state) =>
      const HealthRouteData();

  @override
  String get location => GoRouteData.$location('/health');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $WellbeingRouteData on GoRouteData {
  static WellbeingRouteData _fromState(GoRouterState state) =>
      const WellbeingRouteData();

  @override
  String get location => GoRouteData.$location('/recovery');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

extension<T extends Enum> on Map<T, String> {
  T? _$fromName(String? value) =>
      entries.where((element) => element.value == value).firstOrNull?.key;
}
