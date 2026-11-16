# Men's Health Domain Notes

*Created 2026-09-07 at the fork from FemFit. This file gates what the product may claim. Read before building any physiology-based feature.*

## Population and assumptions

- MenFit assumes an adult male user. The profile does not collect sex; every
  physiology-based calculation uses adult-male reference values and is
  labelled as an estimate wherever it is shown.
- Energy: Mifflin-St Jeor with the male constant (+5), times an activity
  factor. Source and error bands: `knowledge/research/nutrition_energy_estimates.md`.
- Micronutrient reference intakes (adult male 19–50, DRI): iron 8 mg,
  calcium 1000 mg, vitamin D 15 mcg (600 IU), fibre 38 g, vitamin C 90 mg.
  Rationale: `knowledge/research/micronutrient_adequacy.md`.

## Product rules

1. **No medical claims.** Training, recovery and nutrition features are
   informational. No diagnosis, no supplement or hormone guidance.
2. **Evidence-gating:** any recommendation derived from physiology needs a
   written review in `knowledge/research/` and product sign-off first.
3. **Disclaimers:** health-adjacent surfaces carry "not medical advice".
4. **Opt-in everything:** check-ins, flares, weight and location features are
   optional and degrade gracefully when absent.
5. **Recovery is never failure:** streak logic treats recovery days and
   flare-protected days as success-equivalent, no proof demanded.

## Evidence-gated displays shipped on the Health tab (2026-11-16)

Two physiology-based displays have passed the evidence gate and the owner's
sign-off, and are now in the app:

- **Blood-pressure guideline category** per reading and for a 7-day average
  (Heart Foundation of Australia 2016). Evidence and wording:
  `knowledge/research/blood_pressure_classification.md`.
- **Blood-glucose reference range** for fasting and after-meal readings (RCPA
  Manual reference interval). Evidence, as-built narrowing and open items:
  `knowledge/research/blood_glucose_reference_ranges.md`.

Both carry a source line and a not-a-diagnosis line, and neither uses valence
wording (no good or bad, no green or red). No other blood marker has a range;
each new marker needs its own per-marker evidence review first.

**Regulatory caution (not legal advice).** Named guideline categories, a
high-reading prompt and glucose reference ranges sit nearer the boundary
between a general wellness product and a regulated medical device (TGA
excluded-goods rules in Australia, FDA general wellness policy in the US) than
plain logging does. The legal position needs review before a public store
release. A private tester build does not change the legal test, only the
exposure.

## Privacy

Health check-ins, injury/illness flares, body weight and location are
sensitive. Local-first; never logged, never sent to analytics; export and
delete must work for these categories first. See
`knowledge/engineering/security_and_privacy.md`.
