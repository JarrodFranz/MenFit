import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/health/domain/blood_pressure_category.dart';
import 'package:menfit_app/features/health/domain/blood_pressure_reading.dart';
import 'package:menfit_app/features/health/presentation/blood_pressure_copy.dart';
import 'package:menfit_app/features/health/presentation/blood_pressure_dialog.dart';
import 'package:menfit_app/features/health/presentation/blood_pressure_headline.dart';

/// Readings newest first; tap to edit. The highest-range / low line sits
/// under the most recent reading overall ([latestId]) when it applies.
class BloodPressureHistoryList extends StatelessWidget {
  const BloodPressureHistoryList({
    required this.readings,
    required this.latestId,
    super.key,
  });

  final List<BloodPressureReading> readings;
  final String? latestId;

  @override
  Widget build(BuildContext context) {
    if (readings.isEmpty) return const Text(bpRangeEmpty);
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final reading in readings)
          Card(
            key: ValueKey(reading.id),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ListTile(
                  title: Text(bloodPressureRowTitle(reading)),
                  subtitle: Text(
                    [
                      DateFormat(
                        'EEE d MMM y, h:mm a',
                      ).format(reading.measuredAt.toLocal()),
                      ?reading.note,
                    ].join('\n'),
                  ),
                  trailing: const Icon(Icons.edit_outlined),
                  onTap: () =>
                      BloodPressureDialog.show(context, existing: reading),
                ),
                if (reading.id == latestId)
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(
                      tokens.spacingMd,
                      0,
                      tokens.spacingMd,
                      tokens.spacingMd,
                    ),
                    child: BloodPressureRangeLines(
                      systolic: reading.systolic,
                      diastolic: reading.diastolic,
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

/// `128/82 mmHg · pulse 64 · High-normal`; no category below the classified
/// range.
String bloodPressureRowTitle(BloodPressureReading r) {
  final category = classifyBloodPressure(r.systolic, r.diastolic);
  return [
    bpValues(r.systolic, r.diastolic),
    if (r.pulse != null) 'pulse ${r.pulse}',
    ?category?.label,
  ].join(' · ');
}
