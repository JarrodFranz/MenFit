# Women's Health Domain Notes

*Initial bootstrap notes, 2026-08-25. This file gates what the product may claim. Read before building any cycle/health feature.*

## Cycle model (informational level)

- Typical cycle 21–35 days (28 median); phases: **menstrual, follicular, ovulatory, luteal**. Real cycles are irregular — the model must tolerate irregularity, missed logs, anovulatory cycles, hormonal contraception (which changes/eliminates phase physiology), and users who simply don't log.
- The app's v1 cycle feature is **user-logged period tracking**: period start/end dates, optional symptoms/energy. Phase *estimation* beyond "period is logged now" is prediction — label it as an estimate everywhere.

## Product rules (established at bootstrap)

1. **No medical claims.** Cycle features are informational/lifestyle. No diagnosis, no fertility/contraception guidance (that's a regulated medical-device path we are not on).
2. **Evidence-gating:** any training/nutrition recommendation tied to cycle phase requires a documented evidence review in `knowledge/research/` and product sign-off before implementation. The literature on cycle-phase training effects is genuinely mixed — do not ship folklore.
3. **Disclaimers:** cycle-adjacent surfaces carry a clear "not medical advice" statement; pregnancy/postpartum features do not exist until medically reviewed.
4. **Opt-in everything:** cycle tracking is fully optional; every cycle-consuming feature (streak pausing, phase annotations) degrades gracefully when cycle data is absent.

## Streak pausing (named feature) — domain logic sketch

- When a user has logged an active period, streak evaluation treats those days as **paused**: they neither extend nor break the streak. On period end, the streak resumes at its prior count.
- Pausing must be optional per user (some users want to keep earning streaks during their period) and must work retroactively when a period is logged after the fact.
- Edge cases to design for: overlapping/edited period logs, periods logged in the future by prediction (prediction must NOT pause — only confirmed logs), very long logged periods (cap? prompt?).

## Privacy — the defining constraint

Cycle and reproductive-health data is among the most sensitive data an app can hold (see post-Dobbs subpoena concerns around period apps). Established rules:

- Cycle data is stored with the strongest available protection, **local-first**; any future sync of cycle data must be separately consented, ideally end-to-end encrypted, and deletable.
- Cycle data never flows to analytics, logs, crash reports, or third parties. Ever.
- Cycle data is never embedded/denormalised into other records (activities, streak snapshots store "paused" state, not the reason's details, where feasible).
- Full export and deletion must work for this data category first.

See `knowledge/engineering/security_and_privacy.md`.


## Ongoing (un-ended) period records: the protection clamp (2026-09-01)

An un-ended period record (`periodEnd == null`) protects at most
`periodStart + maxPlausiblePeriodDuration - 1` days (14, from
`CyclePredictionEngine`), never "to today" - a stale record must not pause
streaks forever or auto-qualify achievement weeks indefinitely. The clamp
lives in `cycle/domain/period_days.dart#ongoingPeriodEffectiveEnd` and
applies ONLY to the null-end fallback; a logged end of any length is
respected as logged. NOTE the deliberate asymmetry: the cycle CALENDAR still
paints an ongoing record to today (visible over-painting prompts the user to
fix the record; invisible eternal protection was the harm) - registered as
an open product question in knowledge/product/deferred.md.
