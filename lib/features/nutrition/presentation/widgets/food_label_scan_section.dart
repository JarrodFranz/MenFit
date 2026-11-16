import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/core/platform/ocr/text_recognition.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/nutrition/domain/label_ocr/parsed_nutrition_label.dart';
import 'package:menfit_app/features/nutrition/presentation/food_form_controller.dart';
import 'package:menfit_app/features/nutrition/presentation/food_form_seed.dart';
import 'package:menfit_app/features/nutrition/presentation/label_scan_fields.dart';
import 'package:menfit_app/features/nutrition/presentation/nutrition_format.dart';

/// "Scan nutrition label" — photograph a printed panel into the form
/// (ADR 012), plus the review banner that appears once one has been.
///
/// **Phones only.** `textRecognitionSupported` is false on Web, Windows,
/// macOS and Linux, where there is no on-device recogniser at all, and this
/// widget renders nothing there. Unlike the barcode field beside it, which
/// stays on every platform because typing digits is a real path, there is
/// no manual equivalent of "read this photo" — so the section is absent
/// rather than disabled, and manual entry (which is the whole rest of this
/// form) is what those platforms use.
class FoodLabelScanSection extends ConsumerWidget {
  const FoodLabelScanSection({required this.seed, super.key});

  final FoodFormSeed? seed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!textRecognitionSupported) return const SizedBox.shrink();

    final tokens = Theme.of(context).extension<AppTokens>()!;
    final state = ref.watch(foodFormControllerProvider(seed));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nutrition label',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(height: tokens.spacingSm),
        OutlinedButton.icon(
          key: const Key('foodLabelScanButton'),
          onPressed: () => _scan(context, ref),
          icon: const Icon(Icons.document_scanner_outlined),
          label: const Text('Scan nutrition label'),
        ),
        SizedBox(height: tokens.spacingSm),
        Text(
          labelScanExplainerText,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        if (state.labelScanApplied) ...[
          SizedBox(height: tokens.spacingMd),
          LabelScanBanner(
            warnings: state.labelWarnings,
            parsedLabel: state.parsedLabel,
            activeBasis: state.activeLabelBasis,
            onSelectBasis: (basis) {
              ref
                  .read(foodFormControllerProvider(seed).notifier)
                  .switchLabelBasis(basis);
            },
          ),
        ],
      ],
    );
  }

  /// Runs the scan and says what happened.
  ///
  /// Every decision is the controller's; this only renders the answer. The
  /// snack bar goes on the **root** messenger for the same reason every
  /// overlay here targets the root navigator
  /// (`architecture_overview.md`) — a branch-level one is clipped above the
  /// navigation bar.
  Future<void> _scan(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final outcome = await ref
        .read(foodFormControllerProvider(seed).notifier)
        .scanLabel();
    final message = labelScanMessageFor(outcome);
    if (message == null) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

/// "Read from a label — check every value before saving", plus whatever
/// the parser and the merge want to say about this particular panel.
///
/// Shown for the rest of the form's life once a scan has landed. ADR 012's
/// review step is not a state the form passes through; it is what these
/// numbers are, until they save them as their own.
class LabelScanBanner extends StatelessWidget {
  const LabelScanBanner({
    required this.warnings,
    this.parsedLabel,
    this.activeBasis,
    this.onSelectBasis,
    super.key,
  });

  final List<String> warnings;
  final ParsedNutritionLabel? parsedLabel;
  final LabelScanBasis? activeBasis;
  final ValueChanged<LabelScanBasis>? onSelectBasis;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final scheme = Theme.of(context).colorScheme;

    final hasBothColumns =
        parsedLabel != null &&
        parsedLabel!.perServing != null &&
        !parsedLabel!.perServing!.isEmpty &&
        parsedLabel!.per100 != null &&
        !parsedLabel!.per100!.isEmpty;
    final is100ml = parsedLabel?.per100?.basis == ColumnBasis.per100ml;
    final servingGrams = parsedLabel?.serving?.grams;

    return Container(
      key: const Key('labelScanBanner'),
      width: double.infinity,
      padding: EdgeInsets.all(tokens.spacingMd),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(tokens.radiusSm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.photo_camera_outlined, color: scheme.onSurfaceVariant),
              SizedBox(width: tokens.spacingSm),
              Expanded(
                child: Text(
                  labelScanBannerText,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
          if (hasBothColumns && onSelectBasis != null) ...[
            SizedBox(height: tokens.spacingSm),
            Text(
              'Nutrition column:',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: tokens.spacingXs),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<LabelScanBasis>(
                key: const Key('labelScanBasisSelector'),
                segments: [
                  ButtonSegment<LabelScanBasis>(
                    value: LabelScanBasis.serving,
                    label: Text(
                      servingGrams != null
                          ? 'Per Serving '
                                '(${formatNutritionField(servingGrams)}g)'
                          : 'Per Serving',
                    ),
                    icon: const Icon(Icons.restaurant_outlined, size: 16),
                  ),
                  ButtonSegment<LabelScanBasis>(
                    value: is100ml
                        ? LabelScanBasis.per100ml
                        : LabelScanBasis.per100g,
                    label: Text(is100ml ? 'Per 100 mL' : 'Per 100 g'),
                    icon: const Icon(Icons.scale_outlined, size: 16),
                  ),
                ],
                selected: {
                  activeBasis ??
                      (servingGrams != null
                          ? LabelScanBasis.serving
                          : (is100ml
                                ? LabelScanBasis.per100ml
                                : LabelScanBasis.per100g)),
                },
                onSelectionChanged: (selected) {
                  if (selected.isNotEmpty) {
                    onSelectBasis!(selected.first);
                  }
                },
              ),
            ),
          ],
          for (final warning in warnings) ...[
            SizedBox(height: tokens.spacingSm),
            Text(
              warning,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}
