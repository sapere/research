---
applyTo: "**/*RESEARCH_PROGRESS*.md"
---

# Task State Machine — Canonical Specification

All agents MUST follow these transitions. This is the single source of truth for task states.

## Task Line Format

Every task in RESEARCH_PROGRESS.md is a single line starting with the state checkbox:
```
- [ ] TASK-1.1: Verb-first description. Source: WEB. Effort: STANDARD. Output: Section 1.
```
Workers update state by editing the checkbox prefix (e.g., `- [ ]` → `- [~]`). The rest of the line is unchanged. Indented metadata (Search, Cross-ref, Depends-on) follows on subsequent lines.

## States

| State | Notation | Meaning | Set By |
|-------|----------|---------|--------|
| Not Started | `- [ ]` | Task is available for dispatch | Planner |
| In Progress | `- [~]` | Worker has claimed the task | Worker |
| Complete | `- [x]` | Task finished successfully | Worker (sequential) or Coordinator (parallel) |
| Failed | `- [!]` | Task failed, eligible for retry | Worker |
| Retrying | `- [!1]` | Failed once, retry dispatched (attempt 2) | Coordinator |
| Exhausted | `- [!!]` | Failed twice, no more retries | Coordinator |
| Blocked | `- [B]` | Cannot run — prerequisite failed or unavailable | Coordinator |

## Valid Transitions

```
[ ] ──→ [~]   Worker claims task
[~] ──→ [x]   Task completed successfully
[~] ──→ [!]   Task failed (first attempt)
[~] ──→ [ ]   Crash recovery: Coordinator reclaims stale [~] task (previous session crashed)

[!] ──→ [!1]  Coordinator acknowledges failure, dispatches retry
[!1] ──→ [~]  Worker claims retry
[~] ──→ [x]   Retry succeeded
[~] ──→ [!]   Retry failed — Coordinator escalates to [!!]

[!] ──→ [!!]  Coordinator escalates (when [!1] already recorded, meaning second failure)
[!!] ──→ (terminal)  No further transitions

[ ] ──→ [B]   Coordinator blocks task (prerequisite is [!!] or [B])
[B] ──→ (terminal)  No further transitions
```

## Transition Ownership

| Transition | Owner | Notes |
|-----------|-------|-------|
| `[ ]` → `[~]` | Worker | Worker claims via `edit` at start of execution |
| `[~]` → `[x]` | Worker (sequential) / Coordinator (parallel) | In parallel mode, Worker reports status, Coordinator updates ledger |
| `[~]` → `[!]` | Worker | Three-strike rule triggered |
| `[!]` → `[!1]` | Coordinator | Acknowledges failure, prepares retry |
| `[!1]` → `[~]` | Worker | Claims retry task |
| `[!]` → `[!!]` | Coordinator | Second failure after `[!1]` |
| `[ ]` → `[B]` | Coordinator | All prerequisites terminal |
| `[~]` → `[ ]` | Coordinator | Crash recovery only |

## Staleness Rule

A task in `[~]` state is considered stale if it was not completed in the current session. On session restart, the Coordinator reclaims all `[~]` tasks as `[ ]`. Workers encountering `[~]` during auto-select also treat it as claimable.

## Terminal States

`[x]`, `[!!]`, and `[B]` are terminal. The execution loop ends when ALL tasks in the current batch are in terminal states.
