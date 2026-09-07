# Run-Tracking Stack Research

*Verified against primary sources 2026-08-26 (pub.dev, Baseflow/fleaflet GitHub, Android/Apple docs). Feeds ADR 008. Re-verify Play policy items at submission time.*

## Package verdicts

| Package | Version | Verdict |
|---|---|---|
| geolocator | 14.0.3 | ✅ Adopt. All four platforms incl. endorsed Windows impl. Needs Flutter ≥3.29 (we're 3.44.4). `AndroidSettings.intervalDuration` is Android-only; iOS uses `AppleSettings(activityType: fitness, pauseLocationUpdatesAutomatically: false, allowBackgroundLocationUpdates: true, showBackgroundLocationIndicator: true)` |
| permission_handler | 13.0.1 | ✅ Adopt **for POST_NOTIFICATIONS only** (Android 13+); location permission via geolocator's own API — don't duplicate |
| flutter_foreground_task | 11.0.1 | ⏸ Named fallback, not adopted (ADR 008): requires Kotlin ≥2.2.20 / Gradle ≥8.11.1 (toolchain-bump risk) and isolate-based handler (Drift/state complexity) |
| flutter_map | 8.3.1 (+ latlong2 0.10.1 stable) | ✅ Adopt (wave C3). Pure Dart → genuinely all-platform incl. Windows. Default RDP polyline simplification + culling handles long GPS tracks — don't disable it |

## Android foreground-service facts (API 34+)

Manifest for FGS-location recording: `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION`, `FOREGROUND_SERVICE`, `FOREGROUND_SERVICE_LOCATION`, `POST_NOTIFICATIONS`, and the service declared with `android:foregroundServiceType="location"` (geolocator's built-in FGS handles the service entry when using `foregroundNotificationConfig` — verify at implementation).

**`ACCESS_BACKGROUND_LOCATION` is NOT needed** for a Strava-style flow (FGS started while app foregrounded keeps location access with screen off). **Do not add it** — it triggers Play's separate background-location declaration form + video review for zero benefit. Guard-test its ABSENCE.

Play Console: location-FGS type declaration (description + demo video) required for fitness apps regardless — submission-time task.

## Known risks (documented, accepted for v1)

- geolocator GitHub #1023: position streams stalling after 2–4h screen-off on some OEMs (Samsung/Xiaomi) even with FGS; issue closed without retrievable root-cause. Mitigation: real-device long-run testing before release; migration path to flutter_foreground_task if reproduced (ADR 008).
- geolocator built-in FGS notification quirks (#1178, #1252, #1559 — setOngoing not always respected).

## iOS facts

When-in-use auth + `UIBackgroundModes: [location]` + `allowsBackgroundLocationUpdates=true` **suffices for screen-off recording of a foreground-started session** — Always auth NOT required. Info.plist: `NSLocationWhenInUseUsageDescription` (+ background mode). `showsBackgroundLocationIndicator` is UI-only transparency (set true). *(Indicator semantics secondary-sourced; low risk.)*

## Map tiles

OSM's tile.openstreetmap.org: acceptable for dev/low-volume with a unique User-Agent + visible "© OpenStreetMap contributors" attribution (flutter_map's `RichAttributionWidget`); prohibited: bulk prefetch/offline download. **Production tile provider (MapTiler/Stadia/Thunderforest free tiers) is a deferred product decision** — make the tile URL env-configurable from day one.
