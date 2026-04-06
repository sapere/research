# Autonomous Execution Ledger

## Status: IN_PROGRESS

> **Source:** `01_PRD.md` v1.0.0
> **Generated:** 2026-04-06
> **Protocol:** Each task = 1–2 file changes. Tasks are strictly sequential. Mark `[~]` before starting, `[x]` on completion.

---

## Phase 1: Foundation & Configuration

- [x] TASK-1.1: Create `.vscode/settings.json` with `chat.subagents.allowInvocationsFromSubagents: true` and `chat.useCustomizationsInParentRepositories: true`.
- [x] TASK-1.2: Create directory structure: `.github/skills/source-evaluation/`, `.github/skills/synthesis-writing/`, `.github/instructions/`.

## Phase 2: Core Agent Files

- [x] TASK-2.1: Create `01_Research_Planner.agent.md` — Full YAML frontmatter (name, description, tools: [read, search, edit, agent], agents: [Research Worker, Research Reviewer], model: [Claude Opus 4.5 (copilot), GPT-5 (copilot)], handoffs with label/agent/prompt/send) + complete Phase 1–6 behavioral protocol as specified in PRD Section 3.1. Replace existing file.
- [ ] TASK-2.2: Create `02_Research_Worker.agent.md` — Full YAML frontmatter (name, description, tools: [read, edit, search, web, fetch, agent, all 7 Playwright MCP tools], model: [Claude Sonnet 4.5 (copilot)], handoffs to Reviewer) + complete 9-step Ralph Loop behavioral protocol, three-strike rule, hallucination prevention rules, narrator summary generation spec, and self-improvement step as specified in PRD Section 3.2. Replace existing file.
- [ ] TASK-2.3: Create `03_Research_Reviewer.agent.md` — Full YAML frontmatter (name, description, tools: [read, search, web, fetch] — READ ONLY, user-invocable: false, model: [Claude Opus 4.5 (copilot)]) + 7-step verification protocol and structured verdict format as specified in PRD Section 3.3. New file.
- [ ] TASK-2.4: Create `04_Research_Coordinator.agent.md` — Full YAML frontmatter (name, description, tools: [agent, read, edit], agents: [Research Planner, Research Worker, Research Reviewer], model: [Claude Opus 4.5 (copilot)], handoffs to Planner and Worker) + 4-step orchestration loop as specified in PRD Section 3.4. New file.

## Phase 3: Skills & Instructions

- [ ] TASK-3.1: Create `.github/skills/source-evaluation/SKILL.md` — YAML frontmatter (name: source-evaluation, description, user-invocable: false) + 7-step procedural instructions for evaluating source credibility, domain authority, publication date, author credentials, paywall detection, bias assessment, and accessibility as specified in PRD Section 4.1.
- [ ] TASK-3.2: Create `.github/skills/synthesis-writing/SKILL.md` — YAML frontmatter (name: synthesis-writing, description, user-invocable: false) + 7-step procedural instructions for writing synthesis sections with inline citations, evidence tables, flags, terminology handling, summaries, and length targets as specified in PRD Section 4.2.
- [ ] TASK-3.3: Create `.github/instructions/research-conventions.instructions.md` — YAML frontmatter (`applyTo: "**/*.md"`) + markdown editing conventions: ATX headers, `-` for lists, checkbox format, table format, citation format, relative paths, ISO timestamps, UTF-8/LF as specified in PRD Section 5.1.

## Phase 4: State Machine Templates

- [ ] TASK-4.1: Update `RESEARCH_PROGRESS.md` header to include the five-state legend (`[ ]` Not Started, `[~]` In Progress, `[x]` Complete, `[!]` Failed, `[B]` Blocked) and the `## Status:` header protocol (NOT_STARTED, IN_PROGRESS, COMPLETE, BLOCKED) as documented in PRD Section 6.

## Phase 5: Self-Improvement Infrastructure

- [ ] TASK-5.1: Create `/memories/repo/research-agent-conventions.md` with a note documenting the memory-to-skill promotion pipeline (Detect→Record→Evaluate→Create→Clean) and the 200-line user memory limit as specified in PRD Section 7.

## Phase 6: Validation & Integration

- [ ] TASK-6.1: Validate all YAML frontmatter in the four `.agent.md` files. Read each file, check that `tools`, `agents`, `model`, and `handoffs` fields use correct array/object syntax. Fix any formatting errors. Log validation results to `research_activity.log`.
- [ ] TASK-6.2: Validate both `.github/skills/*/SKILL.md` files have correct frontmatter (`name`, `description`, `user-invocable`). Read each file and confirm body content matches PRD specifications. Fix any issues.
- [ ] TASK-6.3: Verify `.github/instructions/research-conventions.instructions.md` has valid `applyTo` glob pattern and body matches PRD conventions. Fix any issues.
- [ ] TASK-6.4: Final integration check — Read all generated files, verify cross-references (agent names in `agents:` arrays match actual agent `name:` fields, skill names are consistent, handoff agent names match). Log final status to `research_activity.log` and update this ledger's Status header to `COMPLETE`.
