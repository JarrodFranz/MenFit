import 'package:flutter/material.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/health/domain/blood_marker_reading.dart';
import 'package:menfit_app/features/health/presentation/blood_marker_copy.dart';

/// Always-visible "Reference ranges" block: both range lines in [unit], then
/// source, scope, not-a-diagnosis and meter lines.
class BloodGlucoseReferenceBlock extends StatelessWidget {
  const BloodGlucoseReferenceBlock({required this.unit, super.key});

  final BloodMarkerUnit unit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppTokens>()!;
    Widget line(String text, [TextStyle? style]) => Padding(
      padding: EdgeInsets.only(bottom: tokens.spacingSm),
      child: Text(text, style: style),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text(glucoseReferenceTitle, style: theme.textTheme.titleSmall),
        ),
        SizedBox(height: tokens.spacingXs),
        for (final text in glucoseRangeLines(unit)) line(text),
        for (final text in const [
          glucoseSourceLine,
          glucoseScopeLine,
          glucoseNotADiagnosis,
          glucoseMeterLine,
        ])
          line(text, theme.textTheme.bodySmall),
      ],
    );
  }
}
