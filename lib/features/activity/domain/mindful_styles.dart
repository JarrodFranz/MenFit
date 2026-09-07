import 'package:menfit_app/features/activity/domain/activity.dart';

/// The single source of truth for the mindful-session style and focus-area
/// labels.
///
/// These lists were duplicated between the exercise hub's literals and the
/// mindful tracker screen's private `_yogaStyles`/`_pilatesStyles`/
/// `_focusAreas` constants, which is how the hub's "Restorative Yin" and the
/// tracker's separate "Restorative"/"Yin" entries drifted apart. Persisted
/// values (`WorkoutDetails`' `style`/`focusArea`) are free-form strings, so a
/// stored label that is no longer in these lists must still render — treat
/// them as the *offered* choices, never as a closed set to validate against.
abstract final class MindfulStyles {
  static const List<String> yogaStyles = [
    'Vinyasa',
    'Yin',
    'Hatha',
    'Ashtanga',
    'Power Yoga',
    'Restorative',
    'Kundalini',
  ];

  static const List<String> pilatesStyles = [
    'Mat Pilates',
    'Reformer Pilates',
    'Classical',
    'Contemporary',
    'Core Power',
  ];

  static const List<String> focusAreas = [
    'Full Body Flow',
    'Core & Spine',
    'Hip Opening',
    'Shoulders & Upper Body',
    'Balance & Stability',
    'Mobility & Recovery',
  ];

  /// The styles offered for [type]. Pilates has its own vocabulary; every
  /// other mindful type (yoga today) uses [yogaStyles].
  static List<String> stylesFor(ActivityType type) =>
      type == ActivityType.pilates ? pilatesStyles : yogaStyles;
}
