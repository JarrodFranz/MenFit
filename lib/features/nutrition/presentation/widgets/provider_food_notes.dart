import 'package:flutter/material.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/nutrition/domain/provider_food.dart';
import 'package:menfit_app/features/nutrition/presentation/food_form_seed.dart';

/// What the food database did and did not say, shown above the review form.
///
/// Three separate things, because they answer different questions and only
/// the first is always present:
///
/// 1. **What the numbers are per** ([ServingBasis]). "Per serving" means
///    three materially different things depending on what the source
///    actually stated, and presenting all three identically would be the
///    quiet dishonesty `domain/provider_food.dart` was shaped to avoid.
/// 2. **That the record carries no nutrition at all**
///    (`ProviderFood.hasNoNutritionData`) — the database asserting there is
///    nothing to have, which is different from us having nothing.
/// 3. **That the record looks thin** — some fields empty, or a low
///    completeness score.
///
/// The third one **informs and does not scold**, and nothing here hides a
/// result: a sparse record means nobody has filled the product in yet, not
/// that the food is deficient in anything. That is a statement about the
/// database, and the copy says so.
class ProviderFoodNotes extends StatelessWidget {
  const ProviderFoodNotes({required this.seed, super.key});

  final FoodFormSeed seed;

  /// Below this the provider's own 0–1 record score is worth mentioning.
  /// A round number, not a threshold with meaning — it only decides
  /// whether a sentence appears.
  static const double _thinRecordScore = 0.5;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final completeness = seed.completeness;
    final looksThin =
        !seed.hasCompleteMacros ||
        (completeness != null && completeness < _thinRecordScore);

    final lines = <String>[
      if (seed.servingBasis != null) _basisLine(seed.servingBasis!),
      if (seed.hasNoNutritionData) _noDataLine,
      if (looksThin && !seed.hasNoNutritionData) _thinRecordLine,
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(tokens.spacingMd),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(tokens.radiusSm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final line in lines) ...[
            Text(line, style: textTheme.bodyMedium),
            if (line != lines.last) SizedBox(height: tokens.spacingSm),
          ],
        ],
      ),
    );
  }
}

/// Says what the numbers below are *per*, in the user's terms.
String _basisLine(ServingBasis basis) => switch (basis) {
  ServingBasis.statedPerServing =>
    'These figures are the ones stated for one serving.',
  ServingBasis.derivedFromPer100g =>
    'These figures were worked out from the per-100 g values and the '
        'serving weight, so they are only as good as that weight.',
  ServingBasis.per100g =>
    'These figures are per 100 g — there was no serving size to work '
        'from. Change the serving below if the packet gives one.',
  ServingBasis.per100ml =>
    'These figures are per 100 ml — there was no serving size to work '
        'from. Change the serving below if the packet gives one.',
};

const String _noDataLine =
    'This product has no nutrition information recorded. Whatever the '
    'packet says can go in below.';

/// Non-judgemental by construction: it describes the *record*, and names
/// the reason a field is empty so an empty field is not read as a zero.
const String _thinRecordLine =
    'Parts of this record are empty. That means nobody has filled them in '
    'yet, not that the food has none — worth checking against the packet.';
