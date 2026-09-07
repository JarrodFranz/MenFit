# Package Decisions

*Every dependency and its verdict. Ecosystem status facts: central base `package-ecosystem-status.md`. Update on every pubspec change.*

## Adopted 2026-09-03 (nutrition label OCR, ADR 012)

| Package | Version | Verdict |
|---|---|---|
| google_mlkit_text_recognition | 0.17.1 (exact pin) | **ADOPTED** (owner go, 2026-09-03). Android/iOS only, behind an `OcrAdapter` + `textRecognitionSupported` capability flag (pattern of `barcode_scanning.dart`). Fully on-device via `MethodChannel`; Latin model **bundled** with the package — no first-use download. Only dep `google_mlkit_commons ^0.13.0`, no analyzer-chain transitive deps. iOS 15.5 / minSdk 21 floors both already met. No Dart-level conflict with `mobile_scanner` 7.4.0 (that package has no Dart ML Kit dependency of its own); native Gradle coexistence of the two ML Kit artifacts (barcode + text recognition) is a first-integration smoke item, not a known conflict. `TextElement.confidence` is nullable and reportedly often null — unverified until on-device testing; parser computes its own confidence as the primary signal regardless. flutter-ml.dev, MIT, 410 likes / 150 pub points. Output never auto-saves — mandatory review form, same posture as `ProviderFood` (ADR 010). |
| image_picker | 1.2.3 (exact pin) | **ADOPTED 2026-09-03** for `ImageSource.camera` on mobile only — the app had no still-photo capture at all (`mobile_scanner` streams frames and cannot return a photo). flutter.dev verified publisher, 160 pub points, 7.76k likes, 3.9M weekly downloads, Apache-2.0/BSD-3, all six platforms. Adding it moved nothing already in the lock (0 deletions); its tree is platform-interface packages plus `cross_file`/`http`/`mime`/`plugin_platform_interface`/`web` — **nothing analyzer/build/source_gen**, so the analyzer-13 window is safe. On Android the camera capture lands in `activity.getCacheDir()` (verified in the plugin source — app-private cache, NOT MediaStore/the gallery) and the delegate requests the runtime CAMERA permission itself, because `mobile_scanner` already merges the declaration into our manifest. Used from exactly one file, `lib/core/platform/ocr/label_capture.dart`, pinned by a source-scan guard; the captured file is deleted in a `finally`. `requestFullMetadata: false` (no EXIF/GPS lookup) and **no** `maxWidth`/`maxHeight`/`imageQuality` (resizing hurts small print, and the Android plugin writes a *second* file when asked to resize) are both deliberate. Gallery/`ImageSource.gallery` is deliberately NOT used: it reaches the whole camera roll and would need its own decision. |

Adoption also changed native config: iOS deployment target 13.0 → **15.5**
(ML Kit's floor) across all three build configurations, plus a
**committed `ios/Podfile`** — there was none before — with
`platform :ios, '15.5'`. Drops iOS 13/14 devices. Not compilable here; see
the Mac-verify list in `platform_notes.md`.

**Trap found at adoption:** `google_mlkit_commons` imports `dart:io`
unconditionally, so importing the ML Kit adapter from web-reachable code
breaks `flutter build web` at *compile* time. It is reached only through
the conditional export in `lib/core/platform/ocr/ocr_platform.dart`
(same mechanism as `health_platform_adapter.dart`), guarded by a test.

Deferred: Apple Vision platform channel (would duplicate ML Kit's iOS
coverage and reportedly gives better confidence values; revisit only if ML
Kit underperforms on iOS); Tesseract.js on web (needs self-hosted WASM +
traineddata under `web/`, same CDN-privacy stance as `mobile_scanner`'s web
backend, plus a hand-written `dart:js_interop` bridge, ~3-5 days).

Blocked (not a package problem): `Windows.Media.Ocr` — needs package
identity (MSIX/sparse package) an unpackaged `flutter build windows` lacks;
also Windows has no live camera frame stream at all (`camera_windows`), so
any Windows flow would be photo-import only, never live capture.

Rejected: `flutter_tesseract_ocr` (slower than ML Kit by its own docs, no
Windows, large bundled traineddata assets, no platform-coverage gain);
`flutter_ocr_native` 0.3.3 (2 likes / 533 downloads / unverified publisher /
0.x — below the adoption bar); `nutrition_ai` (Passio) (commercial, needs an
account + SDK key + internet setup — violates the local-only requirement
outright, licence not even evaluated further).

## Evaluated 2026-09-02 for native sharing

| Package | Version | Verdict |
|---|---|---|
| share_plus | 13.3.0 (exact pin) | GO, behind a `SharingAdapter` in `core/platform/`. Only maintained all-four-platform share option (fluttercommunity, 150 pts, 4,020 likes, BSD-3, verified publisher, monthly releases). No codegen/analyzer-touching deps - safe for the analyzer-13 window. `win32 ^6.0.1` already satisfied by our locked `win32 6.4.0`. `XFile.fromData` shares in-memory PNG bytes (workout share card) without a temp file; built-in web download/mailto fallback when the Web Share API is absent (desktop Firefox). **Windows is a real `DataTransferManager` COM implementation, not a stub, but has recurring edition-specific failures** (plus_plugins #3687, Win11 Home, closed-not-fixed; #3619, open) and `ShareResultStatus` is always `unavailable` there - `supportsShareResult` is `false` on Windows and the UI must never claim confirmed delivery. **Copy (`Clipboard.setData`) stays first-class at all five share surfaces, not fallback-only**, because of the Windows caveats above and because desktop Firefox has no Web Share API at all. Windows behaviour must be verified on the dev machine before trusted. See ADR 011. |

Rejected: `share_handler` (receive-only, doesn't send); `flutter_share`
(discontinued by its own author in favour of share_plus); `social_share` /
`esys_flutter_share` (both effectively dead, mobile-only, and the latter is
Dart-3-incompatible).

## Evaluated 2026-09-01 for Task 1.6 (audio coaching cues) - approved, not yet adopted

| Package | Version | Verdict |
|---|---|---|
| flutter_tts | ^4.2.5 | GO with conditions. Dominant TTS plugin (150 pts, 1.6k likes, MIT). iOS ducking built in (`setIosAudioCategory` + duckOthers). **Windows declared-but-broken** (open MissingPluginException issues incl. 2026 reports) - capability-flag OFF until manually verified, same pattern as `health`. Web works via Web Speech API but cannot duck (browser limitation - product decision: visual-only cues or unducked). ~198 open issues / single maintainer: budget for workarounds. Android 11+ needs a `<queries>` manifest entry for the TTS engine intent. First-run missing-voice-data needs explicit UX (`ACTION_CHECK_TTS_DATA`). |
| audio_session | ^0.2.4 | GO alongside flutter_tts for Android ducking (`AndroidAudioFocusGainType.gainTransientMayDuck` - flutter_tts has no Android ducking of its own, issue #194 open since forever). No Windows support at all. |

**Pre-adoption gate:** a real-device spike proving audio_session's focus request
actually ducks music while flutter_tts's separate engine speaks - no working
example of the combination was found anywhere. Also unproven: TTS during the
geolocator FGS on OEM builds (piggyback on ADR 008's existing 3h+ device test).
Rejected alternatives: `text_to_speech` (weaker maintenance), pre-recorded
clips via just_audio (better ducking/quality but cannot construct dynamic
split/pace phrases; plausible v2 hybrid), flutter_foreground_task-hosted audio
(ADR 008 already rejected that package).

## Evaluated 2026-09-04 for the yoga sequence runner (pose-transition chime + screen-awake) - adopted behind adapters (ADR 014)

| Package | Version | Verdict |
|---|---|---|
| audioplayers | 6.8.1 (exact pin) | **GO WITH CONDITIONS**, behind `AudioCuePlayer` in `core/platform/audio/`. Only candidate with real **local-asset** playback on all four targets (feature parity table: "Local asset" Yes on Android/iOS/Web/Windows). blue-fire.xyz verified, MIT, 150 pts, 3.4k likes, 1.17M weekly downloads; 231 open issues, bus factor ~1-2. Deps analyzer-safe (only `synchronized` new). **Ducking is Android-only** (`AndroidAudioFocus.gainTransientMayDuck`); iOS uses `AVAudioSessionCategory.ambient` with NO explicit options (mixes with other audio implicitly, no duck, **respects the silent switch** - product decision 2026-09-04). **Correction:** the evaluation recommended passing `mixWithOthers` explicitly; `AudioContextIOS`'s constructor ASSERTS that option is only valid under `playback`/`playAndRecord`/`multiRoute`, so with `ambient` it throws in debug - the adapter omits it; Web/Windows cannot duck. **`audio_session` NOT needed** (audioplayers has its own Android focus handling; audio_session has no Windows). **Condition 1 (blocking):** `audioplayers_android` 5.3.0 dropped `apply plugin: 'kotlin-android'` for AGP 9 built-in Kotlin (#1991); this repo has AGP 9.0.1 + `android.builtInKotlin=false` -> configuration failure predicted; fallback `dependency_overrides: audioplayers_android: 5.2.1`. Never flip builtInKotlin (measured to fail 2026-08-27). **Outcome (measured 2026-09-04):** the predicted failure did NOT happen - `flutter build apk --debug` and `--release` (R8) both passed with `audioplayers_android 5.3.0` and `wakelock_plus 1.8.0` at head, no `dependency_overrides`, no proguard changes; the KGP warning still names only `health, mobile_scanner`. Do not add the fallback pins pre-emptively. **Condition 2:** `audioplayers_windows` links Media Foundation; on **Windows N/KN without the Media Feature Pack the app crashes at startup** (issue #1956; fixed by PR #1957, regressed, re-fixed by PR #2019 on 2026-07-22 - AFTER 4.4.1 shipped, so the published version carries the crash). Accepted for the dev-only Windows target; re-pin before any Windows distribution (deferred.md). **Condition 3:** `windows/CMakeLists.txt` 3.14 -> 3.15 for VS 2026 (dev box is VS 2022 Build Tools; bumped pre-emptively). |
| wakelock_plus | 1.8.0 (exact pin), fallback 1.6.1 | **GO WITH CONDITIONS**, behind `ScreenAwake` in `core/platform/wakelock/`. fluttercommunity.dev verified (same publisher as `share_plus`), BSD-3, 160 pts, 2.16M weekly downloads. 1.8.0 (2026-09-01) is the Flutter 3.47 upgrade. Resolves with zero lock movement (`package_info_plus`, `win32 6.4.0`, `dbus`, `web`, `meta` already satisfy). **No permission, no manifest edit** - Android impl is the window flag `FLAG_KEEP_SCREEN_ON`, untouched by Android 15/16 background restrictions. **Condition (blocking):** 1.7.0's PR #136 applies KGP only `if (agpMajor < 9)` without checking `builtInKotlin` -> same predicted failure; fallback pin **1.6.1** (last with unconditional `kotlin-android`; identical constraints). **Web degraded:** Screen Wake Lock API is HTTPS/localhost-only and the browser releases the lock when the tab hides - re-acquire on resume. |

**Finding independent of yoga:** no tracker in the app kept the screen on before this (`grep wakelock` was empty) - HIIT, swim, strength, mindful and GPS recording all run `Timer.periodic` while the screen may time out. The `ScreenAwake` seam is generic; wiring the other trackers is a deferred row.

**Chime asset:** synthesized 16-bit PCM mono 44.1 kHz WAV (`scripts/gen_transition_chime.py` -> `assets/audio/transition_chime.wav`, licence-free). PCM WAV decodes everywhere; **never ship OGG** (Safari). WAV does not avoid the Windows N/KN crash (that is MF initialisation, not codec).

**Timers under screen lock:** Android keeps the isolate running with the screen off; iOS suspends within seconds and Dart timers stop. Mitigation = wakelock (the app never suspends) + wall-clock phase ends (`hiit_tracker_controller.dart` pattern), snapping to the right pose on resume with at most one chime. **Do not add iOS `UIBackgroundModes: audio`** (a bell every 45 s is not continuous playback; App Store rejection risk).

Rejected: `soundpool` 2.4.1 (discontinued, no Windows); `just_audio` 0.10.6 (Windows needs a separate federated backend - `just_audio_windows` with open 2026 bugs or `just_audio_media_kit`/libmpv, tens of MB; issue #1274 open since 2024-06); `flutter_soloud` 5.0.0 (best latency but 125 MB unpacked, depends on Dart native-assets build hooks, web needs COOP/COEP cross-origin isolation + index.html script; new major published hours before evaluation); `SystemSound.play` (cannot play our own sound; `alert` desktop-only, `tick` iOS-only, web plays nothing); scheduled local notifications per pose (40 exact alarms rescheduled on every edit, `SCHEDULE_EXACT_ALARM` policy exposure, Windows-rough/web-unsupported).

## Upgraded with Flutter 3.47.2 / Dart 3.13.2 (2026-08-28)

| Package | Version | Purpose / Notes |
|---|---|---|
| flutter_riverpod 3.4.2, riverpod_annotation 4.0.6, riverpod_generator 4.0.8 | 3.4.2 / 4.0.6 / 4.0.8 | State + DI + Codegen (ADR 001). Analyzer 13 support unblocked. |
| go_router 17.5.0, go_router_builder 4.4.1 | 17.5.0 / 4.4.1 | Routing, typed routes (ADR 002) |
| freezed 4.0.0 (annotation ^3.1.0), json_serializable 6.14.1 (annotation ^4.12.0) | 4.0.0 / 6.14.1 | Models/DTOs (ADR 005) |
| drift + drift_dev 2.34.3 / 2.34.5 | 2.34.3 / 2.34.5 | SQLite persistence (ADR 003) |
| drift_flutter 0.3.1, sqlite3 3.5.2, sqlite3_flutter_libs 0.6.0+eol | 0.3.1 / 3.5.2 | Web assets in `web/` match release sqlite3-3.5.2 / drift-2.34.3 |
| shared_preferences 2.5.5 | 2.5.5 | Trivial device prefs only — never secrets |
| intl 0.20.3 | 0.20.3 | Dates/units/formatting |
| build_runner 2.16.0 | 2.16.0 | Codegen runner |
| very_good_analysis 10.3.0 | 10.3.0 | Lint baseline |
| mocktail 1.0.5 | 1.0.5 | Mocks without codegen |
| uuid 4.6.0 | 4.6.0 | UUIDv7 ids (`EntityId.generate()`) |
| geolocator 14.0.3 | 14.0.3 | GPS recording (ADR 008) |
| permission_handler 13.0.1 | 13.0.1 | POST_NOTIFICATIONS only (ADR 008) |
| flutter_map 8.3.2, latlong2 0.10.1 | 8.3.2 / 0.10.1 | Route maps |
| fl_chart 1.1.1 | 1.1.1 | Weekly trends chart |
| dio 5.11.0 | 5.11.0 | HTTP client (ORS route suggestions, ADR 009) |

## Adopted 2026-08-27 (S1-5 barcode scanning)

| Package | Version | Notes |
|---|---|---|
| mobile_scanner | 7.4.0 (exact pin) | Camera barcode scanning for the food diary. **Android + iOS only** — see the capability rules below. |

**Resolution was clean and verified, not assumed:** adding it changed exactly one
`pubspec.lock` entry and moved nothing else — `analyzer` stayed at 9.0.0. Its
only deps (`collection`, `meta`, `plugin_platform_interface`, `web`) were already
in the lock at satisfying versions, and nothing in its tree touches
`analyzer`/`build`/`source_gen`. Plugin `minSdk` 23 ≤ our 24, so no bump.
`flutter build apk --debug` and `flutter build windows --debug` both pass.

**Camera scanning is Android + iOS only** (`lib/core/platform/barcode_scanning.dart`);
**manual barcode entry is available on every platform** and is the primary path,
not a fallback — it is also the permission-denied and unreadable-label path.

- **Windows is impossible, and not because of this package.** `camera_windows`
  is published by flutter.dev but is explicitly *not an endorsed implementation*
  and has never implemented `startImageStream`. With no frame stream there is no
  source to feed any decoder, so swapping barcode libraries cannot fix it.
  Re-check only if `camera_windows` gains image streaming.
- **Web is disabled deliberately, on privacy grounds.** mobile_scanner's web
  backend uses the browser's native `BarcodeDetector` where present but falls
  back to fetching a ~2 MB zxing-wasm binary from the jsDelivr CDN. No image
  data is transmitted, but it discloses the user's IP to a third party merely
  for opening the scanner. Enabling it later means self-hosting that wasm under
  `web/` (same drill as the existing `sqlite3.wasm`/`drift_worker.js`) and
  calling `MobileScannerPlatform.instance.setBarcodeLibraryScriptUrl(...)`
  **before first use**.
- The plugin is imported in **exactly one file**
  (`features/nutrition/presentation/barcode_scan_screen.dart`), so migration
  cost stays confined if it dies. Bus factor ~2, 1.3M downloads, 160/160 pub
  points, BSD-3.
- **Known future blocker:** the Android build now warns `Your app uses the
  following plugins that apply Kotlin Gradle Plugin (KGP): mobile_scanner` —
  *"Future versions of Flutter will fail to build if your app uses plugins that
  apply KGP."* Non-fatal today (we set `android.builtInKotlin=false`, which
  takes the plugin's KGP branch). **Re-check at every Flutter SDK upgrade**;
  upstream tracking issue `juliansteenbakker/mobile_scanner#1708`.
- Keeps ML Kit's **bundled** barcode model (+3–10 MB APK) rather than the
  ~600 KB Play-Services-downloaded variant: a food diary is used in a
  supermarket aisle with poor connectivity, and offline-first is the project's
  stated posture.
- **iOS is unverified** — `NSCameraUsageDescription` is in `Info.plist`, but
  nobody has compiled this target. A Mac session must confirm the pod
  integrates and the permission prompt fires.

Inter variable font bundled in `assets/fonts/` (OFL).

## Accepted, wired later

connectivity_plus — with sync work (ADR 004). logging façade — with first real service.

## Deferred with named candidates (evaluate at feature time)

| Area | Candidate | Key facts |
|---|---|---|
| Maps | **flutter_map** | Only all-4-platform option (pure Dart); maplibre_gl lacks Windows; google_maps rejected (no Windows, lock-in) |
| Location | **geolocator** + flutter_foreground_task (Android) | Free, sufficient for active recording; Transistor bg-geolocation ($500/app) only if passive tracking ever needed |
| Health | ~~**health** (cachet.dk)~~ | **NO LONGER DEFERRED — `health: 13.3.2` was ADOPTED 2026-08-29 (commit `9f30b95`). See the corrected section below.** |
| Notifications | **flutter_local_notifications** | Windows rough, web unsupported → capability-flagged adapter |
| Secure storage | **flutter_secure_storage** behind abstract backend | Web impl not secure — in-memory tokens on web |
| DB encryption | sqlcipher_flutter_libs (with drift) | Revisit at cycle-data privacy review |
| Opening external URLs | **url_launcher** | Wanted from S1-5 (2026-08-27): ODbL obliges linking to Open Food Facts and to the specific product page, and the nutrition UI currently renders those as copyable `SelectableText` instead. Adopting it needs the `package-evaluation` workflow, which S1-5 did not have room for. Also the eventual home for privacy-policy/support links. flutter.dev-published, all four platforms. |

## Health-platform steps / active energy — ADOPTED 2026-08-29 (`health: 13.3.2`)

> ### CORRECTION (2026-09-03), superseding the 2026-08-28 verdict below
>
> **`health: 13.3.2` is in `pubspec.yaml`, pinned exactly (no caret), and has
> been since commit `9f30b95` (2026-08-29).** The section that follows was
> written the day before and concluded "UNRESOLVABLE here". It was wrong about
> the outcome, and reading it as current has already cost one agent an
> afternoon. What is true instead:
>
> - The **analyzer wall opened.** Verified in `pubspec.lock` on 2026-09-03:
>   `analyzer 13.3.0`, `riverpod_generator 4.0.8` (no longer the
>   `analyzer ^9.0.0` pin of 4.0.3), `json_annotation 4.12.0`,
>   `json_serializable 6.14.1`. The re-check trigger listed at the end of the
>   old section is exactly the one that fired.
> - The **`win32` wall was never a wall at 13.3.2**: it applied to versions
>   `<= 13.3.1` via `device_info_plus <13`. 13.3.2 requires
>   `device_info_plus >= 13`; the lock holds `device_info_plus 13.2.0` on
>   `win32 6.4.0`, which is the version this project was already pinned to. The
>   collision the old section describes was real for the versions it names and
>   simply does not apply to the one that shipped.
> - The **web-build trap was real and is what shaped the design.** `health` has
>   a top-level `import 'dart:io' show Platform;`, which fails to *compile* on
>   web. It is therefore reached only through a conditional export —
>   `core/platform/health/health_platform_adapter.dart` exports
>   `health_platform_stub.dart` `if (dart.library.io)`
>   `health_platform_io.dart`. Never import `package:health` anywhere else.
>   `google_mlkit_commons` (ADR 012) needed the identical treatment.
> - Everything the old section lists under "other costs, had it resolved" is now
>   a **live obligation**, not a hypothetical: minSdk 26, `FlutterFragmentActivity`,
>   the second unconditional KGP applier, the hosted privacy policy the Health
>   Connect rationale activity must link to, and the per-release Play data-type
>   declaration whose omission fails silently for users rather than at build.
>   Treat that paragraph as a checklist for release, not as an argument.
> - **`pedometer` stays rejected**, and every word of that paragraph still
>   holds: steps only, a since-boot counter that under-counts after every reboot
>   and records nothing while the app has not run, and the dangerous
>   `ACTIVITY_RECOGNITION` permission for the privilege.
> - **`getHealthIntervalDataFromTypes(..., interval: 86400)` exists but is not
>   used** — its bucketing is a fixed-duration slicer anchored at the range
>   start on both platforms, so it misattributes steps across a DST transition.
>   Per-day `getTotalStepsInInterval` with real local midnights is used instead.
>   Full reasoning in ADR 013.
> - The "minimum viable alternative, adopted instead" paragraph below (derive
>   from recorded activities) describes a **different, still-correct** thing:
>   distance/steps *during tracked activities* (ADR 008), which must never be
>   labelled "daily steps". It did not replace this package; both exist.
>
> Local step **history** (schema v22, `daily_step_totals`) is ADR 013.

### The 2026-08-28 evaluation, kept for its reasoning (verdict superseded above)

**`health` (cachet.dk) could not resolve in this project at any version *on
that date*.** Two
independent walls, both established by intersecting pubspecs pulled from the
pub.dev API rather than by running `pub upgrade`:

1. **13.3.2 breaks the analyzer window.** It needs `json_annotation ^4.12.0`;
   the only `json_serializable` accepting 4.12.x needs `analyzer >=10`, and
   `riverpod_generator 4.0.3` pins `analyzer ^9.0.0`. No analyzer version
   satisfies both. Escaping means moving riverpod + freezed + json_serializable
   together, onto at least one prerelease.
2. **Every version ≤13.3.1 collides with our locked `win32 6.4.0`**, via
   `device_info_plus <13` → `win32 ^5.11.0`. Our floor comes from
   `geolocator → geolocator_linux → package_info_plus → win32 ^6.0.1` — a
   **Linux** package we never ship blocking a **health** package on mobile.

> **Correction to `../troubleshooting/dependency_resolution.md`:** that doc
> attributes the analyzer-9 pin to `freezed`. `freezed 3.2.5` actually allows
> `analyzer >=9 <11`. **The real hard pin is `riverpod_generator 4.0.3`.**

> **Correction to this table's own earlier claim** that health "no-ops
> elsewhere": **`health` and `pedometer` both BREAK `flutter build web`** —
> each has a top-level `import 'dart:io' show Platform;`, and `dart:io` does
> not merely fail at runtime on web, it **fails to compile**. Any adapter must
> use `export 'stub.dart' if (dart.library.io) 'real.dart';`, not a plain
> import. Windows is the benign case: it compiles and throws
> `MissingPluginException`.

**`pedometer` is not an acceptable substitute.** It gives steps only — **no
active energy at all**, which is half the objective — and its `StepCount` is a
*since-boot* counter, so deriving "steps today" silently under-counts after
every reboot and records nothing while the app hasn't run. It still costs the
dangerous `ACTIVITY_RECOGNITION` permission, still breaks the web build, still
applies KGP unconditionally, and would be ripped out later.

**Other costs, had it resolved:** minSdk 24→26, iOS 13→15, `MainActivity` to
`FlutterFragmentActivity`, a **second unconditional KGP applier** (worse than
`mobile_scanner`'s conditional one — it would foreclose the built-in-Kotlin
migration rather than delay it), `connect-client 1.2.0-alpha02` in production,
a **hosted privacy policy as a build-time prerequisite** (the Health Connect
rationale activity must link to it), and a **per-release Play data-type
declaration** whose omission fails silently for users rather than at build.

**Minimum viable alternative, adopted instead:** derive step/distance figures
from activities the app already records via `geolocator` (ADR 008) and label
them honestly — *"during tracked activities"*, never *"daily steps"*. No
dependency, no permission, no store-review commitment.

**Re-check trigger** (a resolution test, not a date — all three must hold):
`riverpod_generator` moves off `analyzer ^9` together with a stable `freezed`
and `json_serializable ≥6.14.0` on one analyzer ≤12 (SDK `test 1.31.0` caps
`<13`); `health` still requires `device_info_plus ≥13`; and it is verified by
intersecting pubspecs, **not** by running `pub upgrade`. Pin exactly
(`health: 13.3.2`, no caret) when the door opens.

## Rejected (do not re-litigate without new facts)

Isar (abandoned), ObjectBox (no web), hive_ce (wrong model here), sqflite raw, auto_route, beamer, provider, bloc (see ADR 001), envied, flutter_dotenv, flutter_adaptive_scaffold (discontinued), google_fonts runtime fetching (offline-first — bundle fonts).
