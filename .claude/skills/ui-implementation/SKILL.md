---
name: ui-implementation
description: Use when building or significantly changing screens, widgets, or visual design in this app.
---

# UI Implementation Workflow

1. **Design first** — read `knowledge/flutter/flutter_patterns.md` (adaptive shell, tokens) and existing screens for conventions. Sketch the layout per window class: compact (<600), medium/expanded, large (≥1200) — desktop/web is a first-class layout, not a stretched phone.
2. **Rules** — colors/spacing/radii/typography only from theme + `AppTokens`; breakpoints only from `core/theme/breakpoints.dart`; extract widgets before files grow; no business logic in widgets; const everywhere possible; semantic labels for accessibility on interactive elements.
3. **Implement** — delegate bounded screen work to `flutter-implementer`; shared primitives go in `core/widgets/` only when used by ≥2 features (no speculative components).
4. **Test** — widget tests at compact AND expanded sizes when layout adapts; no overflow at 320dp-wide compact or with 1.3× text scale.
5. **Visually verify on the Android emulator (`emulator-5554`)** — owner's standing instruction (2026-09-03): screen checks and app testing use the emulator, not a Windows or web build. Install the debug APK (`flutter run -d emulator-5554` or `adb install`), drive it with `scratch/emu.sh` (start/shot/tap/swipe/back/text; 3.5 px/dp) or `adb shell uiautomator dump`, and check the changed screens in light + dark and with 3-button navigation (`cmd overlay enable com.android.internal.systemui.navbar.threebutton`). Wide layouts (tablet/desktop) are a secondary check via widget tests at expanded sizes; only fall back to Windows/web when the change is specific to those platforms.
6. **Capture** — new UI conventions worth reusing go in `flutter_patterns.md`.
