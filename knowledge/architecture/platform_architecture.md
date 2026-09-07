# Platform Architecture

*Established 2026-08-25. Cross-project platform facts live in the central base (`D:\Documents\Claude\Flutter development knowledge\platform-windows.md`, `platform-web.md`).*

## Platform roles

| Platform | Role |
|---|---|
| iOS / Android | Full experience incl. GPS activity recording (foreground service / background modes), health integrations, notifications, barcode scanning |
| Web | Review/planning surface + **trusted-contact live-tracking viewer** (watchers open a tokenised link without installing the app); no background GPS; no secure storage (in-memory tokens) |
| Windows | Review/planning/analysis surface; full local DB; no GPS recording; secure storage via DPAPI |

**Rule:** never assume a task is mobile-only; every feature states its per-platform behaviour (full / degraded / hidden) at design time.

## Adapter boundaries (isolate platform specifics)

Interfaces in `core/platform/` (or the owning feature's domain), per-platform implementations selected at bootstrap via Riverpod overrides:

- `HealthAdapter` — HealthKit (iOS entitlements) / Health Connect (Android) / no-op (Web, Windows). Candidate package: `health` v13+.
- `LocationAdapter` — geolocator streams; Android foreground service for screen-off recording; Windows geolocator impl exists (foreground only); Web browser geolocation (foreground only).
- `NotificationsAdapter` — flutter_local_notifications (mobile); Windows rough, Web unsupported → no-op with capability flag.
- `SecureStorageBackend` — Keychain / Keystore / DPAPI / in-memory-on-web (see central `secure-storage-and-secrets.md`; never call the package directly).
- Future: `BarcodeScannerAdapter` (mobile camera only), wearable import adapters.

Each adapter exposes a `capabilities` surface so UI can hide/degrade honestly rather than error.

## Release-only config surfaces (guard-test these — imported learning CL-27)

iOS: HealthKit entitlement, background-location/`UIBackgroundModes`, notification entitlements. Android: `ACCESS_FINE_LOCATION`, `ACTIVITY_RECOGNITION`, foreground-service declarations, `INTERNET` (in the **main** manifest — debug manifests lie). Each, when added, gets a source-reading guard test under `test/platform/`.

## Build/verification realities on this machine (Windows host)

- Windows + Web + Android build locally; **iOS requires macOS** — the target exists but compilation/signing must happen on a Mac or macOS CI. Documented limitation.
- Desktop verification drives the real built `.exe`; web via headless browser at fixed viewports (see central platform notes).
