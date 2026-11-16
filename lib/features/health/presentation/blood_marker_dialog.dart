import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/core/domain/entity_id.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/errors/error_messages.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/health/domain/blood_marker_reading.dart';
import 'package:menfit_app/features/health/domain/health_reading_validation.dart';
import 'package:menfit_app/features/health/health_providers.dart';
import 'package:menfit_app/features/health/presentation/blood_marker_copy.dart';

/// Add or edit a glucose reading. Same mechanics as `BloodPressureDialog`.
class BloodMarkerDialog extends ConsumerStatefulWidget {
  const BloodMarkerDialog({
    this.existing,
    this.defaultUnit = BloodMarkerUnit.mmolPerL,
    super.key,
  });

  final BloodMarkerReading? existing;

  /// Unit for a new reading: the caller passes the latest reading's unit.
  final BloodMarkerUnit defaultUnit;

  static Future<void> show(
    BuildContext context, {
    BloodMarkerReading? existing,
    BloodMarkerUnit defaultUnit = BloodMarkerUnit.mmolPerL,
  }) => showDialog<void>(
    context: context,
    // Shell overlays explicitly target the root navigator (ADR 002).
    // ignore: avoid_redundant_argument_values
    useRootNavigator: true,
    builder: (_) =>
        BloodMarkerDialog(existing: existing, defaultUnit: defaultUnit),
  );

  @override
  ConsumerState<BloodMarkerDialog> createState() => _BloodMarkerDialogState();
}

class _BloodMarkerDialogState extends ConsumerState<BloodMarkerDialog> {
  static const BloodMarker _marker = BloodMarker.glucose;

  final _form = GlobalKey<FormState>();
  final _valueField = GlobalKey<FormFieldState<String>>();
  late final TextEditingController _value;
  late final TextEditingController _note;
  late BloodMarkerUnit _unit;
  GlucoseContext? _context;
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
    _unit = existing?.unit ?? widget.defaultUnit;
    _context = existing?.context;
    _value = TextEditingController(text: _editable(existing?.value));
    _note = TextEditingController(text: existing?.note);
    _measuredAt =
        existing?.measuredAt ??
        DateTime(_day.year, _day.month, _day.day, now.hour, now.minute).toUtc();
  }

  @override
  void dispose() {
    _value.dispose();
    _note.dispose();
    super.dispose();
  }

  static String? _editable(double? value) {
    if (value == null) return null;
    final text = value.toString();
    return text.endsWith('.0') ? text.substring(0, text.length - 2) : text;
  }

  // Comma is a decimal separator in many locales.
  String get _normalisedValue => _value.text.trim().replaceAll(',', '.');

  void _setUnit(BloodMarkerUnit unit) {
    setState(() => _unit = unit);
    // Re-check the typed number against the new unit; never convert it.
    if (_value.text.trim().isNotEmpty) _valueField.currentState?.validate();
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
              ? 'Add blood glucose reading'
              : 'Edit blood glucose reading',
        ),
        content: Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                key: _valueField,
                controller: _value,
                enabled: !_busy,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp('[0-9.,]')),
                  LengthLimitingTextInputFormatter(8),
                ],
                decoration: InputDecoration(
                  labelText: 'Glucose (${_unit.label})',
                  errorMaxLines: 3,
                ),
                validator: (_) =>
                    bloodMarkerValueError(_marker, _unit, _normalisedValue),
              ),
              SizedBox(height: tokens.spacingSm),
              Wrap(
                spacing: tokens.spacingSm,
                runSpacing: tokens.spacingXs,
                children: [
                  for (final unit in _marker.units)
                    ChoiceChip(
                      label: Text(unit.label),
                      selected: unit == _unit,
                      onSelected: _busy ? null : (_) => _setUnit(unit),
                    ),
                ],
              ),
              SizedBox(height: tokens.spacingSm),
              DropdownButtonFormField<GlucoseContext>(
                initialValue: _context,
                isExpanded: true,
                hint: const Text(glucoseContextHint),
                decoration: const InputDecoration(
                  labelText: 'When measured (optional)',
                ),
                items: [
                  for (final c in GlucoseContext.values)
                    DropdownMenuItem(value: c, child: Text(c.label)),
                ],
                onChanged: _busy ? null : (c) => setState(() => _context = c),
              ),
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
    final note = _note.text.trim();
    final reading = BloodMarkerReading(
      id: widget.existing?.id ?? EntityId.generate(),
      day: _day,
      measuredAt: _measuredAt,
      marker: _marker,
      value: double.parse(_normalisedValue),
      unit: _unit,
      context: _context,
      note: note.isEmpty ? null : note,
      createdAt: createdAt,
      updatedAt: now.isBefore(createdAt) ? createdAt : now,
    );
    await _write(
      () => ref.read(healthReadingsRepositoryProvider).saveBloodMarker(reading),
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
          .deleteBloodMarker(widget.existing!.id),
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
