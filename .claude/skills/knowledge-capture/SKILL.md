---
name: knowledge-capture
description: Use at the end of any session or task that produced discoveries, decisions, or diagnoses worth keeping — and whenever unsure where knowledge belongs.
---

# Knowledge Capture Workflow

1. **Harvest** — scan the completed work for: solved non-obvious problems, platform surprises, package verdicts, established/changed conventions, rejected approaches (and why), domain facts learned, decisions made.
2. **Route each item** (one home per fact; update in place, never duplicate):
   - True in ANY Flutter project → **central base** `D:\Documents\Claude\Flutter development knowledge\` (topical file; date it)
   - Project architecture/pattern/convention → `knowledge/architecture/` or `knowledge/flutter/flutter_patterns.md` or `knowledge/engineering/`
   - Significant decision → ADR in `knowledge/decisions/` (+ index update in decisions README and `architecture_decisions.md`)
   - Package verdict → `knowledge/flutter/package_decisions.md`
   - Diagnosed problem → `knowledge/troubleshooting/` (Symptom/Cause/Fix/versions)
   - Domain/product fact → `knowledge/domain/` or `knowledge/product/`
   - Research conclusions → `knowledge/research/`
   - Incomplete multi-session work → `knowledge/sessions/YYYY-MM-DD_topic.md`
3. **Filter** — capture what prevents rediscovery; do NOT capture routine activity, things git history shows, or restatements of code. Superseded facts are marked superseded, not deleted (ADRs) or corrected in place with the date (topical files).
4. **Link** — new files must be reachable: referenced from the relevant README/index. An unlinked file will be re-created by accident.
