import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/features/nutrition/domain/calorie_target.dart';
import 'package:menfit_app/features/nutrition/domain/macro_locks.dart';
import 'package:menfit_app/features/nutrition/domain/macro_targets.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_validation.dart';

void main() {
  const resolved = CalorieTarget(
    targetKcal: 1800,
    maintenanceKcal: 1800,
    appliedAdjustmentKcal: 0,
  );

  MacroLockSolution solve({
    required MacroLocks locks,
    int? calorieTargetKcal = 2000,
    CalorieTargetOutcome? resolvedTarget,
    double? protein,
    double? carbs,
    double? fat,
  }) => solveMacroTargets(
    locks: locks,
    calorieTargetKcal: calorieTargetKcal,
    resolvedTarget: resolvedTarget,
    proteinTargetGrams: protein,
    carbTargetGrams: carbs,
    fatTargetGrams: fat,
  );

  group('MacroLocks storage', () {
    test('round-trips every subset of the three', () {
      for (final protein in [false, true]) {
        for (final carbs in [false, true]) {
          for (final fat in [false, true]) {
            final locks = MacroLocks(protein: protein, carbs: carbs, fat: fat);
            expect(MacroLocks.fromStorage(locks.toStorage()), locks);
          }
        }
      }
    });

    test('encodes in a stable order however the set was built', () {
      expect(
        MacroLocks.of([MacroNutrient.fat, MacroNutrient.protein]).toStorage(),
        'protein,fat',
      );
      expect(
        MacroLocks.of([MacroNutrient.protein, MacroNutrient.fat]).toStorage(),
        'protein,fat',
      );
    });

    test('null, blank and whitespace read as nothing locked', () {
      expect(MacroLocks.fromStorage(null), MacroLocks.none);
      expect(MacroLocks.fromStorage(''), MacroLocks.none);
      expect(MacroLocks.fromStorage('   '), MacroLocks.none);
      expect(MacroLocks.none.isEmpty, isTrue);
      expect(MacroLocks.none.lockedCount, 0);
    });

    test('unknown keys are dropped, known ones beside them survive', () {
      expect(
        MacroLocks.fromStorage(' protein , fibre ,fat '),
        const MacroLocks(protein: true, fat: true),
        reason:
            'a row written by a version that knows a fourth macro must still '
            'be readable here',
      );
      expect(MacroLocks.fromStorage('fibre'), MacroLocks.none);
    });

    test('a repeated key is still a set', () {
      expect(
        MacroLocks.fromStorage('carbs,carbs'),
        const MacroLocks(carbs: true),
      );
    });

    test('withLock changes one macro and leaves the others alone', () {
      const locks = MacroLocks(protein: true);
      expect(
        locks.withLock(MacroNutrient.fat, locked: true),
        const MacroLocks(protein: true, fat: true),
      );
      expect(
        locks.withLock(MacroNutrient.protein, locked: false),
        MacroLocks.none,
      );
    });

    test('locked and free are complements, both in enum order', () {
      const locks = MacroLocks(protein: true, fat: true);
      expect(locks.locked, [MacroNutrient.protein, MacroNutrient.fat]);
      expect(locks.free, [MacroNutrient.carbs]);
      expect(locks.lockedCount, 2);
    });
  });

  group('solveMacroTargets with two locked', () {
    test('solves carbs from protein and fat', () {
      // 150 g protein = 600 kcal, 67 g fat = 603 kcal, leaving 797 of 2000.
      final solution = solve(
        locks: const MacroLocks(protein: true, fat: true),
        protein: 150,
        fat: 67,
      ) as SolvedMacroTarget;

      expect(solution.macro, MacroNutrient.carbs);
      expect(solution.remainingKcal, closeTo(797, 0.001));
      expect(solution.grams, closeTo(797 / 4, 0.001));
      expect(solution.lockedKcal, closeTo(1203, 0.001));
      expect(solution.basisKcal, 2000);
      expect(solution.basisIsEstimated, isFalse);
    });

    test('solves protein from carbs and fat', () {
      // 200 g carbs = 800 kcal, 60 g fat = 540 kcal, leaving 660 of 2000.
      final solution = solve(
        locks: const MacroLocks(carbs: true, fat: true),
        carbs: 200,
        fat: 60,
      ) as SolvedMacroTarget;

      expect(solution.macro, MacroNutrient.protein);
      expect(solution.grams, closeTo(660 / 4, 0.001));
    });

    test('solves fat from protein and carbs, at 9 kcal a gram', () {
      // 150 g protein = 600 kcal, 200 g carbs = 800 kcal, leaving 600.
      final solution = solve(
        locks: const MacroLocks(protein: true, carbs: true),
        protein: 150,
        carbs: 200,
      ) as SolvedMacroTarget;

      expect(solution.macro, MacroNutrient.fat);
      expect(
        solution.grams,
        closeTo(600 / 9, 0.001),
        reason: 'fat is 9 kcal a gram, not 4',
      );
    });

    test('an exactly-spent budget solves to zero grams, not to a gap', () {
      final solution = solve(
        locks: const MacroLocks(protein: true, carbs: true),
        protein: 250,
        carbs: 250,
      ) as SolvedMacroTarget;

      expect(solution.remainingKcal, 0);
      expect(solution.grams, 0);
    });

    test('the estimate stands in when no calorie target is set', () {
      final solution = solve(
        locks: const MacroLocks(protein: true, carbs: true),
        calorieTargetKcal: null,
        resolvedTarget: resolved,
        protein: 100,
        carbs: 100,
      ) as SolvedMacroTarget;

      expect(solution.basisKcal, 1800);
      expect(solution.basisIsEstimated, isTrue);
      expect(solution.grams, closeTo((1800 - 800) / 9, 0.001));
    });

    test('the floored target counts as a basis - it is what they work to', () {
      const floored = FlooredCalorieTarget(
        targetKcal: 1400,
        requestedKcal: 1100,
        floorKcal: 1400,
        maintenanceKcal: 1900,
        requestedAdjustmentKcal: -800,
      );
      final solution = solve(
        locks: const MacroLocks(protein: true, carbs: true),
        calorieTargetKcal: null,
        resolvedTarget: floored,
        protein: 100,
        carbs: 100,
      ) as SolvedMacroTarget;

      expect(solution.basisKcal, 1400);
    });
  });

  group('solveMacroTargets over budget', () {
    test('carries the overage and never returns grams at all', () {
      // 250 g protein = 1000 kcal, 150 g fat = 1350 kcal: 2350 against 2000.
      final solution = solve(
        locks: const MacroLocks(protein: true, fat: true),
        protein: 250,
        fat: 150,
      ) as MacroTargetsOverBudget;

      expect(solution.lockedKcal, closeTo(2350, 0.001));
      expect(solution.overageKcal, closeTo(350, 0.001));
      expect(solution.basisKcal, 2000);
    });

    test('never a negative gram figure and never a clamped zero', () {
      final solution = solve(
        locks: const MacroLocks(protein: true, fat: true),
        protein: 250,
        fat: 150,
      );

      expect(
        solution,
        isNot(isA<SolvedMacroTarget>()),
        reason:
            'a solve here would have to print -87.5 g of carbs, or hide it '
            'behind a 0 g target they could meet by eating none',
      );
    });

    test('one lock alone can exceed the budget, and says so', () {
      final solution = solve(
        locks: const MacroLocks(fat: true),
        fat: 300,
      ) as MacroTargetsOverBudget;

      expect(solution.overageKcal, closeTo(700, 0.001));
    });

    test('meeting the budget exactly is not over budget', () {
      expect(
        solve(
          locks: const MacroLocks(protein: true, carbs: true),
          protein: 250,
          carbs: 250,
        ),
        isA<SolvedMacroTarget>(),
      );
    });
  });

  group('solveMacroTargets underdetermined', () {
    test('nothing locked reports the whole target as unaccounted for', () {
      final solution =
          solve(locks: MacroLocks.none) as UnderdeterminedMacroTargets;

      expect(solution.lockedCount, 0);
      expect(solution.lockedKcal, 0);
      expect(solution.unaccountedKcal, 2000);
    });

    test('one locked macro reports what is left', () {
      final solution = solve(
        locks: const MacroLocks(protein: true),
        protein: 150,
      ) as UnderdeterminedMacroTargets;

      expect(solution.lockedCount, 1);
      expect(solution.lockedKcal, closeTo(600, 0.001));
      expect(solution.unaccountedKcal, closeTo(1400, 0.001));
    });

    test('it never invents a split for the free macros', () {
      final solution = solve(
        locks: const MacroLocks(protein: true),
        protein: 150,
      );

      expect(solution, isA<UnderdeterminedMacroTargets>());
      expect(
        solution,
        isNot(isA<SolvedMacroTarget>()),
        reason:
            'two free macros are underdetermined; distributing the '
            'remainder would be the app recommending a split',
      );
    });

    test('a lock on a blank field pins nothing, so it cannot solve', () {
      final solution = solve(
        locks: const MacroLocks(protein: true, carbs: true),
        protein: 150,
      ) as UnderdeterminedMacroTargets;

      expect(
        solution.lockedCount,
        1,
        reason: 'only the lock with a number in it counts',
      );
      expect(solution.unaccountedKcal, closeTo(1400, 0.001));
    });

    test('a negative locked value is treated as no value at all', () {
      final solution = solve(
        locks: const MacroLocks(protein: true, carbs: true),
        protein: 150,
        carbs: -20,
      );

      expect(solution, isA<UnderdeterminedMacroTargets>());
    });
  });

  group('solveMacroTargets with all three locked', () {
    test('reports the difference when they come to more', () {
      // 150 g protein + 250 g carbs = 1600 kcal, 60 g fat = 540: 2140.
      final solution = solve(
        locks: const MacroLocks(protein: true, carbs: true, fat: true),
        protein: 150,
        carbs: 250,
        fat: 60,
      ) as AllMacroTargetsLocked;

      expect(solution.lockedKcal, closeTo(2140, 0.001));
      expect(solution.differenceKcal, closeTo(140, 0.001));
    });

    test('reports a negative difference when they come to less', () {
      final solution = solve(
        locks: const MacroLocks(protein: true, carbs: true, fat: true),
        protein: 100,
        carbs: 100,
        fat: 50,
      ) as AllMacroTargetsLocked;

      expect(solution.differenceKcal, closeTo(1250 - 2000, 0.001));
    });

    test('three locked targets that exceed the budget are not an error', () {
      final solution = solve(
        locks: const MacroLocks(protein: true, carbs: true, fat: true),
        protein: 250,
        carbs: 250,
        fat: 100,
      );

      expect(
        solution,
        isA<AllMacroTargetsLocked>(),
        reason:
            'they pinned all three deliberately; the app states the '
            'arithmetic rather than treating their day as a failure',
      );
    });
  });

  group('solveMacroTargets with no basis', () {
    test('no calorie target and no estimate solves nothing', () {
      expect(
        solve(
          locks: const MacroLocks(protein: true, carbs: true),
          calorieTargetKcal: null,
          protein: 150,
          carbs: 200,
        ),
        isA<NoMacroLockSolutionBasis>(),
      );
    });

    test('a zero calorie target is no basis, not a basis of zero', () {
      expect(
        solve(
          locks: const MacroLocks(protein: true, carbs: true),
          calorieTargetKcal: 0,
          resolvedTarget: resolved,
          protein: 150,
          carbs: 200,
        ),
        isA<NoMacroLockSolutionBasis>(),
        reason:
            'a target they set explicitly must not fall through to a '
            'different number the app worked out',
      );
    });
  });

  group('macroLockNote', () {
    String? note(
      MacroLockSolution solution, {
      required MacroLocks locks,
      bool hideCalorieNumbers = false,
    }) => macroLockNote(
      solution,
      locks: locks,
      hideCalorieNumbers: hideCalorieNumbers,
    );

    test('says nothing at all when nothing is locked', () {
      expect(note(solve(locks: MacroLocks.none), locks: MacroLocks.none), null);
    });

    test('says nothing when the third has been worked out', () {
      const locks = MacroLocks(protein: true, carbs: true);
      expect(
        note(solve(locks: locks, protein: 150, carbs: 200), locks: locks),
        null,
        reason: 'the field itself shows the answer',
      );
    });

    test('over budget states what the locked targets come to', () {
      const locks = MacroLocks(protein: true, fat: true);
      expect(
        note(solve(locks: locks, protein: 250, fat: 150), locks: locks),
        'Your locked targets already come to 2350 kcal — 350 more than your '
        'calorie target.',
      );
    });

    test('over budget with calorie numbers hidden still conveys the fact', () {
      const locks = MacroLocks(protein: true, fat: true);
      final message = note(
        solve(locks: locks, protein: 250, fat: 150),
        locks: locks,
        hideCalorieNumbers: true,
      )!;

      expect(message, contains('more energy than your calorie target'));
      expect(
        RegExp(r'\d').hasMatch(message),
        isFalse,
        reason: 'the fact survives the preference; the figures do not',
      );
    });

    test('underdetermined names what is unaccounted for', () {
      const locks = MacroLocks(protein: true);
      expect(
        note(solve(locks: locks, protein: 150), locks: locks),
        'Lock two of the three and the app works out the third. Your locked '
        'targets leave 1400 kcal of your calorie target unaccounted for.',
      );
    });

    test('underdetermined with calorie numbers hidden drops the figure', () {
      const locks = MacroLocks(protein: true);
      final message = note(
        solve(locks: locks, protein: 150),
        locks: locks,
        hideCalorieNumbers: true,
      )!;

      expect(message, contains('leave part of your calorie target'));
      expect(RegExp(r'\d').hasMatch(message), isFalse);
    });

    test(
      'all three locked states the difference, without calling it wrong',
      () {
        const locks = MacroLocks(protein: true, carbs: true, fat: true);
        final message = note(
          solve(locks: locks, protein: 150, carbs: 250, fat: 60),
          locks: locks,
        )!;

        expect(message, contains('2140 kcal'));
        expect(message, contains('140 more than your calorie target'));
        for (final word in [
          'should',
          'too much',
          'too many',
          'balanced',
          'recommend',
          'wrong',
        ]) {
          expect(message.toLowerCase(), isNot(contains(word)));
        }
      },
    );

    test('an estimated basis is named as an estimate, not as their target', () {
      const locks = MacroLocks(protein: true, fat: true);
      final message = note(
        solve(
          locks: locks,
          calorieTargetKcal: null,
          resolvedTarget: resolved,
          protein: 300,
          fat: 100,
        ),
        locks: locks,
      )!;

      expect(message, contains('your estimated daily target'));
    });

    test('no basis explains what is missing rather than showing nothing', () {
      const locks = MacroLocks(protein: true, carbs: true);
      expect(
        note(
          solve(
            locks: locks,
            calorieTargetKcal: null,
            protein: 150,
            carbs: 200,
          ),
          locks: locks,
        ),
        contains('daily calorie figure to work from'),
      );
    });
  });
}
