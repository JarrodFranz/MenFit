import 'package:flutter/material.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/wellbeing/domain/daily_checkin.dart';
import 'package:menfit_app/features/wellbeing/domain/symptom_type.dart';
import 'package:menfit_app/features/wellbeing/presentation/checkin_sheet.dart';
import 'package:menfit_app/features/wellbeing/presentation/flare_dialog.dart';
import 'package:menfit_app/features/wellbeing/presentation/mark_recovery_day_dialog.dart';

// The sections `wellbeing_day_sheet.dart` composes, split out to keep that
// file to the sheet itself (`coding_standards.md`'s ~300-line rule).

/// A section title inside the day sheet.
class SectionHeading extends StatelessWidget {
  const SectionHeading({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(label, style: Theme.of(context).textTheme.titleSmall);
  }
}

/// "Nothing here" copy for a section — a statement of fact, never a
/// prompt about a day that got away.
class SectionEmptyText extends StatelessWidget {
  const SectionEmptyText(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      text,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}

/// What a day that has not happened yet shows: an explanation and nothing
/// to do. Every logging flow in this feature is bounded at today, so
/// offering an action here would only lead to a rejected save.
class FutureDayNotice extends StatelessWidget {
  const FutureDayNotice({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppTokens>()!;
    return Card(
      margin: EdgeInsets.zero,
      color: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: EdgeInsets.all(tokens.spacingMd),
        child: Row(
          children: [
            Icon(Icons.event_outlined, color: theme.colorScheme.primary),
            SizedBox(width: tokens.spacingSm),
            Expanded(
              child: Text(
                "This day hasn't happened yet. You can log it when it does.",
                style: theme.textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The day's check-in, read-only, or the way to record one.
///
/// Read-only on purpose: [CheckinSheet] already owns the five score fields,
/// their validation and the post-save recovery prompt, so this shows what
/// was answered and hands editing straight back to it.
class CheckinSection extends StatelessWidget {
  const CheckinSection({required this.day, required this.checkin, super.key});

  final LocalDate day;

  /// The check-in stored for [day], if any. A stored-but-blank one
  /// (`DailyCheckin.isEmpty`) reads as no check-in — there is nothing to
  /// show and nothing was really answered.
  final DailyCheckin? checkin;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final logged = checkin;
    final hasContent = logged != null && !logged.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeading(label: 'Check-in'),
        SizedBox(height: tokens.spacingSm),
        if (!hasContent)
          const SectionEmptyText('No check-in logged.')
        else ...[
          _ScoreLine(label: 'Energy', value: logged.energy),
          _ScoreLine(label: 'Sleep', value: logged.sleep),
          _ScoreLine(label: 'Soreness', value: logged.soreness),
          _ScoreLine(label: 'Stress', value: logged.stress),
          _ScoreLine(label: 'Pain', value: logged.pain),
          if (logged.symptoms.isNotEmpty) ...[
            SizedBox(height: tokens.spacingSm),
            Wrap(
              spacing: tokens.spacingSm,
              runSpacing: tokens.spacingXs,
              children: [
                for (final symptom in logged.symptoms)
                  Chip(
                    label: Text(
                      symptom == SymptomType.other &&
                              logged.customSymptom != null &&
                              logged.customSymptom!.isNotEmpty
                          ? logged.customSymptom!
                          : symptom.label,
                    ),
                  ),
              ],
            ),
          ],
        ],
        SizedBox(height: tokens.spacingSm),
        // Stacked over this sheet rather than replacing it: the sheet
        // watches the check-in stream, so when [CheckinSheet] saves and
        // pops itself the day underneath is already showing the new
        // answers.
        FilledButton.tonalIcon(
          key: const Key('wellbeingDayLogCheckinButton'),
          onPressed: () =>
              CheckinSheet.show(context, day: day, existing: logged),
          icon: Icon(
            hasContent ? Icons.edit_outlined : Icons.edit_note_outlined,
          ),
          label: Text(
            hasContent ? 'Edit this check-in' : 'Log check-in for this day',
          ),
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
        ),
      ],
    );
  }
}

/// Opens the flare dialog, seeded with [day] (defaulting to today).
class LogFlareButton extends StatelessWidget {
  const LogFlareButton({this.day, super.key});

  final LocalDate? day;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      key: const Key('wellbeingDayLogFlareButton'),
      onPressed: () => FlareDialog.show(context, initialDay: day),
      icon: const Icon(Icons.local_fire_department_outlined),
      label: const Text('Log a flare-up'),
      style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
    );
  }
}

/// Opens the existing retroactive recovery-day dialog on this day.
///
/// The dialog is seeded with [day] rather than today so she does not have
/// to re-find in a picker the date she has already tapped; the date field
/// stays fully editable, and `lastDate: today` still bounds it.
class MarkRecoveryDayButton extends StatelessWidget {
  const MarkRecoveryDayButton({required this.day, super.key});

  final LocalDate day;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      key: const Key('wellbeingDayMarkRecoveryButton'),
      onPressed: () => MarkRecoveryDayDialog.show(context, initialDay: day),
      icon: const Icon(Icons.shield_outlined),
      label: const Text('Mark as a recovery day'),
      style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
    );
  }
}

/// One answered score, as `Energy 4 of 5`. Unanswered scores are omitted
/// entirely rather than shown as a dash: a question she chose to skip is
/// not a gap in the record.
class _ScoreLine extends StatelessWidget {
  const _ScoreLine({required this.label, required this.value});

  final String label;
  final int? value;

  @override
  Widget build(BuildContext context) {
    final score = value;
    if (score == null) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final tokens = theme.extension<AppTokens>()!;
    return Padding(
      padding: EdgeInsets.only(bottom: tokens.spacingXs),
      child: Row(
        children: [
          Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
          Text(
            '$score of 5',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
