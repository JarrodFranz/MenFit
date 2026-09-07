import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:menfit_app/core/theme/tokens.dart';

/// What the user decided in [DataExportNoticeDialog]. Returned only when she
/// chose to go ahead — declining is `null`, not a choice with a `false` in
/// it, so a caller cannot accidentally export by forgetting to check a flag.
class DataExportChoice {
  const DataExportChoice({required this.includeCycleAndWellbeing});

  /// Whether period records, check-ins, flare-ups and recovery days go into
  /// the file. Default off; only ever true because she ticked the box.
  final bool includeCycleAndWellbeing;
}

/// Shown every time, before an export is built.
///
/// A real gate, not an announcement: [show] completes `null` when she backs
/// out, and the caller abandons the export — the same shape as
/// `features/nutrition/presentation/online_lookup_notice_dialog.dart`. Unlike
/// that one it is **not** remembered and shown once, because it is not a
/// consent to an ongoing behaviour: each export is a separate file, made from
/// whatever is in the database that day, going somewhere she picks that day.
///
/// The copy answers the four things a person needs in order to decide what to
/// do with a file: what is in it, where it comes from and goes, what is *not*
/// happening (nothing is sent anywhere), and the one part that would surprise
/// her — that entries she deleted are still in there until they are purged.
/// The voice is the app's: plain, unalarming, and not selling her a yes.
///
/// ## Why cycle and wellbeing data is a checkbox, and defaults to off
///
/// Everything else in the file is a run, a meal, a weight. The four S3 tables
/// are period records, daily check-ins, flare-ups and recovery days, and a
/// file containing those is a different object to hand to a coach, a
/// clinician, or a cloud drive (`knowledge/engineering/security_and_privacy.md`
/// — reproductive data is the tier whose strongest protection is not being
/// somewhere in readable form at all). Off by default because the safe
/// version of this file is the common case, and because an opt-out she has to
/// notice is not a decision she made.
class DataExportNoticeDialog extends StatefulWidget {
  const DataExportNoticeDialog({super.key});

  /// Returns her choice, or `null` to abandon the export — including when the
  /// dialog is dismissed by tapping outside or by the system back gesture,
  /// which are both ways of saying no.
  static Future<DataExportChoice?> show(BuildContext context) {
    return showDialog<DataExportChoice>(
      context: context,
      builder: (_) => const DataExportNoticeDialog(),
    );
  }

  @override
  State<DataExportNoticeDialog> createState() => _DataExportNoticeDialogState();
}

class _DataExportNoticeDialogState extends State<DataExportNoticeDialog> {
  bool _includeCycleAndWellbeing = false;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final textTheme = Theme.of(context).textTheme;

    return AlertDialog(
      title: const Text('Save a copy of your data'),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This makes one file containing everything you have logged: '
                'your activities and their routes, food and water, weight, '
                'steps, strength routines, yoga sequences, achievements and '
                'challenges, and your profile.',
                style: textTheme.bodyMedium,
              ),
              SizedBox(height: tokens.spacingMd),
              // On the web there is no save dialog to choose a destination
              // in - the browser takes the download to wherever it puts
              // downloads - so promising her a choice she does not get would
              // be the one false sentence in a screen about trust.
              Text(
                kIsWeb
                    ? 'The file is made here on this device, and your browser '
                          'will download it. Nothing is sent to us or to '
                          'anyone else.'
                    : 'The file is made here on this device, and it only goes '
                          'where you choose to save it. Nothing is sent to us '
                          'or to anyone else.',
                style: textTheme.bodyMedium,
              ),
              SizedBox(height: tokens.spacingMd),
              // Named because it is the one thing in the file she would not
              // predict, and finding it later without being told would be
              // worse than being told now.
              Text(
                'Entries you have deleted are included too, if the app has '
                'not finished clearing them out yet. It is still your data '
                'until it is gone.',
                style: textTheme.bodyMedium,
              ),
              SizedBox(height: tokens.spacingMd),
              CheckboxListTile(
                key: const Key('dataExportIncludeCycleAndWellbeing'),
                value: _includeCycleAndWellbeing,
                onChanged: (value) => setState(() {
                  _includeCycleAndWellbeing = value ?? false;
                }),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                title: const Text('Include cycle and wellbeing data'),
                subtitle: Text(
                  'Period records, daily check-ins, flare-ups and recovery '
                  'days. Left out unless you ask for them, so the file is '
                  'safer to share.',
                  style: textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          key: const Key('dataExportNoticeDecline'),
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Not now'),
        ),
        FilledButton(
          key: const Key('dataExportNoticeAccept'),
          onPressed: () => Navigator.of(context).pop(
            DataExportChoice(
              includeCycleAndWellbeing: _includeCycleAndWellbeing,
            ),
          ),
          child: const Text('Choose where to save'),
        ),
      ],
    );
  }
}
