import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/core/widgets/field_error_text.dart';
import 'package:menfit_app/features/wellbeing/domain/wellbeing_event.dart';
import 'package:menfit_app/features/wellbeing/presentation/widgets/wellbeing_glyphs.dart';

class EventDialogFields extends StatelessWidget {
  const EventDialogFields({
    required this.day,
    required this.type,
    required this.titleController,
    required this.notesController,
    required this.savedTitles,
    required this.saveForFuture,
    required this.error,
    required this.busy,
    required this.onPickDate,
    required this.onTypeChanged,
    required this.onRemoveTitle,
    required this.onSelectTitle,
    required this.onSaveForFuture,
    required this.onTitleChanged,
    super.key,
  });

  final LocalDate day;
  final WellbeingEventType? type;
  final TextEditingController titleController;
  final TextEditingController notesController;
  final List<String> savedTitles;
  final bool saveForFuture;
  final String? error;
  final bool busy;
  final VoidCallback onPickDate;
  final ValueChanged<WellbeingEventType> onTypeChanged;
  final ValueChanged<String> onRemoveTitle;
  final ValueChanged<String> onSelectTitle;
  final ValueChanged<bool> onSaveForFuture;
  final ValueChanged<String> onTitleChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppTokens>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: busy ? null : onPickDate,
          borderRadius: BorderRadius.circular(tokens.radiusSm),
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Date',
              prefixIcon: Icon(Icons.calendar_today_outlined),
              border: OutlineInputBorder(),
            ),
            child: Text(
              DateFormat('EEEE, MMMM d, yyyy').format(
                DateTime(day.year, day.month, day.day),
              ),
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ),
        SizedBox(height: tokens.spacingMd),
        Text('Event Type', style: theme.textTheme.labelMedium),
        SizedBox(height: tokens.spacingXs),
        Wrap(
          spacing: tokens.spacingSm,
          runSpacing: tokens.spacingXs,
          children: [
            for (final value in WellbeingEventType.values)
              ChoiceChip(
                selected: type == value,
                onSelected: busy ? null : (_) => onTypeChanged(value),
                avatar: Icon(
                  eventTypeIcon(value),
                  size: 16,
                  color: eventTypeColor(value, theme.colorScheme.primary),
                ),
                label: Text(
                  value == WellbeingEventType.other
                      ? 'Other'
                      : value.defaultTitle,
                ),
              ),
          ],
        ),
        SizedBox(height: tokens.spacingMd),
        if (type == WellbeingEventType.other && savedTitles.isNotEmpty) ...[
          Text('Saved Templates', style: theme.textTheme.labelSmall),
          SizedBox(height: tokens.spacingXs),
          Wrap(
            spacing: tokens.spacingSm,
            runSpacing: tokens.spacingXs,
            children: [
              for (final title in savedTitles)
                InputChip(
                  key: ValueKey(title),
                  label: Text(title),
                  onPressed: busy ? null : () => onSelectTitle(title),
                  onDeleted: busy ? null : () => onRemoveTitle(title),
                  deleteButtonTooltipMessage: 'Remove saved name',
                ),
            ],
          ),
          SizedBox(height: tokens.spacingSm),
        ],
        TextField(
          controller: titleController,
          enabled: !busy,
          decoration: const InputDecoration(
            labelText: 'Event Name',
            hintText: 'e.g. Intimacy, Sprained Ankle, Beach Holiday',
            border: OutlineInputBorder(),
          ),
          onChanged: onTitleChanged,
        ),
        if (error != null)
          Padding(
            padding: EdgeInsets.only(top: tokens.spacingXs),
            child: FieldErrorText(error!),
          ),
        if (type == WellbeingEventType.other) ...[
          SizedBox(height: tokens.spacingXs),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            value: saveForFuture,
            onChanged: busy ? null : (value) => onSaveForFuture(value ?? false),
            title: const Text('Save event name for future use'),
            controlAffinity: ListTileControlAffinity.leading,
          ),
        ],
        SizedBox(height: tokens.spacingSm),
        TextField(
          controller: notesController,
          enabled: !busy,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Notes (Optional)',
            hintText: 'Add details or context...',
            border: OutlineInputBorder(),
          ),
        ),
        SizedBox(height: tokens.spacingLg),
      ],
    );
  }
}

IconData eventTypeIcon(WellbeingEventType? type) => switch (type) {
  WellbeingEventType.intimacy => intimacyGlyph,
  WellbeingEventType.injury => injuryGlyph,
  WellbeingEventType.holiday => holidayGlyph,
  WellbeingEventType.other => otherEventGlyph,
  null => Icons.event_outlined,
};

Color eventTypeColor(WellbeingEventType? type, Color fallback) =>
    switch (type) {
      WellbeingEventType.intimacy => intimacyGlyphColor,
      WellbeingEventType.injury => injuryGlyphColor,
      WellbeingEventType.holiday => holidayGlyphColor,
      WellbeingEventType.other => otherEventGlyphColor,
      null => fallback,
    };
