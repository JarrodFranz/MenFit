import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/errors/error_messages.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/core/widgets/field_error_text.dart';
import 'package:menfit_app/features/streaks/domain/recovery_validation.dart';
import 'package:menfit_app/features/streaks/streaks_providers.dart';
import 'package:menfit_app/features/wellbeing/presentation/widgets/date_span_fields.dart';

/// Small dialog for retroactively marking a past (or today's) day — or an
/// inclusive range of days — as protected recovery: the wellbeing history
/// screen's app-bar action.
///
/// The streak card's own "Make today a recovery day" affordance only ever
/// covers *today*; this is the one place a user can mark an **earlier**
/// day, healing a broken streak retroactively — the streak engine
/// recomputes automatically once the record is saved
/// (`streaks/domain/streak_engine.dart`'s "Retroactivity needs no special
/// handling" rule), no separate re-run step needed.
///
/// Deliberately a plain [ConsumerStatefulWidget] with hand-rolled local
/// state rather than a family-provider-backed controller (unlike
/// `flare_controller.dart`/`checkin_controller.dart`) — even with the range
/// mode this dialog has three fields and one save action, still not enough
/// surface to justify the extra layer.
class MarkRecoveryDayDialog extends ConsumerStatefulWidget {
  const MarkRecoveryDayDialog({super.key, this.initialDay});

  /// The day both pickers open on. `null` (the app-bar action's case)
  /// means today, which is where this dialog has always started.
  ///
  /// The wellbeing day sheet passes the day the user is already looking
  /// at: they have tapped 12 August and asked to mark a recovery day, so
  /// making them re-find 12 August in a picker that opened on today would
  /// be asking a question they have already answered. It stays a picker —
  /// the day is still fully editable from here, and `lastDate: today`
  /// still bounds it.
  final LocalDate? initialDay;

  static Future<void> show(BuildContext context, {LocalDate? initialDay}) {
    return showDialog<void>(
      context: context,
      builder: (_) => MarkRecoveryDayDialog(initialDay: initialDay),
    );
  }

  @override
  ConsumerState<MarkRecoveryDayDialog> createState() =>
      _MarkRecoveryDayDialogState();
}

class _MarkRecoveryDayDialogState extends ConsumerState<MarkRecoveryDayDialog> {
  DateSpanMode _mode = DateSpanMode.single;
  late LocalDate _day = widget.initialDay ?? LocalDate.today();
  late LocalDate _endDay = widget.initialDay ?? LocalDate.today();
  final _noteController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorText;
  String? _rangeError;

  bool get _isRange => _mode == DateSpanMode.range;

  LocalDate get _lastDay => _isRange ? _endDay : _day;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final today = LocalDate.today();
    // The whole point of this dialog is *retroactive* marking, so the
    // pickers open well in the past; `lastDate: today` is what stops a
    // future day being picked at all - the same constraint
    // `RecoveryRepository.markRecoveryDays` validates before writing.
    final farBack = LocalDate(today.year - 10, 1, 1);

    return AlertDialog(
      title: const Text('Mark recovery days'),
      content: SizedBox(
        width: 360,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DateSpanModeField(
                mode: _mode,
                enabled: !_isSubmitting,
                onChanged: (mode) => setState(() {
                  _mode = mode;
                  _rangeError = null;
                }),
              ),
              SizedBox(height: tokens.spacingMd),
              DateSpanDateField(
                label: _isRange ? 'First day' : 'Date',
                value: _day,
                firstDate: farBack,
                lastDate: today,
                enabled: !_isSubmitting,
                onChanged: (picked) => setState(() {
                  _day = picked;
                  _rangeError = null;
                }),
              ),
              if (_isRange) ...[
                SizedBox(height: tokens.spacingMd),
                DateSpanDateField(
                  label: 'Last day',
                  value: _endDay,
                  errorText: _rangeError,
                  firstDate: farBack,
                  lastDate: today,
                  enabled: !_isSubmitting,
                  onChanged: (picked) => setState(() {
                    _endDay = picked;
                    _rangeError = null;
                  }),
                ),
              ],
              SizedBox(height: tokens.spacingMd),
              TextField(
                controller: _noteController,
                enabled: !_isSubmitting,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Note (optional)',
                ),
                minLines: 2,
                maxLines: 4,
              ),
              SizedBox(height: tokens.spacingSm),
              Text(
                'Recovery days keep your streak going and need no proof.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (_errorText != null) ...[
                SizedBox(height: tokens.spacingSm),
                FieldErrorText(_errorText!),
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
          onPressed: _isSubmitting ? null : _save,
          child: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(_isRange ? 'Mark recovery days' : 'Mark recovery day'),
        ),
      ],
    );
  }

  Future<void> _save() async {
    // Validate up front so an unusable range reports against the "Last day"
    // control instead of only after a round trip through the repository
    // (which enforces the same rule again before writing anything).
    final validation = validateRecoveryDayRange(
      from: _day,
      to: _lastDay,
      today: LocalDate.today(),
    );
    if (!validation.isValid) {
      setState(() => _rangeError = validation.rangeError);
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorText = null;
      _rangeError = null;
    });
    final note = _noteController.text.trim();
    try {
      await ref
          .read(recoveryRepositoryProvider)
          .markRecoveryDays(
            _day,
            _lastDay,
            note: note.isEmpty ? null : note,
          );
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorText = userMessageFor(error);
      });
      return;
    }
    if (!mounted) return;
    Navigator.of(context).pop();
  }
}
