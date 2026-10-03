#!/usr/bin/env bash
# ==============================================================================
# Sway Module Setup Hook
# ==============================================================================
set -e

# Validate that sway and waybar configurations exist
SWAY_CONFIG="$HOME/.config/sway/config"
WAYBAR_CONFIG="$HOME/.config/waybar/modules.json"

if [ -f "$SWAY_CONFIG" ]; then
    echo "  -> Sway configuration verified at $SWAY_CONFIG"
fi

if [ -f "$WAYBAR_CONFIG" ]; then
    echo "  -> Waybar configuration verified at $WAYBAR_CONFIG"
fi
