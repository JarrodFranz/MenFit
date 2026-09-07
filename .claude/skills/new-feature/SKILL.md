---
name: new-feature
description: Use when building any new feature or user-facing capability in this app — orchestrates understand → research → plan → delegate → implement → test → review → document.
---

# New Feature Workflow

You are the orchestrator. Do not skip stages for substantial features; collapse stages only for genuinely small ones.

1. **Understand** — restate the feature goal; read `knowledge/product/product_vision.md` scope, `knowledge/architecture/architecture_overview.md`, the relevant `knowledge/domain/*.md`, and terminology. Check `knowledge/product/feature_ideas.md` and roadmap for prior intent. State per-platform behaviour (full/degraded/hidden on iOS/Android/Web/Windows) — never assume mobile-only.
2. **Inspect** — read existing code in adjacent features; identify reuse; never duplicate existing functionality.
3. **Research** (if unknowns) — delegate to the `researcher` agent (read-only); domain/health claims are evidence-gated per `knowledge/domain/mens_health.md`.
4. **Plan** — feature folder shape (domain/data/presentation), entities, providers, routes, tests. New packages → run `package-evaluation` first. Schema changes → `schema-change`. Significant architectural choices → ADR.
5. **Delegate implementation** — `flutter-implementer` agent(s) with bounded scope, explicit file allowlist, and the validation sequence. Sequence agents whose files overlap; parallelise only disjoint work.
6. **Test** — meaningful logic gets tests (see `knowledge/engineering/testing_strategy.md`); flare/streak/date logic needs edge-case tests; config-only surfaces need guard tests.
7. **Review** — for important changes, dispatch the `code-reviewer` agent on the full diff; triage findings (fix blocking + should-fix; log deliberate deferrals).
8. **Document & capture** — update `knowledge/` per `knowledge-capture`; ADR if warranted; update roadmap status.

Privacy gate: any feature touching location/health/flare data must be checked against `knowledge/engineering/security_and_privacy.md` at plan time, not review time.
