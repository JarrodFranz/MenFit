import 'package:meta/meta.dart';

/// Color blindness accommodation modes.
///
/// Implements colorblind-safe palettes (e.g. Okabe-Ito universally accessible
/// palette) that avoid confusing red/green or blue/yellow combinations, while
/// ensuring distinct secondary cues (icons and labels) are always present.
enum ColorBlindnessMode {
  none('Standard', 'Default brand palette'),
  protanopia('Protanopia', 'Red-blind / reduced red sensitivity'),
  deuteranopia('Deuteranopia', 'Green-blind / reduced green sensitivity'),
  tritanopia('Tritanopia', 'Blue-blind / reduced blue sensitivity'),
  monochromacy('Monochrome', 'High-contrast grayscale');

  const ColorBlindnessMode(this.label, this.description);

  final String label;
  final String description;
}

/// Text scaling presets for low vision and hard-of-sight accessibility.
enum TextScalePreset {
  system('100%', 1, 'Standard text size'),
  large('115%', 1.15, 'Large text'),
  extraLarge('130%', 1.30, 'Extra large text'),
  huge('150%', 1.50, 'Maximum readability');

  const TextScalePreset(this.label, this.scaleFactor, this.description);

  final String label;
  final double scaleFactor;
  final String description;
}

/// User-configurable accessibility preferences.
@immutable
class AccessibilityPreferences {
  const AccessibilityPreferences({
    this.colorBlindness = ColorBlindnessMode.none,
    this.highContrast = false,
    this.textScale = TextScalePreset.system,
    this.boldText = false,
    this.reduceMotion = false,
    this.largeTouchTargets = false,
    this.hapticFeedback = true,
    this.soundCues = true,
    this.enhancedSemantics = false,
  });

  /// Default baseline preferences.
  static const AccessibilityPreferences defaults = AccessibilityPreferences();

  /// Color blindness simulation or adaptation mode.
  final ColorBlindnessMode colorBlindness;

  /// Whether high contrast (near-black text roles, 1.5px borders) is
  /// enabled. Not a WCAG AAA claim: `AppTokens` (workout intensity,
  /// success/warning) are untouched by it — see
  /// `knowledge/engineering/accessibility.md`.
  final bool highContrast;

  /// Custom text scaling override.
  final TextScalePreset textScale;

  /// Whether typography font weights should be bold across the entire app.
  final bool boldText;

  /// Whether non-essential animations, transitions, and pulsing effects
  /// should be disabled.
  final bool reduceMotion;

  /// Whether interactive touch targets should expand to a minimum of
  /// 48x48 dp.
  ///
  /// Applied through the theme (`core/theme/app_theme.dart`), so it covers
  /// buttons, chips, switches, checkboxes, radios and icon buttons at once.
  /// The one thing it cannot reach is the wellbeing calendar's
  /// seven-column month grid below roughly 400 dp of usable width, where a
  /// 48 dp-wide cell does not fit on the screen at all — see
  /// `core/widgets/month_calendar.dart`.
  final bool largeTouchTargets;

  /// Whether tactile haptic vibrations should trigger on timer intervals
  /// and logs.
  final bool hapticFeedback;

  /// Whether a soft chime plays at pose transitions and interval
  /// boundaries.
  ///
  /// On by default, and the counterpart to [hapticFeedback] rather than a
  /// duplicate of it: the two channels reach different situations. A
  /// vibration is felt by the phone's owner and only while they are near it;
  /// a chime carries across a mat when the phone is face-down, and exists
  /// on web and Windows where there is no haptics API at all. Both are
  /// backed up by the visual channel, which is never switchable.
  ///
  /// Every cue goes through
  /// `features/accessibility/presentation/accessibility_sound.dart`, which
  /// reads this flag — the same single-funnel arrangement
  /// `AccessibilityHaptics` uses, and for the same reason.
  final bool soundCues;

  /// Whether extended screen reader semantic descriptions are attached to
  /// charts and calendar days.
  ///
  /// On, a chart describes its series in words (how many bars, the highest
  /// and lowest and by how much) and a calendar day announces its date,
  /// what was logged, the estimated phase and the confidence in that
  /// estimate. Off — the default — both keep their short labels, because
  /// the long form is genuinely tiring for someone who does not need it.
  final bool enhancedSemantics;

  AccessibilityPreferences copyWith({
    ColorBlindnessMode? colorBlindness,
    bool? highContrast,
    TextScalePreset? textScale,
    bool? boldText,
    bool? reduceMotion,
    bool? largeTouchTargets,
    bool? hapticFeedback,
    bool? soundCues,
    bool? enhancedSemantics,
  }) {
    return AccessibilityPreferences(
      colorBlindness: colorBlindness ?? this.colorBlindness,
      highContrast: highContrast ?? this.highContrast,
      textScale: textScale ?? this.textScale,
      boldText: boldText ?? this.boldText,
      reduceMotion: reduceMotion ?? this.reduceMotion,
      largeTouchTargets: largeTouchTargets ?? this.largeTouchTargets,
      hapticFeedback: hapticFeedback ?? this.hapticFeedback,
      soundCues: soundCues ?? this.soundCues,
      enhancedSemantics: enhancedSemantics ?? this.enhancedSemantics,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccessibilityPreferences &&
          runtimeType == other.runtimeType &&
          colorBlindness == other.colorBlindness &&
          highContrast == other.highContrast &&
          textScale == other.textScale &&
          boldText == other.boldText &&
          reduceMotion == other.reduceMotion &&
          largeTouchTargets == other.largeTouchTargets &&
          hapticFeedback == other.hapticFeedback &&
          soundCues == other.soundCues &&
          enhancedSemantics == other.enhancedSemantics;

  @override
  int get hashCode => Object.hash(
    colorBlindness,
    highContrast,
    textScale,
    boldText,
    reduceMotion,
    largeTouchTargets,
    hapticFeedback,
    soundCues,
    enhancedSemantics,
  );
}
