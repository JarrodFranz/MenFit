/// Every sentence this feature says to the user, in one auditable place.
///
/// Body weight is the most eating-disorder-sensitive surface in this app,
/// so the copy is held to `knowledge/domain/mens_health.md` and to the
/// ED-safe rules `features/nutrition/domain/nutrition_validation.dart`
/// already states for food. Concretely, nothing here may:
///
/// - frame a reading as a gain or a loss, as progress or setback, as good
///   or bad. The exact vocabulary is not listed here — it lives in
///   `test/features/weight/weight_test_vocabulary.dart` as
///   `forbiddenWeightVocabulary`, which is the single list two gates read:
///   `weight_copy_test.dart` runs it over every string in this file *and*
///   over `domain/weight_validation.dart`'s messages, and
///   `weight_screen_test.dart` runs it over what the assembled screen
///   actually renders (widget copy, chart semantics and tooltips, menu and
///   picker labels, and the dialogs). A word added there fails both;
/// - imply a direction is preferable, which is also why the chart has one
///   colour and no red/green anywhere;
/// - state or imply a medical claim;
/// - interpolate a logged value (S2,
///   `knowledge/engineering/security_and_privacy.md`). These are fixed
///   strings; the reading itself is rendered separately by
///   `weight_format.dart`.
library;

import 'package:menfit_app/core/domain/units.dart';
import 'package:menfit_app/features/weight/domain/weight_trend.dart';
import 'package:menfit_app/features/weight/presentation/weight_format.dart';

/// How the smoothed line moved, said without a verdict.
///
/// "Trending upward"/"downward" describes a line on a chart. There is no
/// second clause telling her what it means, because the app does not know
/// and it is not the app's to say.
String weightTrendSentence(WeightTrendDirection direction) =>
    switch (direction) {
      WeightTrendDirection.rising => 'Trending upward across this range.',
      WeightTrendDirection.falling => 'Trending downward across this range.',
      WeightTrendDirection.steady => 'Holding steady across this range.',
      WeightTrendDirection.undetermined =>
        'Not enough readings yet to show a trend.',
    };

/// The fluid-shift explainer that sits under the chart — the sentence this
/// whole feature exists to be able to say.
///
/// Unit-aware only in the magnitude it names, so an imperial user isn't
/// told about kilograms she never sees.
String weightFluidNote(UnitSystem unitSystem) =>
    'Readings move from day to day mostly with fluid — water, salt, what '
    "you've eaten and when, sleep, training load. A shift of a "
    '${weightUnitWord(unitSystem)} or more between two mornings is ordinary '
    "and doesn't reflect a longer-term change. The smoothed line reads "
    'across those swings; the dots are the individual readings behind it.';

/// Shown in place of a trend line when too few days carry a reading.
const String weightMinimumDataNote =
    'A trend line needs readings on at least $minimumDaysForWeightTrend '
    'days. Until then these are the readings on their own — a line through '
    'fewer points would look more certain than it is.';

/// Shown when nothing has ever been logged.
const String weightEmptyStateMessage =
    "No weight readings yet. Log one whenever you'd like to, and the trend "
    'builds itself from there.';

/// Shown when readings exist, but none of them fall inside the range the
/// chart is currently set to.
///
/// Distinct from [weightEmptyStateMessage] on purpose. Telling a user who
/// has months of history that she has "no weight readings yet" is simply
/// false, and reading it as an invitation to log one *now* — because the
/// chart looks empty — is the nudge toward daily weighing this feature is
/// built to avoid. This sentence says what is actually true (the window is
/// empty, the history is not) and points at the control that fixes it.
const String weightRangeEmptyMessage =
    'Nothing was logged in this stretch. Your earlier readings are still '
    'here — widen the range to see them.';

/// Section and screen title.
const String weightSectionTitle = 'Weight';

/// Label above the most recent reading.
const String weightLatestLabel = 'Latest reading';
