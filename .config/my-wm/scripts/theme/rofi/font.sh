#!/usr/bin/env bash
source "$(dirname "$0")/../lib.sh"
load_fonts_context

cat <<EOF > "$GEN_DIR/rofi-fonts.rasi"
/* Generado automáticamente por my-wm/scripts/theme/rofi/font.sh */
* {
    font: "$FONT_PRIMARY $FONT_SIZE_PT";
}
EOF
