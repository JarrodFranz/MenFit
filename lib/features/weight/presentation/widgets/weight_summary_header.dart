import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/domain/units.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/weight/domain/weight_log.dart';
import 'package:menfit_app/features/weight/domain/weight_trend.dart';
import 'package:menfit_app/features/weight/presentation/weight_copy.dart';
import 'package:menfit_app/features/weight/presentation/weight_format.dart';

/// The two facts above the chart: the most recent reading, and which way
/// the smoothed line is going.
///
/// What it deliberately does **not** show is how far the line moved. The
/// domain computes that figure ([WeightTrendSeries.trendChangeKg]) and the
/// UI leaves it there: a running "-1.4 kg since June" next to a body-weight
/// chart is a scoreboard, and a scoreboard is what
/// `knowledge/domain/womens_health.md` rules out. Direction answers "is
/// the fluctuation I'm seeing actually a trend?", which is the question
/// this feature is for; magnitude only invites keeping score.
///
/// The direction text is rendered in [ColorScheme.onSurfaceVariant]
/// whichever way it points — no colour ever encodes which direction the
/// number went.
class WeightSummaryHeader extends StatelessWidget {
  const WeightSummaryHeader({
    required this.latest,
    required this.direction,
    required this.unitSystem,
    super.key,
  });

  final WeightLog? latest;
  final WeightTrendDirection direction;
  final UnitSystem unitSystem;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final reading = latest;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (reading != null) ...[
          Text(
            weightLatestLabel,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            formatWeight(reading.weightKg, unitSystem),
            style: textTheme.headlineSmall,
          ),
          Text(
            _longDate(reading.day),
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: tokens.spacingXs),
        ],
        Text(
          weightTrendSentence(direction),
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

String _longDate(LocalDate day) =>
    DateFormat('EEE d MMM y').format(DateTime(day.year, day.month, day.day));
