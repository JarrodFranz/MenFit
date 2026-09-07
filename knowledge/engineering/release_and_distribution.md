# Release & Distribution (2026-09-05)

How tester builds leave the dev machine. Two channels, one identity:

| Platform | Built by | Delivered by | Script / config |
|---|---|---|---|
| Android | dev machine (Windows) | **Firebase App Distribution** | `scripts/distribute_android.ps1`, `distribution/android.json` |
| iOS | **Codemagic** (Mac runner) | **TestFlight** | `codemagic.yaml` |
| Web / Windows | not distributed yet | - | see "Not covered" |

Guarded by `test/platform/app_identity_guard_test.dart`.

## Permanent identity: `com.jarrodfranz.menfit`

Decided 2026-09-05, replacing the bootstrap placeholder `com.example.menfit_app`
/ `com.example.menfitApp`. It is registered with Apple and Firebase and is what
every installed copy is keyed on, so it never changes again. It appears in:

- `android/app/build.gradle.kts` - `applicationId` and `namespace`
- `android/app/src/main/kotlin/com/jarrodfranz/menfit/MainActivity.kt` - package path
- `ios/Runner.xcodeproj/project.pbxproj` - `PRODUCT_BUNDLE_IDENTIFIER` (Runner and
  `...RunnerTests`)
- `codemagic.yaml` - `ios_signing.bundle_identifier` and `BUNDLE_ID`

The **Dart package** name stays `menfit_app` (`pubspec.yaml`, every
`package:menfit_app/...` import). It is internal, never shown to users or
stores, and renaming it would touch hundreds of files for no benefit.

## Android: upload keystore (do this once, keep it forever)

Android refuses to install an update whose signing certificate differs from
the installed app's. A tester on a build signed with key A cannot update to key
B; they must uninstall, and uninstalling deletes their local health, cycle and
activity data (the app is local-first, ADR 003). So: **one key, created once,
backed up off-machine, used for every tester and store build.**

```powershell
.\scripts\create_upload_keystore.ps1
```

- Writes `%USERPROFILE%\menfit-signing\upload-keystore.jks` (outside the repo,
  so `git clean` and re-clones cannot touch it) and `android/key.properties`
  (gitignored) pointing at it. Refuses to overwrite an existing keystore;
  `-PropertiesOnly` rewrites `key.properties` for an existing keystore after
  verifying the password against it (use this if `key.properties` is lost or
  after a re-clone).
- Passwords are entered hidden and passed to `keytool` via `-storepass:env`,
  never on a command line.
- Uses the full JDK 17 at `C:\Program Files\Java\jdk-17` (same reason as
  `org.gradle.java.home` in `knowledge/troubleshooting/android_build.md`).
- Prints the SHA-1 / SHA-256 fingerprints; Firebase App Distribution does not
  need them, Play and Firebase Auth-style features later would.

`android/app/build.gradle.kts` reads `key.properties` when present and signs
`release` with it. When absent (fresh clone, CI without the secret) it falls
back to the debug key **and prints a WARNING**; `distribute_android.ps1` refuses
to upload in that state.

**Backup:** the `.jks` plus its password, in a password manager or encrypted
drive that is not this PC. Losing either means no existing tester can ever
receive another update.

## Android: Firebase App Distribution from the dev machine

One-time:

1. Firebase console -> project (the existing `menfit-5e600` GCP project used
   by the FatSecret proxy can host it) -> Add app -> Android -> package name
   `com.jarrodfranz.menfit`. `google-services.json` is **not** needed for
   distribution alone; only download it if Firebase SDKs are added later.
2. Copy the **App ID** (`1:<project-number>:android:<hash>`, Project settings ->
   Your apps) into `distribution/android.json` -> `firebaseAppId`. It is a
   public identifier, safe to commit. (It lives outside `env/` on purpose: the
   env guard test would flag a value that long as credential-shaped.)
3. App Distribution -> Testers & Groups -> create group `testers` (or edit
   `testerGroups`), add tester emails.
4. `npm install -g firebase-tools` (installed 2026-09-05, v15.29.0) and
   `firebase login` (browser sign-in; the CLI stores its own token under the
   user profile, nothing in the repo).

Every build:

```powershell
.\scripts\distribute_android.ps1 -Notes "What changed"
```

Builds `flutter build apk --release` with `env/staging.json` (+ the gitignored
`env/staging.secrets.json` overlay if present, ADR 006), uploads it, and
Firebase emails the groups. Testers install once via the emailed link (Android
asks to allow installs from the browser / App Tester app), then each later
upload arrives as a notification and installs **over** the previous one
because the signer and application id are unchanged. `-Env prod`, `-Groups`,
`-AppId`, `-SkipBuild` override the defaults.

Size: the universal release APK is ~123 MB (bundled ML Kit Latin model +
plugins, see `troubleshooting/android_build.md`). Fine for testers; split
ABIs / App Bundle stay the registered fix for store size.

**Do not** upload a debug-signed APK, ever, even "just to try it". A tester who
installs it is stranded on the debug certificate (see keystore section).

### MenFit Deploy (GUI)

`tools/menfit_deploy/bin/MenFitDeploy.exe` is a double-click WinForms wrapper
around the same script (it never reimplements it). It finds the repo by
walking up from its own folder, lists `env/*.json`, prefills the release
notes from `git log`, shows a preflight panel mirroring the script's refusals
(key.properties, `firebase`/`flutter` on PATH, app id, env file; missing
`env/<env>.secrets.json` is a warning only), then runs
`powershell.exe -File scripts\distribute_android.ps1 -Env .. -Groups .. -Notes ..`
and streams the output. Groups come from `distribution/android.json`:
`testerGroups` (alias `main`) always; `optionalTesterGroups` (`testers`) only
when the "also send to" checkbox is ticked. Values are Firebase group
*aliases* (lowercase, shown in the console next to each group's display
name). The exe is gitignored; rebuild with the Windows-bundled .NET Framework
compiler (no dotnet SDK):

```powershell
powershell -ExecutionPolicy Bypass -File tools/menfit_deploy/build.ps1
tools\menfit_deploy\bin\MenFitDeploy.exe --dry-run   # self-test, writes bin/dry-run.txt
```

Details: `tools/menfit_deploy/README.md`.

## iOS: Codemagic -> TestFlight

Nothing in the repo holds a secret. `codemagic.yaml` at the root defines one
workflow, `ios-testflight`, triggered by pushing a tag matching `ios-v*` (or by
hand in the Codemagic UI). Steps: write the secrets overlay -> `flutter pub get`
-> `flutter analyze --fatal-infos` -> `pod install` -> `xcode-project
use-profiles` -> `flutter build ipa` with build number = latest TestFlight
build + 1 -> upload to TestFlight. The `Internal testers` group has automatic
distribution on, so App Store Connect gives it every processed build itself;
`codemagic.yaml` deliberately lists no `beta_groups` (assigning an internal
group through the API is rejected - first build, 2026-09-06). External groups,
if ever created, are listed there explicitly.

One-time setup, in this order (Apple Developer Program membership required;
TestFlight also needs it):

1. **Apple Developer portal** -> Identifiers -> register App ID
   `com.jarrodfranz.menfit` with capabilities: **HealthKit** (steps/energy
   sync, ADR 013). Location, camera, Bluetooth and TTS need only
   `Info.plist` strings, not capabilities.
2. **App Store Connect** -> My Apps -> New app, bundle id above, name MenFit
   (working title; the store name can be changed until first release). Note
   the numeric **Apple ID** of the app record (App Information page).
3. **App Store Connect -> Users and Access -> Integrations -> App Store
   Connect API** -> generate a key with the **App Manager** role. Download the
   `.p8` once; note Issuer ID and Key ID.
4. **Codemagic -> Settings -> Integrations -> Developer Portal** -> add the key,
   name it **`menfit-asc`** (the name `codemagic.yaml` references). Codemagic
   uses it to generate the distribution certificate, fetch profiles, read the
   latest TestFlight build number and upload the build.
4b. **Signing files must exist in Codemagic before the first build.** The
   `ios_signing {distribution_type, bundle_identifier}` block only *fetches*
   signing files already stored under Codemagic -> Settings -> Code signing
   identities; it does not create them (verified against the Codemagic docs
   2026-09-06 after the first build failed with `No matching profiles found
   for bundle identifier "com.jarrodfranz.menfit" and distribution type
   "app_store"`). Once, no Mac needed: (a) Code signing identities -> iOS
   certificates -> Generate certificate, type Apple Distribution, API key
   `menfit-asc`, reference name `menfit_distribution`; (b) Apple portal ->
   Profiles -> + -> App Store Connect -> App ID MenFit -> that certificate ->
   name `MenFit App Store` -> Generate; (c) Code signing identities -> iOS
   provisioning profiles -> Fetch profiles -> select it -> Download selected.
   Regenerate the profile (b, c) whenever the App ID's capabilities change.
5. **Codemagic -> app -> Environment variables**, group **`menfit_secrets`**:
   - `APP_STORE_APPLE_ID` = the numeric Apple ID from step 2 (not secure).
   - `ENV_SECRETS_JSON` = the full contents of `env/staging.secrets.json`
     (mark **Secure**). Optional: without it the build runs and the route
     suggestion / FatSecret features show their setup cards.
6. **TestFlight** -> Internal Testing -> create group **`Internal testers`**
   with "Enable automatic distribution" left on, and add App Store Connect
   users (invite them under Users and Access first; the **Marketing** role
   scoped to MenFit only is the least-privileged role that qualifies).
   Internal groups need no Apple review, up to 100 testers. External groups
   allow anyone by email but the first build of each version goes through
   Beta App Review.
7. Push a tag: `git tag ios-v0.1.0-1 && git push origin ios-v0.1.0-1`, or
   click Start new build in Codemagic.

**Xcode project facts Codemagic relies on:** `CODE_SIGN_STYLE = Automatic`
and no `DEVELOPMENT_TEAM` committed (`use-profiles` injects both);
`IPHONEOS_DEPLOYMENT_TARGET` 15.5 and a committed `ios/Podfile` (ADR 012).
HealthKit entitlement: the `health` plugin needs `Runner.entitlements` with
`com.apple.developer.healthkit`; **not yet committed** - the first Codemagic
build will show whether the profile Codemagic generates carries it or whether
a Mac session must add the entitlements file (tracked in `handoff/HANDOFF.md`).

**What the first upload (build 1, 2026-09-06) taught, all fixed in the repo:**

- **Missing Compliance** in TestFlight: Info.plist now carries
  `ITSAppUsesNonExemptEncryption = false` (HTTPS via the OS only, exempt), so
  later builds skip the question. Build 1 needs it answered once by hand:
  Manage -> "None of the algorithms mentioned above" -> Save.
- **ITMS-90683 missing purpose string**: geolocator references the
  Always-location API, so Apple wants `NSLocationAlwaysAndWhenInUseUsageDescription`
  even though the app never requests Always (ADR 008). The string is present
  and says so.
- **HealthKit entitlement**: `ios/Runner/Runner.entitlements` is now committed
  and wired via `CODE_SIGN_ENTITLEMENTS` in the three Runner configurations.
  Build 1 was not entitled, so Apple Health sync would have failed silently.
- **App icon**: the iOS icon set was still the Flutter template. It is
  generated from `assets/images/app_icon.png` by
  `python scripts/generate_ios_icons.py` (`--check` to verify); rerun it
  whenever the emblem changes.

Version numbers: `CFBundleShortVersionString` comes from `pubspec.yaml`
`version:` (bump it for each TestFlight *version*); the build number is
assigned by the workflow, so never hand-set `+N` for iOS.

## Env for tester builds

Both channels default to **`staging`** (`LOG_LEVEL=info`; otherwise identical
to prod today). `OFF_CONTACT` in `env/staging.json` / `env/prod.json` is
still empty - the pre-distribution checklist in `flutter/platform_notes.md`
says to set a role/support address before builds reach outsiders.

Tester builds now carry `env/staging.secrets.json` (created 2026-09-05 on the
dev machine, gitignored, ADR 006) with `FATSECRET_PROXY_URL` set to the proxy
endpoint (`backend/fatsecret-proxy/README.md`). `distribute_android.ps1`
picks up this overlay automatically when present (see the Android section
above), so Android tester builds get FatSecret-primary-with-OFF-fallback
lookups (ADR 016) without any script change.

Codemagic's iOS workflow needs the **same JSON pasted into the
`ENV_SECRETS_JSON` variable** in the `menfit_secrets` group (owner step, see
the iOS section above) — it does not read `env/staging.secrets.json` off the
dev machine, since nothing in the repo or in Codemagic's config holds a
secret value.

`ORS_API_KEY` (route suggestions, ADR 009) is **deliberately not** in the
staging overlay yet — an owner decision pending on API quota, separate from
the FatSecret rollout above.

**Without the secrets overlay, a build silently uses Open Food Facts only**
(no FatSecret call is attempted, and route suggestions show their setup
card) — this is ADR 010's original, still-supported behaviour, not a broken
or degraded state.

## Not covered

- **Web / Windows** distribution: Firebase App Distribution does not support
  them. Web would be Firebase Hosting (also code-free); Windows is blocked
  anyway by the `audioplayers` N/KN crash (`product/deferred.md`). MSIX
  identity and `web/manifest.json` still carry the working title.
- **Play Store**: needs a Google Play Developer account; App Distribution
  does not. When Play arrives, use this same upload key.
- **Silent in-app updates** (Shorebird-style): out of scope; both channels
  notify and reinstall.
