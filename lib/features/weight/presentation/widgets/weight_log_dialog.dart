import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:menfit_app/core/domain/entity_id.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/domain/units.dart';
import 'package:menfit_app/core/errors/error_messages.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/core/widgets/field_error_text.dart';
import 'package:menfit_app/features/weight/domain/weight_log.dart';
import 'package:menfit_app/features/weight/domain/weight_validation.dart';
import 'package:menfit_app/features/weight/presentation/weight_format.dart';
import 'package:menfit_app/features/weight/presentation/weight_history_providers.dart';
import 'package:menfit_app/features/weight/weight_providers.dart';

/// Records a weight reading, or edits one already recorded.
///
/// Writes **only** to the weight history. It deliberately does not touch
/// the profile's `weightKg`: the write-through is one-way, profile ->
/// log (`features/profile/presentation/profile_controller.dart`), and a
/// second path back the other way would make "which one is current" a
/// question with two answers.
///
/// S2 data (`knowledge/engineering/security_and_privacy.md`): nothing
/// typed here is logged or sent anywhere; the failure path shows
/// `userMessageFor`, which never carries the value.
class WeightLogDialog extends ConsumerStatefulWidget {
  const WeightLogDialog({required this.unitSystem, this.existing, super.key});

  /// The reading being edited, or `null` to record a new one.
  final WeightLog? existing;

  final UnitSystem unitSystem;

  /// Opens the dialog. Resolves to `true` when a reading was saved.
  static Future<bool?> show(
    BuildContext context, {
    required UnitSystem unitSystem,
    WeightLog? existing,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) =>
          WeightLogDialog(unitSystem: unitSystem, existing: existing),
    );
  }

  @override
  ConsumerState<WeightLogDialog> createState() => _WeightLogDialogState();
}

class _WeightLogDialogState extends ConsumerState<WeightLogDialog> {
  late final TextEditingController _weightController;
  late final TextEditingController _noteController;
  late LocalDate _day;

  WeightLogValidation _validation = const WeightLogValidation();
  String? _saveError;
  bool _isSubmitting = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _weightController = TextEditingController(
      text: existing == null
          ? ''
          : formatWeightValue(existing.weightKg, widget.unitSystem),
    );
    _noteController = TextEditingController(text: existing?.notes ?? '');
    _day = existing?.day ?? ref.read(weightTodayProvider);
  }

  @override
  void dispose() {
    _weightController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDay() async {
    final today = ref.read(weightTodayProvider);
    final lastDate = DateTime(today.year, today.month, today.day);
    final selected = DateTime(_day.year, _day.month, _day.day);
    final picked = await showDatePicker(
      context: context,
      // Clamped into `[firstDate, lastDate]`: `showDatePicker` asserts that
      // `initialDate` is inside its bounds, and a row *can* sit outside
      // them — a reading logged while the device clock was ahead, or one
      // opened for editing after midnight rolled `today` past it. A
      // day-picker assertion is not the way to tell the user about that;
      // `validateWeightLog` reports it as a field error instead.
      initialDate: selected.isAfter(lastDate) ? lastDate : selected,
      firstDate: DateTime(1900),
      // The picker refuses future days up front; `validateWeightLog` still
      // checks, because a picker's bounds are a convenience and the rule
      // belongs in the domain (`domain/weight_validation.dart`).
      lastDate: lastDate,
      helpText: 'Which day was this reading?',
    );
    if (picked == null) return;
    setState(() => _day = LocalDate.fromDateTime(picked));
  }

  Future<void> _submit() async {
    final today = ref.read(weightTodayProvider);
    final raw = _weightController.text;
    final typed = parseWeightInput(raw);
    final weightKg = (typed == null || typed.isNaN)
        ? null
        : displayWeightToKg(typed, widget.unitSystem);
    final note = _noteController.text.trim();

    final validation = validateWeightLog(
      today: today,
      day: _day,
      weightKg: weightKg,
      rawWeightInput: raw,
      notes: note,
      unitSystem: widget.unitSystem,
    );
    if (!validation.isValid) {
      setState(() {
        _validation = validation;
        _saveError = null;
      });
      return;
    }

    setState(() {
      _validation = validation;
      _saveError = null;
      _isSubmitting = true;
    });

    final now = DateTime.now().toUtc();
    final existing = widget.existing;
    final log = WeightLog(
      id: existing?.id ?? EntityId.generate(),
      day: _day,
      weightKg: weightKg!,
      notes: note.isEmpty ? null : note,
      // Provenance survives an edit: a reading seeded from the profile
      // that the user later corrects is still the row that came from the
      // profile, and `WeightLogSource` is metadata about where the number
      // first appeared, not about who last touched it.
      source: existing?.source ?? WeightLogSource.manual,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );

    try {
      await ref.read(weightRepositoryProvider).saveLog(log);
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _saveError = userMessageFor(error);
      });
      return;
    }

    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final textTheme = Theme.of(context).textTheme;
    final unit = weightUnitLabel(widget.unitSystem);

    return AlertDialog(
      title: Text(_isEditing ? 'Edit reading' : 'Log weight'),
      content: SizedBox(
        width: 360,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                key: const Key('weightLogWeightField'),
                controller: _weightController,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: 'Weight ($unit)',
                  errorText: _validation.weightError,
                ),
              ),
              SizedBox(height: tokens.spacingMd),
              InputDecorator(
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: 'Day',
                  errorText: _validation.dayError,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Flexible, not fixed: the long date plus the button is
                    // already close to the dialog's width, and a larger
                    // text scale or a longer locale format pushes it over.
                    Expanded(
                      child: Text(_longDate(_day), style: textTheme.bodyLarge),
                    ),
                    TextButton(
                      key: const Key('weightLogDayButton'),
                      onPressed: _isSubmitting ? null : _pickDay,
                      child: const Text('Change'),
                    ),
                  ],
                ),
              ),
              SizedBox(height: tokens.spacingMd),
              TextField(
                key: const Key('weightLogNoteField'),
                controller: _noteController,
                maxLines: 2,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: 'Note (optional)',
                  helperText: 'Anything worth remembering about this reading.',
                  errorText: _validation.notesError,
                ),
              ),
              if (_saveError != null) ...[
                SizedBox(height: tokens.spacingMd),
                FieldErrorText(_saveError!),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const Key('weightLogSaveButton'),
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}

String _longDate(LocalDate day) =>
    DateFormat('EEE d MMM y').format(DateTime(day.year, day.month, day.day));
