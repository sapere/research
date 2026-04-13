---
applyTo: "**/*.md"
---

When editing markdown files in this workspace, follow these conventions:

- Use ATX-style headers (`#`, `##`, `###`) — never setext-style (underlines with `===` or `---`)
- Use `-` for unordered lists — never `*` or `+`
- Task checkbox states: `- [ ]` Not Started, `- [~]` In Progress, `- [x]` Complete, `- [!]` Failed, `- [!1]` Retrying (attempt 2), `- [~1]` In Progress (retry), `- [!!]` Exhausted (no more retries), `- [B]` Blocked — never other checkbox formats
- Tables must have a header row, separator row (`|---|---|`), and consistent column alignment
- Inline citations: `([source title](URL))` for web sources, `(file:line)` for code references (e.g., `(src/api/routes.ts:42)`) — never footnote-style (`[^1]`)
- File references use relative paths from the workspace root
- Use ISO 8601 timestamps for all dates in logs: `YYYY-MM-DDTHH:MM:SSZ`
- UTF-8 encoding, LF line endings (no CRLF)
- One blank line before and after headers, code blocks, and tables
- No trailing whitespace on any line
