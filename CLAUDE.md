# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repo Is

A multi-agent research orchestration system. No application code — purely agent definitions, skills, and instructions in markdown. Agents are invoked via Claude Code, OpenCode, or any harness that reads `.agent.md` files.

Pipelines:
- **Research** (autonomous): Coordinator → Planner → Worker / Code Analyst → Reviewer — fully autonomous end-to-end research, no human checkpoints. Supports hybrid projects mixing web research (`Source: WEB`) and codebase analysis (`Source: CODE`)
- **Software** (human-in-the-loop): Architect Planner produces specs (`01_PRD.md`, `PROGRESS.md`, `guardrails.md`) with an interview phase → user reviews and approves → Ralph Orchestrator executes the autonomous coding loop with Playwright MCP verification

## Repository Layout

```
agents/            # 7 agent definitions (numbered, ordered by pipeline stage)
instructions/      # Conventions: research-conventions, model-strategy, state-machine
skills/            # Reusable procedures: source-evaluation, synthesis-writing
research-results/  # Output folders (gitignored, one per research run)
.claude/
  settings.local.json   # Permissions: WebSearch, WebFetch, Edit/Write rules
  hooks/                # PreToolUse hook for Bash auto-allow
Dockerfile              # Multi-stage: claude + opencode targets
docker-compose.yml      # One-command run for both targets
```

Research projects create their output in `research-results/` (e.g., `research-results/competitive-landscape-saas-2026-04-13/`).

## Agent Architecture

Agents use a **file-based state machine** — markdown files are the sole coordination mechanism. No conversational memory across invocations (amnesia by design).

State files per research project:
- `RESEARCH_PROGRESS.md` — task ledger with inline checkbox states (`- [ ] TASK-1.1: Description. Source: WEB. Effort: STANDARD.`). See `state-machine.instructions.md` for the canonical format.
- `RESEARCH_BRIEF.md` — scope, objectives, success criteria
- `research_synthesis.md` — accumulated findings with inline citations
- `research_sources.md` — source registry (ID, URL, Type, Rating, Date)
- `research_activity.log` — audit trail (ISO 8601)
- `research_guardrails.md` — quality constraints

Capability tiers (see `instructions/model-strategy.instructions.md` for model mapping):
- **REASONING tier**: Coordinator, Planner, Code Analyst — need high-reasoning models
- **EXECUTION tier**: Worker, Reviewer — capable mid-tier models sufficient

## Critical Constraints When Editing Agents

- **Research pipeline autonomy**: Research agents (Coordinator, Planner, Worker, Code Analyst, Reviewer) never ask clarifying questions, never wait for approval. They make reasonable assumptions and proceed. The Architect Planner is an exception — it uses an interrogation phase by design because software specs require explicit user input on tech stack and acceptance criteria.
- **Diff timeout prevention**: Workers use `cat << 'EOF' >> file` for synthesis writes, not large `edit` operations. Max 30 lines per edit. Keep files under 250 lines initially.
- **Three-strike rule**: After 3 consecutive failures, Worker marks `[!]`. Coordinator retries once. Second failure escalates to `[!!]` (exhausted, no more retries).
- **One task per Worker invocation**: The Coordinator owns iteration, not the Worker.
- **Parallel dispatch cap**: Max 4 concurrent Workers. Sequential fallback for tasks with `Depends-on:` hard dependencies. `Cross-ref:` is a non-blocking hint for connecting findings — it does not affect scheduling.
- **Data isolation**: In hybrid projects (CODE + WEB), Code Analyst translates proprietary terms to public technology names. WEB search queries can be specific about public tech (libraries, frameworks, patterns) but must never contain internal project names, credentials, or private URLs. Code Analyst flags secrets as `[CREDENTIAL_FOUND]` without values.

## Conventions

- ATX-style headers only (`#`, not underlines)
- Hyphens for unordered lists
- Inline citations: `([title](URL))` for web sources, `(file:line)` for code references
- ISO 8601 timestamps in logs
- Evidence flags: `[SINGLE_SOURCE]`, `[CONFLICTING: ...]`, `[CONF: HIGH|MED|LOW]`
- Task effort tags: `LIGHT` / `STANDARD` / `DEEP` (controls source depth and word targets)
- Task source tags: `Source: WEB` (dispatched to Worker) / `Source: CODE` (dispatched to Code Analyst)

## Web Extraction Security Model

Workers choose extraction tools per-URL based on domain trust. This prevents both prompt injection (via hidden page text) and permission prompts (which break autonomous execution).

**Domain trust check:** Workers run `grep -Fxq "$DOMAIN" ~/.claude/hooks/tranco-domains.txt` before each extraction. The Tranco list (top 100K domains by traffic, research-grade ranking) is cached locally.

- **Trusted domain (in Tranco)** → `WebFetch` — fast, auto-allowed by the PreToolUse hook in `~/.claude/settings.json`. No user prompt.
- **Untrusted domain (not in Tranco)** → Playwright `browser_navigate` + `browser_snapshot` — returns an accessibility tree that structurally excludes hidden elements (`display:none`, zero-size, `aria-hidden`). No permission prompt needed, injection-resistant.
- **Firecrawl MCP (when configured)** → server-side rendering. Best for complex tables. Optional — requires API key.

**Refresh Tranco list:** `bash ~/.claude/hooks/update-tranco.sh` (default: top 100K, adjustable)

**Static allowlist** in `settings.local.json` covers only niche domains outside Tranco (e.g., bun.sh, tc39.es). The Tranco hook handles the remaining ~100K domains dynamically.

## Permissions

**Portable (travel with the repo, no setup):**
- **Bash commands**: `.claude/hooks/research-bash-allow.sh` — PreToolUse hook that auto-allows research file operations (appends, mkdir, temp file cleanup) by regex-matching command + filename. Matches both absolute and relative paths. Works in background subagents where declarative `Bash()` patterns fail.
- **Edit operations**: `Edit(/**/RESEARCH_PROGRESS.md)` etc. in `settings.local.json` — globstar patterns for research state files.

**Optional global setup (outside the repo):**
- **Tranco domain list**: `~/.claude/hooks/tranco-domains.txt` + `webfetch-domain-check.sh`. Without these, Workers use Playwright for all domains (safe but slower). See Web Extraction section above for setup.
- **RTK**: Token-saving CLI proxy. See README for install.

## Git

- **Origin**: `sapere/research` — primary
- **Upstream**: `maverock24/Research` — community fork
- **Main branch**: `main` (default branch for PRs)
- Never auto-commit. User commits when ready.

## Docker

Two build targets in the multi-stage Dockerfile:
- `claude` — Claude Code CLI + Anthropic subscription auth (mounted read-only from host `~/.claude/`)
- `opencode` — OpenCode CLI + Ollama local LLMs (host network for `localhost:11434`)

Both include Playwright + Chromium, jq, and all repo files. Docker provides filesystem isolation — agents cannot access host files outside mounted volumes, mitigating prompt injection → file access risks. The Bash hook still runs inside as a secondary defense.
