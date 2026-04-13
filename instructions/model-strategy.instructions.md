# Model Strategy for Research Agents

This guide is harness-agnostic. The agents define capability **tiers**, not specific models. You map tiers to whatever models your harness provides.

## Capability Tiers

| Tier | Agents | Why | Minimum Requirements |
|------|--------|-----|---------------------|
| **REASONING** | Coordinator, Planner, Code Analyst | Orchestration, decomposition, and code analysis decisions cascade through the pipeline. Bad planning or shallow analysis wastes downstream tokens | Strong analytical reasoning, long-context handling, reliable instruction following |
| **EXECUTION** | Worker, Reviewer | Structured task protocols (search → extract → write, verification checklists). ~80% of total token spend | Tool use, web search, instruction following. Moderate reasoning sufficient |

## Model Mapping Examples

Pick one column. Edit your harness config to map each agent to the corresponding model.

| Agent | Tier | Claude Code | OpenCode / Ollama | OpenAI | Google |
|-------|------|-------------|-------------------|--------|--------|
| Coordinator | REASONING | opus latest | qwen3:32b / llama3.3:70b | o3 / gpt-4.1 | gemini-2.5-pro |
| Planner | REASONING | opus latest | qwen3:32b / llama3.3:70b | o3 / gpt-4.1 | gemini-2.5-pro |
| Worker | EXECUTION | sonnet latest| qwen3:8b / llama3.1:8b | gpt-4.1-mini | gemini-2.5-flash |
| Code Analyst | REASONING | opus latest | qwen3:32b / llama3.3:70b | o3 / gpt-4.1 | gemini-2.5-pro |
| Reviewer | EXECUTION | sonnet latest | qwen3:8b / llama3.1:8b | gpt-4.1-mini | gemini-2.5-flash |

## Cost Profiles

### Max Quality
Map all agents to REASONING-tier models. Use for: regulatory analysis, contested topics, high-stakes output.

### Balanced (recommended)
Map Coordinator + Planner + Code Analyst to REASONING, Worker + Reviewer to EXECUTION. Best cost/quality ratio.

### Budget
Map all agents to EXECUTION-tier models (or smaller). Use for: exploratory drafts, narrow-scope lookups. Not recommended for DEEP effort tasks.

## How to Configure Per Harness

### Claude Code
Add `model:` to each `.agent.md` frontmatter. Values: `opus latest`, `sonnet latest`, `haiku latest `. Or override globally:
```bash
export CLAUDE_CODE_SUBAGENT_MODEL=sonnet
```

### OpenCode
Set model per agent in your `opencode.json` or session config. Refer to OpenCode docs for agent model override syntax.

### Direct API / SDK
Pass the model ID when constructing each agent. Example (Python):
```python
coordinator = Agent(prompt=load("04_Research_Coordinator.agent.md"), model="claude-opus-4-6")
worker = Agent(prompt=load("02_Research_Worker.agent.md"), model="claude-sonnet-4-6")
```

## Effort-Level Interaction

The `Effort:` tag on tasks (LIGHT/STANDARD/DEEP) controls depth of work **within** whatever model is selected. A DEEP task on a small model still runs more searches and verification — it just uses that model's reasoning for synthesis. If DEEP tasks consistently produce low-quality synthesis on your EXECUTION-tier model, promote those tasks to a REASONING-tier model.

## Invocation Volume Estimate

A typical 12-task SINGLE_PASS project: ~1 Coordinator + 1 Planner + 12 Workers + 2-3 Reviewers = 16-17 agent invocations. Workers dominate cost.
