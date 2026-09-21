#!/usr/bin/env bash
source "$(dirname "$0")/../lib.sh"
load_fonts_context

cat <<EOF > "$GEN_DIR/waybar-fonts.css"
/* Generado automáticamente por my-wm/scripts/theme/waybar/font.sh */
* {
    font-family: "$FONT_PRIMARY", $FONT_FALLBACK;
    font-size: ${FONT_SIZE_PX}px;
}
EOF
