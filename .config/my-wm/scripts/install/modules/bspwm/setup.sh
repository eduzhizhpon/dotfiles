#!/usr/bin/env bash
# ==============================================================================
# BSPWM Module Setup Hook
# ==============================================================================
set -e

BSPWM_CONFIG="$HOME/.config/bspwm/bspwmrc"
if [ -f "$BSPWM_CONFIG" ]; then
    chmod +x "$BSPWM_CONFIG" 2>/dev/null || true
    echo "  -> bspwm configuration verified at $BSPWM_CONFIG"
fi
