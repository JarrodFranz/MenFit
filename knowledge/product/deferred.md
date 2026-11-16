# Deferred Work Registry

*Reset 2026-09-07 at the fork from FemFit (ADR 017). FemFit's deferred-work
history is not reproduced here — most of it was resolved or was specific to
women's-health features removed in the fork. Rows are never deleted going
forward; strike through with a note when shipped. This is the one place to
answer "known gap or unnoticed bug?".*

| Item | Priority | Context |
|---|---|---|
| Re-add `custom_lint` + `riverpod_lint`; retry latest riverpod/freezed | later | Blocked by analyzer window inherited from FemFit — re-attempt after next Flutter SDK upgrade (`knowledge/troubleshooting/dependency_resolution.md`) |
| Windows MSIX identity / `web/manifest.json` still carry the working title | later | No distribution planned for Windows/web yet; update when either ships |
| Real brand artwork (replace `assets/images/app_icon.png`, rerun `scripts/generate_brand_assets.py`) | near-term | Placeholder assets shipped with the fork; tracked in `TASKS_TO_DO.md` |
| Sex field if the product ever widens | later | The profile deliberately does not collect sex today (`knowledge/domain/mens_health.md`); revisit only as a deliberate, separately-reviewed product decision, not a quiet code change |
| Further blood markers (cholesterol, HbA1c, testosterone, and others) | later | Each marker needs a per-marker evidence review before any reference range is shown; until then it would be store-and-chart only (added 2026-11-16, `knowledge/research/blood_pressure_classification.md` lists units) |
| Trends for watch metrics (heart rate, SpO2, sleep, HRV, respiratory rate) | later | Watch vitals are read on demand and never stored, so a trend needs a storage decision first and an S3 privacy review (added 2026-11-16) |
| Read blood pressure and glucose from Health Connect | later | Manual entry only today; reading them would need new permissions and a Play declaration (added 2026-11-16) |
| Glucose "15.0 mmol/L or more" urgent line and the 3.0 to 3.9 soft note | later | Not implemented: no source gives these triggers for people without diabetes. Open owner decision (`knowledge/research/blood_glucose_reference_ranges.md`, added 2026-11-16) |
| Shared history-range enum | later | `blood_marker_reference.dart` (glucose) imports `BloodPressureRange` from the blood-pressure domain; extract a neutral enum (added 2026-11-16) |
| File size: `blood_marker_dialog.dart` (316 lines) and `health_platform_io.dart` (546 lines) | later | Both exceed the ~300-line guide; split when next touched (added 2026-11-16) |
