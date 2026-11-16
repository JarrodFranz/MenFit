import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/errors/error_messages.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/health/domain/blood_pressure_category.dart';
import 'package:menfit_app/features/health/domain/blood_pressure_reading.dart';
import 'package:menfit_app/features/health/health_providers.dart';
import 'package:menfit_app/features/health/presentation/blood_pressure_chart.dart';
import 'package:menfit_app/features/health/presentation/blood_pressure_copy.dart';
import 'package:menfit_app/features/health/presentation/blood_pressure_dialog.dart';
import 'package:menfit_app/features/health/presentation/blood_pressure_headline.dart';
import 'package:menfit_app/features/health/presentation/blood_pressure_history_list.dart';

class BloodPressureSection extends ConsumerStatefulWidget {
  const BloodPressureSection({super.key});

  @override
  ConsumerState<BloodPressureSection> createState() =>
      _BloodPressureSectionState();
}

class _BloodPressureSectionState extends ConsumerState<BloodPressureSection> {
  BloodPressureRange _range = BloodPressureRange.days90;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppTokens>()!;
    // All readings: the weekly average and the latest-reading line must not
    // depend on the selected range; the range is applied in memory.
    final readings = ref.watch(bloodPressureReadingsProvider());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: tokens.spacingSm,
          runSpacing: tokens.spacingSm,
          children: [
            Text(bpSectionTitle, style: theme.textTheme.titleLarge),
            FilledButton.icon(
              onPressed: () => BloodPressureDialog.show(context),
              icon: const Icon(Icons.add),
              label: const Text(bpAddReading),
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
                onPressed: () => ref.invalidate(bloodPressureReadingsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
          data: _content,
        ),
        SizedBox(height: tokens.spacingMd),
        for (final line in const [
          bpSourceLine,
          bpNotADiagnosis,
          bpSingleReading,
          bpAgeSex,
        ])
          Padding(
            padding: EdgeInsets.only(bottom: tokens.spacingSm),
            child: Text(line, style: theme.textTheme.bodySmall),
          ),
      ],
    );
  }

  Widget _content(List<BloodPressureReading> all) {
    if (all.isEmpty) return const Text(bpEmptyState);
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final today = LocalDate.today();
    final inRange = bloodPressureReadingsInRange(all, _range, today);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BloodPressureHeadline(
          average: bloodPressureWeeklyAverage(all, today),
          daysLogged: bloodPressureDaysLoggedThisWeek(all, today),
        ),
        SizedBox(height: tokens.spacingMd),
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
        BloodPressureChart(readings: inRange),
        SizedBox(height: tokens.spacingMd),
        // Repository order is newest first, so the first row is the latest.
        BloodPressureHistoryList(readings: inRange, latestId: all.first.id),
      ],
    );
  }
}
