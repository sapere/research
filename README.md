# Research Agents

A multi-agent research orchestration system. Agents are defined as portable `.agent.md` files and run on any compatible harness — Claude Code, OpenCode, or direct API/SDK.

## What It Does

- **Web research**: Autonomous end-to-end research on any topic — planning, source discovery, extraction, verification, synthesis
- **Codebase analysis**: Inspect a repository to identify patterns, gaps, and improvements
- **Hybrid research**: Combine codebase analysis with web best practices in a single project
- **Software implementation**: Plan and build software projects with autonomous task execution

## Prerequisites

**Required:**
- An agent harness that reads `.agent.md` files (Claude Code, OpenCode, etc.)
- `jq` — used by the Bash auto-allow hook (`.claude/hooks/research-bash-allow.sh`). Pre-installed on most systems; install via `apt install jq` / `brew install jq` if missing.

**Required for full capability (degrades gracefully without):**
- [Playwright MCP](https://github.com/anthropics/anthropic-tools/tree/main/computer-use/playwright) — primary extraction tool. Workers use `browser_navigate` + `browser_snapshot` (accessibility tree) for injection-resistant content extraction from untrusted domains. Without Playwright, Workers fall back to `WebSearch` + `WebFetch` only — extraction is limited to allowlisted domains and more exposed to content injection. JavaScript-rendered pages are flagged as `[JS_REQUIRED]`.

**Recommended:**
- [RTK](https://github.com/rtk-ai/rtk) — token-optimized CLI proxy. Reduces token usage 60-90% on dev operations by rewriting commands (e.g., `git status` → `rtk git status`). Also auto-allows rewritten commands in background subagents via its PreToolUse hook. Install: `cargo install rtk` or see [RTK installation guide](https://github.com/rtk-ai/rtk#installation).
- **Tranco domain list** — run `bash ~/.claude/hooks/update-tranco.sh` to cache the top 100K domains. Workers check this before choosing extraction tool. Without it, Workers use Playwright for everything (safe but slower).
- [Firecrawl MCP](https://github.com/mendableai/firecrawl) (optional) — server-side rendering for complex tables and structured data. Requires API key.

## Permissions

**Portable (no setup):** Bash hook and Edit rules travel with the repo in `.claude/`.

- **Bash commands:** `.claude/hooks/research-bash-allow.sh` — PreToolUse hook that auto-allows research file operations (appends, mkdir, temp file cleanup). Required because declarative `Bash()` patterns don't work with shell redirects (`>>`, `>`) or in background subagents.
- **Edit operations:** `Edit(/**/RESEARCH_PROGRESS.md)` etc. in `.claude/settings.local.json` — globstar patterns for research state files.

**Optional global setup:** The Tranco domain list and WebFetch hook live outside the repo (`~/.claude/hooks/`). Without them, Workers use Playwright for all domains (safe but slower). To enable Tranco-based domain routing, see the Web Extraction section in CLAUDE.md.

## Agents

| Agent | Pipeline | Tier | Purpose |
|-------|----------|------|---------|
| Research Coordinator | Research | REASONING | Orchestrates the full pipeline: Planner -> Worker/Code Analyst -> Reviewer |
| Research Planner | Research | REASONING | Decomposes a question into a task ledger with search queries and effort levels |
| Research Worker | Research | EXECUTION | Executes one web research task: search, scrape, verify, write synthesis |
| Research Code Analyst | Research | REASONING | Executes one code analysis task: read files, identify patterns, write findings |
| Research Reviewer | Research | EXECUTION | Read-only verification of citations, claims, source quality |
| Architect Planner | Software | REASONING | Interview-based planning that produces PRD, task ledger, and guardrails |
| Ralph Orchestrator | Software | EXECUTION | Autonomous coding loop: implement, verify with Playwright, update ledger |

See [model-strategy.instructions.md](instructions/model-strategy.instructions.md) for model mapping across harnesses (Claude, OpenAI, Google, Ollama).

## Usage

### Web Research

```
@Research Coordinator research the current state of LLM observability tools and frameworks
```

More example prompts:

```
@Research Coordinator compare SQLite, DuckDB, and LibSQL as embedded databases for app developers in 2025-2026

@Research Coordinator what are the current best practices for rate limiting in distributed APIs?

@Research Coordinator analyze the competitive landscape of open-source vector databases — Qdrant, Milvus, Weaviate, Chroma

@Research Coordinator research WebAssembly runtimes for server-side use — Wasmtime, Wasmer, WasmEdge, performance and ecosystem
```

The Coordinator runs autonomously. Output lands in `research-results/`:

```
research-results/llm-observability-tools-2026-04-13/
  RESEARCH_BRIEF.md           # Scope, objectives, methodology
  RESEARCH_PROGRESS.md        # Task ledger with status checkboxes
  research_synthesis.md       # Findings with inline citations
  research_sources.md         # Source registry
  research_guardrails.md      # Quality constraints
  research_activity.log       # Audit trail
  research_narrator_summary.md # TTS-friendly spoken summary
```

### Codebase Analysis (Hybrid)

```
@Research Coordinator analyze /home/user/my-app and propose testing improvements

@Research Coordinator review the error handling patterns in /home/user/api-service and compare with industry best practices

@Research Coordinator audit /home/user/cli-tool for Rust idiomatic patterns and suggest improvements based on current community standards
```

The Planner creates CODE tasks first (inspect the repo), then WEB tasks (research best practices). Code Analyst reads the codebase, Worker researches the web, synthesis combines both with improvement proposals.

### Direct Worker Invocation

If a research project is already planned (RESEARCH_PROGRESS.md exists):

```
@Research Worker
```

Picks the next open task and executes it.

### Software Implementation

```
@Architect Planner build a CLI tool for managing research projects in Rust
```

Reviews the plan, then:

```
@Ralph Orchestrator
```

Executes tasks from the generated PROGRESS.md.

## How It Works

Agents coordinate through a **file-based state machine** — markdown files are the sole communication mechanism. No shared memory, no databases. Each agent invocation starts fresh (amnesia by design).

```
User asks a question
       |
       v
Coordinator (orchestrates everything)
       |
       v
Planner (decomposes into tasks)
       |
       v
  +---------+----------+
  |                    |
Worker            Code Analyst
(web research)    (codebase analysis)
  |                    |
  +---------+----------+
            |
            v
       Reviewer (verifies quality)
            |
            v
   research_synthesis.md
```

**Task states:** `[ ]` Not Started -> `[~]` In Progress -> `[x]` Complete or `[!]` Failed -> `[!1]` Retrying -> `[~1]` In Progress (retry) -> `[x]` or `[!!]` Exhausted. See [state-machine.instructions.md](instructions/state-machine.instructions.md) for the full spec.

**Parallel execution:** Independent tasks run concurrently (up to 4). Workers write to task-scoped temp files to prevent race conditions. The Coordinator merges results and owns all ledger updates during parallel dispatch.

**Data isolation:** In hybrid projects, the Code Analyst sanitizes findings — translates proprietary names to public technology terms, flags credentials without values. Web search queries never contain internal identifiers.

## Project Structure

```
agents/                    # Agent definitions (numbered by pipeline stage)
instructions/              # Shared conventions
  research-conventions     # Markdown style, citation format, task states
  model-strategy           # Capability tiers and model mapping per harness
  state-machine            # Canonical task state transitions
skills/                    # Reusable procedures
  source-evaluation/       # Source credibility assessment
  synthesis-writing/       # Citation format, evidence flags, confidence scoring
research-results/          # Output folders (gitignored, one per research run)
.claude/
  settings.local.json      # Permissions (Edit rules, WebSearch, WebFetch)
  hooks/                   # PreToolUse hook for Bash auto-allow
```
