#!/usr/bin/env bash
# ==============================================================================
# Fonts Module Setup Hook
# ==============================================================================
set -e

if command -v fc-cache &>/dev/null; then
    echo "  -> Updating font cache with fc-cache..."
    fc-cache -f >/dev/null 2>&1 || true
fi
