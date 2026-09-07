import 'package:flutter/material.dart';
import 'package:menfit_app/core/theme/tokens.dart';

/// Says a read of wellbeing data failed, rather than letting the failure
/// read as an absence.
///
/// "Nothing logged" is a claim about their records; a `StorageException`
/// swallowed into an empty list makes the app state that claim about data
/// it never managed to look at. For S3 health data that is the wrong
/// silence to keep.
///
/// Deliberately a one-line row alongside the content rather than a
/// replacement for it: on the calendar the dates are still correct and
/// still tappable and only the markers are unknown, and in the day sheet
/// the sections that did load are still worth showing.
class WellbeingLoadFailure extends StatelessWidget {
  const WellbeingLoadFailure({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppTokens>()!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.error_outline, size: 16, color: theme.colorScheme.error),
        SizedBox(width: tokens.spacingXs),
        Flexible(
          child: Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ),
      ],
    );
  }
}
