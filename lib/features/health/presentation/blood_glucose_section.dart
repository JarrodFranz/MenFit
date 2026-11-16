import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/errors/error_messages.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/health/domain/blood_marker_reading.dart';
import 'package:menfit_app/features/health/domain/blood_marker_reference.dart';
import 'package:menfit_app/features/health/domain/blood_pressure_category.dart';
import 'package:menfit_app/features/health/health_providers.dart';
import 'package:menfit_app/features/health/presentation/blood_glucose_history_list.dart';
import 'package:menfit_app/features/health/presentation/blood_glucose_reference_block.dart';
import 'package:menfit_app/features/health/presentation/blood_marker_chart.dart';
import 'package:menfit_app/features/health/presentation/blood_marker_copy.dart';
import 'package:menfit_app/features/health/presentation/blood_marker_dialog.dart';
import 'package:menfit_app/features/health/presentation/blood_pressure_copy.dart'
    show BloodPressureRangeLabel;

class BloodGlucoseSection extends ConsumerStatefulWidget {
  const BloodGlucoseSection({super.key});

  @override
  ConsumerState<BloodGlucoseSection> createState() =>
      _BloodGlucoseSectionState();
}

class _BloodGlucoseSectionState extends ConsumerState<BloodGlucoseSection> {
  BloodPressureRange _range = BloodPressureRange.days90;

  /// Null follows the most recent reading's unit.
  BloodMarkerUnit? _chosenUnit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppTokens>()!;
    final provider = bloodMarkerReadingsProvider(BloodMarker.glucose);
    final readings = ref.watch(provider);
    // Repository order is newest first.
    final latestUnit = readings.value?.firstOrNull?.unit;
    final unit = _chosenUnit ?? latestUnit ?? BloodMarkerUnit.mmolPerL;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: tokens.spacingSm,
          runSpacing: tokens.spacingSm,
          children: [
            Text(glucoseSectionTitle, style: theme.textTheme.titleLarge),
            FilledButton.icon(
              onPressed: () => BloodMarkerDialog.show(
                context,
                defaultUnit: latestUnit ?? BloodMarkerUnit.mmolPerL,
              ),
              icon: const Icon(Icons.add),
              label: const Text(glucoseAddReading),
            ),
          ],
        ),
        SizedBox(height: tokens.spacingSm),
        readings.when(
          loading: () => const LinearProgressIndicator(),
          error: (error, _) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(userMessageFor(error)),
              TextButton(
                onPressed: () => ref.invalidate(provider),
                child: const Text('Retry'),
              ),
            ],
          ),
          data: (all) => _content(all, unit),
        ),
        SizedBox(height: tokens.spacingMd),
        BloodGlucoseReferenceBlock(unit: unit),
      ],
    );
  }

  Widget _content(List<BloodMarkerReading> all, BloodMarkerUnit unit) {
    if (all.isEmpty) return const Text(glucoseEmptyState);
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final inRange = bloodMarkerReadingsInRange(
      all,
      _range,
      LocalDate.today(),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: tokens.spacingSm,
          runSpacing: tokens.spacingXs,
          children: [
            for (final option in BloodMarker.glucose.units)
              ChoiceChip(
                label: Text(option.label),
                selected: option == unit,
                onSelected: (_) => setState(() => _chosenUnit = option),
              ),
          ],
        ),
        SizedBox(height: tokens.spacingXs),
        Wrap(
          spacing: tokens.spacingSm,
          runSpacing: tokens.spacingXs,
          children: [
            for (final range in BloodPressureRange.values)
              ChoiceChip(
                label: Text(range.label),
                selected: range == _range,
                onSelected: (_) => setState(() => _range = range),
              ),
          ],
        ),
        SizedBox(height: tokens.spacingSm),
        BloodMarkerChart(readings: inRange, unit: unit),
        SizedBox(height: tokens.spacingMd),
        BloodGlucoseHistoryList(readings: inRange, latestId: all.first.id),
      ],
    );
  }
}
