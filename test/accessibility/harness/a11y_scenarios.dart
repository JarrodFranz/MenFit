import 'package:flutter/material.dart';
import 'package:menfit_app/features/accessibility/domain/accessibility_preferences.dart';

/// One cell of the audit matrix: a set of accessibility preferences, the
/// surface they are exercised on, and the OS-level text scale underneath
/// them.
///
/// Width is part of the scenario, not a constant, because width and text
/// scale interact: the overflows the owner photographed appear at (narrow
/// width) OR (large scale), and worst at both. A matrix that varied only
/// scale would miss the bug it was built to find.
class A11yScenario {
  const A11yScenario({
    required this.id,
    required this.prefs,
    this.surface = phone411,
    this.osTextScale = 1.0,
  });

  /// Smallest width the app claims to support (`breakpoints.dart` compact).
  static const Size phone320 = Size(320, 640);

  /// The commonest Android phone width.
  static const Size phone360 = Size(360, 780);

  /// Pixel 6 Pro — the device the coordinator reproduced the bugs on.
  static const Size phone411 = Size(411, 891);

  final String id;
  final AccessibilityPreferences prefs;
  final Size surface;

  /// The OS font-scale the device reports, *underneath* the app's own
  /// preference. Android allows up to 2.0.
  final double osTextScale;

  String get label =>
      '$id@${surface.width.toInt()}dp'
      '${osTextScale == 1.0 ? '' : '/os${osTextScale}x'}';
}

const AccessibilityPreferences _defaults = AccessibilityPreferences.defaults;

const AccessibilityPreferences _worstPrefs = AccessibilityPreferences(
  textScale: TextScalePreset.huge,
  boldText: true,
  highContrast: true,
  largeTouchTargets: true,
);

/// Every text-scale preset at the reference width, plus the same presets at
/// the narrowest supported width, plus the all-switches-on worst case at
/// all three widths.
///
/// Rationale for not running the full cross-product (4 scales x 2 contrast
/// x 2 bold x 2 touch-target x 5 colour modes x 3 widths = 960 cells per
/// screen): the non-scale switches only ever *add* layout pressure — bold
/// widens glyphs, high contrast thickens borders, large touch targets grow
/// hit areas — and none of them shrinks anything. So the union of "every
/// scale alone" and "everything on at once" brackets the space: the first
/// isolates which scale first breaks a screen, the second proves whether it
/// survives the maximum. Colour modes change no metrics at all, so they are
/// audited separately on the colour-carrying screens and in the contrast
/// test.
const List<A11yScenario> standardMatrix = [
  A11yScenario(id: 'scale-100', prefs: _defaults),
  A11yScenario(
    id: 'scale-115',
    prefs: AccessibilityPreferences(textScale: TextScalePreset.large),
  ),
  A11yScenario(
    id: 'scale-130',
    prefs: AccessibilityPreferences(textScale: TextScalePreset.extraLarge),
  ),
  A11yScenario(
    id: 'scale-150',
    prefs: AccessibilityPreferences(textScale: TextScalePreset.huge),
  ),
  A11yScenario(
    id: 'scale-100',
    prefs: _defaults,
    surface: A11yScenario.phone320,
  ),
  A11yScenario(
    id: 'scale-150',
    prefs: AccessibilityPreferences(textScale: TextScalePreset.huge),
    surface: A11yScenario.phone320,
  ),
  A11yScenario(
    id: 'worst-case',
    prefs: _worstPrefs,
    surface: A11yScenario.phone360,
  ),
  A11yScenario(
    id: 'worst-case',
    prefs: _worstPrefs,
    surface: A11yScenario.phone320,
  ),
];

/// A shorter matrix for the screens where a full sweep is not worth the
/// runtime (nine exercise hubs, four live trackers): the default, the
/// narrow default, and the worst case.
const List<A11yScenario> shortMatrix = [
  A11yScenario(id: 'scale-100', prefs: _defaults),
  A11yScenario(
    id: 'scale-100',
    prefs: _defaults,
    surface: A11yScenario.phone320,
  ),
  A11yScenario(
    id: 'scale-150',
    prefs: AccessibilityPreferences(textScale: TextScalePreset.huge),
  ),
  A11yScenario(
    id: 'worst-case',
    prefs: _worstPrefs,
    surface: A11yScenario.phone320,
  ),
];

/// OS-level scaling with the app preference *also* set — the combination
/// `app.dart`'s `targetScale` resolves, and the one that can silently make
/// text smaller than the OS asked for.
const List<A11yScenario> osScaleMatrix = [
  A11yScenario(id: 'os130-app100', prefs: _defaults, osTextScale: 1.3),
  A11yScenario(
    id: 'os130-app115',
    prefs: AccessibilityPreferences(textScale: TextScalePreset.large),
    osTextScale: 1.3,
  ),
  A11yScenario(id: 'os200-app100', prefs: _defaults, osTextScale: 2),
  A11yScenario(
    id: 'os200-app150',
    prefs: AccessibilityPreferences(textScale: TextScalePreset.huge),
    osTextScale: 2,
  ),
];

/// The **Large Touch Targets** preference off, at the reference width —
/// the baseline every "with it on" measurement is compared against.
const A11yScenario touchTargetsOff = A11yScenario(
  id: 'touch-off',
  prefs: _defaults,
);

/// The **Large Touch Targets** preference on, at the reference width.
///
/// Nothing else is varied: this scenario exists to isolate one switch, so a
/// finding under it can only be that switch failing to keep its promise.
const A11yScenario touchTargetsOn = A11yScenario(
  id: 'touch-on',
  prefs: AccessibilityPreferences(largeTouchTargets: true),
);

/// **Enhanced Semantics** off — the shipped default, and the state every
/// existing screen test already exercises.
const A11yScenario enhancedSemanticsOff = A11yScenario(
  id: 'semantics-off',
  prefs: _defaults,
);

/// **Enhanced Semantics** on, nothing else varied.
const A11yScenario enhancedSemanticsOn = A11yScenario(
  id: 'semantics-on',
  prefs: AccessibilityPreferences(enhancedSemantics: true),
);

/// Colour-blindness modes, for the colour-carrying screens.
const List<A11yScenario> colorBlindnessScenarios = [
  A11yScenario(
    id: 'cb-protanopia',
    prefs: AccessibilityPreferences(
      colorBlindness: ColorBlindnessMode.protanopia,
    ),
  ),
  A11yScenario(
    id: 'cb-deuteranopia',
    prefs: AccessibilityPreferences(
      colorBlindness: ColorBlindnessMode.deuteranopia,
    ),
  ),
  A11yScenario(
    id: 'cb-tritanopia',
    prefs: AccessibilityPreferences(
      colorBlindness: ColorBlindnessMode.tritanopia,
    ),
  ),
  A11yScenario(
    id: 'cb-monochromacy',
    prefs: AccessibilityPreferences(
      colorBlindness: ColorBlindnessMode.monochromacy,
    ),
  ),
];
