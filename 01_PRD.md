# Product Requirements Document — Self-Improving Autonomous Research Agent System

## Version: 1.0.0
## Date: April 6, 2026
## Status: APPROVED
## Source: research_synthesis.md (1,199-line research output)

---

## 1. Executive Summary

Build a self-improving autonomous research agent system that lives entirely within VS Code Copilot Agent Mode. The system decomposes complex research questions into granular tasks, executes them autonomously via a Ralph Wiggum loop, verifies output through a read-only Reviewer, and progressively improves its own capabilities through a memory-to-skill promotion pipeline.

The implementation replaces the existing four agent files in `.github/agents/` with four improved agents derived from the technical blueprint in `research_synthesis.md` Section 4.1, adds seed skills and conditional instructions, and embeds the self-improvement infrastructure directly into agent instructions.

---

## 2. System Architecture

### 2.1 Technology Stack

| Component | Technology | Version/Spec |
|-----------|-----------|-------------|
| Runtime | VS Code Copilot Agent Mode | Latest (April 2026) |
| Agent Format | `.agent.md` (YAML frontmatter + Markdown body) | VS Code standard |
| Skills | `SKILL.md` (YAML frontmatter + Markdown body) | VS Code standard |
| Instructions | `.instructions.md` (YAML frontmatter + Markdown body) | VS Code standard |
| State Machine | Markdown files with checkbox protocol | Custom 5-state |
| Memory | `/memories/` 3-tier system (user/session/repo) | VS Code built-in |
| Browser Automation | Playwright MCP (headless) | Via `mcp_microsoft_pla_*` tools |
| Model: Planner | Claude Opus 4.5 (copilot) | Fallback: GPT-5 (copilot) |
| Model: Worker | Claude Sonnet 4.5 (copilot) | Speed-optimized |
| Model: Reviewer | Claude Opus 4.5 (copilot) | Depth-optimized |
| Model: Coordinator | Claude Opus 4.5 (copilot) | Orchestration |

### 2.2 File System Layout

```
project-root/
├── .github/
│   ├── agents/
│   │   ├── 01_Research_Planner.agent.md      # REPLACE — Interview + planning agent
│   │   ├── 02_Research_Worker.agent.md       # REPLACE — Autonomous Ralph Loop executor
│   │   ├── 03_Research_Reviewer.agent.md     # REPLACE — Read-only verification agent
│   │   └── 04_Research_Coordinator.agent.md  # REPLACE — Top-level Planner→Worker→Reviewer orchestrator
│   ├── instructions/
│   │   └── research-conventions.instructions.md  # NEW — Conditional instructions for *.md files
│   └── skills/
│       ├── source-evaluation/
│       │   └── SKILL.md                      # NEW — Seed skill: how to evaluate source quality
│       └── synthesis-writing/
│           └── SKILL.md                      # NEW — Seed skill: how to write synthesis sections
├── .vscode/
│   └── settings.json                         # UPDATE — Enable subagent nesting + parent repo discovery
├── RESEARCH_BRIEF.md                         # Existing (Planner output, remains read-only)
├── RESEARCH_PROGRESS.md                      # Existing (shared state machine, updated format)
├── research_guardrails.md                    # Existing (quality standards, read-only)
├── research_synthesis.md                     # Existing (Worker writes, Reviewer reads)
├── research_sources.md                       # Existing (Worker writes)
├── research_activity.log                     # Existing (Worker writes)
└── research_narrator_summary.md              # Existing (Worker writes, final task)
```

### 2.3 Agent Architecture Diagram

```
USER
  │
  ▼
┌─────────────────────────────────────────┐
│  Research Coordinator (optional)         │
│  Model: Opus 4.5                        │
│  Tools: agent, read, edit               │
│  Agents: [Planner, Worker, Reviewer]    │
│                                         │
│  Orchestrates: Planner→Worker→Reviewer  │
│  Via: runSubagent()                     │
└──────┬──────────┬──────────┬────────────┘
       │          │          │
       ▼          ▼          ▼
┌──────────┐ ┌──────────┐ ┌──────────┐
│ Planner  │ │ Worker   │ │ Reviewer │
│ Opus 4.5 │ │ Sonnet   │ │ Opus 4.5 │
│ read,    │ │ 4.5      │ │ read,    │
│ search,  │ │ FULL     │ │ search,  │
│ edit,    │ │ TOOLS    │ │ web,     │
│ agent    │ │          │ │ fetch    │
│          │ │          │ │ (R/O!)   │
└──────────┘ └──────────┘ └──────────┘
```

---

## 3. Agent Specifications

### 3.1 Agent 1: Research Planner (`01_Research_Planner.agent.md`)

**Purpose:** Decompose research questions into granular tasks and initialize the state ledger.

**YAML Frontmatter:**
```yaml
---
name: Research Planner
description: An interview-based planning agent that decomposes complex research questions into discrete, actionable tasks and initializes the RESEARCH_PROGRESS.md state ledger.
tools: ['read', 'search', 'edit', 'agent']
agents: ['Research Worker', 'Research Reviewer']
model: ['Claude Opus 4.5 (copilot)', 'GPT-5 (copilot)']
handoffs:
  - label: Begin Research Execution
    agent: Research Worker
    prompt: "Proceed with the autonomous research loop. Read RESEARCH_PROGRESS.md for the current state."
    send: false
---
```

**Behavioral Protocol (Markdown Body):**
1. **Phase 1 — Interrogation:** Analyze user prompt. If missing scope, depth, output format, source preferences, or verification rigor → ask numbered clarifying questions. Never assume.
2. **Phase 2 — Brief Generation:** Create `RESEARCH_BRIEF.md` with: Executive Summary, Research Objectives (numbered), Scope Definition (in/out), Search Operations Lexicon (Boolean strings, dorks, exclusions), Source Strategy (primary/secondary/tertiary), Methodology (verification standard), Output Specification, Success Criteria (deterministic), Risk Register.
3. **Phase 3 — Ledger Generation:** Create `RESEARCH_PROGRESS.md` with phase-grouped tasks following the five-state checkbox protocol (`[ ]`, `[~]`, `[x]`, `[!]`, `[B]`). Each task is verb-first, specifies output location, and is completable in one context window.
4. **Phase 4 — Guardrails Generation:** Create `research_guardrails.md` with source quality standards, forbidden sources, citation format, hallucination prevention rules, token budget guidelines.
5. **Phase 5 — State File Initialization:** Create empty `research_sources.md`, `research_synthesis.md`, `research_activity.log` with header templates.
6. **Phase 6 — Handoff:** Present generated files for human review, then offer handoff button to Research Worker.

**Task Granularity Rules for the Planner:**
- Each task ≤ 1 source type + 1 output section
- Tasks ordered by dependency (discovery before extraction, extraction before verification)
- Every task has explicit output target ("Compile findings into section X of research_synthesis.md")
- Include specific search queries, URLs, or keywords within task descriptions
- TASK-FINAL for TTS narrator summary always last

**Constraint:** The Planner must NEVER conduct research itself (no web fetching, no browsing). Planning only.

### 3.2 Agent 2: Research Worker (`02_Research_Worker.agent.md`)

**Purpose:** Execute research tasks autonomously using the Ralph Wiggum loop pattern.

**YAML Frontmatter:**
```yaml
---
name: Research Worker
description: An autonomous research agent that executes tasks from the ledger using Playwright browser automation, verifies findings, and writes to synthesis files in a continuous Ralph Wiggum loop.
user-invocable: true
tools: ['read', 'edit', 'search', 'web', 'fetch', 'agent', 'mcp_microsoft_pla_browser_navigate', 'mcp_microsoft_pla_browser_snapshot', 'mcp_microsoft_pla_browser_click', 'mcp_microsoft_pla_browser_evaluate', 'mcp_microsoft_pla_browser_press_key', 'mcp_microsoft_pla_browser_wait_for', 'mcp_microsoft_pla_browser_take_screenshot']
model: ['Claude Sonnet 4.5 (copilot)']
handoffs:
  - label: Review Results
    agent: Research Reviewer
    prompt: "Review the latest completed task in RESEARCH_PROGRESS.md. Check research_synthesis.md for quality."
    send: false
---
```

**Behavioral Protocol (Markdown Body) — The Ralph Loop:**
1. **INIT:** Read RESEARCH_PROGRESS.md, RESEARCH_BRIEF.md, research_guardrails.md. Skim synthesis and sources.
2. **SELECT:** Find first `- [ ]` or `- [!]` task sequentially. If all `[x]` → verify success criteria → generate narrator summary → TERMINATE.
3. **MARK:** Change `- [ ]` to `- [~]` via `replace_string_in_file`.
4. **EXECUTE:** Use tool hierarchy: native search → Playwright browser → file analysis. Extract only needed content. Record source URL.
5. **VERIFY:** Cross-reference claims. Apply single-source flags, contradictory evidence flags, URL validation. Never fabricate.
6. **WRITE:** Append findings to research_synthesis.md with inline citations. Register in research_sources.md.
7. **UPDATE:** Mark `- [x]` in PROGRESS. Append to activity.log.
8. **SELF-IMPROVE:** Check if this task revealed a reusable pattern. If so, write to `/memories/session/patterns.md`. If pattern seen 3+ times, spawn subagent to create SKILL.md (see Section 7).
9. **LOOP:** Return to step 1. Continue until all tasks complete or three-strike halt.

**Three-Strike Rule:** If a task fails 3 times → mark `- [!]`, log failure, mark dependents `- [B]`, continue to next.

**Hallucination Prevention (absolute rules):**
- NEVER fabricate URLs, author names, dates, DOIs, or statistics
- Write `[SOURCE NOT FOUND]` or `[DATA NOT FOUND]` for missing information
- Only cite sources fetched and read in the CURRENT iteration

**Narrator Summary Generation (TASK-FINAL):**
- Pure flowing prose, no tables/lists/headers/citations
- Explain every technical term inline on first use
- Spell out all numbers and percentages
- ~3,000–5,000 words, conversational tone
- Write to `research_narrator_summary.md`

### 3.3 Agent 3: Research Reviewer (`03_Research_Reviewer.agent.md`)

**Purpose:** Read-only verification of research quality, source validity, and synthesis completeness.

**YAML Frontmatter:**
```yaml
---
name: Research Reviewer
description: A read-only verification agent that checks research quality, source validity, and synthesis completeness against the research brief.
user-invocable: false
disable-model-invocation: false
tools: ['read', 'search', 'web', 'fetch']
model: ['Claude Opus 4.5 (copilot)']
---
```

**Behavioral Protocol (Markdown Body):**
1. Read the completed section of research_synthesis.md specified in the review prompt.
2. Verify all inline citations have valid, accessible URLs (spot-check 3–5 URLs via fetch).
3. Check statistical claims include exact sources (not rounded/estimated).
4. Verify `[SINGLE_SOURCE]` and `[CONFLICTING]` flags are appropriately handled.
5. Check synthesis covers all requirements from RESEARCH_BRIEF.md for that task.
6. Verify no hallucinated data (claims without citations, fabricated URLs, invented statistics).
7. Return structured verdict:

```
VERDICT: PASS | FAIL
SCORE: [1-10]
ISSUES:
1. [specific problem with file path and line reference]
2. [specific problem]
SUGGESTIONS:
1. [actionable improvement]
```

**Tool Restriction Rationale:** Read-only tools (`read`, `search`, `web`, `fetch`) prevent the Reviewer from modifying the Worker's output. This enforces independent verification — the Ralph "oracle" pattern.

**Invocation:** The Reviewer is NEVER directly user-invocable (`user-invocable: false`). It is only invoked as a subagent by the Coordinator or via handoff from the Worker.

### 3.4 Agent 4: Research Coordinator (`04_Research_Coordinator.agent.md`)

**Purpose:** Top-level orchestrator managing the full Planner→Worker→Reviewer pipeline.

**YAML Frontmatter:**
```yaml
---
name: Research Coordinator
description: Top-level orchestrator that manages the Planner, Worker, and Reviewer pipeline for autonomous research execution.
tools: ['agent', 'read', 'edit']
agents: ['Research Planner', 'Research Worker', 'Research Reviewer']
model: ['Claude Opus 4.5 (copilot)']
handoffs:
  - label: Start Planning
    agent: Research Planner
    prompt: "Begin the research planning phase for the topic described above."
    send: false
  - label: Start Execution
    agent: Research Worker
    prompt: "Proceed with the autonomous research loop."
    send: false
---
```

**Behavioral Protocol (Markdown Body):**
1. Accept research request from user.
2. `runSubagent("Research Planner", "Decompose this research: [topic]")` → Planner creates BRIEF, PROGRESS, guardrails.
3. Loop:
   a. Read RESEARCH_PROGRESS.md → find next pending task.
   b. `runSubagent("Research Worker", "Execute TASK-X.Y from RESEARCH_PROGRESS.md.")` → Worker executes one task.
   c. `runSubagent("Research Reviewer", "Verify TASK-X.Y output in research_synthesis.md.")` → Reviewer returns verdict.
   d. If FAIL: `runSubagent("Research Worker", "Fix issues: [reviewer feedback]")`
   e. If PASS: Continue to next task.
4. When all tasks complete: Verify success criteria, output summary, offer handoff to user.

**Note:** The Coordinator is optional for simple workflows. Users can invoke Planner and Worker directly. The Coordinator adds value for full Planner→Worker→Reviewer verification per task.

---

## 4. Skills Specifications

### 4.1 Seed Skill: Source Evaluation (`.github/skills/source-evaluation/SKILL.md`)

**YAML Frontmatter:**
```yaml
---
name: source-evaluation
description: Evaluate the credibility, relevance, and reliability of a web source for research purposes. Apply source quality hierarchy, detect paywalls, assess publication date freshness, and flag potential bias.
user-invocable: false
disable-model-invocation: false
---
```

**Body Content — Procedural Instructions:**
1. Check domain authority: `.gov` > `.edu` > `.org` > established news > blogs
2. Check publication date: Prefer sources within 2 years unless historical context needed
3. Check author credentials: Named authors with verifiable affiliations preferred
4. Detect paywalls: If content truncated or login-gated, mark `[PAYWALLED]` and attempt archive.org fallback
5. Assess bias indicators: Check for sponsored content, advertorials, think-tank funding disclosures
6. Verify URL accessibility: Fetch and confirm 200 status before citing
7. Rate: HIGH (primary/governmental/academic) | MEDIUM (established industry/news) | LOW (blogs/forums/social)

### 4.2 Seed Skill: Synthesis Writing (`.github/skills/synthesis-writing/SKILL.md`)

**YAML Frontmatter:**
```yaml
---
name: synthesis-writing
description: Write structured research synthesis sections with inline citations, proper heading hierarchy, evidence tables, and cross-referenced findings following the research_synthesis.md format conventions.
user-invocable: false
disable-model-invocation: false
---
```

**Body Content — Procedural Instructions:**
1. Section structure: `### X.Y Title (TASK-X.Y)` header, followed by contextual introduction, then findings
2. Citation format: Inline markdown links `([source](URL))` immediately after the claim
3. Evidence presentation: Use tables for comparative data, prose for narrative findings
4. Flags: Mark single-source claims `[SINGLE_SOURCE]`, conflicts `[CONFLICTING: A says X, B says Y]`
5. Terminology: Define domain-specific terms on first use
6. Summary: End each section with a relevance statement connecting findings to the research objective
7. Length: Target 200–500 words per task section unless the task explicitly specifies more

---

## 5. Instructions Specification

### 5.1 Conditional Instructions: Research Conventions (`.github/instructions/research-conventions.instructions.md`)

**YAML Frontmatter:**
```yaml
---
applyTo: "**/*.md"
---
```

**Body Content:**
- When editing markdown files in this workspace, follow these conventions:
  - Use ATX-style headers (`#`, `##`, `###`) — never setext-style
  - Use `-` for unordered lists, never `*` or `+`
  - Use `- [ ]` / `- [x]` for task checkboxes — never other formats
  - Tables must have header row, separator row, and consistent column alignment
  - Inline citations use markdown links: `([source title](URL))`
  - Never use footnote-style citations (`[^1]`)
  - File references use relative paths from workspace root
  - ISO 8601 timestamps (`2026-04-06T12:00:00Z`) for all dates in logs
  - UTF-8 encoding, LF line endings

---

## 6. State Machine Specification

### 6.1 RESEARCH_PROGRESS.md — Five-State Checkbox Protocol

| Marker | State | Meaning | Max Concurrent |
|--------|-------|---------|----------------|
| `- [ ]` | Not Started | Available for assignment | Unlimited |
| `- [~]` | In Progress | Currently being worked on | **1** |
| `- [x]` | Complete | Verified and committed | Unlimited |
| `- [!]` | Failed | 3 strikes exhausted | Unlimited |
| `- [B]` | Blocked | Waiting on failed dependency | Unlimited |

### 6.2 State Transitions

| From | To | Trigger | Tool |
|------|-----|---------|------|
| `[ ]` | `[~]` | Worker selects task | `replace_string_in_file` |
| `[~]` | `[x]` | Task verified | `replace_string_in_file` |
| `[~]` | `[!]` | Three failures | `replace_string_in_file` |
| `[!]` | `[~]` | Retry after fix | `replace_string_in_file` |
| `[ ]` | `[B]` | Dependency on `[!]` task | `replace_string_in_file` |
| `[B]` | `[ ]` | Blocker resolved | `replace_string_in_file` |
| All `[x]` | Status: COMPLETE | Loop termination | `replace_string_in_file` on header |

### 6.3 Status Header Protocol

The `## Status:` field in RESEARCH_PROGRESS.md header drives loop behavior:
- `NOT_STARTED` → Planner has not yet populated tasks
- `IN_PROGRESS` → Worker loop is active
- `COMPLETE` → All tasks verified, loop should terminate
- `BLOCKED` → Systemic failure, human intervention needed

### 6.4 Signal-Based Termination

| Signal | Written By | Read By | Effect |
|--------|-----------|---------|--------|
| `## Status: COMPLETE` | Worker | Worker (next iteration) | Loop terminates |
| `## Status: BLOCKED` | Worker | Worker/Coordinator | Halt, request human |
| `- [!]` on task | Worker | Worker | Skip to next; mark dependents `[B]` |

---

## 7. Self-Improvement Pipeline Specification

### 7.1 Memory-to-Skill Promotion Pipeline

Embedded in the Worker's Step 8 ("Self-Improve"):

```
DETECT: Worker encounters novel pattern during task execution
  → Write to /memories/session/patterns.md (ephemeral, current session)

RECORD: Same pattern encountered in a subsequent session
  → Promote to /memories/research-patterns.md (permanent, auto-loaded)

EVALUATE: Pattern seen 3+ times across sessions
  → Spawn subagent to create .github/skills/<pattern-name>/SKILL.md
  → Set user-invocable: false (background auto-loading)
  → Write detailed procedural instructions

CLEAN: After creating skill
  → Remove promoted entries from /memories/research-patterns.md
  → Replace with pointer: "- See skill: <pattern-name>"
  → Keep User Memory under 200-line limit
```

### 7.2 Simplified Evolution (No External Frameworks)

The `research_activity.log` serves as execution trace data:
1. Every N tasks, the Worker or Coordinator reads the activity log
2. Identifies: tool selections that worked well → candidate for skill creation
3. Identifies: tasks that failed repeatedly → candidate for guardrail update
4. Spawns subagent to propose skill improvement or guardrail amendment
5. All changes visible via `git diff` — human reviews before committing

### 7.3 Memory Architecture

| Tier | Path | Persistence | Auto-Loaded | Content |
|------|------|-------------|-------------|---------|
| User | `/memories/` | Permanent | First 200 lines | Research preferences, source patterns, methodology insights |
| Session | `/memories/session/` | Current session | No (must read) | Current task notes, ephemeral patterns, URL queues |
| Repo | `/memories/repo/` | Workspace-scoped | Create-only | Project-specific conventions, fixed facts |

---

## 8. Configuration Requirements

### 8.1 VS Code Settings (`.vscode/settings.json`)

```json
{
  "chat.subagents.allowInvocationsFromSubagents": true,
  "chat.useCustomizationsInParentRepositories": true
}
```

### 8.2 Playwright MCP Configuration

The existing `.vscode/mcp.json` must include `--headless` flag for Playwright. This is assumed to already be configured based on the current workspace.

---

## 9. Acceptance Criteria

The implementation is considered complete when:

1. **AC-1:** All four agent files exist in `.github/agents/` with correct YAML frontmatter and full behavioral instructions.
2. **AC-2:** Invoking `@Research Planner` with a research question triggers the interrogation → brief → ledger → guardrails → handoff workflow.
3. **AC-3:** Invoking `@Research Worker proceed` reads RESEARCH_PROGRESS.md, picks the first pending task, executes it, and updates all state files.
4. **AC-4:** The Research Reviewer can be invoked as a subagent and returns a structured PASS/FAIL verdict.
5. **AC-5:** The Research Coordinator can orchestrate a full Planner→Worker→Reviewer cycle using `runSubagent`.
6. **AC-6:** Both seed skills exist and are auto-loaded by the Worker when relevant.
7. **AC-7:** The conditional instruction file applies to all `*.md` files.
8. **AC-8:** The Worker's self-improvement step writes patterns to `/memories/session/` during execution.
9. **AC-9:** `.vscode/settings.json` enables subagent nesting.
10. **AC-10:** All agent handoffs render correctly in the VS Code chat UI.

---

## 10. Non-Functional Requirements

### 10.1 Context Efficiency
- Agent instructions must be concise enough to leave ≥70% of the context window for tool output and working memory.
- Skills use progressive loading — only name+description loaded by default.
- File reads use targeted ranges, never full-file ingestion unless necessary.

### 10.2 Resilience
- Three-strike failure handling on every task.
- File-system state machine survives context window exhaustion — user re-invokes with "proceed" and agent resumes.
- No in-memory state that can be lost.

### 10.3 Auditability
- Every research action logged to `research_activity.log` with ISO timestamps.
- Every source registered in `research_sources.md` with type and relevance rating.
- All state changes visible via `git diff`.

### 10.4 Security
- Research Reviewer has read-only tool access — cannot modify Worker output.
- No credentials stored in agent files.
- No URL fabrication (hallucination prevention enforced in instructions).
- Playwright runs headless — no visible browser window.

---

## 11. Risk Register

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Context window fills mid-task | High | Medium | Ralph stateless re-entry; file-system state persists |
| Subagent nesting disabled | Medium | High | TASK-1.1 creates .vscode/settings.json with the setting |
| Model unavailable | Low | Medium | Model arrays with fallbacks in YAML frontmatter |
| Skill bloat (>200 lines in /memories/) | Medium | Medium | Clean step in promotion pipeline removes old entries |
| Agent file syntax errors | Medium | High | TASK-6.1 validates all YAML frontmatter via dry-run |
| Handoff buttons don't render | Low | Low | Handoffs are optional UX sugar; core workflow uses runSubagent |
