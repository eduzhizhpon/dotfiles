#!/bin/bash
#
# A simple script to toggle between two keyboard layouts for Xorg, Sway, and Hyprland.
#

set -euo pipefail

# --- Configuration ---
# Define the two layouts to toggle between.
# The user can customize this array.
LAYOUTS=("us" "latam")

# --- Functions ---

handle_error() {
    echo "Error: $1" >&2
    exit 1
}

notify() {
    if command -v notify-send &>/dev/null; then
        notify-send -t 1000 -u low "Keyboard Layout" "$1"
    else
        echo "$1"
    fi
}

# --- Main Script ---

# Detect the session type (Xorg or Wayland)
if [ -n "$WAYLAND_DISPLAY" ]; then
    SESSION_TYPE="wayland"
else
    SESSION_TYPE="xorg"
fi

case "$SESSION_TYPE" in
wayland)
    # For Wayland, detect the compositor (Sway or Hyprland)
    case "${XDG_CURRENT_DESKTOP:-}" in
    sway)
        if ! command -v swaymsg &>/dev/null || ! command -v jq &>/dev/null; then
            handle_error "swaymsg or jq not found."
        fi
        # Get the current layout index from the first keyboard found
        current_layout_index=$(swaymsg -t get_inputs -r | jq -r '.[] | select(.type=="keyboard") | .xkb_active_layout_index' | head -n 1)
        # Calculate the next layout index (0 or 1)
        next_layout_index=$(( (current_layout_index + 1) % ${#LAYOUTS[@]} ))
        # Switch all keyboards to the next layout
        swaymsg input type:keyboard xkb_switch_layout $next_layout_index > /dev/null
        # Notify the user of the new layout
        notify "Switched to ${LAYOUTS[$next_layout_index]}"
        ;;
    Hyprland)
        if ! command -v hyprctl &>/dev/null || ! command -v jq &>/dev/null; then
            handle_error "hyprctl or jq not found. This version of the script requires jq for Hyprland."
        fi
        
        # Switch the layout for all keyboards
        hyprctl devices -j | jq -r '.keyboards[].name' | while read -r keyboard_name; do
            hyprctl switchxkblayout "$keyboard_name" next >/dev/null
        done
        
        # Get the new active keymap for the notification
        new_active_keymap=$(hyprctl devices -j | jq -r '.keyboards[0].active_keymap')
        notify "Switched to $new_active_keymap"
        ;;
    *)
        handle_error "Unsupported Wayland compositor: ${XDG_CURRENT_DESKTOP:-not set}."
        ;;
    esac
    ;;
xorg)
    if ! command -v setxkbmap &>/dev/null; then
        handle_error "setxkbmap not found."
    fi
    # Get the current layout
    current_layout=$(setxkbmap -query | awk '/layout:/ {print $2}')
    # Determine the next layout
    next_layout=${LAYOUTS[0]}
    if [[ "$current_layout" == "${LAYOUTS[0]}" ]]; then
        next_layout=${LAYOUTS[1]}
    fi
    # Set the new layout
    setxkbmap "$next_layout"
    # Notify the user
    notify "Switched to $next_layout"
    ;;
*)
    handle_error "Unsupported session type."
    ;;
esac
