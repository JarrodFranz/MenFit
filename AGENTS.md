# Agent instructions

**Read these two files before doing anything, in this order:**

1. **`handoff/HANDOFF.md`** — current state, what happens next and why, the
   traps that will otherwise cost you an hour, and a **Corrections** section of
   things believed earlier in this work and since measured to be wrong. Read
   that section even if you skim the rest.
2. **`CLAUDE.md`** (project root) — the standing rules for this repo:
   architecture, the validation sequence, the hard rules. It is named for Claude
   Code but **its contents apply to any agent working here.**

Then read the specific `knowledge/` documents those two point you at.
`knowledge/` is this project's durable memory — architecture, ADRs, domain
rules, troubleshooting. `handoff/` is only session-scoped state and does not
duplicate it.

## Two rules that matter more than the rest

- **Only one `flutter test` may run at a time in this package.** Concurrent runs
  deadlock on shared `.dart_tool` state at zero CPU, and `--timeout` never
  fires. If you delegate, have helpers write tests and run the suite yourself,
  once, centrally.
- **Keep `handoff/HANDOFF.md` and `handoff/session-log.md` current.** Update
  them whenever state materially changes and before ending any turn that changed
  something — the whole point is that the next agent, which may not be you or
  even the same model, can continue without a transcript.

## Health and safety of the content

This app handles menstrual-cycle, location, body-weight and nutrition data.
`knowledge/engineering/security_and_privacy.md` and
`knowledge/domain/womens_health.md` are binding, not advisory — in particular,
no health calculation ships without a written evidence review, and nutrition
copy must never shame or frame eating as a budget to spend down.
