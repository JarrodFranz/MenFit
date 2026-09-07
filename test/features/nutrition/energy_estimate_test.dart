import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/domain/units.dart';
import 'package:menfit_app/features/nutrition/domain/energy_estimate.dart';
import 'package:menfit_app/features/profile/domain/user_profile.dart';

UserProfile _profile({
  LocalDate? dateOfBirth,
  double? heightCm,
  double? weightKg,
}) {
  final now = DateTime.utc(2026);
  return UserProfile(
    id: 'profile-1',
    displayName: 'Jordan',
    unitSystem: UnitSystem.metric,
    createdAt: now,
    updatedAt: now,
    dateOfBirth: dateOfBirth,
    heightCm: heightCm,
    weightKg: weightKg,
  );
}

void main() {
  group('estimateEnergyNeeds — known-value check', () {
    test(
      'Mifflin-St Jeor (female coefficients), hand-computed: 65 kg, 170 cm, '
      '30 years => BMR 1401.5 kcal',
      () {
        // (10 x 65) + (6.25 x 170) - (5 x 30) - 161
        //   = 650 + 1062.5 - 150 - 161
        //   = 1401.5
        // Recomputed here rather than copied from the implementation - if
        // the coefficients or the female constant ever change, this fails.
        const expectedBmr = 650 + 1062.5 - 150 - 161;

        final result = estimateEnergyNeeds(
          ageYears: 30,
          heightCm: 170,
          weightKg: 65,
          activityLevel: ActivityLevel.sedentary,
        );

        expect(result, isA<EnergyEstimate>());
        final estimate = result as EnergyEstimate;
        expect(estimate.basalMetabolicRateKcal, closeTo(expectedBmr, 1e-9));
        expect(estimate.basalMetabolicRateKcal, closeTo(1401.5, 1e-9));
      },
    );

    test('TDEE is BMR times the chosen activity factor', () {
      const bmr = 650 + 1062.5 - 150 - 161;

      for (final level in ActivityLevel.values) {
        final result = estimateEnergyNeeds(
          ageYears: 30,
          heightCm: 170,
          weightKg: 65,
          activityLevel: level,
        ) as EnergyEstimate;
        expect(
          result.totalDailyEnergyKcal,
          closeTo(bmr * level.factor, 1e-9),
          reason: level.name,
        );
        expect(result.activityLevel, level);
      }
    });

    test('the male +5 constant is NOT used - the female variant is', () {
      final result = estimateEnergyNeeds(
        ageYears: 30,
        heightCm: 170,
        weightKg: 65,
        activityLevel: ActivityLevel.sedentary,
      ) as EnergyEstimate;

      // Male form would be 1562.5 + 5 = 1567.5; the difference between the
      // two variants is exactly 166 kcal (see
      // knowledge/research/nutrition_energy_estimates.md).
      expect(result.basalMetabolicRateKcal, isNot(closeTo(1567.5, 1e-9)));
      expect(result.basalMetabolicRateKcal, closeTo(1567.5 - 166, 1e-9));
    });
  });

  group('estimateEnergyNeeds — no estimate, one missing input at a time', () {
    test('missing date of birth (age) yields no estimate, and says so', () {
      final result = estimateEnergyNeeds(
        ageYears: null,
        heightCm: 170,
        weightKg: 65,
        activityLevel: ActivityLevel.sedentary,
      );

      expect(result, isA<NoEnergyEstimate>());
      final gap = result as NoEnergyEstimate;
      expect(gap.missing, {EnergyEstimateInput.dateOfBirth});
      expect(gap.activityLevelMissing, isFalse);
    });

    test('missing height yields no estimate, and says so', () {
      final result = estimateEnergyNeeds(
        ageYears: 30,
        heightCm: null,
        weightKg: 65,
        activityLevel: ActivityLevel.sedentary,
      ) as NoEnergyEstimate;

      expect(result.missing, {EnergyEstimateInput.heightCm});
    });

    test('missing weight yields no estimate, and says so', () {
      final result = estimateEnergyNeeds(
        ageYears: 30,
        heightCm: 170,
        weightKg: null,
        activityLevel: ActivityLevel.sedentary,
      ) as NoEnergyEstimate;

      expect(result.missing, {EnergyEstimateInput.weightKg});
    });

    test(
      'a missing activity level yields no estimate, reported separately '
      'from the profile inputs (it lives somewhere else in the UI)',
      () {
        final result = estimateEnergyNeeds(
          ageYears: 30,
          heightCm: 170,
          weightKg: 65,
          activityLevel: null,
        ) as NoEnergyEstimate;

        expect(result.missing, isEmpty);
        expect(result.activityLevelMissing, isTrue);
      },
    );

    test('everything missing is reported at once, not one at a time', () {
      final result = estimateEnergyNeeds(
        ageYears: null,
        heightCm: null,
        weightKg: null,
        activityLevel: null,
      ) as NoEnergyEstimate;

      expect(result.missing, EnergyEstimateInput.values.toSet());
      expect(result.activityLevelMissing, isTrue);
    });

    test(
      'a non-positive stored value is treated as missing, never fed into '
      'the equation',
      () {
        for (final bad in <double>[0, -1]) {
          final byHeight = estimateEnergyNeeds(
            ageYears: 30,
            heightCm: bad,
            weightKg: 65,
            activityLevel: ActivityLevel.sedentary,
          ) as NoEnergyEstimate;
          expect(byHeight.missing, contains(EnergyEstimateInput.heightCm));

          final byWeight = estimateEnergyNeeds(
            ageYears: 30,
            heightCm: 170,
            weightKg: bad,
            activityLevel: ActivityLevel.sedentary,
          ) as NoEnergyEstimate;
          expect(byWeight.missing, contains(EnergyEstimateInput.weightKg));
        }

        final byAge = estimateEnergyNeeds(
          ageYears: 0,
          heightCm: 170,
          weightKg: 65,
          activityLevel: ActivityLevel.sedentary,
        ) as NoEnergyEstimate;
        expect(byAge.missing, contains(EnergyEstimateInput.dateOfBirth));
      },
    );
  });

  group('estimateEnergyNeedsForProfile', () {
    final today = LocalDate(2026, 8, 20);

    test('derives age from the profile and agrees with the raw function', () {
      final profile = _profile(
        dateOfBirth: LocalDate(1996, 8, 20),
        heightCm: 170,
        weightKg: 65,
      );

      final viaProfile = estimateEnergyNeedsForProfile(
        profile: profile,
        activityLevel: ActivityLevel.moderatelyActive,
        today: today,
      ) as EnergyEstimate;
      final viaAge = estimateEnergyNeeds(
        ageYears: profile.ageOn(today),
        heightCm: 170,
        weightKg: 65,
        activityLevel: ActivityLevel.moderatelyActive,
      ) as EnergyEstimate;

      expect(profile.ageOn(today), 30);
      expect(
        viaProfile.basalMetabolicRateKcal,
        viaAge.basalMetabolicRateKcal,
        reason:
            'the profile overload must not re-implement calendar arithmetic '
            "- it delegates to UserProfile.ageOn's leap-day-tested rule",
      );
    });

    test('a null profile reports every profile input as missing', () {
      final result = estimateEnergyNeedsForProfile(
        profile: null,
        activityLevel: ActivityLevel.sedentary,
        today: today,
      ) as NoEnergyEstimate;

      expect(result.missing, EnergyEstimateInput.values.toSet());
    });

    test('a profile with no body data reports every profile input', () {
      final result = estimateEnergyNeedsForProfile(
        profile: _profile(),
        activityLevel: ActivityLevel.sedentary,
        today: today,
      ) as NoEnergyEstimate;

      expect(result.missing, EnergyEstimateInput.values.toSet());
    });
  });

  group('ActivityLevel storage', () {
    test('every value round-trips through storage', () {
      for (final level in ActivityLevel.values) {
        expect(
          ActivityLevel.fromStorage(level.toStorage()),
          level,
          reason: level.name,
        );
      }
    });

    test(
      'null and unknown storage values stay null - never guessed into a '
      'level, which would invent an estimate the user never asked for',
      () {
        expect(ActivityLevel.fromStorage(null), isNull);
        expect(ActivityLevel.fromStorage('something-else'), isNull);
        expect(ActivityLevel.fromStorage(''), isNull);
      },
    );
  });
}
