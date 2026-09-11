#!/usr/bin/env bash

# ==============================================================================
#                  🤖  AI AGENT CLI INSTALLER  🤖
# ==============================================================================
# A beautiful, interactive, and robust script to install leading AI CLI agents.
# Supporting: Claude Code, Antigravity CLI (agy), OpenCode, Gentle-AI, Qwen Code, Pi Coding Agent (pi), and others.
# ==============================================================================

set -euo pipefail

# --- Color Definitions (ANSI Escape Sequences) ---
CLR_ESC="\e["
CLR_RESET="${CLR_ESC}0m"
CLR_BOLD="${CLR_ESC}1m"
CLR_DIM="${CLR_ESC}2m"
CLR_ITALIC="${CLR_ESC}3m"
CLR_UNDERLINE="${CLR_ESC}4m"

# Palette
CLR_PRIMARY="${CLR_ESC}38;5;141m"   # Soft Purple
CLR_ACCENT="${CLR_ESC}38;5;39m"     # Bright Blue
CLR_SUCCESS="${CLR_ESC}38;5;82m"    # Vibrant Green
CLR_WARNING="${CLR_ESC}38;5;214m"   # Amber/Orange
CLR_ERROR="${CLR_ESC}38;5;196m"     # Red
CLR_RED="${CLR_ESC}38;5;196m"       # Red (Alias)
CLR_INFO="${CLR_ESC}38;5;51m"       # Cyan
CLR_CYAN="${CLR_ESC}38;5;51m"       # Cyan (quick-start command hints)
CLR_MUTED="${CLR_ESC}38;5;244m"     # Gray

# --- Icons ---
ICON_SUCCESS="${CLR_SUCCESS}✔${CLR_RESET}"
ICON_ERROR="${CLR_ERROR}✖${CLR_RESET}"
ICON_WARNING="${CLR_WARNING}⚠${CLR_RESET}"
ICON_INFO="${CLR_INFO}ℹ${CLR_RESET}"
ICON_PROMPT="${CLR_PRIMARY}➜${CLR_RESET}"
ICON_BULLET="${CLR_ACCENT}•${CLR_RESET}"

# --- State Variables ---
DRY_RUN=false
NON_INTERACTIVE=false
INSTALL_ALL=false

# Default selections
CHOSEN_CLAUDE=true
CHOSEN_AGY=true
CHOSEN_OPENCODE=true
CHOSEN_GENTLE_AI=true
CHOSEN_QWEN=true
CHOSEN_PI=true
CHOSEN_AIDER=false
CHOSEN_INTERPRETER=false
CHOSEN_GENTLE_PI=false
CHOSEN_DOTFILES=false
CHOSEN_PI_EXTENSIONS=false

# Pi extension manifest. Resolved next to this script when it was cloned, and
# fetched from the repo when the script is piped straight from curl.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd || echo "$PWD")"
PI_EXTENSIONS_FILE="$SCRIPT_DIR/configs/pi/extensions.json"
PI_EXTENSIONS_URL="https://raw.githubusercontent.com/nahuel893/dev-tools/main/configs/pi/extensions.json"

# --- Logging Helpers ---
log_header() {
    echo -e "\n${CLR_BOLD}${CLR_PRIMARY}┌────────────────────────────────────────────────────────┐${CLR_RESET}"
    echo -e "${CLR_BOLD}${CLR_PRIMARY}│             🤖  AI AGENT CLI INSTALLER  🤖             │${CLR_RESET}"
    echo -e "${CLR_BOLD}${CLR_PRIMARY}└────────────────────────────────────────────────────────┘${CLR_RESET}\n"
}

log_info() {
    echo -e " ${ICON_INFO} ${CLR_BOLD}${CLR_INFO}Info:${CLR_RESET} $1"
}

log_success() {
    echo -e " ${ICON_SUCCESS} ${CLR_BOLD}${CLR_SUCCESS}Success:${CLR_RESET} $1"
}

log_warning() {
    echo -e " ${ICON_WARNING} ${CLR_BOLD}${CLR_WARNING}Warning:${CLR_RESET} $1"
}

log_error() {
    echo -e " ${ICON_ERROR} ${CLR_BOLD}${CLR_ERROR}Error:${CLR_RESET} $1" >&2
}

log_step() {
    echo -e "\n${CLR_BOLD}${CLR_ACCENT}❯ $1${CLR_RESET}"
}

log_bullet() {
    echo -e "   ${ICON_BULLET} $1"
}

# --- Spinner Helper ---
run_with_spinner() {
    local message="$1"
    shift
    local cmd=("$@")

    if [ "$DRY_RUN" = true ]; then
        echo -e "  ${CLR_MUTED}[Dry-Run] Would run: ${cmd[*]}${CLR_RESET}"
        return 0
    fi

    # Run the command in the background, redirecting stdout/stderr to a temporary file
    local tmp_log
    tmp_log=$(mktemp)
    
    # Start the command
    "${cmd[@]}" > "$tmp_log" 2>&1 &
    local pid=$!

    # Spinner animation
    local spin=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
    local delay=0.08
    
    while kill -0 "$pid" 2>/dev/null; do
        for i in "${spin[@]}"; do
            printf "\r  ${CLR_PRIMARY}%s${CLR_RESET} %s..." "$i" "$message"
            sleep "$delay"
            if ! kill -0 "$pid" 2>/dev/null; then
                break
            fi
        done
    done

    # Get the exit code
    wait "$pid" && local exit_code=0 || local exit_code=$?
    
    # Clear the spinner line
    printf "\r\033[K"

    if [ "$exit_code" -eq 0 ]; then
        log_success "$message completed successfully."
        rm -f "$tmp_log"
        return 0
    else
        log_error "$message failed (Exit code: $exit_code)."
        echo -e "${CLR_RED}----- Command Output -----${CLR_RESET}"
        cat "$tmp_log"
        echo -e "${CLR_RED}--------------------------${CLR_RESET}"
        rm -f "$tmp_log"
        return "$exit_code"
    fi
}

# --- Show Help ---
show_help() {
    echo -e "${CLR_BOLD}AI Agent CLI Installer${CLR_RESET}"
    echo -e "Usage: ./install.sh [options]\n"
    echo -e "Options:"
    echo -e "  -y, --yes          Non-interactive mode, installs core agents (Claude, agy, OpenCode, Gentle-AI, Qwen Code, Pi)"
    echo -e "  -a, --all          Non-interactive mode, installs all available agents/tools"
    echo -e "  --claude           Select Claude Code for installation"
    echo -e "  --agy              Select Antigravity CLI (agy) for installation"
    echo -e "  --opencode         Select OpenCode for installation"
    echo -e "  --gentle-ai        Select Gentle-AI for installation"
    echo -e "  --qwen             Select Qwen Code for installation"
    echo -e "  --pi               Select Pi Coding Agent for installation"
    echo -e "  --aider            Select Aider for installation"
    echo -e "  --interpreter      Select Open Interpreter for installation"
    echo -e "  --gentle-pi        Select Gentle-Pi (Gentle-AI harness for the Pi agent) for installation"
    echo -e "  --pi-extensions    Restore every Pi extension listed in configs/pi/extensions.json"
    echo -e "  --dotfiles         Clone and symlink the nahuel893/dotfiles rice (runs its install.sh)"
    echo -e "  --dry-run          Run script in dry-run mode, printing actions without executing them"
    echo -e "  -h, --help         Display this help message and exit"
    echo -e "\nIf no flags are provided, the script runs in interactive mode."
}

# --- Parse Arguments ---
parse_args() {
    # If arguments are provided, default all selections to false unless specified
    if [ "$#" -gt 0 ]; then
        # Check if only dry-run is specified
        local has_selection_flag=false
        for arg in "$@"; do
            if [[ "$arg" =~ ^--(claude|agy|opencode|gentle-ai|qwen|pi|aider|interpreter|gentle-pi|pi-extensions|dotfiles)$ ]] || [ "$arg" = "-a" ] || [ "$arg" = "--all" ] || [ "$arg" = "-y" ] || [ "$arg" = "--yes" ]; then
                has_selection_flag=true
                break
            fi
        done
        
        if [ "$has_selection_flag" = true ]; then
            CHOSEN_CLAUDE=false
            CHOSEN_AGY=false
            CHOSEN_OPENCODE=false
            CHOSEN_GENTLE_AI=false
            CHOSEN_QWEN=false
            CHOSEN_PI=false
            CHOSEN_AIDER=false
            CHOSEN_INTERPRETER=false
            CHOSEN_GENTLE_PI=false
            CHOSEN_DOTFILES=false
            CHOSEN_PI_EXTENSIONS=false
        fi
    fi

    while [ "$#" -gt 0 ]; do
        case "$1" in
            -y|--yes)
                NON_INTERACTIVE=true
                CHOSEN_CLAUDE=true
                CHOSEN_AGY=true
                CHOSEN_OPENCODE=true
                CHOSEN_GENTLE_AI=true
                CHOSEN_QWEN=true
                CHOSEN_PI=true
                shift
                ;;
            -a|--all)
                NON_INTERACTIVE=true
                INSTALL_ALL=true
                CHOSEN_CLAUDE=true
                CHOSEN_AGY=true
                CHOSEN_OPENCODE=true
                CHOSEN_GENTLE_AI=true
                CHOSEN_QWEN=true
                CHOSEN_PI=true
                CHOSEN_AIDER=true
                CHOSEN_INTERPRETER=true
                CHOSEN_GENTLE_PI=true
                CHOSEN_DOTFILES=true
                CHOSEN_PI_EXTENSIONS=true
                shift
                ;;
            --claude)
                NON_INTERACTIVE=true
                CHOSEN_CLAUDE=true
                shift
                ;;
            --agy)
                NON_INTERACTIVE=true
                CHOSEN_AGY=true
                shift
                ;;
            --opencode)
                NON_INTERACTIVE=true
                CHOSEN_OPENCODE=true
                shift
                ;;
            --gentle-ai)
                NON_INTERACTIVE=true
                CHOSEN_GENTLE_AI=true
                shift
                ;;
            --qwen)
                NON_INTERACTIVE=true
                CHOSEN_QWEN=true
                shift
                ;;
            --pi)
                NON_INTERACTIVE=true
                CHOSEN_PI=true
                shift
                ;;
            --aider)
                NON_INTERACTIVE=true
                CHOSEN_AIDER=true
                shift
                ;;
            --interpreter)
                NON_INTERACTIVE=true
                CHOSEN_INTERPRETER=true
                shift
                ;;
            --gentle-pi)
                NON_INTERACTIVE=true
                CHOSEN_GENTLE_PI=true
                shift
                ;;
            --pi-extensions)
                NON_INTERACTIVE=true
                CHOSEN_PI_EXTENSIONS=true
                shift
                ;;
            --dotfiles)
                NON_INTERACTIVE=true
                CHOSEN_DOTFILES=true
                shift
                ;;
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

# --- Verify System Prerequisites ---
check_prerequisites() {
    log_step "Checking System Prerequisites"
    
    local missing_deps=()
    
    # Essential dependencies
    for dep in curl git; do
        if ! command -v "$dep" &>/dev/null; then
            missing_deps+=("$dep")
        fi
    done
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        log_error "Missing essential tools: ${missing_deps[*]}"
        log_info "Please install them before running this script again."
        log_info "On Debian/Ubuntu: sudo apt update && sudo apt install -y ${missing_deps[*]}"
        exit 1
    else
        log_success "All essential tools (curl, git) are available."
    fi

    # Check for package managers if Aider or Interpreter are chosen
    if [ "$CHOSEN_AIDER" = true ] || [ "$CHOSEN_INTERPRETER" = true ]; then
        if ! command -v pipx &>/dev/null; then
            log_warning "pipx is required to install python-based agents (Aider / Open Interpreter)."
            log_info "We will attempt to use 'pip' if 'pipx' is unavailable, but pipx is highly recommended."
            
            if ! command -v pip3 &>/dev/null && ! command -v pip &>/dev/null; then
                log_error "Neither pipx nor pip is installed. Cannot install python-based agents."
                log_info "To install pipx on Debian/Ubuntu: sudo apt install -y pipx && pipx ensurepath"
                log_info "Alternatively, deselect Aider and Open Interpreter."
                
                if [ "$NON_INTERACTIVE" = true ]; then
                    log_error "Exiting due to missing dependencies in non-interactive mode."
                    exit 1
                else
                    echo -e "\nPress ENTER to return to the menu..."
                    read -r _
                    return 1
                fi
            fi
        fi
    fi
    
    return 0
}

# --- Interactive Selector Menu (arrow keys + space to toggle) ---
interactive_menu() {
    # Data-driven rows: each entry is the name of its CHOSEN_* variable.
    local -a keys=(
        CHOSEN_CLAUDE CHOSEN_AGY CHOSEN_OPENCODE CHOSEN_GENTLE_AI CHOSEN_QWEN
        CHOSEN_PI CHOSEN_GENTLE_PI CHOSEN_PI_EXTENSIONS CHOSEN_AIDER CHOSEN_INTERPRETER
        CHOSEN_DOTFILES
    )
    local -a labels=(
        "Claude Code" "Antigravity CLI (agy)" "OpenCode" "Gentle-AI" "Qwen Code"
        "Pi Coding Agent" "Gentle-Pi" "Pi Extensions" "Aider" "Open Interpreter"
        "Dotfiles"
    )
    local -a descs=(
        "Anthropic's official terminal agent"
        "Google's terminal agent"
        "Open-source provider-agnostic agent"
        "AI harness, SDD configurator & memory booster"
        "Qwen's official CLI coding agent"
        "Minimalist open-source coding agent"
        "Gentle-AI harness for the Pi agent - requires Pi"
        "Every extension in configs/pi/extensions.json - requires Pi"
        "Coding pair programmer - requires pipx"
        "Local code runner - requires pipx"
        "Clone & symlink nahuel893/dotfiles (backs up existing configs)"
    )
    local -a defaults=(CHOSEN_CLAUDE CHOSEN_AGY CHOSEN_OPENCODE CHOSEN_GENTLE_AI CHOSEN_QWEN CHOSEN_PI)
    local n=${#keys[@]}
    local sel=0 key rest kk val box i any allsel nv

    printf '\e[?25l'                    # hide cursor
    trap 'printf "\e[?25h"' RETURN      # restore cursor when the function returns
    trap 'printf "\e[?25h"' EXIT        # ...and on any exit path (Ctrl-C, exit 1 from a check)

    while true; do
        clear
        log_header
        echo -e "${CLR_BOLD}Select agents / tools to install${CLR_RESET}"
        echo -e "${CLR_MUTED}  ↑/↓ (or j/k) move · SPACE toggle · a all · i defaults · d deps · ENTER install · q quit${CLR_RESET}\n"

        for (( i = 0; i < n; i++ )); do
            kk="${keys[$i]}"; val="${!kk}"
            if [ "$val" = true ]; then box="[${CLR_SUCCESS}✔${CLR_RESET}]"; else box="[ ]"; fi
            if [ "$i" -eq "$sel" ]; then
                echo -e "  ${CLR_PRIMARY}${CLR_BOLD}❯${CLR_RESET} $box ${CLR_BOLD}${labels[$i]}${CLR_RESET}  ${CLR_MUTED}${descs[$i]}${CLR_RESET}"
            else
                echo -e "    $box ${labels[$i]}  ${CLR_MUTED}${descs[$i]}${CLR_RESET}"
            fi
        done
        echo -e "\n  ${CLR_BOLD}${CLR_SUCCESS}[ENTER] proceed with installation${CLR_RESET}     ${CLR_ERROR}[q] quit${CLR_RESET}"

        # Read one keystroke; decode arrow-key escape sequences (\e[A / \e[B).
        # EOF (stdin closed or not a terminal): fail closed. Otherwise the empty
        # key would be treated as ENTER and install the defaults unattended.
        if ! IFS= read -rsn1 key; then
            log_error "No keyboard input available (stdin closed). Re-run in a terminal, or use --yes / explicit flags."
            exit 1
        fi
        if [ "$key" = $'\e' ]; then
            read -rsn2 -t 0.005 rest || true
            key+="$rest"
        fi

        case "$key" in
            $'\e[A'|k|K) sel=$(( (sel - 1 + n) % n )) ;;   # up
            $'\e[B'|j|J) sel=$(( (sel + 1) % n )) ;;        # down
            ' ')                                            # toggle current row
                kk="${keys[$sel]}"
                if [ "${!kk}" = true ]; then printf -v "$kk" 'false'; else printf -v "$kk" 'true'; fi
                ;;
            a|A)                                            # toggle every row
                allsel=true
                for kk in "${keys[@]}"; do [ "${!kk}" = true ] || { allsel=false; break; }; done
                nv=true; [ "$allsel" = true ] && nv=false
                for kk in "${keys[@]}"; do printf -v "$kk" "$nv"; done
                ;;
            i|I)                                            # toggle the default set
                allsel=true
                for kk in "${defaults[@]}"; do [ "${!kk}" = true ] || { allsel=false; break; }; done
                nv=true; [ "$allsel" = true ] && nv=false
                for kk in "${defaults[@]}"; do printf -v "$kk" "$nv"; done
                ;;
            d|D)                                            # run dependency check
                printf '\e[?25h'
                set +e; check_prerequisites; set -e
                echo -e "\nPress ENTER to return..."; read -r _ || true
                printf '\e[?25l'
                ;;
            ''|$'\n'|$'\r')                                 # ENTER → proceed
                any=false
                for kk in "${keys[@]}"; do [ "${!kk}" = true ] && { any=true; break; }; done
                if [ "$any" = false ]; then
                    log_warning "No tools selected. Use SPACE to mark at least one."
                    sleep 1.5
                else
                    set +e
                    if check_prerequisites; then set -e; break; fi
                    set -e
                    echo -e "\nPress ENTER to return to the menu..."; read -r _ || true
                fi
                ;;
            q|Q)
                printf '\e[?25h'
                log_info "Exiting. No changes made."
                exit 0
                ;;
        esac
    done
}

# --- Installers ---
install_claude() {
    log_step "Installing Claude Code..."
    # The official script runs curl -fsSL https://claude.ai/install.sh | bash
    run_with_spinner "Downloading and executing Claude Code installer" bash -c "curl -fsSL https://claude.ai/install.sh | bash"
}

install_agy() {
    log_step "Installing Antigravity CLI (agy)..."
    # Canonical: curl -fsSL https://antigravity.google/cli/install.sh | bash
    run_with_spinner "Downloading and executing Antigravity CLI installer" bash -c "curl -fsSL https://antigravity.google/cli/install.sh | bash"
}

install_opencode() {
    log_step "Installing OpenCode..."
    # Canonical: curl -fsSL https://opencode.ai/install | bash
    run_with_spinner "Downloading and executing OpenCode installer" bash -c "curl -fsSL https://opencode.ai/install | bash"
}

install_gentle_ai() {
    log_step "Installing Gentle-AI..."
    # Canonical: curl -fsSL https://raw.githubusercontent.com/Gentleman-Programming/gentle-ai/main/scripts/install.sh | bash
    run_with_spinner "Downloading and executing Gentle-AI installer" bash -c "curl -fsSL https://raw.githubusercontent.com/Gentleman-Programming/gentle-ai/main/scripts/install.sh | bash"
}

install_qwen() {
    log_step "Installing Qwen Code..."
    # Canonical: bash -c "$(curl -fsSL https://qwen-code-assets.oss-cn-hangzhou.aliyuncs.com/installation/install-qwen.sh)" -s --source qwenchat
    run_with_spinner "Downloading and executing Qwen Code installer" bash -c 'bash -c "$(curl -fsSL https://qwen-code-assets.oss-cn-hangzhou.aliyuncs.com/installation/install-qwen.sh)" -s --source qwenchat'
}

install_pi() {
    log_step "Installing Pi Coding Agent..."
    # Canonical: curl -fsSL https://pi.dev/install.sh | sh
    run_with_spinner "Downloading and executing Pi Coding Agent installer" bash -c 'curl -fsSL https://pi.dev/install.sh | sh'
}

install_aider() {
    log_step "Installing Aider..."
    # Canonical: curl -LsSf https://aider.chat/install.sh | sh
    run_with_spinner "Downloading and executing Aider installer" bash -c "curl -LsSf https://aider.chat/install.sh | sh"
}

install_interpreter() {
    log_step "Installing Open Interpreter..."
    if command -v pipx &>/dev/null; then
        run_with_spinner "Installing Open Interpreter via pipx" pipx install open-interpreter
    else
        local pip_cmd="pip3"
        command -v pip &>/dev/null && pip_cmd="pip"
        run_with_spinner "Installing Open Interpreter via pip (user-level)" "$pip_cmd" install --user open-interpreter
    fi
}

install_gentle_pi() {
    log_step "Installing Gentle-Pi..."
    # gentle-pi ships as a Pi package: pi install npm:gentle-pi@latest (needs the Pi agent).
    hash -r
    if [ "$DRY_RUN" = false ] && ! command -v pi &>/dev/null; then
        log_error "Gentle-Pi requires the Pi agent, but 'pi' was not found in PATH."
        log_info "Select Pi as well (--pi / menu option 6) or install it first, then re-run with --gentle-pi."
        return 1
    fi
    run_with_spinner "Installing Gentle-Pi (pi install npm:gentle-pi@latest)" pi install npm:gentle-pi@latest
}

# Restores the Pi extensions captured by scripts/snapshot-ai-configs.sh.
# Before this existed the snapshot was write-only: the manifest was committed
# on every run and nothing ever read it back, so a fresh box got Pi and
# Gentle-Pi and silently missed the rest.
install_pi_extensions() {
    log_step "Restoring Pi extensions..."
    hash -r

    if [ "$DRY_RUN" = false ] && ! command -v pi &>/dev/null; then
        log_error "Pi extensions require the Pi agent, but 'pi' was not found in PATH."
        log_info "Select Pi as well (--pi / the Pi Coding Agent row) or install it first, then re-run with --pi-extensions."
        return 1
    fi

    # Cloned checkout first; fall back to the repo when piped from curl.
    local manifest="$PI_EXTENSIONS_FILE"
    local tmp_manifest=""
    if [ ! -f "$manifest" ]; then
        log_info "No local manifest at $manifest — fetching it from the repo."
        tmp_manifest="$(mktemp)"
        if ! curl -fsSL "$PI_EXTENSIONS_URL" -o "$tmp_manifest"; then
            rm -f "$tmp_manifest"
            log_error "Could not read the extension manifest, locally or from $PI_EXTENSIONS_URL."
            return 1
        fi
        manifest="$tmp_manifest"
    fi

    # jq when it is around, otherwise a plain text scan. The manifest is
    # generated with one "spec" per package, so the fallback is not a gamble.
    local specs
    if command -v jq &>/dev/null; then
        specs="$(jq -r '.packages[].spec' "$manifest" 2>/dev/null)"
    else
        specs="$(grep -o '"spec"[[:space:]]*:[[:space:]]*"[^"]*"' "$manifest" | cut -d'"' -f4)"
    fi
    [ -n "$tmp_manifest" ] && rm -f "$tmp_manifest"

    if [ -z "$specs" ]; then
        log_error "The extension manifest listed no packages."
        return 1
    fi

    local total failed=0 spec name
    total="$(printf '%s\n' "$specs" | wc -l | tr -d ' ')"
    log_info "Found $total extension(s) in the manifest."

    # Each extension installs on its own so one bad package cannot take the
    # rest down with it. pi install is idempotent, so re-running is harmless
    # and Gentle-Pi appearing here as well is not a conflict.
    while IFS= read -r spec; do
        [ -n "$spec" ] || continue
        name="${spec#npm:}"
        if ! run_with_spinner "Installing $name" pi install "$spec"; then
            log_warning "Failed to install $name — continuing with the rest."
            failed=$((failed + 1))
        fi
    done <<< "$specs"

    if [ "$failed" -gt 0 ]; then
        log_warning "$failed of $total extension(s) failed."
        return 1
    fi

    log_success "All $total Pi extension(s) restored."
    return 0
}

install_dotfiles() {
    log_step "Installing dotfiles (nahuel893/dotfiles)..."
    local dir="$HOME/dotfiles"
    if [ -d "$dir/.git" ]; then
        run_with_spinner "Updating existing dotfiles repo" git -C "$dir" pull --ff-only || return 1
    else
        run_with_spinner "Cloning nahuel893/dotfiles into $dir" git clone https://github.com/nahuel893/dotfiles "$dir" || return 1
    fi
    if [ "$DRY_RUN" = false ] && [ ! -f "$dir/install.sh" ]; then
        log_error "dotfiles install.sh not found at $dir; skipping symlink step."
        return 1
    fi
    # The repo's own install.sh symlinks configs into ~/.config (backing up any
    # existing real files to <file>.bak first).
    run_with_spinner "Linking dotfiles (running its install.sh)" bash "$dir/install.sh"
}

configure_gentle_ai() {
    if [ "$DRY_RUN" = true ]; then
        echo -e "  ${CLR_MUTED}[Dry-Run] Would automate Gentle-AI configuration${CLR_RESET}"
        return 0
    fi

    # Clear Bash path cache so it can find newly installed binaries
    hash -r

    # Find the binary
    local gentle_bin="gentle-ai"
    if [ -f "$HOME/.local/bin/gentle-ai" ]; then
        gentle_bin="$HOME/.local/bin/gentle-ai"
    elif [ -f "/usr/local/bin/gentle-ai" ]; then
        gentle_bin="/usr/local/bin/gentle-ai"
    fi

    # Determine which successfully selected agents we can configure
    local agents=()
    [ "$CHOSEN_CLAUDE" = true ] && agents+=("claude-code")
    [ "$CHOSEN_OPENCODE" = true ] && agents+=("opencode")
    
    if [ ${#agents[@]} -eq 0 ]; then
        return 0
    fi

    local agents_str
    agents_str=$(IFS=,; echo "${agents[*]}")

    log_step "Gentle-AI Post-Installation Configuration"
    log_info "Gentle-AI supports silent automation for: ${agents_str}"

    if [ "$NON_INTERACTIVE" = true ]; then
        log_info "Automating Gentle-AI setup silently using the 'full-gentleman' preset..."
        run_with_spinner "Configuring Gentle-AI for ${agents_str}" "$gentle_bin" install --agent "$agents_str" --preset full-gentleman
    else
        echo ""
        local auto_cfg
        read -p "➜ Would you like to automatically run Gentle-AI setup for [${agents_str}] now? (y/N): " auto_cfg
        if [[ "$auto_cfg" =~ ^[Yy]$ ]]; then
            echo ""
            # Run the preset configuration which is clean and automated!
            if "$gentle_bin" install --agent "$agents_str" --preset full-gentleman; then
                log_success "Gentle-AI successfully configured for ${agents_str}."
            else
                log_warning "Gentle-AI configuration completed with some warnings."
            fi
        else
            log_info "Skipping automatic Gentle-AI setup. You can run it manually later via: gentle-ai"
        fi
    fi
}

# --- Main Logic ---
main() {
    parse_args "$@"
    
    if [ "$NON_INTERACTIVE" = false ]; then
        interactive_menu
    else
        log_header
        log_info "Running in non-interactive mode."
        check_prerequisites
    fi

    log_step "Beginning installation for selected agents/tools"
    [ "$CHOSEN_CLAUDE" = true ] && log_bullet "Claude Code"
    [ "$CHOSEN_AGY" = true ] && log_bullet "Antigravity CLI (agy)"
    [ "$CHOSEN_OPENCODE" = true ] && log_bullet "OpenCode"
    [ "$CHOSEN_GENTLE_AI" = true ] && log_bullet "Gentle-AI"
    [ "$CHOSEN_QWEN" = true ] && log_bullet "Qwen Code"
    [ "$CHOSEN_PI" = true ] && log_bullet "Pi Coding Agent"
    [ "$CHOSEN_GENTLE_PI" = true ] && log_bullet "Gentle-Pi"
    [ "$CHOSEN_AIDER" = true ] && log_bullet "Aider Pair Programmer"
    [ "$CHOSEN_INTERPRETER" = true ] && log_bullet "Open Interpreter"
    [ "$CHOSEN_DOTFILES" = true ] && log_bullet "Dotfiles (nahuel893/dotfiles)"
    echo ""

    if [ "$DRY_RUN" = true ]; then
        log_warning "DRY RUN MODE ENABLED. No software will be actually installed."
    fi

    local failed_installs=()
    local success_installs=()

    # Run installers
    if [ "$CHOSEN_CLAUDE" = true ]; then
        if install_claude; then
            success_installs+=("Claude Code")
        else
            failed_installs+=("Claude Code")
        fi
    fi

    if [ "$CHOSEN_AGY" = true ]; then
        if install_agy; then
            success_installs+=("Antigravity CLI (agy)")
        else
            failed_installs+=("Antigravity CLI (agy)")
        fi
    fi

    if [ "$CHOSEN_OPENCODE" = true ]; then
        if install_opencode; then
            success_installs+=("OpenCode")
        else
            failed_installs+=("OpenCode")
        fi
    fi

    if [ "$CHOSEN_GENTLE_AI" = true ]; then
        if install_gentle_ai; then
            success_installs+=("Gentle-AI")
        else
            failed_installs+=("Gentle-AI")
        fi
    fi

    if [ "$CHOSEN_QWEN" = true ]; then
        if install_qwen; then
            success_installs+=("Qwen Code")
        else
            failed_installs+=("Qwen Code")
        fi
    fi

    if [ "$CHOSEN_PI" = true ]; then
        if install_pi; then
            success_installs+=("Pi Coding Agent")
        else
            failed_installs+=("Pi Coding Agent")
        fi
    fi

    # Gentle-Pi runs after Pi so the 'pi' package manager is available.
    if [ "$CHOSEN_GENTLE_PI" = true ]; then
        if install_gentle_pi; then
            success_installs+=("Gentle-Pi")
        else
            failed_installs+=("Gentle-Pi")
        fi
    fi

    # After Gentle-Pi for the same reason: 'pi' has to exist first.
    if [ "$CHOSEN_PI_EXTENSIONS" = true ]; then
        if install_pi_extensions; then
            success_installs+=("Pi Extensions")
        else
            failed_installs+=("Pi Extensions")
        fi
    fi

    if [ "$CHOSEN_AIDER" = true ]; then
        if install_aider; then
            success_installs+=("Aider")
        else
            failed_installs+=("Aider")
        fi
    fi

    if [ "$CHOSEN_INTERPRETER" = true ]; then
        if install_interpreter; then
            success_installs+=("Open Interpreter")
        else
            failed_installs+=("Open Interpreter")
        fi
    fi

    if [ "$CHOSEN_DOTFILES" = true ]; then
        if install_dotfiles; then
            success_installs+=("Dotfiles")
        else
            failed_installs+=("Dotfiles")
        fi
    fi

    # Run post-install configurations if applicable (only if Gentle-AI was successfully installed)
    local gentle_success=false
    for item in "${success_installs[@]}"; do
        if [ "$item" = "Gentle-AI" ]; then
            gentle_success=true
            break
        fi
    done

    if [ "$CHOSEN_GENTLE_AI" = true ] && [ "$gentle_success" = true ]; then
        configure_gentle_ai
    fi

    # --- Print Post-Installation Report ---
    echo -e "\n${CLR_BOLD}${CLR_SUCCESS}┌────────────────────────────────────────────────────────┐${CLR_RESET}"
    echo -e "${CLR_BOLD}${CLR_SUCCESS}│             🚀  INSTALLATION COMPLETE!  🚀            │${CLR_RESET}"
    echo -e "${CLR_BOLD}${CLR_SUCCESS}└────────────────────────────────────────────────────────┘${CLR_RESET}\n"
    
    if [ ${#failed_installs[@]} -eq 0 ]; then
        log_success "Congratulations! All selected AI tools/agents were installed successfully."
    else
        if [ ${#success_installs[@]} -gt 0 ]; then
            log_success "The following tools were installed successfully:"
            for tool in "${success_installs[@]}"; do
                log_bullet "${CLR_SUCCESS}$tool${CLR_RESET}"
            done
        fi
        echo ""
        log_warning "Some installations failed. The following tools could not be installed:"
        for tool in "${failed_installs[@]}"; do
            log_bullet "${CLR_ERROR}$tool${CLR_RESET}"
        done
        log_info "Please check the terminal output above to troubleshoot the failures."
    fi

    echo -e "\n${CLR_BOLD}Quick Start & Authentication Instructions:${CLR_RESET}"

    # Only show quick start for successfully installed tools!
    local show_claude_instructions=false
    local show_agy_instructions=false
    local show_opencode_instructions=false
    local show_gentle_instructions=false
    local show_qwen_instructions=false
    local show_pi_instructions=false
    local show_aider_instructions=false
    local show_interpreter_instructions=false
    local show_gentle_pi_instructions=false
    local show_dotfiles_instructions=false

    for item in "${success_installs[@]}"; do
        [ "$item" = "Claude Code" ] && show_claude_instructions=true
        [ "$item" = "Antigravity CLI (agy)" ] && show_agy_instructions=true
        [ "$item" = "OpenCode" ] && show_opencode_instructions=true
        [ "$item" = "Gentle-AI" ] && show_gentle_instructions=true
        [ "$item" = "Qwen Code" ] && show_qwen_instructions=true
        [ "$item" = "Pi Coding Agent" ] && show_pi_instructions=true
        [ "$item" = "Aider" ] && show_aider_instructions=true
        [ "$item" = "Open Interpreter" ] && show_interpreter_instructions=true
        [ "$item" = "Gentle-Pi" ] && show_gentle_pi_instructions=true
        [ "$item" = "Dotfiles" ] && show_dotfiles_instructions=true
    done

    # In dry-run mode, simulate all instructions
    if [ "$DRY_RUN" = true ]; then
        show_claude_instructions=$CHOSEN_CLAUDE
        show_agy_instructions=$CHOSEN_AGY
        show_opencode_instructions=$CHOSEN_OPENCODE
        show_gentle_instructions=$CHOSEN_GENTLE_AI
        show_qwen_instructions=$CHOSEN_QWEN
        show_pi_instructions=$CHOSEN_PI
        show_aider_instructions=$CHOSEN_AIDER
        show_interpreter_instructions=$CHOSEN_INTERPRETER
        show_gentle_pi_instructions=$CHOSEN_GENTLE_PI
        show_dotfiles_instructions=$CHOSEN_DOTFILES
    fi

    if [ "$show_claude_instructions" = true ]; then
        echo -e "\n ${CLR_BOLD}${CLR_PRIMARY}1. Claude Code${CLR_RESET}"
        log_bullet "Command: ${CLR_BOLD}claude${CLR_RESET}"
        log_bullet "Authenticate by running: ${CLR_CYAN}claude auth login${CLR_RESET}"
        log_bullet "Note: Requires a Claude Pro/Team account or Console API billing configured."
    fi

    if [ "$show_agy_instructions" = true ]; then
        echo -e "\n ${CLR_BOLD}${CLR_PRIMARY}2. Antigravity CLI (agy)${CLR_RESET}"
        log_bullet "Command: ${CLR_BOLD}agy${CLR_RESET}"
        log_bullet "Start and authenticate by running: ${CLR_CYAN}agy${CLR_RESET}"
        log_bullet "Note: Initiates Google Sign-in flow automatically on first execution."
    fi

    if [ "$show_opencode_instructions" = true ]; then
        echo -e "\n ${CLR_BOLD}${CLR_PRIMARY}3. OpenCode${CLR_RESET}"
        log_bullet "Command: ${CLR_BOLD}opencode${CLR_RESET}"
        log_bullet "Authenticate by launching TUI or running: ${CLR_CYAN}opencode auth login${CLR_RESET}"
        log_bullet "Note: Supports custom model endpoints and multiple providers."
    fi

    if [ "$show_gentle_instructions" = true ]; then
        echo -e "\n ${CLR_BOLD}${CLR_PRIMARY}4. Gentle-AI${CLR_RESET}"
        log_bullet "Command: ${CLR_BOLD}gentle-ai${CLR_RESET}"
        log_bullet "Run first-time setup and config: ${CLR_CYAN}gentle-ai install${CLR_RESET}"
        log_bullet "Alternatively, launch the TUI for setup by simply running: ${CLR_CYAN}gentle-ai${CLR_RESET}"
        log_bullet "Sync configurations anytime: ${CLR_CYAN}gentle-ai sync${CLR_RESET}"
    fi

    if [ "$show_qwen_instructions" = true ]; then
        echo -e "\n ${CLR_BOLD}${CLR_PRIMARY}5. Qwen Code${CLR_RESET}"
        log_bullet "Command: ${CLR_BOLD}qwen${CLR_RESET}"
        log_bullet "Launch Qwen CLI coding agent by running: ${CLR_CYAN}qwen${CLR_RESET}"
        log_bullet "Note: Follow on-screen instructions during the first run to complete setup."
    fi

    if [ "$show_pi_instructions" = true ]; then
        echo -e "\n ${CLR_BOLD}${CLR_PRIMARY}6. Pi Coding Agent${CLR_RESET}"
        log_bullet "Command: ${CLR_BOLD}pi${CLR_RESET}"
        log_bullet "Launch Pi CLI coding agent by running: ${CLR_CYAN}pi${CLR_RESET}"
        log_bullet "Note: Visit https://pi.dev for documentation and setup instructions."
    fi

    if [ "$show_aider_instructions" = true ]; then
        echo -e "\n ${CLR_BOLD}${CLR_PRIMARY}7. Aider${CLR_RESET}"
        log_bullet "Command: ${CLR_BOLD}aider${CLR_RESET}"
        log_bullet "Start inside any git repo by configuring your API key (e.g. export ANTHROPIC_API_KEY=...) and running: ${CLR_CYAN}aider${CLR_RESET}"
    fi

    if [ "$show_interpreter_instructions" = true ]; then
        echo -e "\n ${CLR_BOLD}${CLR_PRIMARY}8. Open Interpreter${CLR_RESET}"
        log_bullet "Command: ${CLR_BOLD}interpreter${CLR_RESET}"
        log_bullet "Start by running: ${CLR_CYAN}interpreter${CLR_RESET}"
    fi

    if [ "$show_gentle_pi_instructions" = true ]; then
        echo -e "\n ${CLR_BOLD}${CLR_PRIMARY}9. Gentle-Pi${CLR_RESET}"
        log_bullet "Runs on top of the Pi agent — launch Pi in any repo: ${CLR_CYAN}pi${CLR_RESET}"
        log_bullet "Bootstrap SDD once per project: ${CLR_CYAN}/gentle-sdd-init${CLR_RESET} (inside Pi)"
        log_bullet "Update anytime: ${CLR_CYAN}pi install npm:gentle-pi@latest${CLR_RESET}"
    fi

    if [ "$show_dotfiles_instructions" = true ]; then
        echo -e "\n ${CLR_BOLD}${CLR_PRIMARY}10. Dotfiles${CLR_RESET}"
        log_bullet "Cloned to ${CLR_BOLD}~/dotfiles${CLR_RESET} and symlinked via its own install.sh."
        log_bullet "Existing real configs were backed up to ${CLR_BOLD}<file>.bak${CLR_RESET}."
        log_bullet "Re-link anytime: ${CLR_CYAN}bash ~/dotfiles/install.sh${CLR_RESET}"
    fi

    echo -e "\n${CLR_BOLD}${CLR_MUTED}Thank you for using the AI Agent CLI Installer! Keep exploring! 🚀${CLR_RESET}\n"

    # Exit with code 1 if any installation failed
    if [ ${#failed_installs[@]} -gt 0 ] && [ "$DRY_RUN" = false ]; then
        exit 1
    fi
}

main "$@"
