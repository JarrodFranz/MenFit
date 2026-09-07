import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:menfit_app/core/config/shared_preferences_provider.dart';
import 'package:menfit_app/core/domain/entity_id.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/core/widgets/field_error_text.dart';
import 'package:menfit_app/features/wellbeing/domain/wellbeing_event.dart';
import 'package:menfit_app/features/wellbeing/presentation/widgets/wellbeing_glyphs.dart';
import 'package:menfit_app/features/wellbeing/wellbeing_providers.dart';

const String _savedEventTitlesKey = 'saved_custom_wellbeing_events';

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
  late WellbeingEventType _type;
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
    _type = existing?.type ?? WellbeingEventType.intimacy;
    _titleController = TextEditingController(
      text: existing?.title ?? _type.defaultTitle,
    );
    _notesController = TextEditingController(text: existing?.notes ?? '');
    _saveForFuture = existing?.isCustomSaved ?? false;
    _loadSavedTitles();
  }

  void _loadSavedTitles() {
    final prefs = ref.read(sharedPreferencesProvider);
    final list = prefs.getStringList(_savedEventTitlesKey) ?? const [];
    setState(() {
      _savedTitles = list;
    });
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
    if (picked != null) {
      setState(() {
        _day = LocalDate(picked.year, picked.month, picked.day);
      });
    }
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() {
        _titleError = 'Please enter an event name.';
      });
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
        type: _type,
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
        final prefs = ref.read(sharedPreferencesProvider);
        final current = List<String>.from(
          prefs.getStringList(_savedEventTitlesKey) ?? const [],
        );
        if (!current.contains(title)) {
          current.add(title);
          await prefs.setStringList(_savedEventTitlesKey, current);
        }
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
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
    if (existing == null) return;

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
      await ref.read(wellbeingRepositoryProvider).deleteEvent(existing.id);
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppTokens>()!;
    final isEditing = widget.existing != null;
    final dateStr = DateFormat(
      'EEEE, MMMM d, yyyy',
    ).format(DateTime(_day.year, _day.month, _day.day));

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
                    _iconForType(_type),
                    color: _colorForType(_type),
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
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      tooltip: 'Delete event',
                      onPressed: _delete,
                    ),
                ],
              ),
              SizedBox(height: tokens.spacingMd),

              // Date Picker Field
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(tokens.radiusSm),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    prefixIcon: Icon(Icons.calendar_today_outlined),
                    border: OutlineInputBorder(),
                  ),
                  child: Text(dateStr, style: theme.textTheme.bodyMedium),
                ),
              ),
              SizedBox(height: tokens.spacingMd),

              // Event Type Selector
              Text(
                'Event Type',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: tokens.spacingXs),
              Wrap(
                spacing: tokens.spacingSm,
                runSpacing: tokens.spacingXs,
                children: [
                  _typeChip(
                    type: WellbeingEventType.intimacy,
                    label: 'Intimacy',
                    icon: intimacyGlyph,
                    color: intimacyGlyphColor,
                  ),
                  _typeChip(
                    type: WellbeingEventType.injury,
                    label: 'Injury',
                    icon: injuryGlyph,
                    color: injuryGlyphColor,
                  ),
                  _typeChip(
                    type: WellbeingEventType.holiday,
                    label: 'Holiday',
                    icon: holidayGlyph,
                    color: holidayGlyphColor,
                  ),
                  _typeChip(
                    type: WellbeingEventType.other,
                    label: 'Other',
                    icon: otherEventGlyph,
                    color: otherEventGlyphColor,
                  ),
                ],
              ),
              SizedBox(height: tokens.spacingMd),

              // Reusable suggestions if Other is selected
              if (_type == WellbeingEventType.other &&
                  _savedTitles.isNotEmpty) ...[
                Text(
                  'Saved Templates',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: tokens.spacingXs),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    for (final saved in _savedTitles)
                      ActionChip(
                        avatar: const Icon(Icons.history, size: 14),
                        label: Text(
                          saved,
                          style: const TextStyle(fontSize: 12),
                        ),
                        onPressed: () {
                          setState(() {
                            _titleController.text = saved;
                            _titleError = null;
                          });
                        },
                      ),
                  ],
                ),
                SizedBox(height: tokens.spacingSm),
              ],

              // Event Title / Name
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Event Name',
                  hintText: 'e.g. Intimacy, Sprained Ankle, Beach Holiday',
                  border: const OutlineInputBorder(),
                  errorText: _titleError,
                ),
                onChanged: (_) {
                  if (_titleError != null) {
                    setState(() => _titleError = null);
                  }
                },
              ),
              if (_titleError != null)
                Padding(
                  padding: EdgeInsets.only(top: tokens.spacingXs),
                  child: FieldErrorText(_titleError!),
                ),

              // Save template checkbox if Other
              if (_type == WellbeingEventType.other) ...[
                SizedBox(height: tokens.spacingXs),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  value: _saveForFuture,
                  onChanged: (val) {
                    setState(() {
                      _saveForFuture = val ?? false;
                    });
                  },
                  title: const Text(
                    'Save event name for future use',
                    style: TextStyle(fontSize: 13),
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ],
              SizedBox(height: tokens.spacingSm),

              // Optional Notes
              TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                  hintText: 'Add details or context...',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: tokens.spacingLg),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSaving ? null : () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  SizedBox(width: tokens.spacingSm),
                  FilledButton.icon(
                    onPressed: _isSaving ? null : _save,
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

  Widget _typeChip({
    required WellbeingEventType type,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    final selected = _type == type;
    return ChoiceChip(
      selected: selected,
      onSelected: (val) {
        if (val) _onTypeChanged(type);
      },
      avatar: Icon(
        icon,
        size: 16,
        color: selected ? Colors.white : color,
      ),
      label: Text(label),
      selectedColor: color,
      labelStyle: TextStyle(
        color: selected ? Colors.white : null,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  IconData _iconForType(WellbeingEventType type) => switch (type) {
    WellbeingEventType.intimacy => intimacyGlyph,
    WellbeingEventType.injury => injuryGlyph,
    WellbeingEventType.holiday => holidayGlyph,
    WellbeingEventType.other => otherEventGlyph,
  };

  Color _colorForType(WellbeingEventType type) => switch (type) {
    WellbeingEventType.intimacy => intimacyGlyphColor,
    WellbeingEventType.injury => injuryGlyphColor,
    WellbeingEventType.holiday => holidayGlyphColor,
    WellbeingEventType.other => otherEventGlyphColor,
  };
}
