import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/db/app_database.dart' as db;
import 'package:menfit_app/core/db/app_database_provider.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/domain/units.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/features/nutrition/domain/calorie_target.dart';
import 'package:menfit_app/features/nutrition/domain/energy_estimate.dart';
import 'package:menfit_app/features/nutrition/domain/food.dart';
import 'package:menfit_app/features/nutrition/domain/macro_targets.dart';
import 'package:menfit_app/features/nutrition/domain/meal_type.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_entry.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_facts.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_goals.dart';
import 'package:menfit_app/features/nutrition/domain/quantity_unit.dart';
import 'package:menfit_app/features/nutrition/nutrition_providers.dart';
import 'package:menfit_app/features/nutrition/presentation/nutrition_goals_screen.dart';
import 'package:menfit_app/features/nutrition/presentation/nutrition_screen.dart';
import 'package:menfit_app/features/nutrition/presentation/widgets/day_totals_card.dart';
import 'package:menfit_app/features/nutrition/presentation/widgets/meal_section.dart';
import 'package:menfit_app/features/nutrition/presentation/widgets/nutrition_overview_carousel.dart';
import 'package:menfit_app/features/profile/domain/user_profile.dart';
import 'package:menfit_app/features/profile/profile_providers.dart';

/// Tears the tree down and pumps once so live Drift stream timers fire and
/// cancel instead of being reported as pending. Top-level so it can be
/// referenced from `addTearDown` (see `test/features/routes_flow_test.dart`
/// for what happens without it).
Future<void> flushDriftTimers(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 1));
}

/// Scrolls a lazily-built ListView until [finder] matches — content
/// outside the fold has never been built, so `ensureVisible` alone throws
/// (it can only scroll to a widget that already exists).
///
/// **Searches downwards first and then back upwards.** A target *above*
/// the current offset is the case that used to be unreachable: a long form
/// scrolled to its Save button has disposed its own top, so looking for a
/// validation error on the first field dragged fifteen times further down
/// and then threw. The upward pass is allowed twice as many drags so that
/// it can undo the downward ones and still reach the top.
///
/// Only entered when the finder matches nothing, so a target that is
/// already built takes exactly the path it always did.
Future<void> scrollTo(WidgetTester tester, Finder finder) async {
  Future<void> search(Offset step, int limit) async {
    for (var i = 0; i < limit && finder.evaluate().isEmpty; i++) {
      await tester.dragFrom(const Offset(250, 1100), step);
      await tester.pump();
    }
  }

  await search(const Offset(0, -300), 15);
  await search(const Offset(0, 300), 30);
  await tester.ensureVisible(finder);
}

Finder mealSection(MealType meal) => find.byWidgetPredicate(
  (widget) => widget is MealSection && widget.meal == meal,
);

void main() {
  final today = LocalDate.today();
  final now = DateTime.utc(2026, 8, 27, 8);

  late db.AppDatabase database;

  setUp(() {
    database = db.AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
    final binding = TestWidgetsFlutterBinding.instance;
    binding.platformDispatcher.implicitView?.resetPhysicalSize();
    binding.platformDispatcher.implicitView?.resetDevicePixelRatio();
  });

  Food oats({double? servingGrams}) => Food(
    id: 'food-oats',
    name: 'Porridge oats',
    servingDescription: '1 cup (dry)',
    servingGrams: servingGrams,
    perServing: const NutritionFacts(
      caloriesKcal: 300,
      proteinGrams: 10,
      carbsGrams: 54,
      fatGrams: 5,
      ironMg: 3,
    ),
    createdAt: now,
    updatedAt: now,
  );

  Food apple() => Food(
    id: 'food-apple',
    name: 'Apple',
    servingDescription: '1 medium',
    perServing: const NutritionFacts(
      caloriesKcal: 95,
      proteinGrams: 1,
      carbsGrams: 25,
      // Iron left unstated (unknown, not zero) — this is what makes a day's
      // total partial.
    ),
    createdAt: now,
    updatedAt: now,
  );

  Widget buildScreen(Widget screen) {
    return ProviderScope(
      overrides: [appDatabaseProvider.overrideWithValue(database)],
      child: MaterialApp(theme: AppTheme.light(), home: screen),
    );
  }

  Future<void> pumpDay(WidgetTester tester) async {
    tester.view
      ..physicalSize = const Size(500, 1400)
      ..devicePixelRatio = 1;
    addTearDown(() => flushDriftTimers(tester));
    await tester.pumpWidget(buildScreen(const NutritionScreen()));
    await tester.pumpAndSettle();
  }

  Future<void> pumpGoals(WidgetTester tester) async {
    tester.view
      ..physicalSize = const Size(500, 1400)
      ..devicePixelRatio = 1;
    addTearDown(() => flushDriftTimers(tester));
    await tester.pumpWidget(buildScreen(const NutritionGoalsScreen()));
    await tester.pumpAndSettle();
  }

  Future<void> logEntry({
    required Food food,
    required MealType meal,
    required double amount,
    String id = 'entry-1',
    QuantityUnit unit = QuantityUnit.serving,
  }) async {
    final container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(database)],
    );
    addTearDown(container.dispose);
    final repository = container.read(nutritionRepositoryProvider);
    await repository.saveFood(food);
    await repository.saveEntry(
      NutritionEntry.fromFood(
        id: id,
        day: today,
        meal: meal,
        food: food,
        amount: amount,
        unit: unit,
        now: now,
      ),
    );
  }

  Future<void> saveGoals(NutritionGoals goals) async {
    final container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(database)],
    );
    addTearDown(container.dispose);
    await container.read(nutritionGoalsRepositoryProvider).saveGoals(goals);
  }

  Future<void> saveProfile() async {
    final container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(database)],
    );
    addTearDown(container.dispose);
    await container
        .read(profileRepositoryProvider)
        .saveProfile(
          UserProfile(
            id: 'profile-1',
            displayName: 'Jordan',
            unitSystem: UnitSystem.metric,
            createdAt: now,
            updatedAt: now,
            dateOfBirth: LocalDate(today.year - 30, 1, 1),
            heightCm: 170,
            weightKg: 65,
          ),
        );
  }

  testWidgets('a day with nothing logged renders its empty state, with every '
      'meal still offering a way in', (tester) async {
    await pumpDay(tester);

    expect(
      find.textContaining('Nothing in the diary for this day'),
      findsOneWidget,
    );
    expect(find.text('Today'), findsOneWidget);
    // Every meal section renders even when empty, so the day keeps a stable
    // shape (`DayNutritionTotals.byMeal` guarantees the subtotals for it).
    for (final meal in MealType.values) {
      expect(mealSection(meal), findsOneWidget);
    }
    // No shaming, and no instruction about eating.
    expect(find.textContaining('should'), findsNothing);
    expect(find.textContaining('over'), findsNothing);

    await flushDriftTimers(tester);
  });

  testWidgets('logging a food fills that meal subtotal and the day totals, '
      'iron included', (tester) async {
    await logEntry(food: oats(), meal: MealType.breakfast, amount: 2);
    await pumpDay(tester);

    // 2 x 300 kcal, into breakfast only.
    expect(
      find.descendant(
        of: find.byType(DayTotalsCard),
        matching: find.text('600 kcal'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: mealSection(MealType.breakfast),
        matching: find.text('600 kcal'),
      ),
      // The section's subtotal, and the row's own trailing figure.
      findsNWidgets(2),
    );
    expect(
      find.descendant(
        of: mealSection(MealType.lunch),
        matching: find.textContaining('kcal'),
      ),
      findsNothing,
    );

    // Protein and iron are both first-class figures in the summary.
    final totals = find.byType(DayTotalsCard);
    expect(
      find.descendant(of: totals, matching: find.text('Protein')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: totals, matching: find.text('20 g')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: totals, matching: find.text('Iron')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: totals, matching: find.text('6.0 mg')),
      findsOneWidget,
    );
    // A complete iron total carries no "partial" caveat.
    expect(find.textContaining("doesn't list iron"), findsNothing);

    await flushDriftTimers(tester);
  });

  testWidgets(
    'a diary row shows what she logged, in the unit she logged it in — and '
    'not the serving count as well',
    (tester) async {
      await logEntry(
        food: oats(servingGrams: 30),
        meal: MealType.breakfast,
        amount: 47,
        unit: QuantityUnit.gram,
      );
      await pumpDay(tester);

      final breakfast = mealSection(MealType.breakfast);
      expect(
        find.descendant(
          of: breakfast,
          matching: find.text('47 g · 1 cup (dry)'),
        ),
        findsOneWidget,
      );
      // 47 g works out to 1.57 servings; printing that too would state the
      // same fact twice, in a number she never typed.
      expect(find.textContaining('1.57'), findsNothing);
      expect(find.textContaining('servings'), findsNothing);
      // The nutrition still follows the conversion: 47/30 x 300 kcal.
      expect(
        find.descendant(of: breakfast, matching: find.text('470 kcal')),
        findsWidgets,
      );

      await flushDriftTimers(tester);
    },
  );

  testWidgets(
    'a percent-mode goal still shows macro targets in the diary, derived '
    'from the calorie target',
    (tester) async {
      await logEntry(food: oats(), meal: MealType.breakfast, amount: 2);
      await saveGoals(
        NutritionGoals(
          id: 'goals-1',
          createdAt: now,
          updatedAt: now,
          calorieTargetKcal: 2000,
          macroTargetMode: MacroTargetMode.percent,
          proteinTargetPercent: 30,
          carbTargetPercent: 40,
          fatTargetPercent: 30,
        ),
      );
      await pumpDay(tester);

      // The regression this guards: the day view used to read the *grams*
      // columns directly, which a percent-mode goal never populates, so the
      // targets silently vanished from the diary the moment the user stated
      // them as shares. Derived here from 2000 kcal at 4/4/9 kcal per gram.
      final totals = find.byType(DayTotalsCard);
      expect(
        find.descendant(of: totals, matching: find.text('of 150 g')),
        findsOneWidget,
        reason: '30% of 2000 kcal at 4 kcal/g',
      );
      expect(
        find.descendant(of: totals, matching: find.text('of 200 g')),
        findsOneWidget,
        reason: '40% of 2000 kcal at 4 kcal/g',
      );
      expect(
        find.descendant(of: totals, matching: find.text('of 67 g')),
        findsOneWidget,
        reason: '30% of 2000 kcal at 9 kcal/g',
      );

      await flushDriftTimers(tester);
    },
  );

  testWidgets(
    'hide calorie numbers builds no calorie figure anywhere on the day view, '
    'while protein and iron stay',
    (tester) async {
      await logEntry(food: oats(), meal: MealType.breakfast, amount: 2);
      await saveGoals(
        NutritionGoals(
          id: 'goals-1',
          createdAt: now,
          updatedAt: now,
          calorieTargetKcal: 2000,
          hideCalorieNumbers: true,
        ),
      );
      await pumpDay(tester);

      // The mode's whole promise: not one calorie figure is findable.
      expect(find.textContaining('kcal'), findsNothing);
      expect(find.textContaining('600'), findsNothing);
      expect(
        find.descendant(
          of: find.byType(DayTotalsCard),
          matching: find.textContaining('2000'),
        ),
        findsNothing,
      );
      expect(
        find.descendant(
          of: find.byType(NutritionOverviewCarousel),
          matching: find.textContaining('2000'),
        ),
        findsNothing,
      );
      expect(find.text('Energy'), findsNothing);
      expect(
        find.descendant(
          of: find.byType(NutritionOverviewCarousel),
          matching: find.byType(LinearProgressIndicator),
        ),
        findsNothing,
      );

      // ...and the adequacy figures are untouched.
      expect(
        find.descendant(
          of: find.byType(DayTotalsCard),
          matching: find.text('20 g'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(DayTotalsCard),
          matching: find.text('6.0 mg'),
        ),
        findsOneWidget,
      );
      // Meal subtotals fall back to macros rather than disappearing.
      expect(
        find.descendant(
          of: mealSection(MealType.breakfast),
          matching: find.text('P 20 g · C 108 g · F 10 g'),
        ),
        findsWidgets,
      );

      await flushDriftTimers(tester);
    },
  );

  testWidgets('a total with an iron-less food in it says so instead of '
      'looking complete', (tester) async {
    await logEntry(food: oats(), meal: MealType.breakfast, amount: 1);
    await logEntry(
      food: apple(),
      meal: MealType.snack,
      amount: 1,
      id: 'entry-2',
    );
    await pumpDay(tester);

    final totals = find.byType(DayTotalsCard);
    // Only the oats stated iron, so the figure is a floor, not the day's
    // iron — and it is labelled as such.
    expect(
      find.descendant(of: totals, matching: find.text('3.0 mg')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: totals, matching: find.text('So far')),
      findsOneWidget,
    );
    expect(
      find.textContaining("doesn't list iron"),
      findsOneWidget,
    );

    await flushDriftTimers(tester);
  });

  testWidgets(
    'a deficit that would go below estimated resting needs is floored, and '
    'the goals screen explains it rather than clamping quietly',
    (tester) async {
      await saveProfile();
      await saveGoals(
        NutritionGoals(
          id: 'goals-1',
          createdAt: now,
          updatedAt: now,
          activityLevel: ActivityLevel.sedentary,
          weightGoal: WeightGoal.lose,
          dailyDeficitKcal: 500,
        ),
      );
      await pumpGoals(tester);

      // BMR ~1402, TDEE ~1682: the requested 500 gap lands below the floor.
      expect(find.textContaining('estimated resting needs'), findsWidgets);
      expect(
        find.textContaining('not something this app will suggest'),
        findsOneWidget,
      );
      // The explanation is the domain's own words, unedited.
      expect(find.text(floorExplanation), findsOneWidget);
      // Nothing frames it as the user's error.
      expect(find.textContaining('too low'), findsNothing);
      expect(find.textContaining('cannot'), findsNothing);

      await flushDriftTimers(tester);
    },
  );

  testWidgets(
    'with no profile figures the goals screen names exactly what is missing, '
    'and says where each one lives',
    (tester) async {
      await pumpGoals(tester);

      expect(
        find.text(
          'We still need your date of birth, your height and your weight.',
        ),
        findsOneWidget,
      );
      expect(find.text('Open your profile'), findsOneWidget);
      // The activity level is tracked separately because it lives on this
      // screen, not in the profile.
      expect(
        find.textContaining('typical activity level'),
        findsOneWidget,
      );
      // A missing estimate is never presented as a requirement.
      expect(
        find.textContaining('The diary works without any of this'),
        findsOneWidget,
      );

      await flushDriftTimers(tester);
    },
  );

  testWidgets(
    'the goals screen defaults to staying where you are, with no daily gap '
    'offered until the goal moves',
    (tester) async {
      await pumpGoals(tester);

      expect(find.text('Stay where I am'), findsOneWidget);
      expect(find.byKey(const Key('dailyGapField')), findsNothing);
      await scrollTo(tester, find.byKey(const Key('hideCaloriesSwitch')));
      expect(
        tester
            .widget<SwitchListTile>(
              find.byKey(const Key('hideCaloriesSwitch')),
            )
            .value,
        isFalse,
      );

      await flushDriftTimers(tester);
    },
  );
}
