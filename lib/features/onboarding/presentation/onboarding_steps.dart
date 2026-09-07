import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/domain/units.dart';
import 'package:menfit_app/core/domain/weekday.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/core/widgets/single_choice_chips.dart';
import 'package:menfit_app/features/onboarding/presentation/onboarding_controller.dart';
import 'package:menfit_app/features/profile/domain/profile_validation.dart';
import 'package:menfit_app/features/profile/domain/user_profile.dart';
import 'package:menfit_app/features/profile/presentation/widgets/weekday_toggle_row.dart';

/// Step 1: what the app is for.
class WelcomeStep extends StatelessWidget {
  const WelcomeStep({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/menfit_logo.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => ColoredBox(
                    color: colorScheme.primary,
                    child: const Icon(
                      Icons.directions_run,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: tokens.spacingLg),
            Text(
              'Welcome to MenFit',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: tokens.spacingMd),
            Text(
              'A training and nutrition companion built around how men '
              'actually train, recover and progress.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}

/// Step 2: display name (required), unit system, and optional measurements.
class AboutYouStep extends ConsumerStatefulWidget {
  const AboutYouStep({super.key});

  @override
  ConsumerState<AboutYouStep> createState() => _AboutYouStepState();
}

class _AboutYouStepState extends ConsumerState<AboutYouStep> {
  late final TextEditingController _nameController;
  late final TextEditingController _heightController;
  late final TextEditingController _heightInchesController;
  late final TextEditingController _weightController;

  @override
  void initState() {
    super.initState();
    final state = ref.read(onboardingControllerProvider);
    _nameController = TextEditingController(text: state.displayName);
    _heightController = TextEditingController();
    _heightInchesController = TextEditingController();
    _weightController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _heightController.dispose();
    _heightInchesController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _onHeightChanged() {
    final state = ref.read(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);
    double? cm;
    if (state.unitSystem == UnitSystem.imperial) {
      final feet = double.tryParse(_heightController.text)?.floor();
      final inches = double.tryParse(_heightInchesController.text);
      if (_heightController.text.trim().isNotEmpty ||
          _heightInchesController.text.trim().isNotEmpty) {
        cm = UnitConversions.feetInchesToCm(feet ?? 0, inches ?? 0);
      }
    } else {
      final val = double.tryParse(_heightController.text);
      if (_heightController.text.trim().isNotEmpty) {
        cm = val;
      }
    }
    if (cm == null) {
      controller.updateHeight(null);
      return;
    }
    final validation = validateProfileFields(
      today: LocalDate.today(),
      heightCm: cm,
      unitSystem: state.unitSystem,
    );
    controller.updateHeight(cm, error: validation.heightError);
  }

  void _onWeightChanged() {
    final state = ref.read(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);
    final text = _weightController.text.trim();
    if (text.isEmpty) {
      controller.updateWeight(null);
      return;
    }
    final val = double.tryParse(text);
    if (val == null) {
      controller.updateWeight(null, error: 'Enter a valid number');
      return;
    }
    final kg = state.unitSystem == UnitSystem.imperial
        ? UnitConversions.lbToKg(val)
        : val;
    final validation = validateProfileFields(
      today: LocalDate.today(),
      weightKg: kg,
      unitSystem: state.unitSystem,
    );
    controller.updateWeight(kg, error: validation.weightError);
  }

  Future<void> _pickDateOfBirth(BuildContext context) async {
    final state = ref.read(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);
    final now = DateTime.now();
    final initialDate = state.dateOfBirth != null
        ? DateTime(
            state.dateOfBirth!.year,
            state.dateOfBirth!.month,
            state.dateOfBirth!.day,
          )
        : DateTime(now.year - 25, now.month, now.day);

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) {
      controller.updateDateOfBirth(LocalDate.fromDateTime(picked));
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final state = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('About you', style: Theme.of(context).textTheme.headlineSmall),
          SizedBox(height: tokens.spacingLg),
          TextField(
            key: const Key('onboardingNameField'),
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Display name',
              border: const OutlineInputBorder(),
              errorText: state.displayNameError,
            ),
            textInputAction: TextInputAction.done,
            onChanged: controller.updateDisplayName,
          ),
          SizedBox(height: tokens.spacingLg),
          Text('Units', style: Theme.of(context).textTheme.titleMedium),
          SizedBox(height: tokens.spacingSm),
          SegmentedButton<UnitSystem>(
            segments: const [
              ButtonSegment(value: UnitSystem.metric, label: Text('Metric')),
              ButtonSegment(
                value: UnitSystem.imperial,
                label: Text('Imperial'),
              ),
            ],
            selected: {state.unitSystem},
            onSelectionChanged: (selection) {
              controller.updateUnitSystem(selection.first);
              _heightController.clear();
              _heightInchesController.clear();
              _weightController.clear();
              controller
                ..updateHeight(null)
                ..updateWeight(null);
            },
          ),
          SizedBox(height: tokens.spacingLg),
          ExpansionTile(
            key: const Key('onboardingOptionalMeasurementsTile'),
            title: const Text('Optional: Height, weight & birthday'),
            subtitle: const Text(
              'Used to estimate calories and pace targets.',
            ),
            childrenPadding: EdgeInsets.only(
              top: tokens.spacingSm,
              bottom: tokens.spacingMd,
            ),
            children: [
              InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date of birth (optional)',
                  border: OutlineInputBorder(),
                ),
                child: InkWell(
                  key: const Key('onboardingDobField'),
                  onTap: () => _pickDateOfBirth(context),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        state.dateOfBirth == null
                            ? 'Not set'
                            : DateFormat.yMMMd().format(
                                DateTime(
                                  state.dateOfBirth!.year,
                                  state.dateOfBirth!.month,
                                  state.dateOfBirth!.day,
                                ),
                              ),
                      ),
                      const Icon(Icons.calendar_today, size: 18),
                    ],
                  ),
                ),
              ),
              SizedBox(height: tokens.spacingMd),
              if (state.unitSystem == UnitSystem.imperial)
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        key: const Key('onboardingHeightFeetField'),
                        controller: _heightController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          labelText: 'Height (ft)',
                          suffixText: 'ft',
                          border: const OutlineInputBorder(),
                          errorText: state.heightError,
                        ),
                        onChanged: (_) => _onHeightChanged(),
                      ),
                    ),
                    SizedBox(width: tokens.spacingSm),
                    Expanded(
                      child: TextField(
                        key: const Key('onboardingHeightInchesField'),
                        controller: _heightInchesController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Height (in)',
                          suffixText: 'in',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (_) => _onHeightChanged(),
                      ),
                    ),
                  ],
                )
              else
                TextField(
                  key: const Key('onboardingHeightField'),
                  controller: _heightController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Height (cm)',
                    suffixText: 'cm',
                    border: const OutlineInputBorder(),
                    errorText: state.heightError,
                  ),
                  onChanged: (_) => _onHeightChanged(),
                ),
              SizedBox(height: tokens.spacingMd),
              TextField(
                key: const Key('onboardingWeightField'),
                controller: _weightController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: 'Weight',
                  suffixText: state.unitSystem == UnitSystem.imperial
                      ? 'lb'
                      : 'kg',
                  border: const OutlineInputBorder(),
                  errorText: state.weightError,
                ),
                onChanged: (_) => _onWeightChanged(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Step 3 (optional, index [moreAboutYouStepIndex]): fitness goals,
/// exercise goal, and training preferences.
class MoreAboutYouStep extends ConsumerWidget {
  const MoreAboutYouStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final state = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tell us a little more',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          SizedBox(height: tokens.spacingXs),
          Text(
            'Optional — you can add or change more in Profile any time.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: tokens.spacingLg),
          Text(
            'Fitness goals (optional)',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: tokens.spacingXs),
          Wrap(
            spacing: tokens.spacingSm,
            runSpacing: tokens.spacingXs,
            children: [
              for (final goal in FitnessGoal.values)
                FilterChip(
                  label: Text(goal.label),
                  selected: state.fitnessGoals.contains(goal),
                  onSelected: (_) => controller.toggleFitnessGoal(goal),
                ),
            ],
          ),
          SizedBox(height: tokens.spacingLg),
          Text(
            'Running experience (optional)',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: tokens.spacingSm),
          SingleChoiceChips<ExperienceLevel>(
            options: ExperienceLevel.values,
            labelFor: (level) => level.label,
            selected: state.runningExperience,
            onChanged: controller.updateRunningExperience,
          ),
          SizedBox(height: tokens.spacingLg),
          Row(
            children: [
              Expanded(
                child: Text(
                  'How many times per week is your goal to exercise?',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.info_outline, size: 20),
                tooltip: 'Target number of exercise sessions per week.',
                onPressed: () {
                  unawaited(
                    showDialog<void>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Exercise Goal'),
                        content: const Text(
                          'Set how many workouts or active sessions you aim to '
                          'complete each week. We use this to help you pace '
                          'your routine and monitor consistency.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            child: const Text('Got it'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          SizedBox(height: tokens.spacingSm),
          _OnboardingGoalStepper(
            value: state.weeklyActivityGoal,
            onChanged: controller.updateWeeklyActivityGoal,
          ),
          SizedBox(height: tokens.spacingLg),
          Text(
            'Preferred training days (optional)',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: tokens.spacingSm),
          WeekdayToggleRow(
            selected: state.trainingDays,
            onChanged: (days) {
              for (final d in Weekday.values) {
                if (days.contains(d) != state.trainingDays.contains(d)) {
                  controller.toggleTrainingDay(d);
                }
              }
            },
          ),
        ],
      ),
    );
  }
}

class _OnboardingGoalStepper extends StatelessWidget {
  const _OnboardingGoalStepper({
    required this.value,
    required this.onChanged,
  });

  final int? value;
  final ValueChanged<int?> onChanged;

  static const int _min = 1;
  static const int _max = 14;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: tokens.spacingSm,
      runSpacing: tokens.spacingSm,
      children: [
        FilterChip(
          label: const Text('No goal'),
          selected: value == null,
          onSelected: (selected) => selected ? onChanged(null) : null,
        ),
        IconButton(
          icon: const Icon(Icons.remove_circle_outline),
          tooltip: 'One session fewer per week',
          onPressed: value == null || value! <= _min
              ? null
              : () => onChanged(value! - 1),
        ),
        SizedBox(
          width: 112,
          child: Text(
            value == null
                ? 'Not set'
                : '$value ${value == 1 ? 'time' : 'times'} / week',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          tooltip: 'One session more per week',
          onPressed: value != null && value! >= _max
              ? null
              : () => onChanged(value == null ? 3 : value! + 1),
        ),
      ],
    );
  }
}

/// Step 4: plain-language privacy summary.
class PrivacyStep extends StatelessWidget {
  const PrivacyStep({super.key});

  static const String _healthDataBullet =
      'Health and location data never leave your device without explicit '
      'consent.';

  static const List<String> _bullets = [
    'Your data stays on this device unless you choose to sync it.',
    _healthDataBullet,
    'You can delete your data at any time.',
  ];

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your privacy',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          SizedBox(height: tokens.spacingLg),
          for (final bullet in _bullets)
            Padding(
              padding: EdgeInsets.only(bottom: tokens.spacingMd),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle_outline, color: colorScheme.primary),
                  SizedBox(width: tokens.spacingSm),
                  Expanded(
                    child: Text(
                      bullet,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
