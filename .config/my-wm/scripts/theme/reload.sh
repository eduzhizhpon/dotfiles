#!/usr/bin/env bash
# Recarga inteligente multi-WM sin duplicaciones ni parpadeos

# 1. Recargar Window Manager activo
if [[ "$XDG_CURRENT_DESKTOP" == *"Hyprland"* ]] || pgrep -x "hyprland" >/dev/null; then
    if command -v hyprctl &>/dev/null; then
        hyprctl reload >/dev/null 2>&1 || true
    fi
elif [[ "$XDG_CURRENT_DESKTOP" == *"sway"* ]] || pgrep -x "sway" >/dev/null; then
    if command -v swaymsg &>/dev/null; then
        swaymsg reload >/dev/null 2>&1 || true
    fi
fi

# 2. Recargar Waybar
if command -v swaymsg &>/dev/null && pgrep -x "sway" >/dev/null; then
    swaymsg exec "$HOME/.config/waybar/launch.sh" >/dev/null 2>&1 || true
elif command -v hyprctl &>/dev/null && pgrep -x "hyprland" >/dev/null; then
    hyprctl dispatch exec "$HOME/.config/waybar/launch.sh" >/dev/null 2>&1 || true
elif [ -x "$HOME/.config/waybar/launch.sh" ]; then
    bash "$HOME/.config/waybar/launch.sh" &>/dev/null &
fi

# 3. Recargar Dunst
if pgrep -x dunst >/dev/null; then
    killall dunst 2>/dev/null || true
    if [ -f "$HOME/.config/my-wm/theme/generated/dunstrc" ]; then
        dunst -config "$HOME/.config/my-wm/theme/generated/dunstrc" &>/dev/null &
    else
        dunst &>/dev/null &
    fi
fi
