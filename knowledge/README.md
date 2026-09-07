# Project Knowledge Base

This directory is the **persistent technical memory** of the project. Claude Code sessions and sub-agents must treat it as first-class: read the relevant parts before substantial work, and write back anything future sessions would otherwise have to rediscover.

## Structure

| Directory | Contents |
|---|---|
| `product/` | Vision, target users, terminology, feature ideas, implementation roadmap, deferred-work registry (`deferred.md`) |
| `architecture/` | Architecture overview, decisions summary, data architecture, platform architecture |
| `flutter/` | Flutter-specific learnings, patterns, package decisions, platform notes |
| `domain/` | Running, fitness, nutrition, and women's-health domain knowledge |
| `engineering/` | Coding standards, testing strategy, error handling, security & privacy, release & distribution |
| `decisions/` | Architectural Decision Records (ADRs) — see its README for conventions |
| `research/` | Findings from research tasks worth keeping |
| `troubleshooting/` | Diagnosed problems and their fixes (build issues, platform quirks, package bugs) |
| `sessions/` | Optional session summaries for significant multi-session efforts |

## Rules

1. **Read before work.** Before substantial work in an area, read the relevant knowledge files. `architecture/architecture_overview.md` and `engineering/coding_standards.md` are the baseline for any code change.
2. **Write discoveries, not activity logs.** Capture facts that prevent rediscovery: a package that breaks on Windows, an entitlement HealthKit needs, a rejected approach and why. Do not log routine work.
3. **One place per fact.** Update the existing file rather than duplicating. Platform quirks go in `flutter/platform_notes.md`; solved build/runtime problems go in `troubleshooting/`.
4. **ADRs for significant decisions** (state management, database, backend, auth…). Trivial implementation choices do not get ADRs.
5. **Keep files current.** If a decision is superseded, mark the old content as superseded and link to the replacement — don't silently delete history in ADRs.
6. **Date important entries** (YYYY-MM-DD) so staleness is visible.
