import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/core/domain/entity_id.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/errors/error_messages.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/health/domain/blood_pressure_reading.dart';
import 'package:menfit_app/features/health/domain/health_reading_validation.dart';
import 'package:menfit_app/features/health/health_providers.dart';

class BloodPressureDialog extends ConsumerStatefulWidget {
  const BloodPressureDialog({this.existing, super.key});

  final BloodPressureReading? existing;

  static Future<void> show(
    BuildContext context, {
    BloodPressureReading? existing,
  }) => showDialog<void>(
    context: context,
    // Shell overlays explicitly target the root navigator (ADR 002).
    // ignore: avoid_redundant_argument_values
    useRootNavigator: true,
    builder: (_) => BloodPressureDialog(existing: existing),
  );

  @override
  ConsumerState<BloodPressureDialog> createState() =>
      _BloodPressureDialogState();
}

class _BloodPressureDialogState extends ConsumerState<BloodPressureDialog> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _systolic;
  late final TextEditingController _diastolic;
  late final TextEditingController _pulse;
  late final TextEditingController _note;
  late LocalDate _day;
  late DateTime _measuredAt;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    final now = DateTime.now();
    _day = existing?.day ?? LocalDate.fromDateTime(now);
    _systolic = TextEditingController(text: existing?.systolic.toString());
    _diastolic = TextEditingController(text: existing?.diastolic.toString());
    _pulse = TextEditingController(text: existing?.pulse?.toString());
    _note = TextEditingController(text: existing?.note);
    _measuredAt =
        existing?.measuredAt ??
        DateTime(_day.year, _day.month, _day.day, now.hour, now.minute).toUtc();
  }

  @override
  void dispose() {
    _systolic.dispose();
    _diastolic.dispose();
    _pulse.dispose();
    _note.dispose();
    super.dispose();
  }

  Widget _numberField(
    TextEditingController controller,
    String label,
    String? Function(String) validator,
  ) => TextFormField(
    controller: controller,
    enabled: !_busy,
    keyboardType: TextInputType.number,
    inputFormatters: [
      FilteringTextInputFormatter.digitsOnly,
      LengthLimitingTextInputFormatter(3),
    ],
    decoration: InputDecoration(labelText: label, errorMaxLines: 3),
    validator: (value) => validator((value ?? '').trim()),
  );

  String? _diastolicValidator(String input) {
    final own = diastolicError(input);
    if (own != null) return own;
    final systolic = _systolic.text.trim();
    if (systolicError(systolic) != null) return null;
    return bloodPressurePairError(int.parse(systolic), int.parse(input));
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final time = TimeOfDay.fromDateTime(_measuredAt.toLocal()).format(context);
    return PopScope(
      canPop: !_busy,
      child: AlertDialog(
        scrollable: true,
        title: Text(
          widget.existing == null
              ? 'Add blood pressure reading'
              : 'Edit blood pressure reading',
        ),
        content: Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              _numberField(
                _systolic,
                'Systolic, top number (mmHg)',
                systolicError,
              ),
              SizedBox(height: tokens.spacingSm),
              _numberField(
                _diastolic,
                'Diastolic, bottom number (mmHg)',
                _diastolicValidator,
              ),
              SizedBox(height: tokens.spacingSm),
              _numberField(_pulse, 'Pulse (bpm, optional)', pulseError),
              SizedBox(height: tokens.spacingSm),
              TextFormField(
                controller: _note,
                enabled: !_busy,
                maxLength: maxHealthNoteLength,
                decoration: const InputDecoration(
                  labelText: 'Note (optional)',
                  errorMaxLines: 3,
                ),
                validator: (value) => healthNoteError((value ?? '').trim()),
              ),
              TextButton.icon(
                onPressed: _busy ? null : _pickDay,
                icon: const Icon(Icons.calendar_today_outlined),
                label: Text('Date: ${_day.toIso()}'),
              ),
              TextButton.icon(
                onPressed: _busy ? null : _pickTime,
                icon: const Icon(Icons.schedule),
                label: Text('Time: $time'),
              ),
              if (_error != null)
                Semantics(liveRegion: true, child: Text(_error!)),
              if (widget.existing != null)
                TextButton.icon(
                  onPressed: _busy ? null : _delete,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Delete reading'),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: _busy ? null : () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: _busy ? null : _save,
            child: Text(_busy ? 'Saving…' : 'Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDay() async {
    final today = DateUtils.dateOnly(DateTime.now());
    final selected = DateTime(_day.year, _day.month, _day.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: selected.isAfter(today) ? today : selected,
      firstDate: DateTime(1),
      lastDate: today,
    );
    if (picked == null || !mounted) return;
    final time = _measuredAt.toLocal();
    setState(() {
      _day = LocalDate.fromDateTime(picked);
      _measuredAt = DateTime(
        picked.year,
        picked.month,
        picked.day,
        time.hour,
        time.minute,
      ).toUtc();
    });
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_measuredAt.toLocal()),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _measuredAt = DateTime(
        _day.year,
        _day.month,
        _day.day,
        picked.hour,
        picked.minute,
      ).toUtc();
    });
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final now = DateTime.now().toUtc();
    if (_measuredAt.isAfter(now) &&
        _measuredAt != widget.existing?.measuredAt) {
      setState(
        () => _error = 'Choose a measurement time that has already happened.',
      );
      return;
    }
    final createdAt = widget.existing?.createdAt ?? now;
    final pulse = _pulse.text.trim();
    final note = _note.text.trim();
    final reading = BloodPressureReading(
      id: widget.existing?.id ?? EntityId.generate(),
      day: _day,
      measuredAt: _measuredAt,
      systolic: int.parse(_systolic.text.trim()),
      diastolic: int.parse(_diastolic.text.trim()),
      pulse: pulse.isEmpty ? null : int.parse(pulse),
      note: note.isEmpty ? null : note,
      createdAt: createdAt,
      updatedAt: now.isBefore(createdAt) ? createdAt : now,
    );
    await _write(
      () => ref
          .read(healthReadingsRepositoryProvider)
          .saveBloodPressure(
            reading,
          ),
    );
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      // Shell overlays explicitly target the root navigator (ADR 002).
      // ignore: avoid_redundant_argument_values
      useRootNavigator: true,
      builder: (context) => AlertDialog(
        title: const Text('Delete reading?'),
        content: const Text('This permanently removes this reading.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await _write(
      () => ref
          .read(healthReadingsRepositoryProvider)
          .deleteBloodPressure(widget.existing!.id),
    );
  }

  Future<void> _write(Future<void> Function() action) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
      if (mounted) Navigator.of(context).pop();
    } on Object catch (error) {
      if (mounted) setState(() => _error = userMessageFor(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
