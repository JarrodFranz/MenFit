import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/domain/units.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/activity/domain/activity_energy.dart';
import 'package:menfit_app/features/profile/domain/user_profile.dart';

void main() {
  group('resolveActivityMet', () {
    test('linearly interpolates running MET between speed points', () {
      // 8.0 km/h is 8.5 MET, 9.7 km/h is 9.3 MET
      // At midpoint 8.85 km/h: 8.5 + 0.5 * 0.8 = 8.9 MET
      final met = resolveActivityMet(ActivityType.run, 8.85);
      expect(met, closeTo(8.9, 0.05));
    });

    test('clamps below min and above max speeds', () {
      expect(resolveActivityMet(ActivityType.run, 4), equals(6.5));
      expect(resolveActivityMet(ActivityType.run, 20), equals(14.8));
    });
  });

  group('estimateActivityEnergy', () {
    final refDate = DateTime.utc(2026, 8, 29);
    final userDob = LocalDate(1996, 8, 29); // 30 years old

    final fullProfile = UserProfile(
      id: 'test-user',
      displayName: 'Test User',
      unitSystem: UnitSystem.metric,
      dateOfBirth: userDob,
      heightCm: 165,
      weightKg: 65,
      createdAt: refDate,
      updatedAt: refDate,
    );

    test('returns NoActivityEnergyBasis when weight is missing', () {
      final profileNoWeight = fullProfile.copyWith(weightKg: null);
      final activity = Activity(
        id: 'act-1',
        activityType: ActivityType.run,
        title: 'Morning Run',
        startedAt: refDate,
        movingTime: const Duration(minutes: 30),
        elapsedTime: const Duration(minutes: 30),
        distanceMeters: 5000,
        source: ActivitySource.recorded,
        createdAt: refDate,
        updatedAt: refDate,
      );

      final outcome = estimateActivityEnergy(
        activity: activity,
        profile: profileNoWeight,
        referenceDate: refDate,
      );

      expect(outcome, isA<NoActivityEnergyBasis>());
    });

    test('calculates net energy and rounded range for 5k run (65kg user)', () {
      // 5km in 30min -> 10 km/h -> ~9.5 MET.
      // BMR for 65kg, 165cm, 30yo = (10*65) + (6.25*165) - (5*30) - 161 = 650 + 1031.25 - 150 - 161 = 1370.25 kcal/day.
      // 30 min resting = (1370.25 / 1440) * 30 = 28.5 kcal.
      // Gross = 9.5 * 65 * 0.5 = 308.75 kcal.
      // Net = 308.75 - 28.5 = 280.25 kcal.
      // Range: [280.25 * 0.80, 280.25 * 1.20] = [224, 336].
      final activity = Activity(
        id: 'act-1',
        activityType: ActivityType.run,
        title: '5K Run',
        startedAt: refDate,
        movingTime: const Duration(minutes: 30),
        elapsedTime: const Duration(minutes: 30),
        distanceMeters: 5000,
        source: ActivitySource.recorded,
        createdAt: refDate,
        updatedAt: refDate,
      );

      final outcome = estimateActivityEnergy(
        activity: activity,
        profile: fullProfile,
        referenceDate: refDate,
      );

      expect(outcome, isA<ActivityEnergyEstimate>());
      final estimate = outcome as ActivityEnergyEstimate;
      expect(estimate.minKcal, greaterThan(200));
      expect(estimate.maxKcal, lessThan(360));
      expect(estimate.minKcal, lessThan(estimate.maxKcal));
      expect(estimate.rangeLabel, contains('kcal'));
    });

    test('widens upper bound when elevation gain is present', () {
      final flatActivity = Activity(
        id: 'act-flat',
        activityType: ActivityType.run,
        title: 'Flat Run',
        startedAt: refDate,
        movingTime: const Duration(minutes: 40),
        elapsedTime: const Duration(minutes: 40),
        distanceMeters: 6000,
        source: ActivitySource.recorded,
        createdAt: refDate,
        updatedAt: refDate,
        elevationGainMeters: 0,
      );

      final hillyActivity = flatActivity.copyWith(
        id: 'act-hilly',
        elevationGainMeters: 200,
      );

      final flatEstimate = estimateActivityEnergy(
        activity: flatActivity,
        profile: fullProfile,
        referenceDate: refDate,
      ) as ActivityEnergyEstimate;

      final hillyEstimate = estimateActivityEnergy(
        activity: hillyActivity,
        profile: fullProfile,
        referenceDate: refDate,
      ) as ActivityEnergyEstimate;

      expect(hillyEstimate.minKcal, equals(flatEstimate.minKcal));
      expect(hillyEstimate.maxKcal, greaterThan(flatEstimate.maxKcal));
      expect(hillyEstimate.elevationWidened, isTrue);
    });
  });

  group('calculateTotalActiveCaloriesKcal', () {
    final refDate = DateTime.utc(2026, 8, 29);
    final userDob = LocalDate(1996, 8, 29);

    final fullProfile = UserProfile(
      id: 'test-user',
      displayName: 'Test User',
      unitSystem: UnitSystem.metric,
      dateOfBirth: userDob,
      heightCm: 165,
      weightKg: 65,
      createdAt: refDate,
      updatedAt: refDate,
    );

    test('sums energy across multiple activities with full profile', () {
      final run = Activity(
        id: 'run-1',
        activityType: ActivityType.run,
        title: 'Morning Run',
        startedAt: refDate,
        movingTime: const Duration(minutes: 30),
        elapsedTime: const Duration(minutes: 30),
        distanceMeters: 5000,
        source: ActivitySource.recorded,
        createdAt: refDate,
        updatedAt: refDate,
      );

      final walk = Activity(
        id: 'walk-1',
        activityType: ActivityType.walk,
        title: 'Afternoon Walk',
        startedAt: refDate,
        movingTime: const Duration(minutes: 20),
        elapsedTime: const Duration(minutes: 20),
        distanceMeters: 1500,
        source: ActivitySource.manual,
        createdAt: refDate,
        updatedAt: refDate,
      );

      final total = calculateTotalActiveCaloriesKcal(
        activities: [run, walk],
        profile: fullProfile,
        referenceDate: refDate,
      );

      // Run ~280 kcal, walk ~50-60 kcal -> total ~330-350 kcal
      expect(total, greaterThan(300));
      expect(total, lessThan(400));
    });

    test('calculates energy with partial or null profile using fallback', () {
      final walk = Activity(
        id: 'walk-1',
        activityType: ActivityType.walk,
        title: 'Afternoon Walk',
        startedAt: refDate,
        movingTime: const Duration(minutes: 30),
        elapsedTime: const Duration(minutes: 30),
        distanceMeters: 2000,
        source: ActivitySource.manual,
        createdAt: refDate,
        updatedAt: refDate,
      );

      final total = calculateTotalActiveCaloriesKcal(
        activities: [walk],
        profile: null,
        referenceDate: refDate,
      );

      expect(total, greaterThan(20));
      expect(total, lessThan(100));
    });
  });
}
