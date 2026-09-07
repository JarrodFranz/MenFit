import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/errors/error_messages.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/streaks/domain/recovery_day_entry.dart';
import 'package:menfit_app/features/streaks/streaks_providers.dart';
import 'package:menfit_app/features/wellbeing/domain/daily_checkin.dart';
import 'package:menfit_app/features/wellbeing/domain/flare_event.dart';
import 'package:menfit_app/features/wellbeing/presentation/checkin_sheet.dart';
import 'package:menfit_app/features/wellbeing/presentation/flare_dialog.dart';
import 'package:menfit_app/features/wellbeing/presentation/widgets/wellbeing_glyphs.dart';

// The row widgets and day formatting used by the wellbeing history list.
// Split out of `presentation/wellbeing_screen.dart` to keep that file to
// the screen itself (coding_standards.md's ~300-line splitting rule).

/// One day, e.g. `3 Mar`.
String formatHistoryDay(LocalDate date) {
  return DateFormat('d MMM').format(DateTime(date.year, date.month, date.day));
}

/// The calendar span a flare covers, as a row title reads it:
/// `3 Mar` for a single day, `3–7 Mar` within one month, `28 Feb – 3 Mar`
/// across a month boundary. A multi-day flare is one record, so its row must
/// read as the whole stretch rather than only its first day.
String formatFlareSpan(FlareEvent flare) {
  final first = flare.day;
  final last = flare.lastDay;
  if (first == last) return formatHistoryDay(first);
  if (first.year == last.year && first.month == last.month) {
    return '${first.day}–${formatHistoryDay(last)}';
  }
  return '${formatHistoryDay(first)} – ${formatHistoryDay(last)}';
}

class WellbeingEmptyState extends StatelessWidget {
  const WellbeingEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(tokens.spacingLg),
        child: Column(
          children: [
            Icon(
              Icons.self_improvement_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(height: tokens.spacingMd),
            Text(
              'Nothing logged yet. Check-ins are optional — they help the '
              'app adapt to you.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class CheckinTile extends StatelessWidget {
  const CheckinTile({required this.checkin, super.key});

  final DailyCheckin checkin;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(
            checkinGlyph,
            color: colorScheme.primary,
            size: 20,
          ),
        ),
        title: Text(
          formatHistoryDay(checkin.day),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(_summaryFor(checkin)),
        onTap: () => CheckinSheet.show(
          context,
          day: checkin.day,
          existing: checkin,
        ),
      ),
    );
  }

  String _summaryFor(DailyCheckin checkin) {
    final parts = <String>[
      if (checkin.energy != null) 'Energy ${checkin.energy}',
      if (checkin.sleep != null) 'Sleep ${checkin.sleep}',
      if (checkin.soreness != null) 'Soreness ${checkin.soreness}',
      if (checkin.stress != null) 'Stress ${checkin.stress}',
      if (checkin.pain != null) 'Pain ${checkin.pain}',
      if (checkin.symptoms.isNotEmpty)
        if (checkin.symptoms.length == 1)
          '1 symptom'
        else
          '${checkin.symptoms.length} symptoms',
    ];
    return parts.isEmpty ? 'Checked in' : parts.join(' · ');
  }
}

class FlareTile extends StatelessWidget {
  const FlareTile({required this.flare, super.key});

  final FlareEvent flare;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: flareGlyphBackground(isDark: isDark),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            flareGlyph,
            color: flareGlyphColor,
            size: 20,
          ),
        ),
        title: Text(
          '${formatFlareSpan(flare)} · Flare-up',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${flare.severity.label} · ${flare.impact.label}'),
        onTap: () => FlareDialog.show(context, existing: flare),
      ),
    );
  }
}

/// A logged recovery day's row — shield icon, "Recovery day", and its note
/// if one was attached.
class RecoveryTile extends StatelessWidget {
  const RecoveryTile({required this.entry, super.key, this.onRemoved});

  final RecoveryDayEntry entry;

  /// Called once the day has actually been unmarked, before the
  /// undo snackbar is raised.
  ///
  /// Exists for one reason: this tile raises its snackbar on the ROOT
  /// [ScaffoldMessenger], which paints it in the root [Scaffold] — and a
  /// caller that shows this tile inside a bottom sheet has that sheet
  /// sitting on top of exactly where the snackbar appears, so its Undo
  /// action is invisible and untappable. Such a caller passes a callback
  /// that closes itself, which is what puts Undo back within reach.
  /// `null` (the wellbeing history list, which has nothing covering the
  /// snackbar) leaves the behaviour exactly as it was.
  final VoidCallback? onRemoved;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasNote = entry.note != null && entry.note!.trim().isNotEmpty;
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: recoveryGlyphBackground(isDark: isDark),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            recoveryGlyph,
            color: recoveryGlyphColor,
            size: 20,
          ),
        ),
        title: Text(
          '${formatHistoryDay(entry.day)} · Recovery day',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: hasNote ? Text(entry.note!) : null,
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          tooltip: 'Remove',
          onPressed: () => _remove(context),
        ),
      ),
    );
  }

  Future<void> _remove(BuildContext context) async {
    final day = entry.day;
    final previousNote = entry.note;
    // Captured SYNCHRONOUSLY, before any await. Unmarking the day removes
    // this entry from the stream, so on the wellbeing day sheet the
    // recovery section swaps straight to its empty text and THIS TILE
    // UNMOUNTS - after which `ref.read` throws a StateError and `context`
    // is dead, so an Undo written against them silently fails to restore
    // the day. The root container and the messenger both outlive the tile.
    // Same capture-before-unmount pattern as
    // `features/home/presentation/widgets/today_sheet.dart`.
    final container = ProviderScope.containerOf(context, listen: false);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await container.read(recoveryRepositoryProvider).unmarkRecoveryDay(day);
    } on Object catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(userMessageFor(error))));
      return;
    }
    // Before the snackbar, so a sheet that has to get out of its way is
    // already gone by the time it appears.
    onRemoved?.call();
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text('Recovery day removed'),
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              // Fire-and-forget, same convention as the streak card's own
              // undo action - a failure surfaces via the repository's
              // normal error path on the next read.
              unawaited(
                container
                    .read(recoveryRepositoryProvider)
                    .markRecoveryDay(day, note: previousNote),
              );
            },
          ),
        ),
      );
  }
}

class WellbeingDisclaimers extends StatelessWidget {
  const WellbeingDisclaimers({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final style = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );
    return Column(
      children: [
        Text(
          'Symptom tracking is informational only, not medical advice.',
          textAlign: TextAlign.center,
          style: style,
        ),
        SizedBox(height: tokens.spacingXs),
        Text(
          'This data stays on your device.',
          textAlign: TextAlign.center,
          style: style,
        ),
      ],
    );
  }
}
