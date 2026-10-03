#!/usr/bin/env bash
# ==============================================================================
# MWM Installer - Modular Desktop Environment & Dotfiles Orchestrator
# Description: Validates and installs packages defined in install/modules/*/,
#              only installing missing dependencies and running module setup hooks.
# ==============================================================================

set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MY_WM_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"
MODULES_DIR="${SCRIPT_DIR}/modules"

# Source shared installer library
# shellcheck source=./lib.sh
source "${SCRIPT_DIR}/lib.sh"

# Dynamic list of all available modules in modules/
mapfile -t ALL_MODULE_NAMES < <(get_available_modules "$MODULES_DIR")

show_help() {
    cat <<EOF
${BOLD}MWM Modular Installer${RESET} - Desktop Environment & Dotfiles Orchestrator

${BOLD}USAGE:${RESET}
    ./mwm.sh [PROFILE] [OPTIONS]
    mwm-install.sh [PROFILE] [OPTIONS]

${BOLD}PROFILES (Bundled Presets):${RESET}
    --sway         Install Sway Wayland desktop (core + fonts + themes + sway + shell)
    --hyprland     Install Hyprland Wayland desktop (core + fonts + themes + hyprland + shell)
    --i3           Install i3 X11 desktop (core + fonts + themes + i3 + shell)
    --bspwm        Install BSPWM X11 desktop (core + fonts + themes + bspwm + shell)
    --all          Install all available modules in modules/

${BOLD}MODULAR OPTIONS:${RESET}
    -m, --module <name>   Select specific module from install/modules/<name>
                          Available modules: ${ALL_MODULE_NAMES[*]}
                          Can be specified multiple times.

${BOLD}EXECUTION FLAGS:${RESET}
    -c, --check, --dry-run  Validate package status and list missing packages without installing
    --setup-only            Run module setup.sh hooks without installing packages
    --post-install          Alias for --setup-only
    --skip-setup            Skip module setup.sh hooks after package installation
    --no-confirm            Pass non-interactive flag to the package manager
    -h, --help              Show this help message and exit

${BOLD}EXAMPLES:${RESET}
    ./mwm.sh --sway
    ./mwm.sh --hyprland --check
    ./mwm.sh -m core -m fonts -m sway
    ./mwm.sh --setup-only
EOF
}

# ==============================================================================
# Argument Parsing
# ==============================================================================

SELECTED_MODULES=()
DRY_RUN=false
SETUP_ONLY=false
SKIP_SETUP=false
NO_CONFIRM=false

if [ $# -eq 0 ]; then
    show_help
    exit 0
fi

while [[ $# -gt 0 ]]; do
    case "$1" in
        --sway)
            SELECTED_MODULES+=("core" "fonts" "themes" "sway" "shell")
            shift
            ;;
        --hyprland|--hypr)
            SELECTED_MODULES+=("core" "fonts" "themes" "hyprland" "shell")
            shift
            ;;
        --i3)
            SELECTED_MODULES+=("core" "fonts" "themes" "i3" "shell")
            shift
            ;;
        --bspwm)
            SELECTED_MODULES+=("core" "fonts" "themes" "bspwm" "shell")
            shift
            ;;
        --all)
            SELECTED_MODULES+=("${ALL_MODULE_NAMES[@]}")
            shift
            ;;
        -m|--module)
            if [ -z "$2" ]; then
                log_error "Option '$1' requires a module name."
                exit 1
            fi
            SELECTED_MODULES+=("$2")
            shift 2
            ;;
        -c|--check|--dry-run)
            DRY_RUN=true
            shift
            ;;
        --setup-only|--post-install)
            SETUP_ONLY=true
            shift
            ;;
        --skip-setup)
            SKIP_SETUP=true
            shift
            ;;
        --no-confirm)
            NO_CONFIRM=true
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            echo "Run './mwm.sh --help' for usage."
            exit 1
            ;;
    esac
done

# Deduplicate selected modules
mapfile -t UNIQUE_MODULES < <(printf "%s\n" "${SELECTED_MODULES[@]}" | awk '!seen[$0]++')

# If --setup-only or --post-install was passed without profile, default to all discovered modules
if [ "$SETUP_ONLY" = true ] && [ ${#UNIQUE_MODULES[@]} -eq 0 ]; then
    UNIQUE_MODULES=("${ALL_MODULE_NAMES[@]}")
fi

if [ ${#UNIQUE_MODULES[@]} -eq 0 ]; then
    log_error "No valid profile or modules selected."
    show_help
    exit 1
fi

# Validate that each module exists in modules/
for mod in "${UNIQUE_MODULES[@]}"; do
    if [ ! -d "${MODULES_DIR}/${mod}" ]; then
        log_error "Module not found: '${mod}'. Available: ${ALL_MODULE_NAMES[*]}"
        exit 1
    fi
done

# ==============================================================================
# Setup-Only Execution Mode
# ==============================================================================

if [ "$SETUP_ONLY" = true ]; then
    log_section "Executing Module Setup Hooks"
    for mod in "${UNIQUE_MODULES[@]}"; do
        run_module_setup "$mod" "${MODULES_DIR}/${mod}"
    done
    log_section "Setup Complete"
    log_success "All setup hooks completed successfully!"
    exit 0
fi

# ==============================================================================
# Package Resolution & Fast Diff Engine
# ==============================================================================

detect_pkg_manager
log_section "MWM Environment Installer"
log_info "Package Manager: ${BOLD}${PKG_MGR}${RESET}"
log_info "Selected Modules: ${BOLD}${UNIQUE_MODULES[*]}${RESET}"
[ "$DRY_RUN" = true ] && log_warn "Running in DRY-RUN / CHECK mode (no packages will be installed)"

# Collect target packages across all selected module packages.txt
TARGET_PKGS_RAW=()
for mod in "${UNIQUE_MODULES[@]}"; do
    while IFS= read -r pkg; do
        [[ -n "$pkg" ]] && TARGET_PKGS_RAW+=("$pkg")
    done < <(read_module_packages "${MODULES_DIR}/${mod}")
done

# Deduplicate target packages
mapfile -t TARGET_PKGS < <(printf "%s\n" "${TARGET_PKGS_RAW[@]}" | awk '!seen[$0]++')

# Load installed packages cache via pacman -Qq (~30ms)
load_installed_packages_cache

INSTALLED_LIST=()
MISSING_LIST=()

for pkg in "${TARGET_PKGS[@]}"; do
    if [[ -n "${INSTALLED_MAP[$pkg]}" ]]; then
        INSTALLED_LIST+=("$pkg")
    else
        MISSING_LIST+=("$pkg")
    fi
done

# Print Summary Table
log_section "Package Validation Status"
echo -e "Total target packages : ${BOLD}${#TARGET_PKGS[@]}${RESET}"
echo -e "Already installed     : ${GREEN}${BOLD}${#INSTALLED_LIST[@]}${RESET}"
echo -e "Missing / Required    : ${YELLOW}${BOLD}${#MISSING_LIST[@]}${RESET}"

if [ ${#MISSING_LIST[@]} -gt 0 ]; then
    echo -e "\n${BOLD}Missing packages to be installed:${RESET}"
    for pkg in "${MISSING_LIST[@]}"; do
        echo -e "  ${RED}✗${RESET} $pkg"
    done
else
    echo -e "\n${GREEN}✓ All packages for selected modules are already installed!${RESET}"
fi

# Exit early if dry-run
if [ "$DRY_RUN" = true ]; then
    echo ""
    log_info "Dry-run check complete. No changes made."
    exit 0
fi

# ==============================================================================
# Package Installation Phase
# ==============================================================================

if [ ${#MISSING_LIST[@]} -gt 0 ]; then
    ensure_aur_helper

    log_section "Installing Missing Packages"
    
    INSTALL_CMD=()
    if [ "$PKG_MGR" = "pacman" ]; then
        INSTALL_CMD=(sudo pacman -S --needed)
    elif [ "$PKG_MGR" = "paru" ]; then
        INSTALL_CMD=(paru -S --needed)
    elif [ "$PKG_MGR" = "yay" ]; then
        INSTALL_CMD=(yay -S --needed)
    fi

    if [ "$NO_CONFIRM" = true ]; then
        INSTALL_CMD+=(--noconfirm)
    fi

    INSTALL_CMD+=("${MISSING_LIST[@]}")

    log_info "Executing: ${GRAY}${INSTALL_CMD[*]}${RESET}"
    "${INSTALL_CMD[@]}"
    log_success "Missing packages successfully installed."
fi

# ==============================================================================
# Post-Install Module Setup Hooks Phase
# ==============================================================================

if [ "$SKIP_SETUP" = false ]; then
    log_section "Running Module Setup Hooks"
    for mod in "${UNIQUE_MODULES[@]}"; do
        run_module_setup "$mod" "${MODULES_DIR}/${mod}"
    done
fi

log_section "Environment Ready"
log_success "Your ${UNIQUE_MODULES[*]} environment is configured and ready to use!"
