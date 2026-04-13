#!/usr/bin/env bash
# research-bash-allow.sh — PreToolUse hook for research pipeline Bash commands
#
# Auto-allows specific Bash operations on research project files so the
# autonomous pipeline runs without permission prompts (including background
# subagents where declarative Bash() patterns don't work).
#
# Security model:
#   - Newline injection blocked: multi-line commands rejected unless heredoc
#   - Path containment enforced: writes only under the workspace directory
#   - Argument shapes restricted: no $(), backticks, or pipe chains in echo/cat
#   - All rules fully end-anchored
#
# Referenced from .claude/settings.local.json (travels with the repo).

set -euo pipefail

if ! command -v jq &>/dev/null; then
  exit 0  # jq missing — pass through to normal permission handling
fi

INPUT=$(cat)
CMD=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

if [ -z "$CMD" ]; then
  exit 0
fi

# --- C1 fix: Newline injection guard ---
# grep tests ^...$ per line, so a multi-line CMD where any single line matches
# would auto-allow the entire command. Block multi-line unless it's a heredoc.
if [[ "$CMD" == *$'\n'* ]] && [[ ! "$CMD" =~ ^cat\ .*\<\<\ *\'?[A-Z] ]]; then
  exit 0  # multi-line non-heredoc — do not auto-allow
fi

# --- C2 fix: Workspace containment ---
# Resolve the workspace root (where this hook lives: .claude/hooks/)
WORKSPACE="$(cd "$(dirname "$0")/../.." && pwd)"

# For rules that write files, extract the target path and verify containment.
# Returns 0 if the path is under $WORKSPACE or is a bare relative filename.
path_ok() {
  local target="$1"
  # Bare filename (no slashes) — always OK (resolves to cwd which is workspace)
  if [[ "$target" != */* ]]; then return 0; fi
  # Absolute path — must start with workspace
  if [[ "$target" == /* ]]; then
    [[ "$target" == "$WORKSPACE"/* ]] && return 0 || return 1
  fi
  # Relative path with dirs — always OK (relative to workspace cwd)
  return 0
}

# --- Allowed research file basenames ---
RESEARCH_FILES='research_activity\.log|research_sources\.md|research_synthesis[^/]*\.md|research_narrator_summary\.md|research_guardrails\.md|research_review_memo\.md'
RESEARCH_STATE='RESEARCH_PROGRESS\.md|RESEARCH_BRIEF\.md'
ALL_FILES="${RESEARCH_FILES}|${RESEARCH_STATE}"

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

# ========== RULE 1: Tranco domain trust check (read-only, fully anchored) ==========

# 1a) DOMAIN="..."; grep -Fxq "$DOMAIN" .../tranco-domains.txt 2>/dev/null && echo "TRUSTED" || echo "UNTRUSTED"
#     Domain value restricted to [a-zA-Z0-9._-] to block $() and backtick injection
if echo "$CMD" | grep -qE '^DOMAIN="[a-zA-Z0-9._-]+"; grep -Fxq "\$DOMAIN" [^ ]+tranco-domains\.txt 2>/dev/null && echo "TRUSTED" \|\| echo "UNTRUSTED"$'; then
  allow
fi
# 1b) bare grep: grep -Fxq "domain" .../tranco-domains.txt ...
if echo "$CMD" | grep -qE '^grep -Fxq "[a-zA-Z0-9._-]+" [^ ]+tranco-domains\.txt 2>/dev/null && echo "TRUSTED" \|\| echo "UNTRUSTED"$'; then
  allow
fi
# 1c) subdomain extraction: echo "domain.name" | rev | cut -d. -f1-2 | rev
if echo "$CMD" | grep -qE '^echo "[a-zA-Z0-9._-]+" \| rev \| cut -d\. -f1-2 \| rev$'; then
  allow
fi
# 1d) variable form: echo "$DOMAIN" | rev | cut -d. -f1-2 | rev
if echo "$CMD" | grep -qE '^echo "\$DOMAIN" \| rev \| cut -d\. -f1-2 \| rev$'; then
  allow
fi

# ========== RULE 2: echo append (>>) to research files ==========
# H1+H2 fix: only allow quoted string arguments (no $(), backticks, or pipes)
# Matches: echo "quoted text" >> path/research_activity.log
#          echo '...' >> research_sources.md
if echo "$CMD" | grep -qE '^echo "[^"`$]+" >> (.+/)?('"${RESEARCH_FILES}"')$'; then
  local_target=$(echo "$CMD" | grep -oE '>> .+$' | sed 's/^>> //')
  path_ok "$local_target" && allow
fi
if echo "$CMD" | grep -qE "^echo '[^']+' >> (.+/)?(${RESEARCH_FILES})$"; then
  local_target=$(echo "$CMD" | grep -oE '>> .+$' | sed 's/^>> //')
  path_ok "$local_target" && allow
fi

# ========== RULE 3: cat heredoc append/create to research files ==========
# H3 fix: only allow heredoc syntax (cat << 'EOF' or cat << EOF), not cat <file>
# Matches: cat << 'EOF' >> path/research_synthesis.md
#          cat << 'SYNTHESIS_EOF' > path/research_synthesis_TASK-1.1.md
if echo "$CMD" | grep -qE "^cat << '?[A-Za-z_]+' >> (.+/)?(${RESEARCH_FILES})$"; then
  local_target=$(echo "$CMD" | grep -oE '>> .+$' | sed 's/^>> //')
  path_ok "$local_target" && allow
fi
if echo "$CMD" | grep -qE "^cat << '?[A-Za-z_]+' > (.+/)?(research_synthesis[^/]*\.md|research_narrator_summary\.md)$"; then
  local_target=$(echo "$CMD" | grep -oE '> .+$' | sed 's/^> //')
  path_ok "$local_target" && allow
fi

# ========== RULE 4: mkdir -p for research project folders ==========
# H4 fix: workspace containment enforced
if echo "$CMD" | grep -qE "^mkdir -p (.+/)?[a-z0-9][-a-z0-9]*-[0-9]{4}-[0-9]{2}-[0-9]{2}[a-z0-9/-]*$"; then
  local_target=$(echo "$CMD" | sed 's/^mkdir -p //')
  path_ok "$local_target" && allow
fi

# ========== RULE 5: rm temp synthesis files after merge ==========
if echo "$CMD" | grep -qE "^rm (.+/)?research_synthesis_TASK-[A-Za-z0-9._-]+\.md$"; then
  local_target=$(echo "$CMD" | sed 's/^rm //')
  path_ok "$local_target" && allow
fi

# ========== RULE 6: mv synthesis merge ==========
if echo "$CMD" | grep -qE "^mv (.+/)?research_synthesis_merged\.md (.+/)?research_synthesis\.md$"; then
  allow
fi

# ========== RULE 7: sed substitution on research files ==========
# Only single-quoted s/// command, no -e, no chaining
if echo "$CMD" | grep -qE "^sed -i 's/[^']+/[^']*/' (.+/)?(${ALL_FILES})$"; then
  local_target=$(echo "$CMD" | grep -oE "[^ ]+$")
  path_ok "$local_target" && allow
fi

# ========== RULE 8: read-only operations (stat/ls/wc/tail) ==========
if echo "$CMD" | grep -qE "^(stat|ls|wc) (-[a-zA-Z]+ )*(.+/)?(${ALL_FILES})$"; then
  allow
fi
if echo "$CMD" | grep -qE "^tail (-[a-zA-Z0-9]+ )*(.+/)?(${ALL_FILES})$"; then
  allow
fi

# No match — pass through to Claude Code's normal permission handling
exit 0
