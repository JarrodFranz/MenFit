import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/health/domain/blood_marker_reading.dart';
import 'package:menfit_app/features/health/domain/blood_marker_reference.dart';
import 'package:menfit_app/features/health/presentation/blood_marker_copy.dart';
import 'package:menfit_app/features/health/presentation/blood_marker_dialog.dart';

/// Glucose readings newest first, each in the unit it was entered in; tap to
/// edit. The above / low / no-range lines sit under the most recent reading
/// overall ([latestId]).
class BloodGlucoseHistoryList extends StatelessWidget {
  const BloodGlucoseHistoryList({
    required this.readings,
    required this.latestId,
    super.key,
  });

  final List<BloodMarkerReading> readings;
  final String? latestId;

  @override
  Widget build(BuildContext context) {
    if (readings.isEmpty) return const Text(glucoseRangeEmpty);
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
                  title: Text(bloodGlucoseRowTitle(reading)),
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
                      BloodMarkerDialog.show(context, existing: reading),
                ),
                if (reading.id == latestId)
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(
                      tokens.spacingMd,
                      0,
                      tokens.spacingMd,
                      tokens.spacingMd,
                    ),
                    child: BloodGlucoseReadingLines(reading: reading),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

/// `5.2 mmol/L · Fasting · Within the reference range`; the position only
/// when the row's context has a reviewed range.
String bloodGlucoseRowTitle(BloodMarkerReading r) => [
  glucoseValue(r.value, r.unit),
  ?r.context?.label,
  ?positionOf(r)?.label,
].join(' · ');

/// The lines that apply to one reading: below (with the urgent line), above,
/// or "no reference range". Conveyed by text and an icon, never by colour.
class BloodGlucoseReadingLines extends StatelessWidget {
  const BloodGlucoseReadingLines({required this.reading, super.key});

  final BloodMarkerReading reading;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final position = positionOf(reading);
    final lines = [
      if (position == null) glucoseNoRange,
      if (isLowGlucose(reading.value, reading.unit)) ...const [
        glucoseBelowLine,
        glucoseUrgentLine,
      ] else if (position == ReferencePosition.above)
        glucoseAboveLine,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final text in lines)
          Padding(
            padding: EdgeInsets.only(top: tokens.spacingSm),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ExcludeSemantics(child: Icon(Icons.info_outline)),
                SizedBox(width: tokens.spacingSm),
                Expanded(child: Text(text)),
              ],
            ),
          ),
      ],
    );
  }
}
