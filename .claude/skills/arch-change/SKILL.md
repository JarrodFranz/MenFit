---
name: arch-change
description: Use when changing architecture — layers, state management, persistence, sync, navigation structure, cross-cutting patterns, or reversing a prior ADR.
---

# Architectural Change Workflow

1. **Read the record** — `knowledge/architecture/*` and every ADR in `knowledge/decisions/`. If a prior ADR covers this, you are proposing to supersede it — engage with its original reasons explicitly; never contradict silently.
2. **Establish the forcing need** — architecture changes need a concrete, current problem (avoid speculative abstraction; see the anti-overengineering list in `architecture_overview.md`).
3. **Research** — delegate option analysis to a high-effort research agent (or multiple with different angles for big calls); verify package/ecosystem claims against current sources; check the central Flutter base.
4. **Decide & record** — write/supersede the ADR (Context/Options/Decision/Reasons/Consequences/Rejected); update `architecture_overview.md`, `architecture_decisions.md` index, and any affected knowledge files in the same change.
5. **Migrate deliberately** — plan the migration path (big-bang vs incremental); delegate bounded implementation; for pure moves/renames use byte-identical snapshot tests (central `testing-pitfalls.md`).
6. **Independent review** — mandatory `code-reviewer` pass for architectural changes, focused on consistency across all touched features and cross-platform impact.
7. **Validate everything** — full validation sequence plus platform build smoke checks (web + windows on this machine).
