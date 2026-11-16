import 'package:menfit_app/features/nutrition/domain/provider_food.dart';
import 'package:menfit_app/features/nutrition/presentation/nutrition_format.dart';
import 'package:meta/meta.dart';

/// What one online search result row shows: the basis line, and the three
/// macro figures **already put on that basis**.
///
/// A separate value with a pure function behind it because getting this
/// wrong is invisible. A per-100 g figure rendered where a per-serving one
/// belongs is out by `servingGrams / 100` — exactly 1 for a 100 g serving,
/// 6.8 for a 680 g one — and no screenshot shows which of those happened.
@immutable
class OnlineResultDisplay {
  const OnlineResultDisplay({
    required this.basisLine,
    this.proteinGrams,
    this.carbsGrams,
    this.fatGrams,
  });

  /// The line above the macros: `'Serving: 1 serving (710 ml) · 160 kcal'`,
  /// `'Per 100 g · 389 kcal'`, or the same without the energy figure when
  /// calorie numbers are hidden.
  final String basisLine;

  /// Protein on the basis [basisLine] names, or `null` when unstated —
  /// never `0` (`domain/provider_food.dart`).
  final double? proteinGrams;

  /// Carbohydrate on the basis [basisLine] names, or `null`.
  final double? carbsGrams;

  /// Fat on the basis [basisLine] names, or `null`.
  final double? fatGrams;

  /// The macros as the result row prints them.
  String get macroLine => formatPer100gMacroLine(
    proteinGrams: proteinGrams,
    carbsGrams: carbsGrams,
    fatGrams: fatGrams,
  );
}

/// Decides what a result row says, from the summary alone.
///
/// [ProviderFoodSummary.macroBasis] is the authority — the numbers are per
/// 100 g, per 100 ml or per the stated serving, and only the summary knows
/// which. A serving is shown whenever there is a size to scale to; otherwise
/// the row says "per 100 g"/"per 100 ml" out loud rather than implying a
/// serving it cannot compute.
OnlineResultDisplay resolveOnlineResultDisplay(
  ProviderFoodSummary summary, {
  required bool hideCalorieNumbers,
}) {
  final description = _servingDescription(summary);
  final isPer100Description = description == null || _isPer100(description);

  // A row must always name a serving it can print. An unnamed one is "1
  // serving" — the same words the mappers write for a bare serving — never a
  // literal `null` and never a per-100 claim (see the [SummaryMacroBasis]
  // case below).
  final servingText = description ?? '1 serving';

  String servingLine(double? kcal) => hideCalorieNumbers
      ? 'Serving: $servingText'
      : 'Serving: $servingText · ${formatOptionalKcal(kcal)}';

  String per100Line(String unit) {
    final head = 'Per 100 $unit';
    final withEnergy = hideCalorieNumbers
        ? head
        : '$head · ${formatOptionalKcal(summary.caloriesKcal)}';
    // The serving the provider named is worth keeping in view even when the
    // numbers cannot be put on it — it is what the user will be asked to
    // confirm on the next screen.
    return isPer100Description ? withEnergy : '$withEnergy ($description)';
  }

  switch (summary.macroBasis) {
    case SummaryMacroBasis.perServing:
      final kcal = summary.servingCaloriesKcal ?? summary.caloriesKcal;
      // These figures are per serving and undivided. Saying "Per 100 g"
      // over them is the exact mislabel this basis exists to prevent, so
      // only a description that literally *is* a per-100 portion earns the
      // per-100 line; an unnamed serving stays a serving.
      final describesPer100 = description != null && _isPer100(description);
      return OnlineResultDisplay(
        basisLine: describesPer100
            ? per100Line(_isPer100Ml(description) ? 'ml' : 'g')
            : servingLine(kcal),
        proteinGrams: summary.proteinGrams,
        carbsGrams: summary.carbsGrams,
        fatGrams: summary.fatGrams,
      );

    case SummaryMacroBasis.per100g:
      return _scaled(
        summary,
        description: description,
        isPer100Description: isPer100Description,
        size: summary.servingGrams,
        unit: 'g',
        servingLine: servingLine,
        per100Line: per100Line,
      );

    case SummaryMacroBasis.per100ml:
      return _scaled(
        summary,
        description: description,
        isPer100Description: isPer100Description,
        size: summary.servingVolumeMl,
        unit: 'ml',
        servingLine: servingLine,
        per100Line: per100Line,
      );
  }
}

/// The per-100 case, for either unit: scale to the serving when its size is
/// known, and say "per 100" when it is not.
OnlineResultDisplay _scaled(
  ProviderFoodSummary summary, {
  required String? description,
  required bool isPer100Description,
  required double? size,
  required String unit,
  required String Function(double? kcal) servingLine,
  required String Function(String unit) per100Line,
}) {
  final hasSize = size != null && size > 0;
  if (isPer100Description || !hasSize) {
    return OnlineResultDisplay(
      basisLine: per100Line(unit),
      proteinGrams: summary.proteinGrams,
      carbsGrams: summary.carbsGrams,
      fatGrams: summary.fatGrams,
    );
  }

  final scale = size / 100;
  final kcal =
      summary.servingCaloriesKcal ??
      (summary.caloriesKcal == null ? null : summary.caloriesKcal! * scale);
  return OnlineResultDisplay(
    basisLine: servingLine(kcal),
    proteinGrams: summary.proteinGrams == null
        ? null
        : summary.proteinGrams! * scale,
    carbsGrams: summary.carbsGrams == null ? null : summary.carbsGrams! * scale,
    fatGrams: summary.fatGrams == null ? null : summary.fatGrams! * scale,
  );
}

/// The description a row shows, with a size added to a bare "1 serving".
///
/// Volume wins over mass when both are known: a drink is sold in
/// millilitres, and "1 serving (710 ml)" is what is printed on the cup even
/// though the record also knows it weighs 680 g.
String? _servingDescription(ProviderFoodSummary summary) {
  final raw = summary.servingDescription;
  if (raw == null) return null;
  if (!_isGenericServing(raw)) return raw;

  final volumeMl = summary.servingVolumeMl;
  if (volumeMl != null && volumeMl > 0) {
    return '1 serving (${_formatAmount(volumeMl)} ml)';
  }
  final grams = summary.servingGrams;
  if (grams != null && grams > 0) {
    return '1 serving (${_formatAmount(grams)} g)';
  }
  return raw;
}

bool _isGenericServing(String description) =>
    description.toLowerCase().trim() == '1 serving' ||
    description.toLowerCase().trim() == 'serving';

bool _isPer100(String description) =>
    _isPer100G(description) || _isPer100Ml(description);

bool _isPer100G(String description) {
  final normalised = description.toLowerCase().trim();
  return normalised == '100 g' || normalised == '100g';
}

bool _isPer100Ml(String? description) {
  if (description == null) return false;
  final normalised = description.toLowerCase().trim();
  return normalised == '100 ml' || normalised == '100ml';
}

/// Whole units, matching how the mappers write a serving size.
String _formatAmount(double amount) {
  final rounded = amount.roundToDouble();
  if (rounded == amount || rounded >= 1) return rounded.toStringAsFixed(0);
  return amount.toStringAsFixed(1);
}
