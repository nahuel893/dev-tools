# 📦 AI Agent Configuration Snapshots

This directory contains versioned snapshots of AI coding agent configurations, harnesses, subagents, and extensions.

---

## 📂 Structure

```
configs/
├── gentle-ai/
│   └── state.json                 # Global Gentle-AI installation state, preset, TDD, and components
├── gentle-pi/
│   ├── persona.json               # Persona settings ("gentleman" mode)
│   ├── background-subagents.json  # Background subagent policy
│   ├── subagents.json             # Subagent default models, profiles, and reasoning effort
│   ├── managed-assets.json        # Gentle-Pi managed asset manifests
│   ├── chains/                    # Reusable workflow chains (sdd-full, sdd-plan, 4r-review, etc.)
│   └── agents/                    # Subagent definitions (sdd-*, review-*, jd-*, etc.)
└── pi/
    ├── settings.json              # Pi core configuration: theme, TUI mode, package list
    ├── mcp.json                   # Configured MCP servers (CodeGraph, Context7, Engram)
    ├── extensions.json            # Installed Pi extensions manifest with descriptions
    └── npm/
        ├── package.json           # Extension dependency manifest
        ├── package-lock.json      # Locked extension versions
        └── package-core.json      # Core Pi package definition
```

---

## 🧩 Installed Pi Extensions

| Extension | Version | Description |
| :--- | :--- | :--- |
| `pi-claude-bridge` | `^0.7.0` | Bridge connecting Pi agent with Claude CLI and model routing |
| `gentle-pi` | `^2.5.0` | Gentle-AI harness for Pi: SDD workflows, memory, subagent orchestration |
| `gentle-engram` | `^0.1.11` | Engram persistent memory integration for Pi |
| `@juicesharp/rpiv-ask-user-question` | `^2.9.0` | Interactive question and multiple-choice prompt UI tool |
| `pi-web-access` | `^0.28.0` | Web search and URL content fetching tools |
| `pi-btw` | `^0.4.1` | Sidecar assistance and context injection |
| `@estebanforge/pi-antigravity-bridge` | `^1.4.10` | Bridge connecting Pi with Google Antigravity CLI and subagents |
| `pi-mcp-adapter` | `^2.32.1` | Model Context Protocol (MCP) server adapter for Pi |

---

## 🔄 Refreshing Snapshots

To take a fresh snapshot of the current workstation configuration:

```bash
./scripts/snapshot-ai-configs.sh
```

---

## 🛡️ Security & Privacy

All snapshots in this directory are sanitized:
- **Zero API keys, bearer tokens, or secrets** are stored.
- Private session transcripts (`~/.pi/agent/sessions/`) and credential stores (`auth.json`, `models-store.json`) are excluded.
