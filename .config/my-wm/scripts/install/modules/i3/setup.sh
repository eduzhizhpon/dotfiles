#!/usr/bin/env bash
# ==============================================================================
# i3 Module Setup Hook
# ==============================================================================
set -e

I3_CONFIG="$HOME/.config/i3/config"
if [ -f "$I3_CONFIG" ]; then
    echo "  -> i3 configuration verified at $I3_CONFIG"
fi
