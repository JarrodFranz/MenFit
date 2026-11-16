import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/core/domain/entity_id.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/errors/error_messages.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/keto/domain/ketone_reading.dart';
import 'package:menfit_app/features/keto/domain/ketone_validation.dart';
import 'package:menfit_app/features/keto/keto_providers.dart';

class KetoneReadingDialog extends ConsumerStatefulWidget {
  const KetoneReadingDialog({required this.day, this.existing, super.key});

  final LocalDate day;
  final KetoneReading? existing;

  static Future<void> show(
    BuildContext context, {
    required LocalDate day,
    KetoneReading? existing,
  }) => showDialog<void>(
    context: context,
    // Shell overlays explicitly target the root navigator (ADR 002).
    // ignore: avoid_redundant_argument_values
    useRootNavigator: true,
    builder: (_) => KetoneReadingDialog(day: day, existing: existing),
  );

  @override
  ConsumerState<KetoneReadingDialog> createState() =>
      _KetoneReadingDialogState();
}

class _KetoneReadingDialogState extends ConsumerState<KetoneReadingDialog> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _result;
  late LocalDate _day;
  late DateTime _measuredAt;
  late KetoneMeasurementType _type;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    final now = DateTime.now();
    _day = existing?.day ?? widget.day;
    _type = existing?.type ?? KetoneMeasurementType.blood;
    _result = TextEditingController(text: existing?.result ?? '');
    _measuredAt =
        existing?.measuredAt ??
        DateTime(_day.year, _day.month, _day.day, now.hour, now.minute).toUtc();
  }

  @override
  void dispose() {
    _result.dispose();
    super.dispose();
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
              ? 'Add ketone reading'
              : 'Edit ketone reading',
        ),
        content: Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<KetoneMeasurementType>(
                initialValue: _type,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Measurement method',
                ),
                items: [
                  for (final type in KetoneMeasurementType.values)
                    DropdownMenuItem(value: type, child: Text(type.label)),
                ],
                onChanged: _busy
                    ? null
                    : (type) {
                        if (type == null || type == _type) return;
                        setState(() {
                          _type = type;
                          // A result has meaning only with its original method.
                          _result.clear();
                          _error = null;
                        });
                      },
              ),
              SizedBox(height: tokens.spacingMd),
              TextFormField(
                controller: _result,
                enabled: !_busy,
                maxLength: maxKetoneResultLength,
                decoration: InputDecoration(
                  labelText: 'Result (${_type.unit})',
                  helperText: _type == KetoneMeasurementType.urine
                      ? 'Copy the result and unit or category '
                            'printed on your strip.'
                      : 'Copy the number, LO or HI shown by your meter.',
                  helperMaxLines: 4,
                  errorMaxLines: 3,
                ),
                validator: (value) =>
                    ketoneResultError(_type, (value ?? '').trim()),
                textCapitalization: TextCapitalization.characters,
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
    final reading = KetoneReading(
      id: widget.existing?.id ?? EntityId.generate(),
      day: _day,
      measuredAt: _measuredAt,
      type: _type,
      result: _result.text.trim(),
      createdAt: createdAt,
      updatedAt: now.isBefore(createdAt) ? createdAt : now,
    );
    await _write(() => ref.read(ketoneRepositoryProvider).saveReading(reading));
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
      () =>
          ref.read(ketoneRepositoryProvider).deleteReading(widget.existing!.id),
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
