---
name: review
description: Use when reviewing implemented changes — after feature/fix work by sub-agents, before integration, or on request.
---

# Code Review Workflow

1. **Independence** — substantial changes get reviewed by an agent that didn't write them: dispatch `code-reviewer` on the diff/files. Two tiers for multi-task efforts (central `process-patterns.md`): per-task review right after each task; whole-branch review over the full combined diff (catches cross-task seams).
2. **Checklist** (the reviewer agent applies it; orchestrator verifies coverage): correctness & edge cases; architecture/layer rules from `architecture_overview.md`; duplication of existing functionality; **cross-platform behaviour (Web + Windows especially)**; security/privacy per `security_and_privacy.md` (sensitive data in logs? secrets? permissions?); test power; unnecessary complexity/abstraction; performance on hot paths (lists, streams, rebuilds).
3. **Triage** — orchestrator resolves findings: fix blocking and should-fix now (delegating fixes back with the findings); deliberate deferrals go to the deferred registry (`knowledge/product/deferred.md`) with context; incorrect findings are rejected with reasoning (verify, don't blindly implement — `superpowers:receiving-code-review` discipline, if that skill is available).
4. **Close the loop** — re-run validation after fixes; confirm the reviewer's blocking findings are addressed; capture recurring defect shapes in the knowledge base.
