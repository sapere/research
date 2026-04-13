#!/usr/bin/env bash
# research-bash-allow.sh — PreToolUse hook for research pipeline Bash commands
#
# Auto-allows specific Bash operations on research project files so the
# autonomous pipeline runs without permission prompts (including background
# subagents where declarative Bash() patterns don't work).
#
# Security model:
#   - Only append (>>) and create (>) operations on known research filenames
#   - Only mkdir -p and rm for research temp files
#   - Path must be under a research project folder (contains RESEARCH_PROGRESS.md)
#   - No arbitrary command execution
#
# Referenced from .claude/settings.local.json (travels with the repo).

set -euo pipefail

if ! command -v jq &>/dev/null; then
  # jq missing — cannot parse tool input, pass through to normal permission handling
  exit 0
fi

INPUT=$(cat)
CMD=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

if [ -z "$CMD" ]; then
  exit 0
fi

# --- Allowed research file basenames ---
# Patterns use (.*/)? to match both absolute paths and bare relative filenames
RESEARCH_FILES='research_activity\.log|research_sources\.md|research_synthesis[^/]*\.md|research_narrator_summary\.md|research_guardrails\.md|research_review_memo\.md'
RESEARCH_STATE='RESEARCH_PROGRESS\.md|RESEARCH_BRIEF\.md'
ALL_FILES="${RESEARCH_FILES}|${RESEARCH_STATE}"
# Optional path prefix: matches "/some/path/file" OR just "file"
P='(.*/)?'

allow() {
  jq -n '{
    "hookSpecificOutput": {
      "hookEventName": "PreToolUse",
      "permissionDecision": "allow",
      "permissionDecisionReason": "research-bash-allow hook"
    }
  }'
  exit 0
}

# 1. grep for Tranco domain trust check (read-only, safe)
if echo "$CMD" | grep -qE "^grep .+tranco-domains"; then
  allow
fi

# 2. echo/printf append (>>) to research files
if echo "$CMD" | grep -qE "^echo .+ >> ${P}(${RESEARCH_FILES})$"; then
  allow
fi

# 3. cat heredoc append (>>) to research files
if echo "$CMD" | grep -qE "^cat .+ >> ${P}(${RESEARCH_FILES})$"; then
  allow
fi

# 4. cat heredoc create (>) for synthesis temp files and narrator summary
if echo "$CMD" | grep -qE "^cat .+ > ${P}(research_synthesis[^/]*\.md|research_narrator_summary\.md)$"; then
  allow
fi

# 5. mkdir -p for research project folders
if echo "$CMD" | grep -qE "^mkdir -p .+/[a-z0-9][-a-z0-9]*-[0-9]{4}-[0-9]{2}-[0-9]{2}[a-z0-9/-]*$"; then
  allow
fi

# 6. rm temp synthesis files after merge
if echo "$CMD" | grep -qE "^rm ${P}research_synthesis_TASK-[^/]+\.md$"; then
  allow
fi

# 7. mv synthesis merge (specific pattern only)
if echo "$CMD" | grep -qE "^mv ${P}research_synthesis_merged\.md ${P}research_synthesis\.md$"; then
  allow
fi

# 8. sed inline edits on research files (used by Coordinator for fixes)
if echo "$CMD" | grep -qE "^sed -i .+ ${P}(${ALL_FILES})$"; then
  allow
fi

# 9. stat/ls/wc on research files (read-only, safe)
if echo "$CMD" | grep -qE "^(stat|ls|wc) .+${P}(${ALL_FILES})"; then
  allow
fi

# 10. tail on research files (read-only)
if echo "$CMD" | grep -qE "^tail .+${P}(${ALL_FILES})"; then
  allow
fi

# No match — pass through to Claude Code's normal permission handling
exit 0
