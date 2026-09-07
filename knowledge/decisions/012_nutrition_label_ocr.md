# 012 — On-device nutrition label OCR

- **Status:** Accepted (owner go, 2026-09-03; phase 1 platform track adopted)
- **Date:** 2026-09-03

## Context

The food diary currently offers manual entry and Open Food Facts barcode
lookup (ADR 010). The product owner asked for a third path: photograph a
printed nutrition table and pre-fill the entry form from it, with a hard
rule that recognition and parsing run entirely on-device — no photo, crop,
or extracted text may leave the phone. The owner is based in Australia, so
the **FSANZ Nutrition Information Panel (NIP)** is the primary label format
this has to parse — Per Serving and Per 100 g columns, kJ and Cal combined
on one energy row, and indented "of which" sub-rows (saturated fat, sugars)
— with US FDA and EU/UK panel layouts as secondary targets.

## Options considered

- **google_mlkit_text_recognition** 0.17.1 — on-device text recognition via
  Google ML Kit, Android + iOS only.
- **Apple Vision** platform channel (hand-written) — iOS-only native OCR.
- **`Windows.Media.Ocr`** — WinRT OCR API.
- **Tesseract.js** on web — WASM OCR in the browser.
- **`flutter_tesseract_ocr`** — Flutter wrapper around Tesseract.
- **`flutter_ocr_native`** 0.3.3 — small third-party OCR plugin.
- **`nutrition_ai`** (Passio) — commercial nutrition-label/food recognition SDK.

## Decision

Adopt **google_mlkit_text_recognition 0.17.1, pinned exactly**, for
Android/iOS only, reached through a `textRecognitionSupported` capability
flag in `core/platform/` (same pattern as `barcode_scanning.dart`) and an
`OcrAdapter` port, so no feature code imports ML Kit directly. Recognised
text and bounding boxes feed a **pure-Dart heuristic parser** living in the
nutrition domain layer:

- Row clustering by y-coordinate, column bucketing by x-coordinate, both
  from the ML Kit bounding boxes.
- A keyword dictionary (energy, protein, fat, saturated, carbohydrate,
  sugars, sodium, fibre, etc.) with fuzzy matching for common OCR typos.
- Unit handling for g / mg / µg / kJ / kcal / Cal, "<1 g", and comma
  decimals.
- Header-based assignment of columns to per-serving vs per-100 g, per the
  FSANZ NIP layout.
- Parser-derived per-field confidence (not ML Kit's, which is unreliable —
  see Consequences).

Every recognised value goes through a **mandatory review form** before it
can be saved — OCR output is modelled as a candidate, the same shape as
`ProviderFood` (ADR 010), and there is deliberately no path that saves it
unedited. Photo bytes are held in memory only; they are never written to
disk or logged. On Web and Windows, the OCR entry point is hidden entirely
and manual entry remains the only path.

## Reasons

- `google_mlkit_text_recognition` is genuinely on-device: recognition runs
  through a native `MethodChannel`, nothing is sent to Google or anywhere
  else at inference time.
- The Latin recognition model ships **bundled with the package** — no
  first-use download, no network dependency, no "works only after a
  connected first run" edge case.
- Maintenance and licence are solid: flutter-ml.dev, MIT, 410 likes / 150
  pub points.
- Minimal dependency footprint: only `google_mlkit_commons ^0.13.0`, no
  analyzer/codegen-chain transitive dependencies — safe for the current
  analyzer window the same way ADR 011's share_plus was.
- Platform floors are already met: iOS 15.5 and minSdk 21 both sit inside
  what the app already requires.
- No Dart-level conflict with `mobile_scanner` 7.4.0 (ADR barcode scanning
  adoption) — `mobile_scanner` has no Dart-level ML Kit dependency of its
  own, so the two packages don't fight over a shared Dart API surface.
  Native Gradle coexistence of the two underlying ML Kit artifacts
  (barcode + text-recognition) is a first-integration smoke item, not a
  known conflict.

## Consequences

- **`TextElement.confidence` is nullable and reportedly often null** —
  this needs verification on a real device. The parser therefore computes
  its own per-field confidence (keyword-match strength, unit-parse
  success, column-assignment certainty) rather than depending on ML Kit's
  value, and the review form is mandatory regardless of what either
  confidence signal says.
- **Native Gradle coexistence** of `google_mlkit_text_recognition` and
  `mobile_scanner`'s ML Kit barcode artifact is unverified until the first
  integration build; treat it as a smoke-test item, not an assumption.
- **Windows has no OCR path in phase 1.** `Windows.Media.Ocr` needs package
  identity (MSIX or a sparse package), which an unpackaged `flutter build
  windows` does not have — this is a distribution-model decision, not an
  engineering one, and belongs to the owner. Windows also has no live
  camera frame stream (`camera_windows` — see the existing note under
  mobile_scanner in `knowledge/flutter/package_decisions.md`), so any
  eventual Windows flow would have to be "import a photo file," not "point
  the camera."
- **Web has no OCR path in phase 1.** Tesseract.js would need a
  self-hosted WASM binary plus `.traineddata` under `web/` (matching the
  existing CDN-privacy stance already taken for `mobile_scanner`'s web
  backend) and a hand-written `dart:js_interop` bridge — estimated 3-5
  days of standalone work, deferred rather than rejected.
- Effort if the owner says go: capture + OCR + raw preview 1-2 days;
  parser + review form 5-8 days; label-text corpus + tests 2-3 days
  (requires photographing real packaging, so this cannot be done from
  fixtures alone); **total phase 1 estimate ~8-13 engineering days**,
  excluding on-device verification time.
- Open decisions that are the owner's, not engineering's:
  - Whether to invest in MSIX/sparse packaging to unlock Windows OCR (a
    distribution-model change with consequences well beyond this feature).
  - Whether to invest in self-hosting Tesseract.js to unlock Web OCR.
  - ML Kit confidence reliability needs an on-device spike before the
    confidence UI in the review form is finalised.

## Rejected alternatives

- **Apple Vision platform channel** — deferred, not rejected outright. It
  would duplicate ML Kit's iOS coverage and reportedly gives better
  confidence values, but there's no reason to hand-write a second OCR
  integration until ML Kit's iOS behaviour is proven insufficient. Revisit
  only if ML Kit underperforms on iOS in practice.
- **`Windows.Media.Ocr`** — blocked for phase 1: requires package identity
  (MSIX/sparse package) that an unpackaged `flutter build windows` lacks,
  and Windows has no live camera stream regardless, so any Windows flow
  would be photo-import only. Not a package problem to solve later; a
  packaging decision.
- **Tesseract.js on web** — deferred: needs a self-hosted WASM + trained
  data under `web/` (the same privacy posture already applied to
  `mobile_scanner`'s web backend) plus a hand-written `dart:js_interop`
  bridge, roughly 3-5 days of standalone work.
- **`flutter_tesseract_ocr`** — rejected: slower than ML Kit by its own
  documentation, no Windows support, large bundled traineddata assets, and
  no platform coverage advantage over the ML Kit option.
- **`flutter_ocr_native`** 0.3.3 — rejected: 2 likes, 533 downloads,
  unverified publisher, 0.x version — well below the adoption bar this
  project applies to packages.
- **`nutrition_ai` (Passio)** — rejected outright: commercial product
  requiring an account, an SDK key, and internet connectivity to set up
  and/or operate. Violates the hard local-only requirement this feature
  was scoped under before any other comparison was needed. Licence terms
  were not even evaluated further once the connectivity requirement was
  confirmed.

## Implementation notes (platform track, 2026-09-03)

Added at adoption. Everything here was established while wiring the
adapter; none of the iOS items have been compiled.

### Capture path — `image_picker` 1.2.3

The app had no still-photo capture at all: `mobile_scanner` streams frames
for barcode decoding and cannot hand back a photo. `image_picker` was not
previously evaluated and is not on the rejected list, so it was evaluated
now and adopted **for `ImageSource.camera` on mobile only** —
flutter.dev verified publisher, 160 pub points, 7.76k likes, 3.9M weekly
downloads, Apache-2.0/BSD-3, no analyzer-chain transitive dependencies.
Alternatives were `camera` (a full preview surface we would have to build
and a second permission story, for no gain over the OS camera app) and a
hand-written platform channel (two native implementations to own).

Its Android delegate writes the capture into `activity.getCacheDir()` and
hands back that path — app-private cache, not MediaStore, not the gallery
— which is verified in the plugin source, not assumed. That file is read
by the recogniser and deleted in a `finally`
(`core/platform/ocr/label_capture.dart`); it is never copied, never
persisted and never logged. Two settings serve the same rule and must not
be "improved" away: `requestFullMetadata: false` (stops the iOS plugin
reaching into the Photos library for the asset's metadata, which is where
the GPS coordinates of the shot live) and **no** `maxWidth` / `maxHeight`
/ `imageQuality` (resizing costs accuracy on small print, and the Android
plugin implements it by writing a *second* scaled file while leaving the
original in place).

### The photo that outlives the call, and the sweep for it

Added at review. Android may destroy `MainActivity` while the OS camera is
in front — under memory pressure it is entitled to — and when it does, the
`pickImage` future this process is waiting on **never completes**. The
`finally` that deletes the capture never runs, and the JPEG stays in the app
cache indefinitely: the one hole in "the photo does not survive this call".
`image_picker` exists on the other side of that with `retrieveLostData`, so
`captureAndRecognizeLabel` now begins by sweeping it and **deleting**
whatever it recovers *without recognising it* — the user is asking to scan a
label now, and silently reading a stale picture of whatever she photographed
last time would be both wrong and a surprise. Android-only: the platform
interface throws on iOS, and the throw is swallowed rather than guarded on a
platform check, because best-effort cleanup must never be the reason a
capture fails to start. Nothing about it is logged; the exception quotes the
path.

### `google_mlkit_commons` imports `dart:io` unconditionally

Discovered at adoption and not anticipated by the evaluation. It means the
ML Kit adapter cannot be *compiled* into a web build at all — not "throws
at runtime on web", fails `flutter build web`. A capability flag alone is
not enough, because an import is resolved before any flag is read. The
adapter is therefore reached through a conditional export seam,
`core/platform/ocr/ocr_platform.dart`, the same mechanism
`core/platform/health/health_platform_adapter.dart` already uses. A guard
test asserts nothing but that seam imports `ml_kit_ocr_adapter.dart`.

This is the sharpest trap in the feature: the dev machine builds Windows
and Android by default, so a stray import would go unnoticed until
someone runs a web build.

### iOS deployment target 13.0 → 15.5

`google_mlkit_text_recognition` 0.17.1 requires iOS 15.5; the project was
at 13.0. All three `IPHONEOS_DEPLOYMENT_TARGET` entries in
`ios/Runner.xcodeproj/project.pbxproj` were bumped, and an `ios/Podfile`
is now **committed** with `platform :ios, '15.5'` uncommented — previously
there was no Podfile in the repo at all, so a Mac session would have got
the Flutter template with the platform line commented out and CocoaPods
inferring the platform from the Xcode project. The committed file is the
Flutter 3.47 template verbatim apart from that line.

Consequence for the product: iOS 13 and 14 devices are dropped. That is a
distribution decision the OCR feature forces, not a free change.

**Not compiled.** Neither the target bump nor the Podfile can be verified
on the Windows dev machine. Mac-verify list is in
`knowledge/flutter/platform_notes.md`.

### Android

No manifest change needed. `mobile_scanner` already merges
`android.permission.CAMERA` and its `uses-feature` entry into the app
manifest, and `image_picker`'s delegate detects that declaration
(`ImagePickerUtils.needRequestCameraPermission`) and requests the runtime
permission itself before launching `ACTION_IMAGE_CAPTURE`. minSdk 26
clears ML Kit's floor of 21.

**First-Android-build smoke item (unchanged from the evaluation):** Gradle
coexistence of `google_mlkit_text_recognition`'s ML Kit text artifact with
`mobile_scanner`'s ML Kit barcode artifact. They are designed to coexist
and share `com.google.mlkit:common`, and there is no known conflict — but
two bundled ML Kit models also mean a materially larger APK, so check both
that the build succeeds and what it now weighs.

### Camera permission string

iOS permits exactly one `NSCameraUsageDescription`, so the existing
barcode-scanning string was widened to cover both uses rather than a
second key being added. It now names the nutrition label, says processing
is on-device, and says the photo is discarded — three claims the
implementation actually keeps, asserted by
`test/platform/ocr_platform_config_guard_test.dart` so that a future
change to either has to change the other.

## Implementation notes (integration track — the review form, 2026-09-03)

Added while wiring the parser to the food form. Nothing here has been run
on a device; the flows below were exercised against transcribed fixtures
and a fake capture service.

### One declaration of the recognised-text types

The platform track and the parser track each declared their own
`OcrRect`/`OcrElement`/`OcrLine`/`OcrBlock`/`OcrResult`, because neither
layer may import the other: architecture rule 1 keeps a feature's `domain/`
free of `core/platform`, and rule 3 keeps `core/` out of features. Two
structurally identical types with slightly different APIs (`OcrOutcome` and
`unsupported()` on one side, `union()` and `empty` on the other) is the
worst of both — the adapter's mapping and the parser's reader drift apart
silently, and every test double has to pick a side.

Rule 3's actual answer is `core/domain/`, which already hosts the
Flutter-free shared value types (`local_date.dart`, `units.dart`,
`entity_id.dart`) and is importable from both. The two files were replaced
by one **union** at `lib/core/domain/ocr/ocr_text.dart`; the platform
adapter re-exports it through `ocr_adapter.dart`, so nothing outside
`core/platform/ocr/` changed shape.

Both guards were updated rather than merely relaxed:

- `test/features/nutrition/label_ocr/label_ocr_import_guard_test.dart` now
  **scans** `lib/core/domain/ocr/` under the same rules as the parser
  itself (no Flutter, no `dart:ui`, no `dart:io`, no engine package, no
  `core/platform`). Allowing the import without scanning the file would
  have been a hole: a `dart:ui` `Rect` in the shared file breaks the
  parser's testability just as thoroughly as one declared beside it.
- `test/core/platform/ocr/ocr_import_guard_test.dart` gained a test that
  each shared type is declared **exactly once** in `lib/`, and at that
  path. The duplication was not caught by review; it is now caught by a
  test.

### Merge, never replace

A scan fills fields that are **currently blank** and touches nothing else.
Where the panel and a value the user already typed disagree, hers stands
and the difference is stated under the review banner ("Kept your value for
calories (label read 198)."). The alternative — a scan that overwrites —
is one tap away from silent data loss on the screen where the numbers are
the entire point.

The same rule covers the amount/unit: the scanned basis is applied only
when the amount, unit, serving weight and portion description are all
still on their untouched defaults.

Markers from an earlier scan survive a later one for fields it did not
refill: the value is still on the form and was still read off a photo, so
dropping the marker would quietly upgrade an unsure number to a checked
one.

Consequences worth knowing:

- The form's fields now read their text from **controller state**, not
  from the seed. A field wired to the immutable seed keeps showing a blank
  after a scan fills it. `_Field` became
  `widgets/food_form_field.dart#FoodFormTextField` in the process.
- The "Additional nutrients" `ExpansionTile` is re-keyed on
  `labelScanApplied`, so a scan that fills eight optional nutrients
  reopens the section instead of hiding them behind a collapsed header.
- `FoodFormSeed.foundInDatabase` now requires `source == openFoodFacts` as
  well as a non-null `servingBasis`. A per-100 g *label* also carries a
  basis, and the old test would have put the Open Food Facts notes and the
  ODbL attribution under a food nobody but the user has ever seen.

### Per 100 mL is not per 100 g

A drink panel supplies numbers and no mass. The values are prefilled into
"Per Reference" mode with a **blank** amount, `FoodFormState.labelIsPerVolume`
is set, and the save is refused until she supplies a weight — because
`_effectiveServing` reads a blank amount as 100, so doing nothing would
have filed figures printed per 100 mL as "per 100 g" with nobody told. The
copy names the next action rather than the impossibility: "This label is
per 100 mL. FemFit records weight — enter the grams for 100 mL before
saving." (`knowledge/domain/nutrition.md`: 100 ml of oil is ~92 g, of honey
~140 g. It does not offer "or a serving weight": a per-volume panel puts
the form in per-reference mode, where that field is not rendered.)

**The guard has to be sticky, and independent of who set the basis.**
Deriving it from "was the basis untouched" left two ways through, both
ending in per-100 mL figures saved as per-100 g. The first per-volume scan
*is* what touches the basis, so a **second** scan of the same panel
recomputed the flag as false and let the save through; and a user who had
already typed an amount never set the flag at all. So `labelIsPerVolume`
is now `fields.needsWeight || current.labelIsPerVolume`, and a second flag,
`labelVolumeWeightConfirmed`, records whether she has set the amount
*since* that scan — a weight typed beforehand was about a food she was
defining by weight, not a claim about what 100 mL of this drink weighs.
Both gates are load-bearing: the confirmation catches the amount she
already had, and the blank-amount check catches her clearing the field
again afterwards.

### An unrecognised standard is not an unreadable photo

`scanLabel` refuses only on `ParsedNutritionLabel.isEmpty`, never on
`LabelFormat.unknown`. A tight crop that loses the "Nutrition Information"
heading still yields a clean two-column table, and telling the user her
perfectly good photo could not be read is both false and a dead end. The
parser says the true thing instead — `warnUnknownFormat`, rendered in the
review banner as a caution to check every value. Two supporting changes:
`_detectFormat` gained **"per serving"** and **"calories"** as cues, since
the heading row *is* the panel once the title is cropped away (verified
load-bearing: without the first cue that crop scores `unknown`); and an
energy figure printed with **no unit** on a row that names itself
*Calories* is read as kcal regardless of the detected format. That last one
is the sharp edge — the panel-wide default for an unlabelled energy figure
is kilojoules, so a bare "Calories 230" was being read as 230 kJ, which
reaches the form as 55 kcal: a quarter of the truth, and entirely
plausible-looking.

### Confidence threshold 0.6, and what it is for

Values scoring below `labelScanCheckThreshold` (0.6) get a visible marker
beside the field with the semantics label "low confidence, please check".
It is a **UI threshold, not a truth threshold** — every scanned value is
reviewed regardless. 0.6 is roughly "one thing went wrong with this
number" on the parser's own scale: a guessed nutrient name costs 30%, a
repaired digit 20%, a "less than" bound 50%. Only fields actually taken
from the panel can be marked; a number she typed herself never is.

The banner ("Read from a label — check every value before saving.") is
unconditional after a scan and stays for the life of the form. A banner
that appeared only for poor reads would teach the user that its absence
means "this one is fine".

### Camera denied, cancelled, unreadable — three different sentences

`LabelCaptureService.captureAndRecognizeLabel()` returns `null` for a
cancel and throws `PlatformException(camera_access_denied)` for a refused
permission, and the controller keeps them apart:

- cancel → nothing at all (a decision is not a failure worth commenting on)
- denied → "Camera access is off. Allow it in Settings to scan labels."
- `OcrResult.unsupported` → "Scanning labels isn't available on this
  device. You can enter the details yourself." (unreachable behind
  `textRecognitionSupported`; second line of defence)
- empty or `LabelFormat.unknown` → "Couldn't read a nutrition panel in that
  photo. Try again with the table filling the frame, or type the values."
- anything else → "That photo couldn't be read. Try again, or type the
  values."

Every other failure collapses into that last one deliberately: the error
object can carry the path of a photo of someone's food, so it is
classified and dropped — never shown, never logged, never inspected beyond
"was this a denied permission".

### The one place a recognised value is interpolated into a message

`domain/label_ocr/label_warnings.dart` forbids quoting a recognised value
in a warning, because those are fixed parser strings that end up in test
output and crash text. The "Kept your value for X (label read Y)" note is a
deliberate exception: it is built in the presentation layer, exists only to
be rendered beside the fields it compares, and is useless without both
numbers. It remains S2 — display only, never a log line, never an
exception message.

## Revisit triggers

- The product owner gives a go/no-go decision on adoption.
- `google_mlkit_text_recognition` goes unmaintained for more than 9 months.
- A decision is made on MSIX/sparse packaging for Windows distribution
  (would reopen the Windows OCR question).
