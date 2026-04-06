---
applyTo: "**/*.md"
---

When editing markdown files in this workspace, follow these conventions:

- Use ATX-style headers (`#`, `##`, `###`) — never setext-style (underlines with `===` or `---`)
- Use `-` for unordered lists — never `*` or `+`
- Use `- [ ]` / `- [x]` for task checkboxes — never other checkbox formats
- Tables must have a header row, separator row (`|---|---|`), and consistent column alignment
- Inline citations use markdown links: `([source title](URL))` — never footnote-style (`[^1]`)
- File references use relative paths from the workspace root
- Use ISO 8601 timestamps for all dates in logs: `YYYY-MM-DDTHH:MM:SSZ`
- UTF-8 encoding, LF line endings (no CRLF)
- One blank line before and after headers, code blocks, and tables
- No trailing whitespace on any line
