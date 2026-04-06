# Research Brief

## Executive Summary
The core objective is to design and implement an advanced, self-improving autonomous research agent system entirely within VS Code and Copilot. This system will utilize a markdown-based topic list, integrate a continuous learning loop leveraging the `/memories/` file system, and draw structural inspiration from Ralph Wiggum and the Hermes agent. The research must outline the technical architecture, prompt engineering strategies, state machine loops, and memory management protocols required to surpass existing workspace agents in both depth and breadth of research quality.

## Research Objectives
1. **Architecture Design:** How can we best decouple the "Planner," "Worker," and "Reviewer" schemas into modular `.agent.md` files while sharing state via markdown ledgers?
2. **Learning Loop Implementation:** What is the optimal strategy for the agent to auto-generate, refine, and query its own skills and session memories (`/memories/`) across iterations without exceeding token limits?
3. **State Management:** How should the system structure the markdown checklist of research topics to allow a Controller or Planner agent to pop tasks, track progress, and handle interruptions?
4. **Hermes/Ralph Wiggum Patterns:** Which specific prompt structures and loop logic from these inspirations (e.g., rigid schema adherence, discrete state transitions, reflection phases) are most effective for VS Code's environment?

## Scope Definition
- **In-Scope:** VS Code Copilot Chat primitives (`.agent.md`, `.instructions.md`, `.prompt.md`, `SKILL.md`), the `/memories/` file system, markdown tracking ledgers, workspace-native tools.
- **Out-of-Scope:** Paid external APIs, Copilot CLI, standalone Python frameworks (e.g., Autogen, CrewAI) that operate outside the VS Code extension ecosystem.

## Search Operations Lexicon
- "autonomous loop" AND "state machine" AND "VS Code Copilot"
- "Hermes agent" OR "NousResearch" "prompt structure"
- "Ralph Wiggum" agent autonomous "progress ledger"
- "Agent memory management" AND ("file system" OR "markdown")

## Source Strategy
- **Primary Sources:** Available agent customization docs, Hermes GitHub repository, Ralph Wiggum implementations.
- **Secondary Sources:** Community discussions on VS Code Copilot agent crafting and MCP integration.

## Methodology
Every architectural component (Planner, Worker, Memory Manager) proposed must be verified against VS Code Copilot boundaries and evaluated for context-window efficiency.

## Output Specification
A detailed technical blueprint and directly actionable `.agent.md` file contents (including the Planner, Worker, and Learning/Memory module) formatted as a comprehensive Markdown report.

## Success Criteria
The research is complete when a fully defined, implementable blueprint is produced that details the exact files, prompts, and memory schemas needed to deploy the self-improving agent system.

## Risk Register
- **Context Degradation:** The learning loop might fill `/memories/` uncontrollably, leading to irrelevant context injections.
- **Infinite Loops:** The autonomous worker might get stuck retrying the same markdown checklist item if error states are not managed.