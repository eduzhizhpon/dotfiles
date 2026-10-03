#!/usr/bin/env bash
# ==============================================================================
# Hyprland Module Setup Hook
# ==============================================================================
set -e

HYPR_CONFIG="$HOME/.config/hypr/hyprland.conf"
if [ -f "$HYPR_CONFIG" ]; then
    echo "  -> Hyprland configuration verified at $HYPR_CONFIG"
fi
