# Accessibility - settings, harness, and audit state

*Durable record of what each accessibility setting actually does, how it is
proven, and what the audit still leaves open. `handoff/` points here; do not
duplicate this there.*

## The settings (state as of 2026-09-02)

| Setting | Mechanism | Honest status |
|---|---|---|
| Text scale | `app.dart` resolves `max(osScale, appPreset)` | Correct. **Was** `appPreset > 1 ? appPreset : osScale`, which made "Large (115%)" render SMALLER than an OS at 130%. Presets are absolute percentages, so `max` - never multiply (2.0 x 1.5 fits nothing) |
| Large touch targets | `AppTheme._withLargeTouchTargets`: `materialTapTargetSize: padded` + `visualDensity: standard` + `minimumSize 48` on button/switch/checkbox/radio themes | Wired (was read by nothing but its own switch). Fixed unconditionally: streak "recovery day" TextButton (was 20dp), nutrition DaySelector bare InkWell (40dp), Activity filter chips (hard-clamped by `SizedBox(height: 36)`), cycle `_DayGridCell` (46.1 -> ~49.5dp). **Limit:** a 7-column month grid cannot give 48dp-WIDE cells under ~400dp usable width; ~36dp at 320dp. Arithmetic, documented in the widget |
| Enhanced semantics | Explicit widget parameter plumbed from the nearest ConsumerWidget (widgets stay Riverpod-free) | Wired for: weekly distance chart (`weeklyDistanceDescription`), weight trend chart (directionless, vocabulary-gated), cycle calendar days (`cycle_day_semantics.dart`: logged = fact, inferred = "estimate" + confidence via `CycleConfidence.spokenLabel`). Settings subtitle no longer promises "workout splits" (never built). Off by default |
| Haptic feedback | `AccessibilityHaptics.light/medium/heavyImpact(ref)` is the ONLY permitted call path; `grep "HapticFeedback\." lib/` must return only the helper | All 12 sites migrated. Strength x3 and swim x2 previously ignored the setting. HIIT interval timer gained work/rest/complete haptics via `ref.listen` on phase (fires on skip too) |
| Bold text | Variable-font weight bump + `FontVariation('wght')`; forwards `MediaQuery.boldText` | Good. No layout budgets for the extra glyph width - it compounds text-scale failures |
| High contrast | ColorScheme roles -> black/#222, borders 1.5px, forwards `MediaQuery.highContrast` | **Does not touch `AppTokens`** - cycle phase, intensity, success/warning stay at 2.0-3.1:1 with it ON. Was true for two ColorScheme roles only, so the "WCAG AAA" wording was removed from the setting's subtitle and dartdocs on 2026-09-03 (owner's rule: **no WCAG level is named in user-facing copy unless the whole app meets it**; the contrast audit test is the evidence, and it still records gaps). Open |
| Colour-vision modes | `AppTokens.fromAccessibility` swaps palettes; `badge_tier_style` swaps the medal ramp | `ColorScheme` is NOT remapped - Monochrome is still visibly purple. Tritanopia `warning` 2.39:1, protanopia 2.00:1 as label text. Open |
| Reduce motion | `MediaQuery.disableAnimations`; one `AnimationController` in `lib/` (splash) | Good |

The default palette (Standard colour-vision mode, High Contrast off) was reviewed on device 2026-09-02: borderless cards remain distinguishable via the faint `#ECE7EE` side against the page background, and the one colour-only cue found across 13 screens is the cycle calendar's per-day dots (`scratch/review_notes.md`; row in `deferred.md`).

## The harness - `test/accessibility/`

Pumps the REAL `App` (real router, real theme, real `AccessibilityRepository`
on SharedPreferences) at a surface size x OS text scale, navigates by URL,
runs five checks with app-widget attribution: overflow, tap target (from
`RenderBox.size`, inclusive containment de-dup, list-tile controls folded
into their tile), truncation (skips text in fully-faded subtrees), mid-word
wrap, occlusion (tappable over tappable/Text, >4dp both axes; ancestor pairs
and other overlay entries excluded). Loads `assets/fonts/Inter.ttf` via
`FontLoader` - without it every measurement is Ahem and fiction.

- Run: `flutter test test/accessibility` (~35s). Reports ->
  `build/accessibility_audit/*.md` (gitignored).
- `a11y_harness_selftest_test.dart` plants each defect class and fails if
  the harness stays quiet. Extend it BEFORE trusting a new check.
- The audit tests REPORT, they do not gate; only the shell-tabs file fails
  on a critical render failure. Turn a finding into an assertion only after
  it is fixed - asserting now encodes current bugs as expected.
- **Measurements are DESKTOP measurements.** `ThemeData` picks
  `MaterialTapTargetSize.shrinkWrap` + `VisualDensity.compact` on
  Windows/macOS/Linux, so buttons/chips read 38-40dp here and 48dp on
  Android/iOS. Read every tap-target number with that in mind.
- Not covered: content below the fold in scrollables (Flutter reports an
  overflow only when painted - findings are a lower bound); dialogs, sheets,
  menus (an `afterNavigate` hook exists, unused); `/recap` (redirects
  without an in-memory recap); >=600dp NavigationRail / tablet / desktop /
  web widths; dark-mode LAYOUT (contrast is covered); barcode scan; map
  polylines and chart-fill text (imagery background - a static ratio would
  be fiction).

## Layout decisions made from the audit

- **NavigationBar: icon-only fallback.** `AppAdaptiveScaffold` measures the
  longest label with the REAL style at the current effective scale (clamped
  at 1.3 - `NavigationBar` clamps label scaling there itself) against
  `maxWidth / destinations`; fits -> `alwaysShow`, else `alwaysHide`. Zero
  margin is deliberate: the cell boundary IS Material's wrap point. Every
  destination carries a `tooltip`; all six names stay announced when hidden.
  Measured switch points (Inter, 12sp): 411dp hides from 130% (also OS 1.3 at
  app Normal), 360dp and 320dp from 115%. Owner chose this over shorter
  labels or five tabs (2026-09-02).
- **Activity detail app bar keeps all four actions at every width.** An
  interim revision collapsed them into an overflow menu to protect the
  title; the title is the generic word "Activity" (the real name is
  headlined in the body), so that trade was backwards - and it broke the
  delete flow test.
- **Record FAB occlusion on Activity is GONE** (2026-09-03, supersedes the
  2026-09-02 "accepted" ruling): the floating button was removed when the
  Activity tab was restructured hubs-first — Record is now a fixed button
  directly under the Exercise Hubs tile row, so it covers nothing. The
  13 occlusion findings and the allowlist they were going to need both
  disappear with it; no allowlist was ever added to the occlusion check,
  and none is owed.
- Numeric stat values never ellipsise - `FittedBox(scaleDown)`; a clipped
  number is a wrong number, not a cosmetic clip.
- `_CaloriesCard` stacks only when width measurement AND `textScale >= 1.3`
  both say so (unconditional stacking overflowed 48px at 100%/320dp).

## Text measurement trap (project instance)

Theme text styles carry no `fontFamily`; `TextPainter` on a raw theme style
measures the platform fallback ("Nutrition" 108dp instead of 51dp). Use
`lib/core/utils/text_measure.dart#measuredTextWidth`, which merges over
`textTheme.bodyMedium`. Candidate root fix: give `AppTheme` styles an
explicit family. Generic write-up: central `ui-performance.md`.
