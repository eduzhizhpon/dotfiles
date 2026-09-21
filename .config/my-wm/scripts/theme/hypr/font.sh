#!/usr/bin/env bash
source "$(dirname "$0")/../lib.sh"
load_fonts_context

cat <<EOF > "$GEN_DIR/hypr-fonts.conf"
# Generado automáticamente por my-wm/scripts/theme/hypr/font.sh (Futuro Hyprland)
# font_family = $FONT_PRIMARY
EOF
