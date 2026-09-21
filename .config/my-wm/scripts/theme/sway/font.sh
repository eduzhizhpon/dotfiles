#!/usr/bin/env bash
source "$(dirname "$0")/../lib.sh"
load_fonts_context

cat <<EOF > "$GEN_DIR/sway-fonts.conf"
# Generado automáticamente por my-wm/scripts/theme/sway/font.sh
font pango:$FONT_PRIMARY $FONT_SIZE_PT
EOF
