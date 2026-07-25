#!/usr/bin/env bash

LID_STATE=$1

# Load device name
[ -f ~/.device/.env ] && source ~/.device/.env
if [ -z "$DEVICE" ]; then
    DEVICE="scarlet"
fi

CONFIG_FILE="$HOME/.config/my-wm/configs/${DEVICE}.json"

# Auto-detect internal monitor (usually starts with eDP)
INTERNAL_MONITOR=$(swaymsg -t get_outputs | jq -r '.[] | select(.name | startswith("eDP")) | .name')
[ -z "$INTERNAL_MONITOR" ] && INTERNAL_MONITOR="eDP-1"

TARGET_MONITOR=""

if [ -f "$CONFIG_FILE" ]; then
    # Find the monitor configured to be primary on lid close
    TARGET_MONITOR=$(jq -r '.monitors | to_entries[] | select(.value.primaryOnLid == true) | .key' "$CONFIG_FILE" | head -n 1)
fi

# Fallback if no target monitor found
if [ -z "$TARGET_MONITOR" ] || [ "$TARGET_MONITOR" = "null" ]; then
    TARGET_MONITOR="HDMI-A-1"
fi

if [ "$LID_STATE" = "close" ]; then
    # Check if the target external monitor is connected
    if swaymsg -t get_outputs | grep -q "\"name\": \"$TARGET_MONITOR\""; then
        # Disable laptop screen, making the external monitor primary
        swaymsg output "$INTERNAL_MONITOR" disable
        [ -x ~/.config/waybar/launch.sh ] && bash ~/.config/waybar/launch.sh &
    fi
elif [ "$LID_STATE" = "open" ]; then
    # Always re-enable the laptop screen when opening the lid
    swaymsg output "$INTERNAL_MONITOR" enable
    [ -x ~/.config/waybar/launch.sh ] && bash ~/.config/waybar/launch.sh &
fi
