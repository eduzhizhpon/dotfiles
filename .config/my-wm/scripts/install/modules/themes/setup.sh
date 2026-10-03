#!/usr/bin/env bash
# ==============================================================================
# Themes Module Setup Hook
# ==============================================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEME_APPLY="${SCRIPT_DIR}/../../theme/apply.sh"

# Set GTK prefer-dark color scheme
if command -v gsettings &>/dev/null; then
    gsettings set org.gnome.desktop.interface color-scheme prefer-dark 2>/dev/null || true
fi

# Compile theme font/color artifacts
if [ -x "$THEME_APPLY" ]; then
    echo "  -> Compiling theme & font contracts..."
    "$THEME_APPLY" fonts --no-reload || true
fi
