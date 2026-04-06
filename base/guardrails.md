# Implementation Guardrails

> Coding standards, forbidden patterns, and architecture boundaries for the autonomous executor.

---

## 1. Agent File Standards (`.agent.md`)

### YAML Frontmatter Rules
- **Always** use triple-dash delimiters (`---`) on their own lines
- **Always** quote string values that contain special YAML characters (`:`, `{`, `}`, `[`, `]`, `,`, `&`, `*`, `#`, `?`, `|`, `-`, `<`, `>`, `=`, `!`, `%`, `@`, `` ` ``)
- **Always** use bracket-style arrays for `tools`, `agents`, `model`: `['tool1', 'tool2']`
- **Always** use single-quoted strings inside arrays: `['read', 'search', 'edit']`
- **Never** use plain-text lists (dash-prefixed) for tools/agents/model fields
- **Always** include `name` and `description` as the first two fields
- **Handoffs** use the object format: `{ label: "...", agent: "...", prompt: "...", send: false }`
- Agent `name:` values must exactly match the names used in `agents:` arrays of other agents (case-sensitive)

### Markdown Body Rules
- Use numbered steps for behavioral protocols
- Use bold inline labels (`**Phase 1:**`, `**Step 3:**`) for step identification
- Keep total agent instruction length under 4,000 tokens (rough target: ≤300 lines)
- Include the self-improvement step in Worker only — not in other agents

### Valid Tool Names (known VS Code Agent tools)
```
read, edit, search, web, fetch, agent, terminal,
mcp_microsoft_pla_browser_navigate,
mcp_microsoft_pla_browser_snapshot,
mcp_microsoft_pla_browser_click,
mcp_microsoft_pla_browser_evaluate,
mcp_microsoft_pla_browser_press_key,
mcp_microsoft_pla_browser_wait_for,
mcp_microsoft_pla_browser_take_screenshot
```

---

## 2. Skill File Standards (`SKILL.md`)

- **Always** use triple-dash YAML frontmatter
- **Required fields:** `name`, `description`
- **Optional fields:** `user-invocable` (default: false for background skills), `disable-model-invocation`
- Body must contain numbered procedural steps (not prose)
- Each step must be actionable and verifiable
- Skill name in frontmatter must match the parent directory name

---

## 3. Instruction File Standards (`.instructions.md`)

- **Required field:** `applyTo` (glob pattern)
- `applyTo` patterns use standard glob syntax: `**/*.md`, `**/research_*.md`
- Body content is injected into context for matching files — keep concise
- Never include agent behavioral protocols in instructions (those belong in `.agent.md`)

---

## 4. Forbidden Patterns

| Pattern | Reason | Alternative |
|---------|--------|-------------|
| Setext-style headers (`===`, `---` under text) | Inconsistent rendering | ATX-style: `#`, `##`, `###` |
| Footnote citations (`[^1]`) | Not supported by research format | Inline: `([title](URL))` |
| `*` or `+` for unordered lists | Convention conflict | Always use `-` |
| Storing credentials in `.agent.md` | Security violation | Use environment variables or VS Code secrets |
| Worker modifying agent files | Violates separation of concerns | Only human or Coordinator may modify `.agent.md` |
| Reviewer modifying any workspace file | Violates read-only constraint | Reviewer uses `read`, `search`, `web`, `fetch` only |
| Hardcoded absolute paths | Non-portable | Use relative paths from workspace root |
| `bash -c "..."` in terminal commands | Sub-shell anti-pattern | Direct command execution |
| `npm install` or build commands in research agents | Research agents don't build code | Use only file I/O, search, and browser tools |
| YAML `tools:` as plain-text list (dash-prefixed) | VS Code parser expects array syntax | Use `['tool1', 'tool2']` bracket format |

---

## 5. Architecture Boundaries

### Module Import Rules
| Module | Can Reference | Cannot Reference |
|--------|--------------|-----------------|
| Planner | State files, BRIEF, guardrails | synthesis.md (write), sources.md (write) |
| Worker | All state files (read/write) | Agent files (read-only) |
| Reviewer | synthesis.md (read), BRIEF (read), sources.md (read) | Any write operation |
| Coordinator | Agent invocations, PROGRESS.md (read) | Direct synthesis writes |
| Skills | Referenced by agents, loaded on match | Cannot reference other skills |
| Instructions | Auto-injected by VS Code on file match | Cannot invoke agents or skills |

### File Ownership
| File | Owner (Write) | Readers |
|------|--------------|---------|
| `RESEARCH_BRIEF.md` | Planner | Worker, Reviewer, Coordinator |
| `RESEARCH_PROGRESS.md` | Planner (init), Worker (updates), Coordinator (reads) | All |
| `research_guardrails.md` | Planner | Worker, Reviewer |
| `research_synthesis.md` | Worker | Reviewer |
| `research_sources.md` | Worker | Reviewer |
| `research_activity.log` | Worker | Coordinator |
| `research_narrator_summary.md` | Worker (TASK-FINAL only) | User |

---

## 6. Quality Checks for Each Task

Before marking any task `[x]`:
1. Read the created/modified file back and verify content matches PRD specification
2. Verify YAML frontmatter parses correctly (no trailing spaces, correct quoting)
3. Verify agent names cross-reference correctly (name in file A matches agents array in file B)
4. Verify tool names are from the valid tool list in Section 1
5. Log the completion to `research_activity.log` with ISO timestamp

---

## 7. Lessons Learned

> This section is populated by the Ralph Orchestrator during execution.
> Format: `- [YYYY-MM-DD] Lesson description`

_(empty — will be populated during autonomous execution)_
