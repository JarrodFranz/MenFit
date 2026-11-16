import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/errors/error_messages.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/keto/keto_providers.dart';
import 'package:menfit_app/features/keto/presentation/keto_macros_card.dart';
import 'package:menfit_app/features/keto/presentation/ketone_reading_dialog.dart';
import 'package:menfit_app/features/nutrition/nutrition_providers.dart';

class KetoScreen extends ConsumerWidget {
  const KetoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final day = ref.watch(selectedNutritionDayProvider);
    final readings = ref.watch(ketoneReadingsProvider(day));
    return Scaffold(
      appBar: AppBar(title: const Text('Keto')),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: tokens.contentMaxWidth),
            child: ListView(
              padding: EdgeInsets.all(tokens.spacingMd),
              children: [
                _DayPicker(day: day),
                KetoMacrosCard(day: day),
                SizedBox(height: tokens.spacingMd),
                Text(
                  'Ketone readings',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Text(
                  'A manual log, not a monitoring or alerting service. '
                  'Readings are not interpreted. Follow your device '
                  'instructions and clinician’s advice. Not medical advice.',
                ),
                SizedBox(height: tokens.spacingSm),
                FilledButton.icon(
                  onPressed: () => KetoneReadingDialog.show(context, day: day),
                  icon: const Icon(Icons.add),
                  label: const Text('Add reading'),
                ),
                readings.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (error, _) => Column(
                    children: [
                      Text(userMessageFor(error)),
                      TextButton(
                        onPressed: () =>
                            ref.invalidate(ketoneReadingsProvider(day)),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                  data: (items) => Column(
                    children: [
                      if (items.isEmpty)
                        Padding(
                          padding: EdgeInsets.all(tokens.spacingMd),
                          child: const Text(
                            'No readings recorded for this day.',
                          ),
                        ),
                      for (final reading in items)
                        Card(
                          key: ValueKey(reading.id),
                          child: ListTile(
                            title: Text(
                              '${reading.type.label}: ${reading.result} '
                              '${reading.type.unit}',
                            ),
                            subtitle: Text(
                              DateFormat.jm().format(
                                reading.measuredAt.toLocal(),
                              ),
                            ),
                            trailing: const Icon(Icons.edit_outlined),
                            onTap: () => KetoneReadingDialog.show(
                              context,
                              day: day,
                              existing: reading,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DayPicker extends ConsumerWidget {
  const _DayPicker({required this.day});

  final LocalDate day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(selectedNutritionDayProvider.notifier);
    return Row(
      children: [
        IconButton(
          tooltip: 'Previous day',
          onPressed: controller.previousDay,
          icon: const Icon(Icons.chevron_left),
        ),
        Expanded(
          child: TextButton(
            onPressed: () async {
              final today = DateUtils.dateOnly(DateTime.now());
              final selected = DateTime(day.year, day.month, day.day);
              final picked = await showDatePicker(
                context: context,
                initialDate: selected.isAfter(today) ? today : selected,
                firstDate: DateTime(1),
                lastDate: today,
              );
              if (picked != null) {
                controller.select(LocalDate.fromDateTime(picked));
              }
            },
            child: Text(day == LocalDate.today() ? 'Today' : day.toIso()),
          ),
        ),
        IconButton(
          tooltip: 'Next day',
          onPressed: day.isBefore(LocalDate.today())
              ? controller.nextDay
              : null,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }
}
