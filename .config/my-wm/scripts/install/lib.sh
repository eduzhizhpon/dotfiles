#!/usr/bin/env bash
# ==============================================================================
# MWM Installer Core Library
# Description: Helper functions for package caching, diffing, PM detection,
#              and modular hook execution.
# ==============================================================================

# Formatting Colors
BOLD=$'\033[1m'
GREEN=$'\033[0;32m'
BLUE=$'\033[0;34m'
YELLOW=$'\033[0;33m'
RED=$'\033[0;31m'
CYAN=$'\033[0;36m'
GRAY=$'\033[0;90m'
RESET=$'\033[0m'

log_info() {
    echo -e "${BLUE}ℹ ${RESET}$1"
}

log_success() {
    echo -e "${GREEN}✓ ${RESET}$1"
}

log_warn() {
    echo -e "${YELLOW}▲ ${RESET}$1"
}

log_error() {
    echo -e "${RED}✗ ${RESET}$1"
}

log_section() {
    echo -e "\n${BOLD}${CYAN}=== $1 ===${RESET}"
}

# Auto-detect package manager / AUR helper
detect_pkg_manager() {
    if command -v paru &>/dev/null; then
        PKG_MGR="paru"
    elif command -v yay &>/dev/null; then
        PKG_MGR="yay"
    elif command -v pacman &>/dev/null; then
        PKG_MGR="pacman"
    else
        log_error "No supported package manager found (pacman/paru/yay). Are you on Arch Linux?"
        exit 1
    fi
}

# Ensure AUR helper is available if only pacman is present
ensure_aur_helper() {
    if [ "$PKG_MGR" = "pacman" ]; then
        log_warn "Only 'pacman' was found. AUR packages may fail to install."
        local answer="Y"
        if [ "${NO_CONFIRM:-false}" != true ]; then
            read -rp "Would you like to automatically install 'paru-bin' from AUR now? [Y/n] " answer
            answer="${answer:-Y}"
        fi
        if [[ "$answer" =~ ^[Yy]$ ]]; then
            log_info "Bootstrapping paru-bin from AUR..."
            local tmp_dir
            tmp_dir="$(mktemp -d)"
            sudo pacman -S --needed --noconfirm base-devel git
            git clone https://aur.archlinux.org/paru-bin.git "$tmp_dir/paru-bin"
            (cd "$tmp_dir/paru-bin" && makepkg -si --noconfirm)
            rm -rf "$tmp_dir"
            PKG_MGR="paru"
            log_success "paru installed successfully!"
        fi
    fi
}

# Fast-load installed packages into an associative array using pacman -Qq (~30ms)
load_installed_packages_cache() {
    declare -g -A INSTALLED_MAP
    if command -v pacman &>/dev/null; then
        while IFS= read -r pkg; do
            [[ -n "$pkg" ]] && INSTALLED_MAP["$pkg"]=1
        done < <(pacman -Qq 2>/dev/null || true)
    fi
}

# Read package list from a module's packages.txt file (ignoring comments and empty lines)
read_module_packages() {
    local module_dir="$1"
    local pkg_file="${module_dir}/packages.txt"
    local -a pkgs=()

    if [ -f "$pkg_file" ]; then
        while IFS= read -r line || [[ -n "$line" ]]; do
            # Strip whitespace
            line="$(echo "$line" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
            # Ignore empty lines and lines starting with #
            if [[ -n "$line" && ! "$line" =~ ^# ]]; then
                pkgs+=("$line")
            fi
        done < "$pkg_file"
    fi

    printf "%s\n" "${pkgs[@]}"
}

# List all available module names in the modules/ directory
get_available_modules() {
    local modules_dir="$1"
    local -a mod_names=()
    for d in "${modules_dir}"/*; do
        if [ -d "$d" ]; then
            mod_names+=("$(basename "$d")")
        fi
    done
    printf "%s\n" "${mod_names[@]}"
}

# Run module setup hook if present and executable
run_module_setup() {
    local module_name="$1"
    local module_dir="$2"
    local setup_script="${module_dir}/setup.sh"

    if [ -f "$setup_script" ]; then
        log_info "Running setup for module: ${BOLD}${module_name}${RESET}"
        if [ -x "$setup_script" ]; then
            bash "$setup_script"
        else
            bash "$setup_script"
        fi
        log_success "Setup for ${BOLD}${module_name}${RESET} completed."
    fi
}
