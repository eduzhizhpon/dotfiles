#!/usr/bin/env bash
source "$(dirname "$0")/../lib.sh"
load_fonts_context

if command -v gsettings &>/dev/null; then
    gsettings set org.gnome.desktop.interface font-name "$FONT_PRIMARY $FONT_SIZE_PT" 2>/dev/null || true
fi
