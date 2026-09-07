import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:menfit_app/core/config/env.dart';
import 'package:menfit_app/core/config/shared_preferences_provider.dart';
import 'package:menfit_app/core/db/app_database_provider.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/platform/device_locale.dart';
import 'package:menfit_app/core/utils/combine_latest.dart';
import 'package:menfit_app/features/cycle/cycle_providers.dart';
import 'package:menfit_app/features/cycle/domain/cycle_prediction_engine.dart';
import 'package:menfit_app/features/nutrition/data/drift_nutrition_goals_repository.dart';
import 'package:menfit_app/features/nutrition/data/drift_nutrition_repository.dart';
import 'package:menfit_app/features/nutrition/data/drift_water_repository.dart';
import 'package:menfit_app/features/nutrition/data/fat_secret_service.dart';
import 'package:menfit_app/features/nutrition/data/fat_secret_token_manager.dart';
import 'package:menfit_app/features/nutrition/data/food_search_region_store.dart';
import 'package:menfit_app/features/nutrition/data/online_lookup_notice_store.dart';
import 'package:menfit_app/features/nutrition/data/open_food_facts_service.dart';
import 'package:menfit_app/features/nutrition/domain/calorie_target.dart';
import 'package:menfit_app/features/nutrition/domain/energy_estimate.dart';
import 'package:menfit_app/features/nutrition/domain/fallback_food_data_provider.dart';
import 'package:menfit_app/features/nutrition/domain/food.dart';
import 'package:menfit_app/features/nutrition/domain/food_data_provider.dart';
import 'package:menfit_app/features/nutrition/domain/food_search_region.dart';
import 'package:menfit_app/features/nutrition/domain/fueling_consistency_evaluator.dart';
import 'package:menfit_app/features/nutrition/domain/micronutrient_adequacy.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_entry.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_goals.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_repository.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_totals.dart';
import 'package:menfit_app/features/nutrition/domain/water_repository.dart';
import 'package:menfit_app/features/profile/profile_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'nutrition_providers.g.dart';

/// Composition surface for the `nutrition` feature (ADR 007).
///
/// The only legal way for another feature (or the composition root's
/// "Delete my data" flow) to reach this feature's persistence: other
/// features may import this file, never `data/` or `presentation/`
/// directly.
@Riverpod(keepAlive: true)
NutritionRepository nutritionRepository(Ref ref) {
  final database = ref.watch(appDatabaseProvider);
  return DriftNutritionRepository(database);
}

/// Daily hydration and water intake repository.
@Riverpod(keepAlive: true)
WaterRepository waterRepository(Ref ref) {
  final database = ref.watch(appDatabaseProvider);
  return DriftWaterRepository(database);
}

/// Watches water intake in milliliters logged on [day].
@riverpod
Stream<int> dayWaterIntake(Ref ref, LocalDate day) {
  return ref.watch(waterRepositoryProvider).watchWaterForDay(day);
}

/// The single-row nutrition targets/preferences repository — see
/// [nutritionRepositoryProvider]'s dartdoc for the composition-surface
/// rule this shares.
@Riverpod(keepAlive: true)
NutritionGoalsRepository nutritionGoalsRepository(Ref ref) {
  final database = ref.watch(appDatabaseProvider);
  return DriftNutritionGoalsRepository(database);
}

/// The external food database used for barcode lookups and product search.
///
/// **FatSecret is the primary catalogue, Open Food Facts the backup**,
/// whenever FatSecret is configured (ADR 016) — a
/// `FallbackFoodDataProvider` wraps the two, and everything above `data/`
/// sees one [FoodDataProvider] regardless of which one actually answered a
/// given lookup. With no FatSecret credentials configured, Open Food Facts
/// is the only provider, exactly as before this wave.
///
/// Typed as the domain interface so nothing above `data/` knows which
/// provider is in use (ADR 007); swapping providers is a change to this one
/// function. `keepAlive` for the same reason as the other services here —
/// each concrete service holds a `Dio` client whose connection pool should
/// outlive a single screen.
///
/// `kIsWeb` is supplied here rather than read inside the service because
/// `domain/` may not import Flutter: the service takes the answer as a
/// flag, and this composition surface is where the platform question is
/// legal to ask.
///
/// What `useLegacySearch` selects is the **search endpoint**, not whether
/// search works: browsers cannot reach Search-a-licious (no CORS header),
/// so on web the Open Food Facts service uses its legacy CGI search on the
/// same host the product API already uses. `OpenFoodFactsService.search`
/// documents the trade and the conditions under which that fallback should
/// be deleted.
@Riverpod(keepAlive: true)
FoodDataProvider foodDataProvider(Ref ref) {
  const env = AppEnv.instance;
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 20),
    ),
  );

  final off = OpenFoodFactsService(
    dio: dio,
    useLegacySearch: kIsWeb,
    baseUrl: env.offBaseUrl,
    searchBaseUrl: env.offSearchBaseUrl,
    contact: env.offContact,
    appName: env.appName,
  );

  // If a proxy URL is configured, use the proxy without requiring local
  // client credentials.
  if (env.fatSecretProxyUrl.isNotEmpty) {
    return FallbackFoodDataProvider(
      primary: FatSecretService(
        dio: dio,
        apiBaseUrl: env.fatSecretProxyUrl,
        proxyApiKey: env.fatSecretProxyKey.isNotEmpty
            ? env.fatSecretProxyKey
            : null,
      ),
      fallback: off,
    );
  }

  if (env.fatSecretClientId.isNotEmpty &&
      env.fatSecretClientSecret.isNotEmpty) {
    return FallbackFoodDataProvider(
      primary: FatSecretService(
        dio: dio,
        tokenManager: FatSecretTokenManager(
          dio: dio,
          clientId: env.fatSecretClientId,
          clientSecret: env.fatSecretClientSecret,
          tokenUrl: env.fatSecretTokenUrl,
        ),
        apiBaseUrl: env.fatSecretApiBaseUrl,
      ),
      fallback: off,
    );
  }

  return off;
}

/// Remembers whether the first-run online-lookup notice has been shown.
///
/// Device-local and tiny, so `shared_preferences` rather than the database
/// — see [OnlineLookupNoticeStore]. Exposed here because the notice gates
/// every outbound lookup this feature makes, from both the picker's search
/// and the barcode flow.
///
/// **Known departure from ADR 007**, recorded rather than quietly left: the
/// other providers on this surface are typed as `domain/` interfaces so
/// nothing above `data/` knows what backs them, and this one is typed as
/// the concrete `data/` class. It is a single device preference with no
/// second implementation in prospect, and a port for one boolean would be
/// ceremony; the cost is that a substitute has to stand in for a concrete
/// class rather than implement a port. Worth revisiting if anything else
/// ever needs to be remembered here.
@Riverpod(keepAlive: true)
OnlineLookupNoticeStore onlineLookupNoticeStore(Ref ref) {
  return OnlineLookupNoticeStore(ref.watch(sharedPreferencesProvider));
}

/// Remembers the food-database region chosen in Settings.
///
/// Typed as the concrete `data/` class for the same reason, and with the
/// same acknowledged cost, as [onlineLookupNoticeStoreProvider] above: it is
/// one device preference with no second implementation in prospect.
@Riverpod(keepAlive: true)
FoodSearchRegionStore foodSearchRegionStore(Ref ref) {
  return FoodSearchRegionStore(ref.watch(sharedPreferencesProvider));
}

/// The region food-database **searches** are confined to.
///
/// Defaults to the device's country when this app covers it
/// (`FoodSearchRegion.forCountryCode`) and to `anywhere` otherwise, until the
/// user picks one in Settings — at which point her choice wins permanently,
/// including a deliberate choice of `anywhere`.
///
/// Defaulting from the device rather than shipping `anywhere` is the actual
/// fix for the reported bug: nobody would have found a setting they did not
/// know they needed, and the failure ("why is this Bulgarian?") does not
/// point at a region control.
///
/// This lives on the composition surface, not in `presentation/`, because
/// the Settings screen — another feature — has to reach it, and ADR 007 says
/// this file is the only door in.
@Riverpod(keepAlive: true)
class FoodSearchRegionController extends _$FoodSearchRegionController {
  @override
  FoodSearchRegion build() {
    final stored = ref.watch(foodSearchRegionStoreProvider).readRegion();
    if (stored != null) return stored;
    final locale = ref.watch(deviceLocaleProvider);
    return FoodSearchRegion.forCountryCode(locale.countryCode) ??
        FoodSearchRegion.anywhere;
  }

  /// Records [region] as an explicit choice.
  ///
  /// The new value is shown before the write completes, and rolled back if
  /// the write fails: a preference row that snaps back is honest about not
  /// having been saved, whereas one that sticks would lie until restart.
  Future<void> setRegion(FoodSearchRegion region) async {
    final previous = state;
    state = region;
    try {
      await ref.read(foodSearchRegionStoreProvider).setRegion(region);
    } on Object {
      state = previous;
      rethrow;
    }
  }
}

/// The region **and** language every food-database request carries.
///
/// The language is not user-selectable: this app ships one locale, so the
/// only honest answer to "what language do you read" is the device's. It is
/// separate from the region because the two genuinely differ — a German
/// speaker shopping in Australia wants Australian products with German names
/// where records have them.
@Riverpod(keepAlive: true)
FoodSearchScope foodSearchScope(Ref ref) {
  return FoodSearchScope(
    region: ref.watch(foodSearchRegionControllerProvider),
    languageCode: normaliseFoodSearchLanguage(
      ref.watch(deviceLocaleProvider).languageCode,
    ),
  );
}

/// Every food in the user's catalogue, name ascending.
@riverpod
Stream<List<Food>> foods(Ref ref) {
  return ref.watch(nutritionRepositoryProvider).watchFoods();
}

/// How many recently-logged foods [recentFoodsProvider] offers.
///
/// A shortcut, not a second catalogue: the point is that yesterday's
/// breakfast is one tap away, and a list long enough to scroll would just be
/// the alphabetical picker again in a different order.
const int recentFoodsLimit = 10;

/// The foods most recently logged from, most recent first.
///
/// A **stream**, deliberately. The picker can log a food and come straight
/// back to itself, and it can create one from the food-database review
/// screen; a one-shot future would show a stale list after either and stay
/// stale until the screen was rebuilt. `watchRecentFoods` is watched by
/// Drift over both `foods` and `nutrition_entries`, so nothing here has to
/// remember to invalidate it (`data/drift_nutrition_repository.dart`).
@riverpod
Stream<List<Food>> recentFoods(Ref ref) {
  return ref
      .watch(nutritionRepositoryProvider)
      .watchRecentFoods(limit: recentFoodsLimit);
}

/// The user's nutrition goals, or `null` when none have ever been saved.
///
/// `null` is an expected state, not an error — see
/// `domain/nutrition_repository.dart#watchGoals`.
@riverpod
Stream<NutritionGoals?> nutritionGoals(Ref ref) {
  return ref.watch(nutritionGoalsRepositoryProvider).watchGoals();
}

/// Every diary entry logged on [day], grouped by meal.
@riverpod
Stream<List<NutritionEntry>> nutritionEntries(Ref ref, LocalDate day) {
  return ref.watch(nutritionRepositoryProvider).watchEntriesFor(day);
}

/// [day]'s totals — overall and per meal — recomputed on every change to
/// that day's entries.
///
/// **Derived, never stored** (`knowledge/architecture/data_architecture.md`
/// 's "Derived vs stored" section): totals are a pure function of the
/// entries, computed here on demand, with no cache table. Note this is a
/// different thing from each entry's per-serving *snapshot*, which is
/// stored precisely because it must not be recomputed — see
/// `core/db/tables/nutrition_entries.dart`.
@riverpod
Stream<DayNutritionTotals> dayNutritionTotals(Ref ref, LocalDate day) {
  return ref
      .watch(nutritionRepositoryProvider)
      .watchEntriesFor(day)
      .map(computeDayTotals);
}

/// Range totals and daily averages over [start] to [end] inclusive.
@riverpod
Stream<RangeNutritionTotals> rangeNutritionTotals(
  Ref ref, {
  required LocalDate start,
  required LocalDate end,
}) {
  final daysInRange = start.difference(end) + 1;
  return ref
      .watch(nutritionRepositoryProvider)
      .watchEntriesForRange(start, end)
      .map(
        (entries) => computeRangeNutritionTotals(
          entries: entries,
          daysInRange: daysInRange,
        ),
      );
}

/// The user's estimated BMR and TDEE, or a [NoEnergyEstimate] naming what's
/// missing.
///
/// Combines the profile (height, weight, date of birth — S1-3) with the
/// nutrition goals' chosen activity level. Watches `profile`'s composition
/// surface, never its `data/` (ADR 007).
///
/// Every emission is an estimate, never a measurement, and never medical
/// advice — `knowledge/research/nutrition_energy_estimates.md` documents
/// the equation, the female-coefficient assumption, and the error margins
/// the UI must not paper over.
@riverpod
Stream<EnergyEstimateResult> energyEstimate(Ref ref) {
  final profileRepository = ref.watch(profileRepositoryProvider);
  final goalsRepository = ref.watch(nutritionGoalsRepositoryProvider);

  return combineLatest2(
    profileRepository.watchProfile(),
    goalsRepository.watchGoals(),
    (profile, goals) => estimateEnergyNeedsForProfile(
      profile: profile,
      activityLevel: goals?.activityLevel,
      // Read fresh on every recompute rather than captured once, so a
      // session left open across midnight can't keep using yesterday's date
      // to derive age. (Unlike the streak providers, nothing here needs a
      // midnight *tick*: an age that advances a day late is invisible in a
      // kcal estimate, whereas a stale streak day is not.)
      today: LocalDate.today(),
    ),
  );
}

/// The daily calorie target the user's goals resolve to — including the
/// **floored** outcome when the requested deficit would go below their
/// estimated resting needs.
///
/// The floor rule and its explanation live entirely in
/// `domain/calorie_target.dart`; this provider only feeds it. UI code
/// switches on the sealed [CalorieTargetOutcome] and must handle
/// [FlooredCalorieTarget] by *explaining* it — that is the point of the
/// typed result (product decision 2).
///
/// Built from the same two source streams as [energyEstimateProvider]
/// rather than layered on top of it — a second independent derived view
/// over shared sources, the same arrangement as `streaks`'
/// `streakResultProvider` and `todayProtectionSourcesProvider`. Composing
/// providers here would mean turning a stream back into a single future and
/// losing every later emission.
@riverpod
Stream<CalorieTargetOutcome> calorieTarget(Ref ref) {
  final profileRepository = ref.watch(profileRepositoryProvider);
  final goalsRepository = ref.watch(nutritionGoalsRepositoryProvider);

  return combineLatest2(
    profileRepository.watchProfile(),
    goalsRepository.watchGoals(),
    (profile, goals) => resolveCalorieTarget(
      estimate: estimateEnergyNeedsForProfile(
        profile: profile,
        activityLevel: goals?.activityLevel,
        today: LocalDate.today(),
      ),
      weightGoal: goals?.weightGoal ?? WeightGoal.maintain,
      dailyDeficitKcal: goals?.dailyDeficitKcal ?? 0,
    ),
  );
}

/// Resolves the target the diary shows: the user's own calorie target when
/// they set one, otherwise whatever the energy estimate resolves to.
///
/// The user's explicit number wins deliberately — it is the one figure here
/// they actually chose, and quietly overriding it with an estimate would be
/// the app arguing with them. When it is in force the floor is not applied
/// to it and no floor explanation is shown, because the floor is a rule
/// about what *this app suggests*, not a limit imposed on the user's own
/// entry (`knowledge/research/nutrition_energy_estimates.md`).
@riverpod
DayCalorieTarget dayCalorieTarget(Ref ref) {
  final explicit = ref.watch(nutritionGoalsProvider).value?.calorieTargetKcal;
  if (explicit != null) return DayCalorieTarget(targetKcal: explicit);

  return switch (ref.watch(calorieTargetProvider).value) {
    CalorieTarget(:final targetKcal) => DayCalorieTarget(
      targetKcal: targetKcal,
      isEstimate: true,
    ),
    final FlooredCalorieTarget outcome => DayCalorieTarget(
      targetKcal: outcome.targetKcal,
      floored: outcome,
      isEstimate: true,
    ),
    NoCalorieTarget() || null => const DayCalorieTarget(),
  };
}

/// Evaluates 7-day nutrition and protein consistency achievements.
@riverpod
Stream<FuelingConsistencyResult> fuelingConsistency(Ref ref) {
  final nutritionRepository = ref.watch(nutritionRepositoryProvider);
  final goalsRepository = ref.watch(nutritionGoalsRepositoryProvider);
  final today = LocalDate.today();
  final windowStart = today.addDays(-6);

  return combineLatest2(
    nutritionRepository.watchEntriesForRange(windowStart, today),
    goalsRepository.watchGoals(),
    (entries, goals) => const FuelingConsistencyEvaluator().evaluate(
      entries: entries,
      goals: goals,
      today: today,
    ),
  );
}

/// Cycle status for [day] when the user tracks cycles, or null when
/// untracked.
@riverpod
Future<DayCycleStatus?> dayCycleStatus(Ref ref, LocalDate day) async {
  final records = await ref.watch(cycleRepositoryProvider).getRecords();
  if (records.isEmpty) return null;
  return CyclePredictionEngine().getDayStatus(
    date: day,
    records: records,
    today: LocalDate.today(),
  );
}

/// Evaluates micronutrient adequacy items for [day].
@riverpod
Future<List<MicronutrientAdequacyItem>> dayMicronutrientAdequacy(
  Ref ref,
  LocalDate day,
) async {
  final totals = await ref.watch(dayNutritionTotalsProvider(day).future);
  final cycleStatus = await ref.watch(dayCycleStatusProvider(day).future);
  return evaluateMicronutrientAdequacy(
    totals: totals.total,
    cyclePhase: cycleStatus?.phase,
  );
}
