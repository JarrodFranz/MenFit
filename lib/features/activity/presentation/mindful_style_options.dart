import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/activity/domain/mindful_styles.dart';

/// The style chips offered on the manual-entry mindful (yoga/pilates)
/// section for activity [type], given the currently-selected
/// [currentStyle].
///
/// [MindfulStyles.stylesFor] is the vocabulary offered for a fresh entry.
/// Editing an existing activity can carry an older label that vocabulary no
/// longer contains — the mindful style lists have drifted and been
/// consolidated before (see `MindfulStyles`'s doc comment), and persisted
/// `style`/`focusArea` values are free-form strings, never validated
/// against a closed set. Dropping or remapping [currentStyle] here would
/// silently change what she logged, so a value the offered list doesn't
/// recognise is appended as an extra, already-selected chip instead of
/// being lost.
///
/// The empty string is the one value that is **not** appended: it is what
/// "no style" is stored as (the yoga sequence runner writes it for a
/// sequence with no style, and a type change clears it — see
/// `ManualEntryController.updateActivityType`), and a blank chip is not a
/// choice she can read or make.
List<String> mindfulStyleChoices(ActivityType type, String currentStyle) {
  final offered = MindfulStyles.stylesFor(type);
  if (currentStyle.isEmpty || offered.contains(currentStyle)) return offered;
  return [...offered, currentStyle];
}

/// The mindful style to keep when the entry's activity type changes from
/// [from] to [to] — [current], or `''` when it belonged to the type she has
/// just left.
///
/// Yoga and Pilates offer different vocabularies, so carrying 'Vinyasa'
/// into a Pilates entry would show a style she never chose as chosen (the
/// invented-value trap `MindfulWorkoutDetails.rpe` documents). Only a label
/// the *old* type offered and the new one does not is dropped: a legacy or
/// free-form value belongs to neither list, is hers, and stays.
///
/// Focus areas need no equivalent — [MindfulStyles.focusAreas] is one list
/// shared by both types.
String mindfulStyleAfterTypeChange({
  required String current,
  required ActivityType from,
  required ActivityType to,
}) {
  if (current.isEmpty) return current;
  final offered = MindfulStyles.stylesFor(to);
  if (offered.contains(current)) return current;
  return MindfulStyles.stylesFor(from).contains(current) ? '' : current;
}

/// Same idea as [mindfulStyleChoices], for the focus-area chips.
List<String> mindfulFocusAreaChoices(String currentFocusArea) {
  const offered = MindfulStyles.focusAreas;
  if (currentFocusArea.isEmpty || offered.contains(currentFocusArea)) {
    return offered;
  }
  return [...offered, currentFocusArea];
}
