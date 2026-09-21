#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$(realpath "${BASH_SOURCE[0]}")")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

TARGET="${1:-fonts}"
NO_RELOAD=false

for arg in "$@"; do
    if [ "$arg" == "--no-reload" ]; then
        NO_RELOAD=true
    fi
done

if [ "$TARGET" == "fonts" ] || [ "$TARGET" == "all" ]; then
    load_fonts_context
    echo "[my-wm/theme] Generando configuraciones de fuentes..."

    for handler in "$SCRIPTS_DIR"/*/"font.sh"; do
        if [ -f "$handler" ]; then
            component=$(basename "$(dirname "$handler")")
            echo " -> Compilando $component"
            bash "$handler"
        fi
    done
fi

if [ "$NO_RELOAD" = false ]; then
    echo "[my-wm/theme] Recargando entorno de escritorio..."
    bash "$SCRIPTS_DIR/reload.sh"
fi

echo "[my-wm/theme] Configuración aplicada exitosamente."
