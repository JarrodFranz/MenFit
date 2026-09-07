import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/domain/units.dart';
import 'package:menfit_app/features/profile/domain/user_profile.dart';

void main() {
  UserProfile buildProfile({LocalDate? dateOfBirth}) {
    return UserProfile(
      id: 'id-1',
      displayName: 'Jordan',
      unitSystem: UnitSystem.metric,
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
      dateOfBirth: dateOfBirth,
    );
  }

  group('UserProfile.ageOn', () {
    test('returns null when dateOfBirth was never provided', () {
      final profile = buildProfile();
      expect(profile.ageOn(LocalDate(2026, 8, 26)), isNull);
    });

    test('birthday today: age has just advanced', () {
      final profile = buildProfile(dateOfBirth: LocalDate(1990, 8, 26));
      expect(profile.ageOn(LocalDate(2026, 8, 26)), 36);
    });

    test('birthday tomorrow: age has not advanced yet', () {
      final profile = buildProfile(dateOfBirth: LocalDate(1990, 8, 27));
      expect(profile.ageOn(LocalDate(2026, 8, 26)), 35);
    });

    test('birthday yesterday: age has already advanced', () {
      final profile = buildProfile(dateOfBirth: LocalDate(1990, 8, 25));
      expect(profile.ageOn(LocalDate(2026, 8, 26)), 36);
    });

    test(
      'a 29 February birthday: age has not advanced on 28 February of a '
      'non-leap year',
      () {
        final profile = buildProfile(dateOfBirth: LocalDate(2000, 2, 29));
        // 2026 is not a leap year - 28 February is the day before the
        // birthday would fall, so the birthday hasn't "happened yet".
        expect(profile.ageOn(LocalDate(2026, 2, 28)), 25);
      },
    );

    test(
      'a 29 February birthday: age has advanced by 1 March of a non-leap '
      'year',
      () {
        final profile = buildProfile(dateOfBirth: LocalDate(2000, 2, 29));
        expect(profile.ageOn(LocalDate(2026, 3, 1)), 26);
      },
    );

    test('a 29 February birthday: age advances on the real birthday in a '
        'leap year', () {
      final profile = buildProfile(dateOfBirth: LocalDate(2000, 2, 29));
      expect(profile.ageOn(LocalDate(2028, 2, 29)), 28);
    });

    test('newborn (today is the date of birth) is age 0', () {
      final profile = buildProfile(dateOfBirth: LocalDate(2026, 8, 26));
      expect(profile.ageOn(LocalDate(2026, 8, 26)), 0);
    });
  });

  group('FitnessGoal', () {
    test('toStorage round-trips through fromStorage', () {
      for (final goal in FitnessGoal.values) {
        expect(FitnessGoal.fromStorage(goal.toStorage()), goal);
      }
    });

    test('fromStorage returns null for null or an unrecognised value', () {
      expect(FitnessGoal.fromStorage(null), isNull);
      expect(FitnessGoal.fromStorage('bogus'), isNull);
    });

    test('every value has a distinct label', () {
      final labels = FitnessGoal.values.map((g) => g.label).toSet();
      expect(labels, hasLength(FitnessGoal.values.length));
    });
  });

  group('ExperienceLevel', () {
    test('toStorage round-trips through fromStorage', () {
      for (final level in ExperienceLevel.values) {
        expect(ExperienceLevel.fromStorage(level.toStorage()), level);
      }
    });

    test('fromStorage returns null for null or an unrecognised value', () {
      expect(ExperienceLevel.fromStorage(null), isNull);
      expect(ExperienceLevel.fromStorage('bogus'), isNull);
    });

    test('labels match the spec wording', () {
      expect(ExperienceLevel.newTo.label, 'New to it');
      expect(ExperienceLevel.occasional.label, 'Occasional');
      expect(ExperienceLevel.regular.label, 'Regular');
      expect(ExperienceLevel.experienced.label, 'Experienced');
    });
  });
}
