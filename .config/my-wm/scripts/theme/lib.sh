#!/usr/bin/env bash
# Librería compartida para parseo de configuración y carga de contexto

THEME_DIR="$HOME/.config/my-wm/theme"
SCRIPTS_DIR="$HOME/.config/my-wm/scripts/theme"
GEN_DIR="$THEME_DIR/generated"
FONTS_JSON="$THEME_DIR/fonts.json"

mkdir -p "$GEN_DIR"

load_fonts_context() {
    if [ ! -f "$FONTS_JSON" ]; then
        echo "[my-wm/theme] Error: No existe $FONTS_JSON" >&2
        return 1
    fi

    export FONT_PRIMARY=$(jq -r '.font_family_primary' "$FONTS_JSON")
    export FONT_FALLBACK=$(jq -r '.font_family_fallback' "$FONTS_JSON")
    export FONT_SIZE_PT=$(jq -r '.font_size_pt' "$FONTS_JSON")
    export FONT_SIZE_PX=$(jq -r '.font_size_px' "$FONTS_JSON")
}
