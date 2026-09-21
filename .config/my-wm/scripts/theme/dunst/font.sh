#!/usr/bin/env bash
source "$(dirname "$0")/../lib.sh"
load_fonts_context

BASE_DUNSTRC="$HOME/.config/dunst/dunstrc"
TARGET_DUNSTRC="$GEN_DIR/dunstrc"

if [ -f "$BASE_DUNSTRC" ]; then
    sed "s|^    font = .*|    font = \"$FONT_PRIMARY $FONT_SIZE_PT, $FONT_FALLBACK\"|" "$BASE_DUNSTRC" > "$TARGET_DUNSTRC"
fi
