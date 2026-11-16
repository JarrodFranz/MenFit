import 'package:flutter/material.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/health/domain/blood_pressure_category.dart';
import 'package:menfit_app/features/health/presentation/blood_pressure_copy.dart';

/// The 7-day-average headline, or the "n of 5" hint until there is one.
class BloodPressureHeadline extends StatelessWidget {
  const BloodPressureHeadline({
    required this.average,
    required this.daysLogged,
    super.key,
  });

  final BloodPressureWeeklyAverage? average;
  final int daysLogged;

  @override
  Widget build(BuildContext context) {
    final average = this.average;
    if (average == null) return Text(bpWeeklyHint(daysLogged));
    final theme = Theme.of(context);
    final tokens = theme.extension<AppTokens>()!;
    final category = average.category;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(bpWeeklyAverageTitle, style: theme.textTheme.titleSmall),
        Text(
          bpValues(average.systolic, average.diastolic),
          style: theme.textTheme.headlineSmall,
        ),
        if (category != null) Text(category.label),
        Text(
          bpWeeklyBasis(average.readingCount, average.daysWithReadings),
          style: theme.textTheme.bodySmall,
        ),
        if (average.showHomeThresholdNote) ...[
          SizedBox(height: tokens.spacingXs),
          const Text(bpHomeNote),
        ],
        BloodPressureRangeLines(
          systolic: average.systolic,
          diastolic: average.diastolic,
          highestText: bpAverageHighestRangeLine,
          lowText: bpAverageLowLine,
        ),
      ],
    );
  }
}

/// The highest-range or low line for a value pair; empty when neither
/// applies. Conveyed by text and an icon, never by colour.
class BloodPressureRangeLines extends StatelessWidget {
  const BloodPressureRangeLines({
    required this.systolic,
    required this.diastolic,
    this.highestText = bpHighestRangeLine,
    this.lowText = bpLowLine,
    super.key,
  });

  final num systolic;
  final num diastolic;
  final String highestText;
  final String lowText;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    Widget line(String text) => Padding(
      padding: EdgeInsets.only(top: tokens.spacingSm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ExcludeSemantics(child: Icon(Icons.info_outline)),
          SizedBox(width: tokens.spacingSm),
          Expanded(child: Text(text)),
        ],
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isHighestRange(systolic, diastolic)) line(highestText),
        if (isBelowClassifiedRange(systolic, diastolic)) line(lowText),
      ],
    );
  }
}
