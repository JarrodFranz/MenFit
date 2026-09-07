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
