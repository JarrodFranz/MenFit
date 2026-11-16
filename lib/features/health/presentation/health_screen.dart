import 'package:flutter/material.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/health/presentation/blood_glucose_section.dart';
import 'package:menfit_app/features/health/presentation/blood_pressure_section.dart';
import 'package:menfit_app/features/health/presentation/watch_vitals_card.dart';

/// `/health` - the Health tab: watch vitals, then the manual blood pressure
/// and blood glucose logs. Composition only; each section owns its state.
class HealthScreen extends StatelessWidget {
  const HealthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Health')),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: tokens.contentMaxWidth),
            // Not a lazy ListView: a section scrolled off-screen would be
            // disposed, resetting its range/unit choice and re-reading the
            // watch.
            child: SingleChildScrollView(
              padding: EdgeInsets.all(tokens.spacingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const WatchVitalsCard(),
                  SizedBox(height: tokens.spacingLg),
                  const BloodPressureSection(),
                  SizedBox(height: tokens.spacingLg),
                  const BloodGlucoseSection(),
                  SizedBox(height: tokens.spacingLg),
                  Text(
                    'MenFit is not a medical device and does not give medical '
                    'advice.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
