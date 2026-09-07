# Platform Notes (project-specific)

*Project-specific platform observations. Generic Windows/Web facts: central base `platform-windows.md` / `platform-web.md`. Roles & adapter architecture: `../architecture/platform_architecture.md`.*

## Bootstrap facts (2026-08-25)

- Dev machine: Windows 11, Flutter 3.44.4 stable, Dart 3.12.2. Windows + Web + Android build locally; **iOS cannot be compiled here** (needs macOS) — target committed, validation deferred to a Mac/CI.
- ~~Project identifiers `menfit_app` / `com.example` are temporary~~ **Renamed 2026-09-05** to `com.jarrodfranz.menfit` (applicationId, namespace, Kotlin package, iOS bundle id). The Dart package `menfit_app` stays. MSIX identity / web manifest still carry the working title (no Windows/Web distribution yet). See `engineering/release_and_distribution.md`.

## Pre-distribution checklist

Things that are fine locally and **must** be changed before any store or
public distribution build:

- ~~Rename `menfit_app` / `com.example`~~ Done 2026-09-05 for Android + iOS
  (`com.jarrodfranz.menfit`); MSIX identity and web manifest remain on the
  working title until Windows/Web are distributed.
- **Sign Android with the upload keystore** (`scripts/create_upload_keystore.ps1`
  once; `distribute_android.ps1` refuses debug-signed builds) — see
  `engineering/release_and_distribution.md`.
- **Set `OFF_CONTACT` in `env/prod.json`** (added 2026-08-27, S1-5). Open
  Food Facts requires a User-Agent of `AppName/Version (ContactEmail)` and
  uses that contact to reach a misbehaving client — without it, the remedy
  available to them is blocking the app's traffic instead of emailing about
  it. Empty by default, and the User-Agent is built without the
  parenthetical while it stays empty (`core/config/env.dart#offContact`,
  `features/nutrition/data/open_food_facts_service.dart`). **A role/support
  address, never a personal one**: it ships in the binary and is sent on
  every request.
- **Bump `openFoodFactsClientVersion`** with `pubspec.yaml`'s `version:` —
  a guard test in `test/features/nutrition/open_food_facts_service_test.dart`
  fails if the two drift.

## Desktop tap-target defaults differ from mobile (2026-09-02)

`ThemeData` selects `MaterialTapTargetSize.shrinkWrap` and
`VisualDensity.compact` on Windows/macOS/Linux (`theme_data.dart` ~404-408).
Buttons, chips and switches therefore measure 38-40dp under `flutter test`
on this Windows machine and 48dp on Android/iOS. Any accessibility
measurement taken here describes the desktop build; the `largeTouchTargets`
preference forces `padded` + `standard` density so it reaches 48dp on every
platform. See `knowledge/engineering/accessibility.md`.

## Emulator review tooling (2026-09-02)

`scratch/emu.sh` wraps `adb` for on-device screen review (start/shot/tap/swipe/back/text)
against the Pixel 6 Pro API 36 image: 1440x3120 @ 560dpi, so **3.5 px/dp** —
`tap`/`swipe` take logical dp and convert internally. Swipes must start
**above** the NavigationBar (y < ~780dp at 411x891dp) or nothing scrolls and
three identical screenshots look like a frozen screen. When a dp-computed tap
lands on the right-looking spot but does nothing (seen on the GPS record
Finish/confirm screen), fall back to `adb shell uiautomator dump` to read the
element's exact pixel bounds and tap the raw center — more reliable than the
screenshot-scaling maths for small/precise targets.

## Native sharing (share_plus 13.3.0, 2026-09-02)

ADR 011. Reached only through `SharingAdapter` (`lib/core/platform/sharing/`);
`ShareOutcome` is `{success, dismissed, unavailable, fellBackToDownload,
fellBackToClipboard}` plus a `supportsShareResult` flag. Per-platform, from
the package docs (verified by the implementer, **not** on device except where
noted):

- **Android** — no manifest change needed; the plugin ships its own
  `ShareFileProvider`. Toolchain floors are already met (AGP 9.0.1, Gradle
  9.1.0, Kotlin 2.3.20, Java 17, minSdk 26).
- **iOS** — nothing needed; requires iOS >= 13.0 (our target is 13.0).
  Optional `CFBundleAllowMixedLocalizations` fix for share-sheet language
  (plus_plugins #2696) — Mac-only, see below.
- **Web** — needs HTTPS + a user gesture (the workout-card PNG is captured
  post-frame *before* the share tap, specifically to preserve the gesture).
  Desktop Firefox has no Web Share API and downloads instead of sharing;
  `fellBackToDownload` is defined for this but unreachable in practice — the
  web plugin reports a real share and a download fallback identically, so the
  adapter cannot distinguish them.
- **Windows** — `DataTransferManager` needs build >= 17763; below that, text
  falls back to `mailto:` and file shares **throw** (the adapter catches this
  and maps it to `fellBackToClipboard`). `ShareResultStatus` is always
  `unavailable` on Windows, so `supportsShareResult` is `false` there and the
  UI must never claim confirmed delivery. **Dev-machine verification is still
  open** — nothing above has been exercised on this Windows box yet.
- **Linux** — image share degrades to text share (package limitation, not
  ours).

**Mac session must verify** (none of this is checkable on Windows):
iPad share-sheet popover anchoring via `sharePositionOrigin`; the PNG
filename arriving correctly via `XFile.fromData` + `fileNameOverrides` in
Messages/Mail/Photos; the `CFBundleAllowMixedLocalizations` plist question
above; and that image+text share together without a third-party app
silently dropping one of the two.

**Housekeeping not yet done:** share_plus writes temp files to the app cache
under `.../caches/share_plus` on mobile; the package recommends clearing
that directory at app start. Not implemented — tracked in `deferred.md`.

## On-device nutrition-label OCR (ADR 012, 2026-09-03)

`google_mlkit_text_recognition` 0.17.1 + `image_picker` 1.2.3, reached only
through `lib/core/platform/ocr/`. Capability flag
`textRecognitionSupported`; port `OcrAdapter`; capture service
`LabelCaptureService`. Per-platform, from package source and docs — **none
of it exercised on a device yet**:

- **Android** — works, subject to the first-build smoke test below. No
  manifest change: `mobile_scanner` already merges
  `android.permission.CAMERA` + its `uses-feature` entry, and
  `image_picker`'s delegate detects that declaration and requests the
  runtime permission itself before launching `ACTION_IMAGE_CAPTURE`. The
  capture is written to `activity.getCacheDir()` — app-private, not
  MediaStore, so it never appears in the gallery — and is deleted
  immediately after recognition. minSdk 26 clears ML Kit's floor of 21.
  **Smoke item:** two ML Kit artifacts now coexist (text recognition here,
  barcode via `mobile_scanner`). They share `com.google.mlkit:common` and
  are designed to coexist, but the first Android build must confirm both
  that Gradle resolves them and **what the APK now weighs** — both models
  are bundled rather than Play-downloaded.
- **iOS** — cannot be compiled here. Deployment target was raised 13.0 →
  **15.5** in all three `IPHONEOS_DEPLOYMENT_TARGET` entries, and
  `ios/Podfile` is now committed (it did not exist before) with
  `platform :ios, '15.5'`. iOS 13/14 devices are dropped as a result.
  `NSCameraUsageDescription` already existed for barcode scanning and was
  **widened** to cover both uses — iOS permits only one such key.
  `TextElement.confidence` is documented as returning null on iOS.
- **Web** — no OCR, and the reason is stronger than "no implementation":
  `google_mlkit_commons` imports `dart:io` unconditionally, so the adapter
  cannot be *compiled* into a web build. That is why the ML Kit adapter
  sits behind the conditional export in
  `lib/core/platform/ocr/ocr_platform.dart` rather than behind the
  capability flag alone — a flag is read at runtime, an import is resolved
  before that. A guard test asserts only the seam imports it. **This
  machine builds Windows and Android by default, so a stray import would
  not be noticed until someone runs a web build.**
- **Windows / macOS / Linux** — `UnsupportedOcrAdapter`, which returns
  `OcrResult.unsupported()` rather than throwing. Windows would need both
  MSIX/sparse package identity (for `Windows.Media.Ocr`) and a camera
  frame source it does not have; see ADR 012.

**Mac session must verify** (none of it checkable on Windows):

- `pod install` resolves with the committed Podfile and the 15.5 target,
  and the Runner target actually builds at 15.5.
- The camera permission prompt fires with the widened string, from the
  label-capture path as well as the barcode path.
- `ImageSource.camera` with `requestFullMetadata: false` does **not**
  trigger a photo-library permission prompt (there is deliberately no
  `NSPhotoLibraryUsageDescription`), and the returned file really is in
  the app cache and really is gone after the call.
- Whether `TextElement.confidence` / `TextLine.confidence` are null on iOS
  as documented — the review-form confidence UI depends on the answer
  (ADR 012 lists this as an open spike).

## Daily step history (ADR 013, schema v22, 2026-09-03)

`health 13.3.2` behind `core/platform/health/`, reached only through the
conditional export. Capability flag `healthPlatformSupported` (Android + iOS
only); Windows/Web/macOS/Linux get `StubHealthPlatformAdapter`, which reports
unsupported and returns no rows — the steps screen still *displays* history a
phone synced, it just cannot read anything new.

**Device verification still open (not reachable from tests):**

- **DST — verify daily buckets across the 25 October transition.** Each day is
  read as `DateTime(y, m, d)` to `DateTime(y, m, d + 1)`, calendar-field
  arithmetic chosen precisely so the 23-hour and 25-hour local days stay whole.
  The plugin's own ranged call was rejected for getting this wrong (ADR 013),
  so this is the assumption the whole design rests on and it cannot be
  exercised on a test VM. Check on a real device, in a timezone that observes
  DST, that the day either side of the transition holds that day's steps and
  neither borrows nor loses an hour of them.
- **Android** — confirm Health Connect actually returns per-day totals for a
  35-day window without throttling the 36 sequential calls, and that
  `getHealthConnectSdkStatus` gates cleanly on a device without Health Connect
  installed.

**Mac session must verify** (none of it checkable on Windows):

- **iOS never reports READ permission, and the adapter now assumes granted
  there.** `Health.hasPermissions(..., READ)` returns `null` on iOS forever
  (plugin source: `HealthDataOperations.hasPermission` returns `nil` for
  `access == 0`; Apple withholds it because the answer leaks whether the user
  has data). `_hasReadPermission` therefore resolves `null` as granted on iOS
  and denied on Android. **This changes existing behaviour**: before, the OR of
  three `?? false` terms made `hasPermissions()` unconditionally `false` on
  iOS, so `getSnapshotForDate` bailed out early and the home "At a Glance"
  steps/energy card could never have shown data there. Verify on a device that
  (a) the card now populates after granting access, and (b) with access
  **denied**, step days are *omitted* rather than stored as zero — the read is
  expected to throw `STEPS_ERROR`, which `_stepsForDay` maps to an absent day.
- That a denied grant does not surface as a chart full of zeroes anywhere.

## Transition cue audio + screen-awake (ADR 014, 2026-09-04)

`audioplayers 6.8.1` behind `core/platform/audio/` and `wakelock_plus 1.8.0`
behind `core/platform/wakelock/`, both exact pins, both reached only through
their adapter (import guards in `test/core/platform/audio/` and
`test/core/platform/wakelock/`). The cue asset
`assets/audio/transition_chime.wav` is generated by
`scripts/gen_transition_chime.py` — our own synthesis, no third-party licence.

### The AGP 9 blocker that did not happen (MEASURED 2026-09-04)

The package evaluation predicted a Gradle **configuration** failure:
`audioplayers_android 5.3.0` and `wakelock_plus 1.8.0` both dropped
`apply plugin: 'kotlin-android'` for AGP 9's built-in Kotlin, and this repo
runs AGP 9.0.1 with `android.builtInKotlin=false`
(`../troubleshooting/android_build.md` — do not flip that flag, it was measured
to fail). Fallback pins `audioplayers_android: 5.2.1` and
`wakelock_plus: 1.6.1` were prepared.

**Neither was needed.** `flutter build apk --debug` and `--release` both
succeeded on the first attempt with the head versions. The KGP warning still
names only `health, mobile_scanner`; the two new plugins are absent from it,
i.e. they configure and compile without applying KGP at all under this AGP.
Do not add the dependency_overrides pre-emptively.

R8 needed **no** new `-dontwarn`: `flutter build apk --release` passed
`:app:minifyReleaseWithR8` untouched, unlike the ML Kit adoption.

### Per-platform behaviour

| | Android | iOS | Web | Windows |
|---|---|---|---|---|
| Chime plays | yes | yes | yes, after a user gesture | yes (see N/KN below) |
| Other audio | ducks (`gainTransientMayDuck`) | mixes, no duck | mixes | mixes |
| Silent switch | n/a | **respected** (`ambient`) | n/a | n/a |
| Screen awake | `FLAG_KEEP_SCREEN_ON` | `isIdleTimerDisabled` | HTTPS only, lost when the tab hides | `SetThreadExecutionState` |

No permission, manifest, entitlement or Info.plist change was needed for
either package. `UIBackgroundModes: audio` is deliberately **not** declared —
these are foreground cues.

- **Web** — the browser refuses audio that no user gesture led to, and the
  gesture that counts is the one on the call stack. `AudioCuePlayer.preload()`
  must be called synchronously from the Start tap; preloading from a timer or
  a controller `build` leaves the first cue silently dropped. The wake lock
  additionally needs a secure context and **is not restored when the tab comes
  back** — a web caller re-acquires on resume.
- **Windows N / KN** editions have no Windows Media Foundation until the user
  installs the Media Feature Pack, and `audioplayers_windows` fails to create
  a player there. Not detectable from Dart. `AudioplayersCuePlayer` latches
  itself unavailable on the first failed call rather than throwing, so the
  practice degrades to haptic + visual. `audioCueSupport` stays `true` on
  Windows regardless — reporting the whole platform unsupported to spare a
  minority of machines would take the chime from everyone else.
- `windows/CMakeLists.txt` was raised from the template's 3.14 to **3.15**
  (`cmake_minimum_required` and `cmake_policy` both) because
  `audioplayers_windows` requires it. Guarded by
  `test/platform/windows_cmake_minimum_test.dart`. **`flutter build windows`
  has NOT been run against this change** — the bump is the documented fix, not
  a verified one.

### Mac session must verify

- **The iOS silent switch actually silences the cue.** The adapter sets
  `AVAudioSessionCategory.ambient` with **no** explicit options — ADR 014 chose
  to respect the hardware switch and mix with her music rather than override
  either. Confirm on a device that (a) with the switch on Silent there is no
  chime and the practice still runs on haptic + visual, and (b) with sound on,
  her music keeps playing *underneath* the chime rather than pausing.
- `mixWithOthers` is deliberately not passed: `AudioContextIOS` **asserts**
  that the option may only be set explicitly under
  `playback`/`playAndRecord`/`multiRoute`, and iOS enables it implicitly for
  `ambient`. Passing it, as the evaluation's note suggested, would be a debug
  assertion failure rather than a stricter setting.
- That the wake lock releases when the runner is left by any route (finish,
  discard, back gesture, app backgrounded) — an unbalanced lock is a flat
  battery and is invisible on a plugged-in dev machine.

**Screen lock is reference-counted (2026-09-04).** `active_workout_summary.dart`
is a deliberate priority fallthrough over six keepAlive tracker controllers, so
two trackers can be active at once (a GPS recording plus a strength workout
opened and discarded). `WakelockPlusScreenAwake` therefore counts holders and
disables only at the last release; `TrackerScreenAwake` makes each controller
exactly one holder. Do not "simplify" the port back to a bool.

## Add entries as platform work happens

(per-platform build issues → `../troubleshooting/`; behaviours/quirks here)
