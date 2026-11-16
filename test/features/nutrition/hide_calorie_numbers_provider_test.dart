import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_goals.dart';
import 'package:menfit_app/features/nutrition/nutrition_providers.dart';

/// The four states of `nutritionGoalsProvider` the shared hide-calories gate
/// has to answer for. The one that matters most is the first: the goals row
/// arrives over a Drift stream, so *every* cold start passes through
/// `AsyncLoading`, and a gate that fails open there flashes kcal figures at a
/// user who asked never to see one
/// (`knowledge/research/energy_expenditure_estimates.md` §7.4).
void main() {
  final now = DateTime.utc(2026, 9, 17);

  NutritionGoals goals({required bool hideCalorieNumbers}) => NutritionGoals(
    id: 'goals-1',
    createdAt: now,
    updatedAt: now,
    hideCalorieNumbers: hideCalorieNumbers,
  );

  /// Lets the overridden stream's pending event reach the provider.
  Future<void> settle() => Future<void>.delayed(Duration.zero);

  ProviderContainer containerFor(Stream<NutritionGoals?> stream) {
    final container = ProviderContainer(
      overrides: [nutritionGoalsProvider.overrideWith((ref) => stream)],
    );
    addTearDown(container.dispose);
    // Keeps the autoDispose gate alive between reads.
    container.listen(hideCalorieNumbersProvider, (previous, next) {});
    return container;
  }

  test('hides while the goals row has not loaded yet', () async {
    final controller = StreamController<NutritionGoals?>();
    addTearDown(controller.close);
    final container = containerFor(controller.stream);

    await settle();

    expect(container.read(hideCalorieNumbersProvider), isTrue);
  });

  test('hides when the goals stream errors before emitting anything', () async {
    final container = containerFor(
      Stream<NutritionGoals?>.error(StateError('goals unavailable')),
    );

    await settle();

    expect(container.read(hideCalorieNumbersProvider), isTrue);
  });

  test('shows when there is no goals row at all — a resolved answer', () async {
    final container = containerFor(Stream<NutritionGoals?>.value(null));

    await settle();

    expect(container.read(hideCalorieNumbersProvider), isFalse);
  });

  test('follows the saved preference once the row arrives', () async {
    final on = containerFor(
      Stream<NutritionGoals?>.value(goals(hideCalorieNumbers: true)),
    );
    final off = containerFor(
      Stream<NutritionGoals?>.value(goals(hideCalorieNumbers: false)),
    );

    await settle();

    expect(on.read(hideCalorieNumbersProvider), isTrue);
    expect(off.read(hideCalorieNumbersProvider), isFalse);
  });

  test(
    'keeps the last known flag when the stream errors after a value',
    () async {
      final controller = StreamController<NutritionGoals?>();
      addTearDown(controller.close);
      final container = containerFor(controller.stream);

      controller.add(goals(hideCalorieNumbers: true));
      await settle();
      expect(container.read(hideCalorieNumbersProvider), isTrue);

      controller.addError(StateError('goals query failed'));
      await settle();

      // Not "unknown, therefore hide" and not "error, therefore show": the
      // preference she saved is still the last thing this app was told, and
      // `hasValue` stays true across the error — which is also what keeps a
      // background refresh from blinking the figures off and on again.
      expect(container.read(hideCalorieNumbersProvider), isTrue);
    },
  );

  test(
    'a value that arrives with the flag off turns the figures back on',
    () async {
      final controller = StreamController<NutritionGoals?>();
      addTearDown(controller.close);
      final container = containerFor(controller.stream);

      expect(container.read(hideCalorieNumbersProvider), isTrue);

      controller.add(goals(hideCalorieNumbers: false));
      await settle();

      expect(container.read(hideCalorieNumbersProvider), isFalse);
    },
  );
}
