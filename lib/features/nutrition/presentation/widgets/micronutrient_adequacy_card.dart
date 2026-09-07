import 'package:flutter/material.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/cycle/domain/cycle_prediction_engine.dart';
import 'package:menfit_app/features/nutrition/domain/micronutrient_adequacy.dart';
import 'package:menfit_app/features/nutrition/presentation/widgets/micronutrient_info_sheet.dart';

/// Card presenting female-specific micronutrient adequacy against biological
/// reference intakes (DRIs/RDAs) with cycle-phase context and honesty flags.
class MicronutrientAdequacyCard extends StatefulWidget {
  const MicronutrientAdequacyCard({
    required this.items,
    this.cyclePhase,
    this.isMultiDay = false,
    super.key,
  });

  final List<MicronutrientAdequacyItem> items;
  final CyclePhase? cyclePhase;
  final bool isMultiDay;

  @override
  State<MicronutrientAdequacyCard> createState() =>
      _MicronutrientAdequacyCardState();
}

class _MicronutrientAdequacyCardState extends State<MicronutrientAdequacyCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final primaryItems = widget.items.where((i) {
      return i.type == MicronutrientType.iron ||
          i.type == MicronutrientType.calcium ||
          i.type == MicronutrientType.vitaminD;
    }).toList();

    final secondaryItems = widget.items.where((i) {
      return i.type == MicronutrientType.fiber ||
          i.type == MicronutrientType.vitaminC;
    }).toList();

    final isMenstrual = widget.cyclePhase == CyclePhase.menstrual;

    return Card(
      key: const Key('micronutrientAdequacyCard'),
      child: Padding(
        padding: EdgeInsets.all(tokens.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.isMultiDay
                            ? 'Daily Average Micronutrients'
                            : 'Micronutrient Adequacy',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Biological reference benchmarks',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  key: const Key('micronutrientInfoButton'),
                  icon: const Icon(Icons.info_outline, size: 20),
                  tooltip: 'About female micronutrient benchmarks',
                  onPressed: () => MicronutrientInfoSheet.show(context),
                ),
              ],
            ),
            if (isMenstrual) ...[
              SizedBox(height: tokens.spacingSm),
              Container(
                key: const Key('menstrualPhaseNutrientBanner'),
                padding: EdgeInsets.symmetric(
                  horizontal: tokens.spacingSm,
                  vertical: tokens.spacingXs,
                ),
                decoration: BoxDecoration(
                  color: tokens.cyclePhaseMenstrual.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: tokens.cyclePhaseMenstrual.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.water_drop_outlined,
                      size: 16,
                      color: tokens.cyclePhaseMenstrual,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Menstrual phase: iron intake is elevated to '
                        'replace menstrual losses.',
                        style: textTheme.bodySmall?.copyWith(
                          color: tokens.cyclePhaseMenstrual,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            SizedBox(height: tokens.spacingMd),
            for (final item in primaryItems) ...[
              _NutrientAdequacyRow(item: item),
              SizedBox(height: tokens.spacingMd),
            ],
            if (secondaryItems.isNotEmpty) ...[
              if (_expanded)
                for (final item in secondaryItems) ...[
                  _NutrientAdequacyRow(item: item),
                  SizedBox(height: tokens.spacingMd),
                ],
              Center(
                child: TextButton.icon(
                  key: const Key('toggleMoreNutrientsButton'),
                  icon: Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 18,
                  ),
                  label: Text(
                    _expanded ? 'Show fewer nutrients' : 'Show more nutrients',
                  ),
                  onPressed: () => setState(() => _expanded = !_expanded),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NutrientAdequacyRow extends StatelessWidget {
  const _NutrientAdequacyRow({required this.item});

  final MicronutrientAdequacyItem item;

  Color _progressColor(MicronutrientType type, ColorScheme scheme) {
    return switch (type) {
      MicronutrientType.iron => scheme.primary,
      MicronutrientType.calcium => Colors.teal,
      MicronutrientType.vitaminD => Colors.amber.shade700,
      MicronutrientType.fiber => Colors.lightGreen.shade700,
      MicronutrientType.vitaminC => Colors.deepOrangeAccent,
    };
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final color = _progressColor(item.type, colorScheme);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  item.type.label,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (item.isPartial) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Partial floor',
                      style: textTheme.labelSmall?.copyWith(
                        fontSize: 10,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            Text(
              item.hasLoggedValue
                  ? '${item.formattedLogged} / ${item.formattedReference}'
                  : 'Not listed',
              style: textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: item.hasLoggedValue
                    ? colorScheme.onSurface
                    : colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: item.progress,
            minHeight: 6,
            backgroundColor: colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          item.statusMessage,
          style: textTheme.bodySmall?.copyWith(
            fontSize: 11,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
