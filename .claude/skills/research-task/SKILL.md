---
name: research-task
description: Use for any research investigation — technical options, domain/health evidence, APIs/services, platform capabilities — before decisions or implementation.
---

# Research Task Workflow

1. **Frame** — write the exact question(s), what decision the research feeds, and what "enough evidence" looks like. Check `knowledge/research/` and the central Flutter base first — it may exist.
2. **Delegate** — use the `researcher` agent (read-only; returns findings). Multiple agents with distinct angles for big questions; higher model/effort for architecture/security/health-evidence topics, lower for simple lookups.
3. **Standards** — current primary sources (pub.dev, official docs, changelogs, literature); package claims verified against all four target platforms; men's-health claims must separate established vs mixed evidence with citations (`knowledge/domain/mens_health.md` gates what may ship).
4. **Consolidate** — you (orchestrator) resolve conflicts between agent findings and form the recommendation; flag genuine product/business decisions to the user rather than guessing.
5. **Capture** — durable findings → `knowledge/research/<topic>.md` (dated, sourced, conclusions-not-process); ecosystem facts → central `package-ecosystem-status.md`; if it fed a decision, write the ADR and cross-link.
