# Health area — design and shared contract

*2026-11-16. Branch `feat/health` (worktree `../MenFit-health`). Owner request:
a Health section that reads watch data (heart rate, SpO2, sleep, …), lets him
log blood pressure and blood readings (glucose, …) with history, and shows
where a blood-pressure reading sits, charted over time.*

Template: `lib/features/keto/` (commit `d87bc68`). Every convention not stated
here is "do what Keto does".

## Decisions

| Topic | Decision | Status |
|---|---|---|
| Sensitivity | Manual readings are **S3**. Watch vitals are S2 platform data, handled to S3 rules. | fixed |
| Watch data storage | **Read on demand, never persisted, never cached to disk.** Held in provider memory only; gone when the screen's provider is disposed. No new table for it. | fixed |
| Watch permissions | A **separate** just-in-time request for the vitals types, triggered from the Health screen. The existing steps/workout request is unchanged. | fixed |
| Manual BP/glucose from Health Connect | Not read. Manual entry only (not requested). | fixed |
| Blood markers | One table for all markers (`marker` + `value` + `unit` + optional `context`). Only `glucose` is enabled now. Value stored **as entered** with its unit (Keto precedent: no silent conversion); conversion happens at presentation for charting. | fixed |
| Glucose interpretation | Stored and charted only, no reference ranges. | default, owner may change |
| BP category | Named published-guideline category with source line and "not a diagnosis" wording. Which guideline: see `knowledge/research/blood_pressure_classification.md`. | **owner to confirm** |
| Age / sex | No sex field exists (male implied). Birthday optional. Categories must work with birthday missing. | see research note |
| Navigation | Where Health is mounted. | **owner to confirm** |

## Schema v4 (forward migration only; v3 is in testers' hands)

`lib/core/db/tables/blood_pressure_readings.dart`

```dart
/// Manual S3 measurements, hard-deleted.
@TableIndex(name: 'idx_blood_pressure_readings_measured_at', columns: {#measuredAt})
class BloodPressureReadings extends Table {
  TextColumn get id => text()();
  TextColumn get day => text()();            // local date at entry, ISO
  IntColumn get measuredAt => integer()();   // epoch ms, UTC
  IntColumn get systolic => integer()();     // mmHg
  IntColumn get diastolic => integer()();    // mmHg
  IntColumn get pulse => integer().nullable()();   // bpm
  TextColumn get note => text().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}
```

`lib/core/db/tables/blood_marker_readings.dart`

```dart
/// Manual S3 blood-test results, hard-deleted. One row per result; the
/// marker column selects the kind so a new marker needs no new table.
@TableIndex(
  name: 'idx_blood_marker_readings_marker_measured_at',
  columns: {#marker, #measuredAt},
)
class BloodMarkerReadings extends Table {
  TextColumn get id => text()();
  TextColumn get day => text()();
  IntColumn get measuredAt => integer()();
  TextColumn get marker => text()();         // BloodMarker.toStorage(), e.g. 'glucose'
  RealColumn get value => real()();          // as entered
  TextColumn get unit => text()();           // BloodMarkerUnit.toStorage(), e.g. 'mmol/L'
  TextColumn get context => text().nullable()();  // GlucoseContext.toStorage()
  TextColumn get note => text().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}
```

Migration: `schemaVersion => 4`; `if (from < 4) { createTable ×2; customStatement('CREATE INDEX IF NOT EXISTS …') ×2 }`, same shape as the v2 step. Never edit the v2/v3 steps.

## Domain (`lib/features/health/domain/`, no Flutter imports)

```dart
// blood_pressure_reading.dart
@Freezed(toStringOverride: false)   // toString must not print values
abstract class BloodPressureReading with _$BloodPressureReading {
  const factory BloodPressureReading({
    required String id,
    required LocalDate day,
    required DateTime measuredAt,   // UTC
    required int systolic,
    required int diastolic,
    required DateTime createdAt,    // UTC
    required DateTime updatedAt,    // UTC
    int? pulse,
    String? note,
  }) = _BloodPressureReading;
}

// blood_marker_reading.dart
enum BloodMarker { glucose;  toStorage / fromStorage (throws FormatException) / label / units }
enum BloodMarkerUnit { mmolPerL('mmol/L'), mgPerDl('mg/dL'); toStorage / fromStorage / label }
enum GlucoseContext { fasting, beforeMeal, afterMeal, bedtime, other; toStorage / fromStorage / label }

@Freezed(toStringOverride: false)
abstract class BloodMarkerReading with _$BloodMarkerReading {
  const factory BloodMarkerReading({
    required String id,
    required LocalDate day,
    required DateTime measuredAt,
    required BloodMarker marker,
    required double value,
    required BloodMarkerUnit unit,
    required DateTime createdAt,
    required DateTime updatedAt,
    GlucoseContext? context,
    String? note,
  }) = _BloodMarkerReading;
}

/// mg/dL per mmol/L for glucose.
const glucoseMgPerDlPerMmolPerL = 18.016;
double glucoseIn(BloodMarkerUnit target, double value, BloodMarkerUnit from);

// health_reading_validation.dart — used by save AND import (like ketone_validation.dart)
const minSystolic = 40, maxSystolic = 300;
const minDiastolic = 20, maxDiastolic = 200;
const minPulse = 25, maxPulse = 250;
const maxHealthNoteLength = 280;
// glucose bounds per unit: 0.5–50.0 mmol/L, 9–900 mg/dL
String? systolicError(String input);  String? diastolicError(String input);
String? pulseError(String input);     // empty is valid (optional)
String? bloodPressurePairError(int systolic, int diastolic); // systolic must exceed diastolic
String? bloodMarkerValueError(BloodMarker marker, BloodMarkerUnit unit, String input);
String? healthNoteError(String input);   // length + control characters
bool isValidBloodPressureReading(BloodPressureReading r);
bool isValidBloodMarkerReading(BloodMarkerReading r);   // unit must be in marker.units; context only for glucose

// health_readings_repository.dart
abstract interface class HealthReadingsRepository {
  /// Newest first. [since] null = all.
  Stream<List<BloodPressureReading>> watchBloodPressure({DateTime? since});
  Future<void> saveBloodPressure(BloodPressureReading reading);   // upsert by id, keeps createdAt
  Future<void> deleteBloodPressure(String id);                     // hard delete

  Stream<List<BloodMarkerReading>> watchBloodMarker(BloodMarker marker, {DateTime? since});
  Future<void> saveBloodMarker(BloodMarkerReading reading);
  Future<void> deleteBloodMarker(String id);

  Future<void> deleteAllData();   // both tables
}
```

The numeric bounds above are plausibility limits (reject typos, not a
clinical judgement) from the research note, and live in that one file.

Entity/ids/timestamps: `EntityId.generate()`, UTC, `updatedAt >= createdAt`,
same id/day/timestamp sanity checks as `isValidKetoneReading`. Future
measurement times are rejected at the dialog (as Keto), not in the validator.

## Data (`lib/features/health/data/drift_health_readings_repository.dart`)

Copy `DriftKetoneRepository` conventions exactly: validate before write
(`ValidationException(message: 'Invalid blood pressure reading')` etc.),
transactional upsert preserving `createdAt`, revalidate on read, every failure
rethrown as a `StorageException` with a **static** message and **no `cause`**
(bound values must not be retained). Nothing on this path logs.

## Providers (`lib/features/health/health_providers.dart`, ADR 007 surface)

```dart
@Riverpod(keepAlive: true)
HealthReadingsRepository healthReadingsRepository(Ref ref);
@riverpod Stream<List<BloodPressureReading>> bloodPressureReadings(Ref ref, {DateTime? since});
@riverpod Stream<List<BloodMarkerReading>> bloodMarkerReadings(Ref ref, BloodMarker marker, {DateTime? since});
```

Note the name clash to avoid: `lib/core/platform/health/health_providers.dart`
already exists (adapter + `healthSyncProvider`). The feature file has the same
basename in a different folder; import with a prefix where both are needed.

## Data lifecycle

- `sensitiveHealthTables` gains `'blood_pressure_readings'`, `'blood_marker_readings'`.
- `DriftDataImporter`: `_validateBloodPressureRows` and `_validateBloodMarkerRows`, same rules as `_validateKetoneRows` (absent table → leave current data; table present without the sensitive flag → reject; every row type-checked and run through the domain validator; duplicate ids rejected; all before the transaction).
- `DeleteMyDataService`: `required this.healthReadingsRepository`, called in the S3 group next to `ketoneRepository`; wired in `settings_providers.dart`.
- Copy: the delete-confirm text (`settings_screen.dart`) and `data_export_notice_dialog.dart` name blood pressure and blood readings alongside ketone readings.
- Android backup rules already exclude everything; no change, but the guard test must still pass.

## Watch vitals (core adapter — extend, do not add a second integration)

`lib/core/platform/health/health_vitals_snapshot.dart`

```dart
/// Read-on-demand watch metrics. Never persisted. toString prints no values.
class HealthVitalsSnapshot {
  const HealthVitalsSnapshot({
    required this.readAt,
    this.restingHeartRateBpm, this.restingHeartRateAt,
    this.latestHeartRateBpm, this.latestHeartRateAt,
    this.bloodOxygenPercent, this.bloodOxygenAt,
    this.sleep,
    this.hrvMs, this.hrvKind, this.hrvAt,
    this.respiratoryRate, this.respiratoryRateAt,
    this.source,
  });
  bool get isEmpty;   // every metric null
}
enum HrvKind { rmssd, sdnn }     // Health Connect gives RMSSD, HealthKit SDNN — not comparable
class SleepSummary {            // most recent sleep ending in the window
  final DateTime start, end;
  final Duration asleep;
  final Duration? deep, light, rem, awake;   // null when the source gives no stages
}
```

`HealthPlatformAdapter` gains:

```dart
/// null = cannot be determined (iOS never reveals read authorisation).
Future<bool?> hasVitalsPermission();
/// Requests READ for the vitals types only. False on failure/unsupported.
Future<bool> requestVitalsPermissions();
/// Latest values in the 24 h before [now] (resting HR / HRV: 48 h; sleep:
/// most recent session ending in the last 24 h). Null when unsupported.
/// Never throws; a metric that cannot be read is null.
Future<HealthVitalsSnapshot?> getVitals({required DateTime now});
```

Types: `HEART_RATE`, `RESTING_HEART_RATE`, `BLOOD_OXYGEN`, `RESPIRATORY_RATE`,
sleep (`SLEEP_SESSION` Android; `SLEEP_ASLEEP/DEEP/LIGHT/REM/AWAKE` both),
HRV (`HEART_RATE_VARIABILITY_RMSSD` Android, `…_SDNN` iOS). READ only.
`health_platform_io.dart` is already 501 lines: the vitals reading goes in a
new io-only file (e.g. `health_vitals_reader.dart`) that the adapter delegates
to. Errors are swallowed without logging, as the existing reads do (platform
exception messages can carry health values).

Android manifest (permission lines only, self-closed, no extra attributes —
the guard regex requires that): `READ_HEART_RATE`, `READ_RESTING_HEART_RATE`,
`READ_OXYGEN_SATURATION`, `READ_SLEEP`, `READ_HEART_RATE_VARIABILITY`,
`READ_RESPIRATORY_RATE`. iOS `NSHealthShareUsageDescription` widened to name
heart rate, blood oxygen, sleep, HRV and respiratory rate.

Web / Windows / unsupported: stub returns `null` / `false`; the card shows an
explanatory empty state ("Watch data needs Health Connect on Android or Apple
Health on iPhone") and nothing else. No crash, no button that does nothing.

## Presentation (`lib/features/health/presentation/`)

- `health_screen.dart` — `HealthScreen`: AppBar `Health`; `SafeArea > Align(topCenter) > ConstrainedBox(contentMaxWidth) > ListView` of: `WatchVitalsCard`, `BloodPressureSection`, `BloodGlucoseSection`, a "not medical advice" line.
- `watch_vitals_card.dart` (+ `watch_vitals_controller.dart`) — states: unsupported / needs permission (button → `requestVitalsPermissions`) / loading / empty ("No recent watch data") / data with per-metric "as of" times / refresh action.
- `blood_pressure_section.dart`, `blood_pressure_chart.dart`, `blood_pressure_dialog.dart`
- `blood_glucose_section.dart`, `blood_marker_chart.dart`, `blood_marker_dialog.dart`
- Dialogs mirror `KetoneReadingDialog` (`showDialog(useRootNavigator: true)`, `PopScope(canPop: !_busy)`, date picker clamped to today, save-time future check, delete-with-confirm inside the edit dialog, errors in a live region).
- Charts: `fl_chart` (already a dependency), structure copied from `WeightTrendChart` — y-axis not from zero, no interpolation across gaps, semantics label, no green/red valence colours.
- No file over ~300 lines; no logic in widgets.

## Tests

Subagents **write** tests and report them "written, unexecuted". Only the
orchestrator runs `flutter test`, once, centrally. Mirror `test/features/keto/`
and `test/features/data_export/ketone_data_lifecycle_test.dart`; extend
`test/core/db/menfit_upgrade_test.dart` (v1 fixture → v4: both tables exist and
empty, both indices present, earlier data intact), `app_database_test.dart`,
the export table-coverage test, `delete_my_data_covers_every_table_test.dart`,
`android_manifest_guard_test.dart`.

## Workstreams and file ownership

| WS | Owns | When |
|---|---|---|
| A — data | `lib/core/db/**`, `lib/features/health/domain/**` (except `blood_pressure_category.dart`), `lib/features/health/data/**`, `lib/features/health/health_providers.dart`, `lib/features/data_export/**`, `lib/features/settings/application/delete_my_data_service.dart`, `lib/features/settings/settings_providers.dart`, the two copy strings, their tests, `knowledge/architecture/data_architecture.md` | now |
| B — watch | `lib/core/platform/health/**`, `AndroidManifest.xml` (permission lines), `ios/Runner/Info.plist` (one string), `test/platform/**`, the two adapter fakes in `test/`, `lib/features/health/presentation/watch_vitals_card.dart` + `watch_vitals_controller.dart` + their tests, `knowledge/engineering/play_store_declarations.md` | now, parallel with A |
| C — UI | rest of `lib/features/health/presentation/**`, `lib/features/health/domain/blood_pressure_category.dart`, router mount, shell/a11y tests | after A and the owner's answers |

Nobody touches `lib/features/home_widgets/`, `lib/core/platform/widgets/`,
`android/app/src/main/kotlin/**/widgets/`, `lib/app/app.dart`,
`lib/app/bootstrap.dart`, `pubspec.yaml`, `android/app/build.gradle.kts` —
another session is editing those on `feat/home-widgets`.

## Could not be verified on this host (carry into the handoff)

Real watch data on a physical device; anything iOS (needs a Mac: HealthKit
prompt lists the new types, SDNN HRV and sleep-stage mapping, Info.plist
string accepted).

---

## Owner decisions (2026-11-16, relayed from the parent session)

1. **Blood pressure:** "Heart Foundation AU (Recommended)" — Heart Foundation of Australia 2016 category name per reading, a 7-day-average headline, the source, a "not a diagnosis" line, and a re-measure / see a doctor / call 000 line at or above 180/110. The owner was told age and sex do not change the categories.
2. **Navigation:** "Replace Settings tab (Recommended)" — tabs become Home, Train, Nutrition, Keto, Health, Recovery; Settings moves to the gear icon already on Home.
3. **Blood markers:** "Show reference ranges" — published general reference ranges next to each marker, sourced and labelled as not a diagnosis, evidence-reviewed per marker; a marker (or context) without a reviewed source stays store-and-chart only. Review: `knowledge/research/blood_glucose_reference_ranges.md`.

Validation bounds (final): systolic 40–300, diastolic 20–200, pulse 25–250, glucose 0.5–50.0 mmol/L / 9–900 mg/dL.

## Blood pressure category (`lib/features/health/domain/blood_pressure_category.dart`, pure Dart) — WS C1

Thresholds: `knowledge/research/blood_pressure_classification.md`, "Table to implement". Higher of the systolic/diastolic categories wins. No "isolated systolic" label.

```dart
enum BloodPressureCategory { optimal, normal, highNormal, grade1, grade2, grade3 }   // + label getter
/// Null when systolic < 90 or diastolic < 60: the guideline does not classify
/// low readings (hypotension is out of its scope), so no category is shown.
BloodPressureCategory? classifyBloodPressure(num systolic, num diastolic);
bool isBelowClassifiedRange(num systolic, num diastolic);      // < 90 or < 60
bool isHighestRange(num systolic, num diastolic);              // >= 180 or >= 110

class BloodPressureWeeklyAverage { double systolic, diastolic; int daysWithReadings, readingCount;
  BloodPressureCategory? category; bool showHomeThresholdNote; }  // note: avg >= 135 or >= 85, and category below grade1
/// The 7 local days ending [today]. Null when fewer than 5 distinct days have readings.
BloodPressureWeeklyAverage? bloodPressureWeeklyAverage(Iterable<BloodPressureReading> readings, LocalDate today);
int bloodPressureDaysLoggedThisWeek(Iterable<BloodPressureReading> readings, LocalDate today);
```

Copy is the "Draft copy" section of the research note, now signed off, as `const` strings in one file (`blood_pressure_copy.dart` under presentation): category labels, source line, not-a-diagnosis, single-reading caveat, home note, age/sex line ("These categories are the same for all adults. They do not change with age or sex."), highest-range line, low line. No "good/bad", no green/red.

`BloodPressureSection` (public, `const BloodPressureSection({super.key})`): title + "Add reading"; weekly-average headline (or "Log readings on 5 of the last 7 days to see a weekly average. n of 5 so far."); range chips 30 d / 90 d / 1 y / All driving chart and list; chart with systolic and diastolic lines plus dashed reference lines at 140 and 90 captioned with the guideline; history rows `128/82 mmHg · pulse 64 · Normal` + local date/time + note, tap to edit; highest-range / low line shown under the affected headline or most recent reading; footer with the source, not-a-diagnosis, single-reading and age/sex lines.

## Blood marker reference ranges (`lib/features/health/domain/blood_marker_reference.dart`, pure Dart) — WS C2

```dart
class BloodMarkerReference { BloodMarker marker; GlucoseContext? context; double low, high;  // in [unit], inclusive
  BloodMarkerUnit unit; String sourceName; int sourceYear; }
/// Null = no reviewed source for this marker/context: store and chart only.
BloodMarkerReference? bloodMarkerReferenceFor(BloodMarker marker, GlucoseContext? context);
enum ReferencePosition { below, within, above }
ReferencePosition positionInReference(BloodMarkerReference ref, double value, BloodMarkerUnit unit);  // converts units
```

`BloodGlucoseSection` (public, `const BloodGlucoseSection({super.key})`): same shape as the BP section; display unit follows the most recent reading's unit (toggle chips mmol/L / mg/dL); each row shows value, unit, context, and — only when a reviewed range exists for its context — the neutral position ("within / below / above the reference range"); a "Reference ranges" block lists the reviewed ranges with source and not-a-diagnosis lines. Wording from the glucose research note; no diabetes/prediabetes wording, no valence.

## Navigation — WS D

- Shell branches in order: Home, Activity ("Train"), Nutrition, Keto, **Health** (`/health`, `Icons.monitor_heart_outlined` / `Icons.monitor_heart`, label `Health`), Recovery. The Settings branch leaves the shell.
- The Settings route subtree keeps its typed route classes and becomes a child of the Home route (`/home/settings/...`), so every existing `Settings…RouteData().go(context)` call still works and system back returns to Home. The Home app-bar gear opens it.
- `lib/features/health/presentation/health_screen.dart` — `HealthScreen` composing `const WatchVitalsCard()`, `const BloodPressureSection()`, `const BloodGlucoseSection()` and a closing "MenFit is not a medical device and does not give medical advice." line.
- Tests holding copies of the shell destinations are updated in step: `test/app/app_shell_test.dart`, `test/app/keto_branch_test.dart`, `test/core/adaptive_scaffold_real_font_test.dart`, `test/accessibility/a11y_*`, any test using a `/settings` location. `test/core/adaptive_scaffold_test.dart`'s synthetic `_crowdedDestinations` stays as it is (see handoff Traps).

| WS | Owns | Codegen |
|---|---|---|
| C1 — BP UI | `domain/blood_pressure_category.dart`, `presentation/blood_pressure_*.dart`, their tests | none (no new annotated code; do not run build_runner) |
| C2 — glucose UI | `domain/blood_marker_reference.dart`, `presentation/blood_glucose_section.dart`, `presentation/blood_marker_*.dart`, their tests | none |
| D — navigation | `lib/app/router/routes.dart` (+ `.g.dart`), `presentation/health_screen.dart`, Home gear wiring, shell/a11y/route tests, README tab list | runs build_runner |
