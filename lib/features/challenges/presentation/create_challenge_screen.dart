import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/errors/error_messages.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/core/widgets/field_error_text.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/challenges/application/challenge_code_service.dart';
import 'package:menfit_app/features/challenges/challenges_providers.dart';
import 'package:menfit_app/features/challenges/domain/challenge.dart';
import 'package:menfit_app/features/challenges/domain/challenge_validation.dart';
import 'package:menfit_app/features/challenges/presentation/challenges_copy.dart';
import 'package:menfit_app/features/challenges/presentation/widgets/activity_type_picker.dart';
import 'package:menfit_app/features/challenges/presentation/widgets/challenge_code_panel.dart';

/// Sets a challenge up and hands back the code to send.
///
/// Reached at `/challenges/create`.
///
/// ## Units
///
/// They type kilometres; the blueprint stores hundreds of metres
/// (`domain/challenge.dart#ChallengeBlueprint.targetUnits`), because that
/// is what the wire format carries and a shared target both sides cannot
/// read identically is worse than a coarse one. The conversion lives in
/// `challenges_copy.dart#distanceUnitsFromKm` and is pinned in both
/// directions by its own test — get it wrong and two people end up in
/// challenges that look the same and are not.
///
/// ## Validation
///
/// `validateChallenge` reports all three fields at once
/// (`domain/challenge_validation.dart`), and all three are shown at once:
/// a form that surfaces one problem, then another, then a third makes the
/// user pay for the app's convenience.
class CreateChallengeScreen extends ConsumerStatefulWidget {
  const CreateChallengeScreen({super.key});

  @override
  ConsumerState<CreateChallengeScreen> createState() =>
      _CreateChallengeScreenState();
}

class _CreateChallengeScreenState extends ConsumerState<CreateChallengeScreen> {
  final TextEditingController _targetController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final Set<ActivityType> _activityTypes = <ActivityType>{};

  ChallengeKind _kind = ChallengeKind.totalDistance;
  late LocalDate _windowStart;
  late LocalDate _windowEnd;

  ChallengeValidation _validation = const ChallengeValidation();
  String? _saveError;
  bool _isSubmitting = false;
  ChallengeCreated? _created;

  @override
  void initState() {
    super.initState();
    final today = ref.read(challengesTodayProvider);
    _windowStart = today;
    // Four weeks: long enough to mean something, short enough that the
    // end is in sight. They can change it, and most people will.
    _windowEnd = today.addDays(27);
  }

  @override
  void dispose() {
    _targetController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  /// The typed target in the kind's own stored units, or 0 for anything
  /// blank or unparseable — 0 is outside both kinds' bounds, so the
  /// domain's own message is what the user reads either way.
  int get _targetUnits {
    final raw = _targetController.text;
    switch (_kind) {
      case ChallengeKind.totalDistance:
        final km = parseDistanceInput(raw);
        if (km == null || !km.isFinite) return 0;
        return distanceUnitsFromKm(km);
      case ChallengeKind.sessionCount:
        final sessions = parseSessionInput(raw);
        if (sessions == null || !sessions.isFinite) return 0;
        return sessions.toInt();
    }
  }

  Future<void> _pickWindow() async {
    final today = ref.read(challengesTodayProvider);
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(today.year - 1, today.month, today.day),
      lastDate: DateTime(today.year + 1, today.month, today.day),
      initialDateRange: DateTimeRange(
        start: DateTime(
          _windowStart.year,
          _windowStart.month,
          _windowStart.day,
        ),
        end: DateTime(_windowEnd.year, _windowEnd.month, _windowEnd.day),
      ),
      helpText: windowPickHelpText,
    );
    if (picked == null) return;
    setState(() {
      _windowStart = LocalDate.fromDateTime(picked.start);
      _windowEnd = LocalDate.fromDateTime(picked.end);
    });
  }

  Future<void> _submit() async {
    final today = ref.read(challengesTodayProvider);
    setState(() {
      _saveError = null;
      _isSubmitting = true;
    });

    CreateChallengeResult result;
    try {
      result = await ref
          .read(challengeCodeServiceProvider)
          .createChallenge(
            kind: _kind,
            activityTypes: _activityTypes,
            targetUnits: _targetUnits,
            windowStart: _windowStart,
            windowEnd: _windowEnd,
            displayName: _nameController.text,
            today: today,
          );
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _saveError = userMessageFor(error);
      });
      return;
    }

    if (!mounted) return;
    setState(() {
      _isSubmitting = false;
      switch (result) {
        case ChallengeNotCreated(:final validation):
          _validation = validation;
        case ChallengeCreated():
          _validation = const ChallengeValidation();
          _created = result;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final created = _created;

    return Scaffold(
      appBar: AppBar(title: const Text(createChallengeTitle)),
      body: SafeArea(
        // Pinned to the top: a Center around a shrink-wrapping scroll view
        // floats short content mid-screen (seen on device 2026-09-02).
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: tokens.contentMaxWidth),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(tokens.spacingMd),
              child: created == null
                  ? _buildForm(context)
                  : _CreatedView(code: created.code),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppTokens>()!;
    final isDistance = _kind == ChallengeKind.totalDistance;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(kindFieldLabel, style: theme.textTheme.labelLarge),
        SizedBox(height: tokens.spacingXs),
        SegmentedButton<ChallengeKind>(
          key: const Key('challengeKindSelector'),
          showSelectedIcon: false,
          segments: const [
            ButtonSegment(
              value: ChallengeKind.totalDistance,
              label: Text(kindDistanceLabel),
            ),
            ButtonSegment(
              value: ChallengeKind.sessionCount,
              label: Text(kindSessionsLabel),
            ),
          ],
          selected: {_kind},
          onSelectionChanged: (selection) =>
              setState(() => _kind = selection.first),
        ),
        SizedBox(height: tokens.spacingMd),
        ActivityTypePicker(
          selected: _activityTypes,
          onToggle: (type) => setState(() {
            if (!_activityTypes.remove(type)) _activityTypes.add(type);
          }),
        ),
        SizedBox(height: tokens.spacingMd),
        TextField(
          key: const Key('challengeTargetField'),
          controller: _targetController,
          keyboardType: TextInputType.numberWithOptions(decimal: isDistance),
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelText: isDistance ? distanceFieldLabel : sessionsFieldLabel,
            errorText: _validation.targetError,
          ),
        ),
        SizedBox(height: tokens.spacingMd),
        InputDecorator(
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelText: windowFieldLabel,
            errorText: _validation.windowError,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  challengeWindowLine(_windowStart, _windowEnd),
                  style: theme.textTheme.bodyLarge,
                ),
              ),
              TextButton(
                key: const Key('challengeWindowButton'),
                onPressed: _isSubmitting ? null : _pickWindow,
                child: const Text(windowPickLabel),
              ),
            ],
          ),
        ),
        SizedBox(height: tokens.spacingMd),
        TextField(
          key: const Key('challengeNameField'),
          controller: _nameController,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelText: displayNameFieldLabel,
            helperText: displayNameHelper,
            errorText: _validation.displayNameError,
          ),
        ),
        if (_saveError case final error?) ...[
          SizedBox(height: tokens.spacingSm),
          FieldErrorText(error),
        ],
        SizedBox(height: tokens.spacingLg),
        FilledButton(
          key: const Key('challengeCreateSubmitButton'),
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text(createSubmitLabel),
        ),
      ],
    );
  }
}

/// What they see once the challenge exists: the code, big, and what it
/// does and does not contain.
class _CreatedView extends StatelessWidget {
  const _CreatedView({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppTokens>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          challengeCreatedTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: tokens.spacingSm),
        Text(challengeCreatedLine, style: theme.textTheme.bodyMedium),
        SizedBox(height: tokens.spacingLg),
        ChallengeCodePanel(
          code: code,
          copyButtonKey: const Key('challengeCodeCopyButton'),
        ),
        SizedBox(height: tokens.spacingMd),
        Text(
          challengeCodePrivacyNote,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: tokens.spacingLg),
        FilledButton(
          key: const Key('challengeCreateDoneButton'),
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(doneLabel),
        ),
      ],
    );
  }
}
