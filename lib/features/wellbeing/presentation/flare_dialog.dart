import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/core/widgets/field_error_text.dart';
import 'package:menfit_app/features/streaks/domain/recovery_day_entry.dart';
import 'package:menfit_app/features/streaks/streaks_providers.dart';
import 'package:menfit_app/features/wellbeing/domain/flare_event.dart';
import 'package:menfit_app/features/wellbeing/domain/symptom_type.dart';
import 'package:menfit_app/features/wellbeing/presentation/flare_controller.dart';
import 'package:menfit_app/features/wellbeing/presentation/widgets/date_span_fields.dart';
import 'package:menfit_app/features/wellbeing/presentation/widgets/flare_dialog_fields.dart';

/// Modal dialog for logging, editing, or deleting a flare-up — a single day
/// or an inclusive range of days.
///
/// All the field logic lives in `presentation/flare_controller.dart`'s
/// [FlareController] (a family provider keyed by [existing]) — this widget
/// stays a plain [ConsumerWidget], same shape as
/// `features/streaks/` recovery-day prompts.
///
/// The already-marked recovery days are read here and handed to
/// [FlareController.save] rather than watched by the controller: they are
/// both the "also mark these as recovery days" default *and* the before-state
/// the save diffs against, and watching them inside the controller's `build`
/// would reset the half-filled form every time the stream re-emitted.
/// Importing `streaks`' composition surface is ADR-007-legal (see
/// `wellbeing_screen.dart`).
class FlareDialog extends ConsumerWidget {
  const FlareDialog({super.key, this.existing, this.initialDay});

  /// The flare being edited, or `null` to log a new one.
  final FlareEvent? existing;

  /// The day being logged when creating a new flare, defaulting to today.
  final LocalDate? initialDay;

  static Future<void> show(
    BuildContext context, {
    FlareEvent? existing,
    LocalDate? initialDay,
  }) {
    return showDialog<void>(
      context: context,
      builder: (_) => FlareDialog(
        existing: existing,
        initialDay: initialDay,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final provider = flareControllerProvider(existing, initialDay);
    final state = ref.watch(provider);
    final controller = ref.read(provider.notifier);
    final today = LocalDate.today();
    final farBack = LocalDate(today.year - 10, 1, 1);
    final isEditing = existing != null;

    final markedRecoveryDays = <LocalDate>{
      for (final entry
          in ref.watch(recoveryDayEntriesProvider).value ??
              const <RecoveryDayEntry>[])
        entry.day,
    };
    final recoveryTicked =
        state.markAsRecovery ?? controller.rangeFullyMarked(markedRecoveryDays);

    ref.listen(provider, (previous, next) {
      final justFinished =
          (next.didSave && !(previous?.didSave ?? false)) ||
          (next.didDelete && !(previous?.didDelete ?? false));
      if (justFinished && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    });

    return AlertDialog(
      title: Text(isEditing ? 'Edit flare-up' : 'Log a flare-up'),
      content: SizedBox(
        width: 360,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'How long did it last?',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              SizedBox(height: tokens.spacingXs),
              DateSpanModeField(
                mode: state.isRange ? DateSpanMode.range : DateSpanMode.single,
                enabled: !state.isSubmitting,
                onChanged: (mode) => controller.setRangeMode(
                  isRange: mode == DateSpanMode.range,
                ),
              ),
              SizedBox(height: tokens.spacingMd),
              DateSpanDateField(
                label: state.isRange ? 'First day' : 'Date',
                value: state.day,
                errorText: state.dayError,
                firstDate: farBack,
                lastDate: today,
                enabled: !state.isSubmitting,
                onChanged: controller.updateDay,
              ),
              if (state.isRange) ...[
                SizedBox(height: tokens.spacingMd),
                DateSpanDateField(
                  label: 'Last day',
                  value: state.endDay ?? state.day,
                  errorText: state.endDayError,
                  firstDate: farBack,
                  lastDate: today,
                  enabled: !state.isSubmitting,
                  onChanged: controller.updateEndDay,
                ),
              ],
              SizedBox(height: tokens.spacingMd),
              Text(
                'How severe was it?',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              SizedBox(height: tokens.spacingXs),
              SegmentedButton<FlareSeverity>(
                emptySelectionAllowed: true,
                segments: [
                  for (final severity in FlareSeverity.values)
                    ButtonSegment(value: severity, label: Text(severity.label)),
                ],
                selected: state.severity == null ? const {} : {state.severity!},
                onSelectionChanged: (selection) {
                  if (selection.isEmpty) return;
                  controller.setSeverity(selection.first);
                },
              ),
              if (state.severityError != null)
                FieldErrorText(state.severityError!),
              SizedBox(height: tokens.spacingMd),
              Text('Symptoms', style: Theme.of(context).textTheme.labelLarge),
              SizedBox(height: tokens.spacingXs),
              Wrap(
                spacing: tokens.spacingSm,
                runSpacing: tokens.spacingXs,
                children: [
                  for (final symptom in SymptomType.values)
                    FilterChip(
                      label: Text(symptom.label),
                      selected: state.symptoms.contains(symptom),
                      onSelected: (_) => controller.toggleSymptom(symptom),
                    ),
                ],
              ),
              if (state.symptoms.contains(SymptomType.other)) ...[
                SizedBox(height: tokens.spacingSm),
                TextFormField(
                  key: const Key('flareOtherSymptomField'),
                  initialValue: state.otherSymptom ?? '',
                  decoration: const InputDecoration(
                    labelText: 'Describe other symptom',
                    hintText: 'e.g. Sciatica, dizziness, joint pain...',
                    border: OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.done,
                  onChanged: controller.setOtherSymptom,
                ),
              ],
              SizedBox(height: tokens.spacingMd),
              Text(
                'How did this affect your training?',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              for (final impact in FlareImpact.values)
                ImpactOption(
                  impact: impact,
                  selected: state.impact == impact,
                  onTap: () => controller.setImpact(impact),
                ),
              if (state.impactError != null) FieldErrorText(state.impactError!),
              SizedBox(height: tokens.spacingSm),
              RecoveryDaysCheckbox(
                value: recoveryTicked,
                isRange: state.isRange,
                enabled: !state.isSubmitting,
                onChanged: (value) =>
                    controller.setMarkAsRecovery(value: value),
              ),
              if (state.recoveryError != null)
                FieldErrorText(state.recoveryError!),
              SizedBox(height: tokens.spacingMd),
              DropdownButtonFormField<FlareCategory?>(
                initialValue: state.category,
                // Without this, the dropdown sizes itself to its widest
                // item's intrinsic width ("Prefer not to say") rather than
                // the available width, which overflows on a compact-width
                // dialog (`AlertDialog`'s content area is narrower than
                // this widget's own 360px `SizedBox` once inset padding is
                // applied on a ~400dp-wide phone).
                isExpanded: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'What kind of flare-up? (optional)',
                ),
                items: [
                  const DropdownMenuItem(
                    child: Text('Prefer not to say'),
                  ),
                  for (final category in FlareCategory.values)
                    DropdownMenuItem(
                      value: category,
                      child: Text(category.label),
                    ),
                ],
                onChanged: controller.setCategory,
              ),
              SizedBox(height: tokens.spacingMd),
              TextFormField(
                initialValue: state.notes,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Notes (optional)',
                ),
                minLines: 2,
                maxLines: 4,
                onChanged: controller.updateNotes,
              ),
              if (state.submitError != null) ...[
                SizedBox(height: tokens.spacingMd),
                FieldErrorText(state.submitError!),
              ],
            ],
          ),
        ),
      ),
      actions: [
        if (isEditing)
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: state.isSubmitting
                ? null
                : () => _confirmAndDelete(context, controller),
            child: const Text('Delete'),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: state.isSubmitting
              ? null
              : () => unawaited(
                  controller.save(markedRecoveryDays: markedRecoveryDays),
                ),
          child: state.isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(isEditing ? 'Save' : 'Log flare-up'),
        ),
      ],
    );
  }

  Future<void> _confirmAndDelete(
    BuildContext context,
    FlareController controller,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete this flare-up?'),
        content: const Text(
          "This removes it from your history. This can't be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
              foregroundColor: Theme.of(dialogContext).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await controller.delete();
  }
}
