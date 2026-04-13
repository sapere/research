FROM node:20-slim AS base

# System dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    jq \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Playwright MCP and browser engines
RUN npx @playwright/mcp@latest --help 2>/dev/null || true
RUN npx playwright install --with-deps chromium

# Create non-root user and workspace
RUN useradd -m -s /bin/bash researcher
RUN mkdir -p /home/researcher/research/research-results \
    && chown -R researcher:researcher /home/researcher/research
USER researcher
WORKDIR /home/researcher/research

# Copy repo files (agents, instructions, skills, hooks, settings)
COPY --chown=researcher:researcher agents/ agents/
COPY --chown=researcher:researcher instructions/ instructions/
COPY --chown=researcher:researcher skills/ skills/
COPY --chown=researcher:researcher .claude/ .claude/
COPY --chown=researcher:researcher CLAUDE.md .
COPY --chown=researcher:researcher README.md .
COPY --chown=researcher:researcher .gitignore .

VOLUME /home/researcher/research/research-results

# ---------- Claude Code (Anthropic subscription or API key) ----------
FROM base AS claude

USER root
RUN npm install -g @anthropic-ai/claude-code
USER researcher

# Register Playwright MCP at project scope (not user scope).
# User-scope config (~/.claude.json) gets overwritten by the runtime auth mount.
# Project-scope config (.claude.json in WORKDIR) persists independently.
RUN claude mcp add --scope project playwright -- npx @playwright/mcp@latest 2>/dev/null || true

# Mount host ~/.claude/ read-only at runtime for subscription auth tokens.
# Docker provides the sandbox — --dangerously-skip-permissions is safe here.
VOLUME /home/researcher/.claude

ENTRYPOINT ["claude", "--dangerously-skip-permissions", "-p"]
CMD ["@Research Coordinator what is this repo about"]

# ---------- OpenCode (local LLMs via Ollama, or remote APIs) ----------
FROM base AS opencode

# Install OpenCode CLI to /usr/local/bin (accessible to all users)
USER root
RUN curl -fsSL https://opencode.ai/install | BINDIR=/usr/local/bin bash \
    && opencode --version
USER researcher

# Configure: set model per agent in opencode.json or env vars.
# See instructions/model-strategy.instructions.md for tier mapping:
#   REASONING tier (Coordinator, Planner): qwen3:32b / llama3.3:70b
#   EXECUTION tier (Worker, Reviewer):     qwen3:8b / llama3.1:8b
#
# Connect to Ollama on host: --network host or OLLAMA_HOST=http://host.docker.internal:11434

ENTRYPOINT ["opencode"]
CMD ["--help"]
