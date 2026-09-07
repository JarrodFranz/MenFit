import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/core/errors/error_messages.dart';
import 'package:menfit_app/features/nutrition/domain/food_search_region.dart';
import 'package:menfit_app/features/nutrition/nutrition_providers.dart';

/// The Settings row that chooses which country's products a food-database
/// search returns.
///
/// Its own file rather than another hundred lines inside `settings_screen`,
/// which is already long and is the file every settings change touches.
///
/// It reaches the nutrition feature through its **composition surface**
/// (`nutrition_providers.dart`) and the shared **domain** enum, which is the
/// whole of what ADR 007 permits one feature to know about another — no
/// import of nutrition's `data/` or `presentation/`.
///
/// A dropdown rather than a sub-screen or a dialog: seven options with no
/// explanation needed past their names, and the current value has to be
/// readable at a glance because the default is inferred from the device and
/// the user never chose it.
class FoodSearchRegionTile extends ConsumerWidget {
  const FoodSearchRegionTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final region = ref.watch(foodSearchRegionControllerProvider);

    return ListTile(
      leading: const Icon(Icons.public_outlined),
      title: const Text('Food database region'),
      subtitle: const Text(
        'Which country the online food search looks in. Barcode scans are '
        'unaffected.',
      ),
      trailing: DropdownButton<FoodSearchRegion>(
        key: const Key('foodSearchRegionDropdown'),
        value: region,
        // The row's own text carries the meaning; repeating "region" in the
        // control would just be louder.
        underline: const SizedBox.shrink(),
        items: [
          for (final option in FoodSearchRegion.values)
            DropdownMenuItem<FoodSearchRegion>(
              value: option,
              child: Text(option.label),
            ),
        ],
        onChanged: (selected) async {
          if (selected == null || selected == region) return;
          final messenger = ScaffoldMessenger.of(context);
          try {
            await ref
                .read(foodSearchRegionControllerProvider.notifier)
                .setRegion(selected);
          } on Object catch (error) {
            // The controller has already rolled the shown value back, so
            // the row and the message agree: nothing was saved.
            messenger
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(userMessageFor(error)),
                  duration: const Duration(seconds: 3),
                ),
              );
          }
        },
      ),
    );
  }
}
