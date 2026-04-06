# Research Guardrails

- **Source Quality Standards:** Prioritize primary documentation (GitHub repositories, official VS Code API Docs, Copilot release notes).
- **Forbidden Sources:** Avoid generalized, out-of-date blog posts prior to Mid-2025 regarding Copilot behavior (system capabilities have changed rapidly).
- **Citation Format:** Use inline URL links for easy traversal and specific file path links (e.g., `.github/agents/03_Research_Planner.agent.md`).
- **Hallucination Prevention Rules:**
  - Never fabricate API endpoints or capabilities within the VS Code extension architecture.
  - If a specific cross-agent communication (e.g., Planner directly invoking Worker without user interaction) is not natively supported without a CLI hook, document it as a constraint or propose an alternative like `runSubagent`.
- **Token Budget Guidelines:** Read only necessary files/functions. When inspecting Hermes repo, use focused extraction over bulk copying.
- **Lessons Learned:** [Initially empty]
- **Advanced Search Mandates:** Evaluate snippet relevance tightly. Skip tutorial sites unless verifying specific workflows.