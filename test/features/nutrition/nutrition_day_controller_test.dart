import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/nutrition/nutrition_providers.dart';
import 'package:menfit_app/features/streaks/streaks_providers.dart';

void main() {
  test(
    'selected diary day follows local day and go-to-today resets history',
    () async {
      final today = LocalDate(2026, 11, 16);
      final container = ProviderContainer(
        overrides: [
          localDayProvider.overrideWith((ref) => Stream.value(today)),
        ],
      );
      addTearDown(container.dispose);
      container.listen(selectedNutritionDayProvider, (previous, next) {});
      await container.read(localDayProvider.future);
      final controller = container.read(selectedNutritionDayProvider.notifier)
        ..previousDay();
      expect(container.read(selectedNutritionDayProvider), today.addDays(-1));
      controller.goToToday();
      expect(container.read(selectedNutritionDayProvider), today);
      controller.select(today.addDays(5));
      expect(container.read(selectedNutritionDayProvider), today);
    },
  );
}
