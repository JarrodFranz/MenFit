import 'package:menfit_app/core/db/app_database.dart' as db;
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/domain/units.dart';
import 'package:menfit_app/features/achievements/data/drift_award_repository.dart';
import 'package:menfit_app/features/achievements/domain/badge_award.dart';
import 'package:menfit_app/features/achievements/domain/badge_tier.dart';
import 'package:menfit_app/features/activity/data/drift_activity_repository.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/challenges/data/drift_challenge_repository.dart';
import 'package:menfit_app/features/challenges/domain/challenge.dart';
import 'package:menfit_app/features/nutrition/data/drift_nutrition_repository.dart';
import 'package:menfit_app/features/nutrition/data/drift_water_repository.dart';
import 'package:menfit_app/features/nutrition/domain/food.dart';
import 'package:menfit_app/features/nutrition/domain/meal_type.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_entry.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_facts.dart';
import 'package:menfit_app/features/profile/data/drift_profile_repository.dart';
import 'package:menfit_app/features/profile/domain/user_profile.dart';
import 'package:menfit_app/features/routes/data/drift_route_repository.dart';
import 'package:menfit_app/features/routes/domain/geo_point.dart';
import 'package:menfit_app/features/routes/domain/saved_route.dart';
import 'package:menfit_app/features/weight/data/drift_weight_repository.dart';
import 'package:menfit_app/features/weight/domain/weight_log.dart';
import 'package:menfit_app/features/wellbeing/data/drift_wellbeing_repository.dart';
import 'package:menfit_app/features/wellbeing/domain/daily_checkin.dart';
import 'package:menfit_app/features/wellbeing/domain/symptom_type.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/challenges/challenge_fixtures.dart';

/// The ids the seed produced, so route-parameterised screens
/// (`/activity/:id`, `/challenges/:id`, `/activity/routes/:id`) can be
/// audited against real data rather than a 404 state.
class SeededIds {
  const SeededIds({
    required this.activityId,
    required this.strengthActivityId,
    required this.routeId,
    required this.challengeId,
  });

  final String activityId;
  final String strengthActivityId;
  final String routeId;
  final String challengeId;
}

/// Populates [database] with a realistic week of data.
///
/// Empty screens hide overflow bugs — a card that fits "No activities yet"
/// may not fit "Threshold intervals · 12.4 km · 1:02:30". Every value here
/// is chosen to be *typical but wide*: a long-but-plausible activity
/// title, four-digit calories, a two-line food name.
Future<SeededIds> seedRealisticData(
  db.AppDatabase database,
  SharedPreferences preferences,
) async {
  final now = DateTime.now();
  final today = LocalDate.today();
  final stamp = DateTime.utc(2026, 9);

  await DriftProfileRepository(database).saveProfile(
    UserProfile(
      id: 'seed-profile',
      displayName: 'Alexandra',
      unitSystem: UnitSystem.metric,
      createdAt: stamp,
      updatedAt: stamp,
    ),
  );

  final activities = DriftActivityRepository(database);

  DateTime daysAgoNoon(int days) {
    final day = now.subtract(Duration(days: days));
    return DateTime(day.year, day.month, day.day, 9, 30);
  }

  Activity make({
    required String id,
    required ActivityType type,
    required String title,
    required int daysAgo,
    double distanceMeters = 0,
    Duration movingTime = const Duration(minutes: 42),
  }) {
    final startedAt = daysAgoNoon(daysAgo);
    return Activity(
      id: id,
      activityType: type,
      title: title,
      startedAt: startedAt,
      movingTime: movingTime,
      elapsedTime: movingTime + const Duration(minutes: 3),
      distanceMeters: distanceMeters,
      source: ActivitySource.manual,
      createdAt: startedAt.toUtc(),
      updatedAt: startedAt.toUtc(),
    );
  }

  final run = make(
    id: 'seed-activity-run',
    type: ActivityType.run,
    title: 'Thursday threshold intervals along the canal',
    daysAgo: 1,
    distanceMeters: 12400,
    movingTime: const Duration(minutes: 62, seconds: 30),
  );
  final strength = make(
    id: 'seed-activity-strength',
    type: ActivityType.strength,
    title: 'Lower body — squats, hinges and accessories',
    daysAgo: 2,
    movingTime: const Duration(minutes: 55),
  );

  for (final activity in [
    run,
    strength,
    make(
      id: 'seed-activity-walk',
      type: ActivityType.walk,
      title: 'Evening recovery walk',
      daysAgo: 3,
      distanceMeters: 4200,
      movingTime: const Duration(minutes: 48),
    ),
    make(
      id: 'seed-activity-yoga',
      type: ActivityType.yoga,
      title: 'Slow flow',
      daysAgo: 4,
      movingTime: const Duration(minutes: 35),
    ),
    make(
      id: 'seed-activity-swim',
      type: ActivityType.swim,
      title: 'Pool session',
      daysAgo: 5,
      distanceMeters: 1500,
      movingTime: const Duration(minutes: 40),
    ),
    make(
      id: 'seed-activity-ride',
      type: ActivityType.ride,
      title: 'Long ride out to the reservoir and back',
      daysAgo: 6,
      distanceMeters: 42800,
      movingTime: const Duration(hours: 1, minutes: 55),
    ),
  ]) {
    await activities.saveActivity(activity);
  }

  await DriftWellbeingRepository(database).saveCheckin(
    DailyCheckin(
      id: 'seed-checkin',
      day: today,
      createdAt: stamp,
      updatedAt: stamp,
      energy: 4,
      sleep: 3,
      soreness: 2,
      stress: 2,
      pain: 1,
      symptoms: const [SymptomType.cramping, SymptomType.headache],
    ),
  );

  final nutrition = DriftNutritionRepository(database);
  final oats = Food(
    id: 'seed-food-oats',
    name: 'Wholegrain porridge oats with almond butter',
    brand: 'Supermarket own brand',
    servingDescription: '1 bowl (80 g dry)',
    perServing: const NutritionFacts(
      caloriesKcal: 412,
      proteinGrams: 14.2,
      carbsGrams: 58.6,
      fatGrams: 12.4,
    ),
    createdAt: stamp,
    updatedAt: stamp,
  );
  await nutrition.saveFood(oats);
  await nutrition.saveEntry(
    NutritionEntry(
      id: 'seed-entry-breakfast',
      day: today,
      meal: MealType.breakfast,
      foodId: oats.id,
      foodName: oats.name,
      foodBrand: oats.brand,
      servingDescription: oats.servingDescription,
      quantityServings: 1,
      quantityAmount: 1,
      perServing: oats.perServing,
      createdAt: stamp,
      updatedAt: stamp,
    ),
  );
  await nutrition.saveEntry(
    NutritionEntry(
      id: 'seed-entry-lunch',
      day: today,
      meal: MealType.lunch,
      foodName: 'Chicken, rice and roasted vegetables',
      quantityServings: 1.5,
      quantityAmount: 1.5,
      perServing: const NutritionFacts(
        caloriesKcal: 520,
        proteinGrams: 41,
        carbsGrams: 55,
        fatGrams: 14,
      ),
      createdAt: stamp,
      updatedAt: stamp,
    ),
  );

  await DriftWaterRepository(database).logWater(day: today, milliliters: 1250);

  await DriftWeightRepository(database).saveLog(
    WeightLog(
      id: 'seed-weight',
      day: today.addDays(-1),
      weightKg: 63.4,
      createdAt: stamp,
      updatedAt: stamp,
    ),
  );
  await DriftWeightRepository(database).saveLog(
    WeightLog(
      id: 'seed-weight-older',
      day: today.addDays(-15),
      weightKg: 64.1,
      createdAt: stamp,
      updatedAt: stamp,
    ),
  );

  await DriftAwardRepository(database).recordAwards([
    BadgeAward(
      id: 'seed-award-sessions',
      badgeId: 'sessions_logged',
      awardedAt: stamp,
      tier: BadgeTier.silver,
    ),
    BadgeAward(
      id: 'seed-award-run',
      badgeId: 'run_distance',
      awardedAt: stamp,
      tier: BadgeTier.bronze,
    ),
  ]);

  final route = SavedRoute(
    id: 'seed-route',
    name: 'Canal towpath loop from the north gate',
    activityType: ActivityType.run,
    distanceMeters: 8300,
    points: const [
      GeoPoint(latitude: 51.5074, longitude: -0.1278),
      GeoPoint(latitude: 51.5084, longitude: -0.1288),
      GeoPoint(latitude: 51.5094, longitude: -0.1268),
      GeoPoint(latitude: 51.5074, longitude: -0.1278),
    ],
    source: RouteSource.suggested,
    estimatedDuration: const Duration(minutes: 47),
    ascentMeters: 42,
    descentMeters: 40,
    createdAt: stamp,
    updatedAt: stamp,
  );
  await DriftRouteRepository(database).saveRoute(route);

  final challenge = challengeFrom(distanceBlueprint());
  await DriftChallengeRepository(database).saveChallenge(challenge);

  return SeededIds(
    activityId: run.id,
    strengthActivityId: strength.id,
    routeId: route.id,
    challengeId: challenge.id,
  );
}

/// Re-exported so callers can reuse the shared challenge fixture without a
/// second relative import.
Challenge seededChallenge() => challengeFrom(distanceBlueprint());
