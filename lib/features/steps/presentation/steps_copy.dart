/// Every user-visible string on the steps screen, in one place so the copy
/// can be reviewed (and tested) as copy rather than hunted through widgets.
///
/// Tone rule for this surface: a step count is a measurement, never a
/// verdict. "Below target" may appear as a *count* ("4 of 7 days at
/// target"); it may never appear as a judgement about the person, and no
/// string here praises or scolds. The same rule that governs
/// `features/weight`'s vocabulary applies for the same reason — the number
/// is theirs, the app just reports it.
library;

const String stepsScreenTitle = 'Steps';

/// Shown while the health platform is still answering whether step access
/// has been granted, so a permitted device never flashes the permission
/// prompt on the way to its data.
const String stepsCheckingMessage = 'Checking step access…';

/// Shown on the permission panel when the platform never answered within
/// `StepsCheckingPanel`'s timeout. The spinner gives way rather than
/// spinning forever: an unanswered check is indistinguishable from a
/// refused one after long enough, and they are better served by the button
/// than by a wheel.
const String stepsStillCheckingNote =
    'Still checking… you can try allowing access.';

/// Shown on web/Windows, where there is no health platform to read from.
/// Honest rather than aspirational: nothing here is "coming soon".
///
/// Two bodies, because the sentence changes when there is history to show.
/// "Nothing for the app to read" is true of *this device's platform* and
/// false of the screen as a whole when a phone has already synced days into
/// the local database — the panel must not contradict the chart under it.
const String stepsUnsupportedTitle =
    "Step counts aren't available on this device.";
const String stepsUnsupportedBody =
    'Steps are read from Health Connect on Android and Apple Health on '
    'iOS. This device has neither, so there is nothing for the app to '
    'read.';
const String stepsUnsupportedBodyWithHistory =
    'Steps are read from Health Connect on Android and Apple Health on '
    "iOS. This device can't read new step counts; the history below was "
    'synced on your phone.';

/// Shown when the platform can supply steps but the user has fitness-device
/// sync switched off. Same two-body rule as the unsupported case above.
const String stepsSyncOffTitle = 'Step syncing is off.';
const String stepsSyncOffBody =
    'Turn on "Sync Fitness Device" in Settings and your daily step counts '
    'will appear here.';
const String stepsSyncOffBodyWithHistory =
    'Turn on "Sync Fitness Device" in Settings to keep this up to date. '
    'The history below is what was synced before it was switched off.';
const String stepsSyncOffAction = 'Open Settings';

/// Shown when sync is on but the health platform has not granted read
/// access yet.
const String stepsPermissionTitle = 'Step access is not granted yet.';
const String stepsPermissionBody =
    'Your step counts are read from your health platform and stay on this '
    'device.';
const String stepsPermissionAction = 'Allow step access';

/// Shown after a permission request that came back refused. Deliberately
/// not a re-ask loop: it says where the switch lives and stops.
const String stepsPermissionRefusedBody =
    'Step access was not granted. You can change it in your health '
    "platform's settings whenever you want to.";

/// Shown when the platform is available but this particular range has no
/// rows at all.
const String stepsRangeEmptyTitle = 'No step data for this range.';
const String stepsRangeEmptyBody =
    'Days with no recorded step count are left blank — they are never '
    'counted as zero.';

const String stepsRefreshTooltip = 'Refresh steps';

const String stepsSyncFailedMessage =
    "Couldn't read steps just now. Everything already saved is still here.";

const String stepsTotalLabel = 'Total';
const String stepsAverageLabel = 'Daily average';
const String stepsAtTargetLabel = 'Days at target';

const String stepsHistoryHeading = 'Daily';

/// The list row shown for a day inside the range that has no row at all.
const String stepsNoDataRowLabel = 'No data';

/// Caption under the average and the at-target count. Both are computed
/// over days that actually have a row, and the caption says so — an
/// average silently divided by calendar days would understate every gap
/// into a lower number and read as a fabricated fact.
String stepsDaysWithDataCaption(int daysWithData) {
  return daysWithData == 1
      ? 'of 1 day with data'
      : 'of $daysWithData days with data';
}

/// Note under the chart when part of the range has no rows.
String stepsMissingDaysNote(int missingDays) {
  return missingDays == 1
      ? '1 day in this range has no recorded step count.'
      : '$missingDays days in this range have no recorded step count.';
}
