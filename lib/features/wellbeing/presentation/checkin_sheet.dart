import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/errors/error_messages.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/core/widgets/app_bottom_sheet.dart';
import 'package:menfit_app/features/wellbeing/domain/daily_checkin.dart';
import 'package:menfit_app/features/wellbeing/domain/recovery_prompt.dart';
import 'package:menfit_app/features/wellbeing/domain/symptom_type.dart';
import 'package:menfit_app/features/wellbeing/presentation/checkin_controller.dart';
import 'package:menfit_app/features/wellbeing/presentation/flare_dialog.dart';
import 'package:menfit_app/features/wellbeing/presentation/recovery_prompt_controller.dart';
import 'package:menfit_app/features/wellbeing/presentation/recovery_prompt_sheet.dart';
import 'package:menfit_app/features/wellbeing/presentation/widgets/checkin_score_row.dart';

/// The sheet's heading for the day it is logging.
///
/// It used to be the hard-coded "How are you feeling today?" for every
/// day, which was true while the only way in was today's card. The
/// wellbeing calendar opens it on any past day, and asking how they feel
/// *today* while saving against 12 August is asking the wrong question of
/// the wrong day. Past tense plus the date; today keeps its original words.
///
/// Pure, so it is tested as text rather than through the sheet.
String checkinSheetTitle(LocalDate day) {
  if (day == LocalDate.today()) return 'How are you feeling today?';
  final formatted = DateFormat(
    'EEEE d MMMM',
  ).format(DateTime(day.year, day.month, day.day));
  return 'How were you feeling on $formatted?';
}

/// The fast, optional daily check-in sheet — a
/// [showAppBottomSheet], not a full screen (per
/// `knowledge/product/terminology.md`'s "Check-in" definition: fast,
/// optional). All field logic lives in `checkin_controller.dart`'s
/// [CheckinController] (a family provider keyed by [day]/[existing]); the
/// score fields themselves are `widgets/checkin_score_row.dart`'s
/// [CheckinScoreRow]; the post-save recovery-prompt eligibility check is
/// `recovery_prompt_controller.dart`'s [RecoveryPromptController] (F2,
/// extracted out of this file so it stays under the ~300-line splitting
/// guideline — `coding_standards.md`).
class CheckinSheet extends ConsumerWidget {
  const CheckinSheet({required this.day, super.key, this.existing});

  final LocalDate day;

  /// The check-in already logged for [day], if editing one.
  final DailyCheckin? existing;

  static Future<void> show(
    BuildContext context, {
    required LocalDate day,
    DailyCheckin? existing,
  }) {
    return showAppBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => CheckinSheet(day: day, existing: existing),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final provider = checkinControllerProvider(day, existing);
    final state = ref.watch(provider);
    final controller = ref.read(provider.notifier);

    ref.listen(provider, (previous, next) {
      final justSaved = next.didSave && !(previous?.didSave ?? false);
      if (justSaved && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
        unawaited(_maybeOfferRecoveryDay(context, next));
      }
    });

    // No keyboard/nav-bar padding here: `showAppBottomSheet` applies it
    // once, outside this widget.
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: tokens.contentMaxWidth),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(tokens.spacingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                checkinSheetTitle(day),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: tokens.spacingXs),
              Text(
                'Every question is optional — answer as many or as few as '
                "you'd like.",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: tokens.spacingLg),
              CheckinScoreRow(
                label: 'Energy',
                value: state.energy,
                errorText: state.energyError,
                onSelect: controller.setEnergy,
              ),
              SizedBox(height: tokens.spacingMd),
              CheckinScoreRow(
                label: 'Sleep',
                value: state.sleep,
                errorText: state.sleepError,
                onSelect: controller.setSleep,
              ),
              SizedBox(height: tokens.spacingMd),
              CheckinScoreRow(
                label: 'Soreness',
                value: state.soreness,
                errorText: state.sorenessError,
                onSelect: controller.setSoreness,
              ),
              SizedBox(height: tokens.spacingMd),
              CheckinScoreRow(
                label: 'Stress',
                value: state.stress,
                errorText: state.stressError,
                onSelect: controller.setStress,
              ),
              SizedBox(height: tokens.spacingMd),
              CheckinScoreRow(
                label: 'Pain',
                value: state.pain,
                errorText: state.painError,
                onSelect: controller.setPain,
              ),
              SizedBox(height: tokens.spacingLg),
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
                  key: const Key('checkinOtherSymptomField'),
                  initialValue: state.otherSymptom ?? '',
                  decoration: const InputDecoration(
                    labelText: 'Describe other symptom',
                    hintText: 'e.g. Lower back stiffness, nausea...',
                    border: OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.done,
                  onChanged: controller.setOtherSymptom,
                ),
              ],
              SizedBox(height: tokens.spacingLg),
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: EdgeInsets.all(tokens.spacingMd),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Are you having a flare-up?',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      SizedBox(height: tokens.spacingXs),
                      Text(
                        'Log severity, symptoms, and how it affected your '
                        'training — no diagnosis required.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      SizedBox(height: tokens.spacingSm),
                      OutlinedButton(
                        onPressed: () => _logFlare(context, controller),
                        child: const Text('Log a flare-up'),
                      ),
                    ],
                  ),
                ),
              ),
              if (state.submitError != null) ...[
                SizedBox(height: tokens.spacingMd),
                Text(
                  state.submitError!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
              SizedBox(height: tokens.spacingLg),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  SizedBox(width: tokens.spacingSm),
                  FilledButton(
                    onPressed: state.isSubmitting ? null : controller.save,
                    child: state.isSubmitting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// After a successful check-in save (`ref.listen` above), asks
  /// `RecoveryPromptController` whether the recovery-decision prompt
  /// (§5.9) is warranted, and if so, shows it and acts on the answer.
  ///
  /// **Lifecycle note:** this is called right after `Navigator.pop()`
  /// closes this sheet, and then `await`s both the controller's eligibility
  /// check and the user's answer on the prompt it opens — by the time
  /// those resolve, this widget (and the `ref` passed to it) may well be
  /// disposed, so every read this function needs happens either
  /// synchronously up front (safe: nothing has been popped off the
  /// microtask queue yet) or via a captured [ProviderContainer]/
  /// [ScaffoldMessengerState] rather than `ref`/`context` directly after an
  /// `await` (same "capture what you need before the gap" rule as any
  /// async-gap-then-context-use in this codebase, just via a container
  /// instead of a `context.mounted` guard since `context` itself won't
  /// reliably still be mounted here).
  Future<void> _maybeOfferRecoveryDay(
    BuildContext context,
    CheckinFormState saved,
  ) async {
    final container = ProviderScope.containerOf(context, listen: false);
    final promptController = RecoveryPromptController(container);

    // A throwaway evaluation-only entity: the real check-in is already
    // persisted (that's what `saved`/`didSave` confirms) - this exists
    // purely to hand the eligibility check the same shape it validates
    // against real check-ins, without re-reading the just-written row back
    // from Drift (which may not have propagated through its watch stream
    // yet - same "watch() notifies asynchronously" reasoning as
    // `streaks_providers_test.dart`'s `waitFor` helper).
    final now = DateTime.now().toUtc();
    final evaluatedCheckin = DailyCheckin(
      id: 'evaluation-only',
      day: saved.day,
      createdAt: now,
      updatedAt: now,
      energy: saved.energy,
      sleep: saved.sleep,
      soreness: saved.soreness,
      stress: saved.stress,
      pain: saved.pain,
      symptoms: saved.symptoms,
    );

    final decision = await promptController.evaluate(
      day: saved.day,
      checkin: evaluatedCheckin,
      // F2: past-day edits (the wellbeing history screen re-opens this
      // same sheet for an earlier day) never prompt - only today's own
      // check-in flow does.
      isToday: saved.day == LocalDate.today(),
    );
    if (decision != RecoveryPromptDecision.offer) return;

    if (!context.mounted) return;
    // Captured before the `await` below - `ScaffoldMessengerState` is tied
    // to the ancestor `Scaffold` (home's), which stays mounted even once
    // this sheet's own `context` doesn't.
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final makeRecoveryDay = await RecoveryPromptSheet.show(context);

    if (makeRecoveryDay == true) {
      try {
        await promptController.acceptRecoveryDay(saved.day);
      } on Object catch (error) {
        scaffoldMessenger
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(userMessageFor(error)),
              duration: const Duration(seconds: 3),
            ),
          );
      }
    } else {
      // "Keep training", or dismissed another way (e.g. scrim tap) - both
      // count as a dismissal for the session (see
      // `RecoveryPromptSheet`'s dartdoc).
      promptController.dismiss(saved.day);
    }
  }

  Future<void> _logFlare(
    BuildContext context,
    CheckinController controller,
  ) async {
    // "Takes a few seconds — totally optional": saving here persists
    // whatever's already filled in on this check-in (a no-op if it's still
    // blank — see `CheckinController.save`'s dartdoc) so a flare logged
    // mid-check-in isn't lost if the user backs out of the sheet
    // afterwards, then opens the flare dialog on top. `markComplete: false`
    // keeps the sheet open rather than triggering its own auto-close (see
    // `save`'s dartdoc) - the flare dialog should appear on top of the
    // still-open sheet, not replace it.
    await controller.save(markComplete: false);
    if (!context.mounted) return;
    await FlareDialog.show(context);
  }
}
