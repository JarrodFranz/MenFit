# 008 — Run recording stack: geolocator with built-in foreground service; no background-location permission

- **Status:** Accepted
- **Date:** 2026-08-26

## Context
Phase C needs Strava-style GPS recording: user starts a run in-app, screen may turn off, recording continues; multi-hour reliability matters. Research (`../research/run_tracking_stack.md`) verified the 2026 landscape.

## Options considered
(a) geolocator 14 alone, using its built-in `AndroidSettings.foregroundNotificationConfig` FGS; (b) geolocator + flutter_foreground_task owning the FGS (isolate task handler); (c) paid flutter_background_geolocation (Transistor, $500/app).

## Decision
**(a) geolocator 14.0.3 with its built-in foreground-service notification** for v1, plus `permission_handler` 13.x solely for POST_NOTIFICATIONS. **`ACCESS_BACKGROUND_LOCATION` is deliberately NOT requested** (not needed for foreground-started FGS recording; adding it triggers Play's heavier background-location review). iOS: when-in-use auth + `UIBackgroundModes location` + `allowBackgroundLocationUpdates` — Always auth deliberately not requested. Guard tests assert required entries present AND `ACCESS_BACKGROUND_LOCATION` absent.

## Reasons
Single package, no Kotlin 2.2.20/Gradle 8.11.1 toolchain bump (flutter_foreground_task's floor), no background-isolate ↔ Drift/state complexity, and the minimal-permission posture matches our privacy architecture. Typical session lengths (<2h) sit below the reported OEM stall window.

## Consequences
- Accepted risk: geolocator #1023-class stalls after 2–4h screen-off on some OEMs. **Gate before store release: real-device long-run test (3h+, Samsung/Xiaomi class device).** If reproduced → migrate the FGS to flutter_foreground_task (option b) — the recording session API is designed so only the platform adapter layer changes.
- Play submission needs the location-FGS declaration + demo video (tracked in deferred registry).

## Rejected alternatives
- **(b) flutter_foreground_task now** — better worst-case reliability but real toolchain + architecture cost before we have any device evidence we need it. Named migration path, not v1.
- **(c) Transistor** — $500/app for passive-tracking capabilities we don't need (we record active sessions only).

## Amendment (2026-09-06)
Apple's TestFlight upload check (ITMS-90683) flagged the binary — the linked
geolocator plugin references the Always-location API, so Apple requires
`NSLocationAlwaysAndWhenInUseUsageDescription` in Info.plist for any app that
links it, whether or not the app ever requests that authorization level. Added
the key with a truthful string. This decision is unchanged: the app still
never *requests* Always authorization at runtime.
