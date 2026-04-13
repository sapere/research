#!/usr/bin/env bash
# docker-entrypoint.sh — copies auth credentials with correct permissions
# then runs claude as the researcher user.
set -e

# Copy auth files if mounted (read-only mount may have wrong ownership)
if [ -f /tmp/claude-auth/credentials.json ]; then
  mkdir -p /home/researcher/.claude
  cp /tmp/claude-auth/credentials.json /home/researcher/.claude/.credentials.json
  chown -R researcher:researcher /home/researcher/.claude
fi
if [ -f /tmp/claude-auth/claude.json ]; then
  cp /tmp/claude-auth/claude.json /home/researcher/.claude.json
  chown researcher:researcher /home/researcher/.claude.json
fi

# Drop to researcher and run claude with safe argument forwarding
exec su researcher -s /bin/bash - -c 'cd /home/researcher/research && exec claude --dangerously-skip-permissions -p "$@"' -- "$@"
