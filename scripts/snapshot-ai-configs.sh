#!/usr/bin/env bash
# ==============================================================================
# snapshot-ai-configs.sh
# Snapshots AI configs (gentle-ai, gentle-pi, pi, extensions) into dev-tools repo.
# ==============================================================================
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIGS_DIR="$REPO_ROOT/configs"

CLR_CYAN="\033[0;36m"
CLR_GREEN="\033[0;32m"
CLR_YELLOW="\033[0;33m"
CLR_RESET="\033[0m"

echo -e "${CLR_CYAN}📸 Snapshotting AI agent configurations into dev-tools...${CLR_RESET}"

# 1. Gentle-AI
echo -e "  → Backing up Gentle-AI configuration..."
mkdir -p "$CONFIGS_DIR/gentle-ai"
if [ -f "$HOME/.gentle-ai/state.json" ]; then
    cp -p "$HOME/.gentle-ai/state.json" "$CONFIGS_DIR/gentle-ai/state.json"
fi

# 2. Gentle-Pi
echo -e "  → Backing up Gentle-Pi configuration, agents, and chains..."
mkdir -p "$CONFIGS_DIR/gentle-pi/agents" "$CONFIGS_DIR/gentle-pi/chains"
if [ -f "$HOME/.pi/gentle-ai/persona.json" ]; then
    cp -p "$HOME/.pi/gentle-ai/persona.json" "$CONFIGS_DIR/gentle-pi/persona.json"
fi
if [ -f "$HOME/.pi/gentle-ai/background-subagents.json" ]; then
    cp -p "$HOME/.pi/gentle-ai/background-subagents.json" "$CONFIGS_DIR/gentle-pi/background-subagents.json"
fi
if [ -f "$HOME/.pi/agent/subagents.json" ]; then
    cp -p "$HOME/.pi/agent/subagents.json" "$CONFIGS_DIR/gentle-pi/subagents.json"
fi
if [ -f "$HOME/.pi/agent/gentle-ai/managed-assets.json" ]; then
    cp -p "$HOME/.pi/agent/gentle-ai/managed-assets.json" "$CONFIGS_DIR/gentle-pi/managed-assets.json"
fi
if compgen -G "$HOME/.pi/agent/chains/*.chain.md" > /dev/null; then
    cp -p "$HOME/.pi/agent/chains/"*.chain.md "$CONFIGS_DIR/gentle-pi/chains/"
fi
if compgen -G "$HOME/.pi/agent/agents/*.md" > /dev/null; then
    cp -p "$HOME/.pi/agent/agents/"*.md "$CONFIGS_DIR/gentle-pi/agents/"
fi

# 3. Pi & Extensions
echo -e "  → Backing up Pi core settings, MCP configuration, and extensions..."
mkdir -p "$CONFIGS_DIR/pi/npm"
if [ -f "$HOME/.pi/agent/settings.json" ]; then
    cp -p "$HOME/.pi/agent/settings.json" "$CONFIGS_DIR/pi/settings.json"
fi
if [ -f "$HOME/.pi/agent/mcp.json" ]; then
    cp -p "$HOME/.pi/agent/mcp.json" "$CONFIGS_DIR/pi/mcp.json"
fi
if [ -f "$HOME/.pi/agent/claude-bridge.json" ]; then
    cp -p "$HOME/.pi/agent/claude-bridge.json" "$CONFIGS_DIR/pi/claude-bridge.json"
fi
if [ -f "$HOME/.pi/agent/npm/package.json" ]; then
    cp -p "$HOME/.pi/agent/npm/package.json" "$CONFIGS_DIR/pi/npm/package.json"
fi
if [ -f "$HOME/.pi/agent/npm/package-lock.json" ]; then
    cp -p "$HOME/.pi/agent/npm/package-lock.json" "$CONFIGS_DIR/pi/npm/package-lock.json"
fi
if [ -f "$HOME/.pi/npm/package.json" ]; then
    cp -p "$HOME/.pi/npm/package.json" "$CONFIGS_DIR/pi/npm/package-core.json"
fi

cat << 'EXTEOF' > "$CONFIGS_DIR/pi/extensions.json"
{
  "packages": [
    {
      "name": "pi-claude-auth",
      "spec": "npm:pi-claude-auth@latest",
      "version": "^0.1.3",
      "description": "Reuses your Claude Code credentials in Pi, so no separate login is needed"
    },
    {
      "name": "pi-claude-bridge",
      "spec": "npm:pi-claude-bridge",
      "version": "^0.7.0",
      "description": "Bridge connecting Pi agent with Claude CLI and model routing"
    },
    {
      "name": "gentle-pi",
      "spec": "npm:gentle-pi@latest",
      "version": "^2.5.0",
      "description": "Gentle-AI harness for Pi: SDD workflows, memory, subagent orchestration"
    },
    {
      "name": "gentle-engram",
      "spec": "npm:gentle-engram@0.1.11",
      "version": "^0.1.11",
      "description": "Engram persistent memory integration for Pi"
    },
    {
      "name": "@juicesharp/rpiv-ask-user-question",
      "spec": "npm:@juicesharp/rpiv-ask-user-question",
      "version": "^2.9.0",
      "description": "Interactive question and multiple-choice prompt UI tool"
    },
    {
      "name": "pi-web-access",
      "spec": "npm:pi-web-access",
      "version": "^0.28.0",
      "description": "Web search and URL content fetching tools"
    },
    {
      "name": "pi-btw",
      "spec": "npm:pi-btw",
      "version": "^0.4.1",
      "description": "Sidecar assistance and context injection"
    },
    {
      "name": "@estebanforge/pi-antigravity-bridge",
      "spec": "npm:@estebanforge/pi-antigravity-bridge",
      "version": "^1.4.10",
      "description": "Bridge connecting Pi with Google Antigravity CLI and subagents"
    },
    {
      "name": "pi-mcp-adapter",
      "spec": "npm:pi-mcp-adapter",
      "version": "^2.32.1",
      "description": "Model Context Protocol (MCP) server adapter for Pi"
    }
  ]
}
EXTEOF

echo -e "${CLR_GREEN}✓ AI configurations successfully snapshotted into $CONFIGS_DIR${CLR_RESET}"
