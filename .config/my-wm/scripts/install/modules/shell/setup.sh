#!/usr/bin/env bash
# ==============================================================================
# Shell Module Setup Hook - Powerlevel10k & Zsh Plugins
# ==============================================================================
set -e

# 1. Install Powerlevel10k if not already cloned
P10K_DIR="$HOME/powerlevel10k"
if [ ! -d "$P10K_DIR" ]; then
    echo "  -> Cloning Powerlevel10k into $P10K_DIR..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR" 2>/dev/null || true
fi

# 2. Download ohmyzsh zsh-sudo plugin if missing
SUDO_PLUGIN_DIR="/usr/share/zsh/plugins/zsh-sudo"
if [ ! -d "$SUDO_PLUGIN_DIR" ]; then
    echo "  -> Setting up zsh-sudo plugin in $SUDO_PLUGIN_DIR..."
    sudo mkdir -p "$SUDO_PLUGIN_DIR" 2>/dev/null || true
    if command -v curl &>/dev/null; then
        sudo curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/plugins/sudo/sudo.plugin.zsh -o "${SUDO_PLUGIN_DIR}/sudo.plugin.zsh" 2>/dev/null || true
    fi
fi
