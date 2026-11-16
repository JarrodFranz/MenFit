import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/core/domain/entity_id.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/wellbeing/domain/wellbeing_event.dart';
import 'package:menfit_app/features/wellbeing/presentation/widgets/event_dialog_fields.dart';
import 'package:menfit_app/features/wellbeing/wellbeing_providers.dart';

/// Dialog for logging, editing, or deleting a discrete life event.
class EventDialog extends ConsumerStatefulWidget {
  const EventDialog({super.key, this.existing, this.initialDay});

  final WellbeingEvent? existing;
  final LocalDate? initialDay;

  static Future<void> show(
    BuildContext context, {
    WellbeingEvent? existing,
    LocalDate? initialDay,
  }) {
    return showDialog<void>(
      context: context,
      builder: (_) => EventDialog(existing: existing, initialDay: initialDay),
    );
  }

  @override
  ConsumerState<EventDialog> createState() => _EventDialogState();
}

class _EventDialogState extends ConsumerState<EventDialog> {
  late LocalDate _day;
  WellbeingEventType? _type;
  late TextEditingController _titleController;
  late TextEditingController _notesController;
  bool _saveForFuture = false;
  String? _titleError;
  bool _isSaving = false;
  List<String> _savedTitles = const [];

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _day = existing?.day ?? widget.initialDay ?? LocalDate.today();
    _type = existing?.type;
    _titleController = TextEditingController(
      text: existing?.title ?? '',
    );
    _notesController = TextEditingController(text: existing?.notes ?? '');
    _loadSavedTitles();
    _saveForFuture =
        (existing?.isCustomSaved ?? false) &&
        _savedTitles.contains(existing?.title);
  }

  void _loadSavedTitles() {
    try {
      _savedTitles = ref.read(customWellbeingEventStoreProvider).savedTitles();
    } on Object {
      _titleError = 'Could not load saved event names.';
    }
  }

  Future<void> _removeTitle(String title) async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    try {
      await ref.read(customWellbeingEventStoreProvider).removeTitle(title);
      if (!mounted) return;
      setState(() {
        _savedTitles = _savedTitles.where((name) => name != title).toList();
        if (_titleController.text.trim() == title) _saveForFuture = false;
        _titleError = null;
      });
    } on Object {
      if (mounted) setState(() => _titleError = 'Could not remove saved name.');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onTypeChanged(WellbeingEventType newType) {
    setState(() {
      _type = newType;
      if (newType != WellbeingEventType.other) {
        _titleController.text = newType.defaultTitle;
        _titleError = null;
      } else {
        if (_titleController.text == WellbeingEventType.intimacy.defaultTitle ||
            _titleController.text == WellbeingEventType.injury.defaultTitle ||
            _titleController.text == WellbeingEventType.holiday.defaultTitle) {
          _titleController.clear();
        }
      }
    });
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(_day.year, _day.month, _day.day),
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1, 12, 31),
    );
    if (picked != null && mounted) {
      setState(() => _day = LocalDate(picked.year, picked.month, picked.day));
    }
  }

  Future<void> _save() async {
    final type = _type;
    if (type == null || _isSaving) return;

    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() => _titleError = 'Please enter an event name.');
      return;
    }

    setState(() {
      _isSaving = true;
      _titleError = null;
    });

    try {
      final now = DateTime.now().toUtc();
      final event = WellbeingEvent(
        id: widget.existing?.id ?? EntityId.generate(),
        day: _day,
        type: type,
        title: title,
        isCustomSaved: _type == WellbeingEventType.other && _saveForFuture,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        createdAt: widget.existing?.createdAt ?? now,
        updatedAt: now,
      );

      final repo = ref.read(wellbeingRepositoryProvider);
      await repo.saveEvent(event);

      if (_type == WellbeingEventType.other && _saveForFuture) {
        // A secondary preference failure must not invite a duplicate event.
        try {
          await ref.read(customWellbeingEventStoreProvider).saveTitle(title);
        } on Object {
          // The event is already saved; never log sensitive title failures.
        }
      }

      if (mounted) Navigator.of(context).pop();
    } on Object catch (_) {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _titleError = 'Failed to save event. Please try again.';
        });
      }
    }
  }

  Future<void> _delete() async {
    final existing = widget.existing;
    if (existing == null || _isSaving) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Event?'),
        content: Text('Are you sure you want to delete "${existing.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _isSaving = true);
      try {
        await ref.read(wellbeingRepositoryProvider).deleteEvent(existing.id);
        if (mounted) Navigator.of(context).pop();
      } on Object {
        if (mounted) {
          setState(() {
            _isSaving = false;
            _titleError = 'Failed to delete event. Please try again.';
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppTokens>()!;
    final isEditing = widget.existing != null;
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radiusLg),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(tokens.spacingLg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(
                    eventTypeIcon(_type),
                    color: eventTypeColor(_type, theme.colorScheme.primary),
                    size: 24,
                  ),
                  SizedBox(width: tokens.spacingSm),
                  Expanded(
                    child: Text(
                      isEditing ? 'Edit Life Event' : 'Log Life Event',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (isEditing)
                    IconButton(
                      icon: Icon(
                        Icons.delete_outline,
                        color: theme.colorScheme.error,
                      ),
                      tooltip: 'Delete event',
                      onPressed: _isSaving ? null : _delete,
                    ),
                ],
              ),
              SizedBox(height: tokens.spacingMd),

              EventDialogFields(
                day: _day,
                type: _type,
                titleController: _titleController,
                notesController: _notesController,
                savedTitles: _savedTitles,
                saveForFuture: _saveForFuture,
                error: _titleError,
                busy: _isSaving,
                onPickDate: _pickDate,
                onTypeChanged: _onTypeChanged,
                onRemoveTitle: _removeTitle,
                onSelectTitle: (title) => setState(() {
                  _titleController.text = title;
                  _titleError = null;
                }),
                onSaveForFuture: (value) =>
                    setState(() => _saveForFuture = value),
                onTitleChanged: (_) => setState(() => _titleError = null),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSaving ? null : () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  SizedBox(width: tokens.spacingSm),
                  FilledButton.icon(
                    onPressed: _isSaving || _type == null ? null : _save,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.check),
                    label: Text(isEditing ? 'Save Changes' : 'Log Event'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
