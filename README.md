# 🤖 AI Agent CLI Installer

An elegant, interactive, and robust terminal installation assistant designed to deploy, configure, and manage the most powerful AI coding agents and development harnesses on Linux and macOS.

```
┌────────────────────────────────────────────────────────┐
│             🤖  AI AGENT CLI INSTALLER  🤖             │
└────────────────────────────────────────────────────────┘
```

---

## ✨ Features

- 🎨 **Visual Terminal Interface**: Beautiful ANSI-styled console layouts, bold headers, and micro-styled status markers.
- ⠋ **Polished Loading Indicators**: Dynamic braille spinners displaying live progress during agent downloads and installations.
- 🧠 **Automated Gentle-AI Setup**: Dynamically configures Gentle-AI memory harnesses, SDD presets, and persona templates for all selected agents post-installation.
- ⚙️ **Automatic Dependency Checks**: Automatic diagnostics for prerequisites like `curl`, `git`, `npm`, and `pipx`.
- 🕹️ **Interactive Selection Menu**: arrow-key TUI selector — **↑/↓** (or j/k) to move, **SPACE** to toggle a checkbox, **ENTER** to install.
- 🤖 **Non-interactive / Headless Mode**: Full support for flags (e.g. `--yes`, `--all`) to allow seamless automation, scripting, and CI/CD pipelines.
- 🔍 **Safe Simulated Executions**: Support for `--dry-run` to inspect commands before executing changes on your system.

---

## 🚀 Supported Agents & Tools

| Agent / Tool | Binary Name | Description | Installation Method |
| :--- | :--- | :--- | :--- |
| **Claude Code** | `claude` | Anthropic's official high-speed agentic coder | `curl` native script |
| **Antigravity CLI** | `agy` | Google's advanced terminal agent (asynchronous subagents) | `curl` native script |
| **OpenCode** | `opencode` | Open-source, provider-agnostic TUI coding agent | `curl` native script |
| **Gentle-AI** | `gentle-ai` | SDD orchestrator, agent memory harness & curated skills | GitHub script |
| **Qwen Code** | `qwen` | Qwen's official CLI coding agent | Curl installation script |
| **Pi Coding Agent** | `pi` | Minimalist open-source CLI coding agent | Curl installation script |
| **Aider** | `aider` | High-fidelity terminal pair-programming coder | Curl installation script |
| **Open Interpreter**| `interpreter`| Conversational CLI for running local machine code | `pipx` / `pip3` |
| **Gentle-Pi** | `pi` | Gentle-AI harness (SDD, memory & curated skills) for the Pi agent | `pi install` package (requires Pi) |
| **Dotfiles** | `—` | Clone & symlink the nahuel893/dotfiles rice (sway, kitty, ghostty, themes) | `git clone` + repo `install.sh` |

---

## 🛠️ Usage Instructions

Clone this repository and navigate to the directory:

```bash
git clone https://github.com/nahuel/ai-stack.git
cd ai-stack
```

Ensure the installer script is executable:

```bash
chmod +x install.sh
```

### 1. Interactive Mode (Recommended)
Simply execute the installer script without arguments. It will launch a beautiful TUI menu:

```bash
./install.sh
```

Navigate the menu with the **arrow keys** (or `j`/`k`), toggle a checkbox with **SPACE**, and start the install with **ENTER**. `a` toggles every row, `i` toggles the default set, `d` runs a dependency check, and `q` quits without changes.

### 2. Non-interactive Mode (Automated)
To install the **default recommended agents** (Claude Code, agy, OpenCode, Gentle-AI, Qwen Code, and Pi) silently:

```bash
./install.sh --yes
```

To install **all available tools** (including Aider, Open Interpreter, Gentle-Pi, and the dotfiles):

```bash
./install.sh --all
```

To target a **specific combination of tools**:

```bash
./install.sh --claude --gentle-ai
```

### 3. Dry-Run Verification
To simulate the installation flow and inspect the exact commands that would be executed on your machine:

```bash
./install.sh --yes --dry-run
```

---

## 🏁 Quick Start & Authentication

Once installed, use the following commands to authenticate and begin using each tool:

### 1. Claude Code
Initialize and connect your Anthropic account:
```bash
claude auth login
```
*Note: Requires an active Claude Pro/Team subscription or Anthropic Console API credit.*

### 2. Antigravity CLI (agy)
Run to trigger the Google Sign-in authentication flow:
```bash
agy
```

### 3. OpenCode
Start the terminal interface and log in:
```bash
opencode auth login
```

### 4. Gentle-AI
Inject spec-driven development configurations, skills, and memory optimizations:
```bash
# Launch interactive TUI configuration
gentle-ai

# Or install configurations non-interactively
gentle-ai install --agent claude-code,opencode
```

### 5. Qwen Code
Launch the Qwen CLI agent:
```bash
qwen
```
*Note: Follow the on-screen configuration prompts during the first startup.*

### 6. Pi Coding Agent
Launch the Pi CLI agent:
```bash
pi
```
*Note: Run `pi` inside any project directory to initialize an agentic session.*

### 7. Aider
Export your API key and start coding:
```bash
export ANTHROPIC_API_KEY="your-key-here"
aider
```

### 8. Open Interpreter
Run locally to execute code:
```bash
interpreter
```

### 9. Gentle-Pi
The Gentle-AI harness for the **Pi** agent (requires Pi to be installed first). It ships as a Pi package:
```bash
pi install npm:gentle-pi@latest
```
Then launch Pi inside any repository and bootstrap Spec-Driven Development once per project:
```bash
pi
# inside Pi:
/gentle-sdd-init
```

### 10. Dotfiles
Clones **nahuel893/dotfiles** to `~/dotfiles` (or pulls if it already exists) and runs the repo's own `install.sh`, which symlinks the configs into `~/.config` — backing up any existing real files to `<file>.bak` first.
```bash
# select it: menu checkbox, or
./install.sh --dotfiles
# re-link anytime:
bash ~/dotfiles/install.sh
```

---

> [!TIP]
> **Automated Workflow:** The installer will automatically offer to configure Gentle-AI for you upon successful completion! In non-interactive mode (using `--yes` or `--all`), this step is entirely automated, injecting the `full-gentleman` SDD presets directly into your installed agents (like Claude Code and OpenCode) without requiring manual setup.

Enjoy building with your new suite of AI coding agents! 🚀
