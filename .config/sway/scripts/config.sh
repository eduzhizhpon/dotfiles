#!/usr/bin/env bash

DEVICE_MONITOR_CONF="$HOME/.config/sway/configs/$DEVICE.conf"

# --- 1) If device has its own config, use it ---
if [ -f "$DEVICE_MONITOR_CONF" ]; then
    echo "Loading per-device monitor config: $DEVICE_MONITOR_CONF"
    while IFS= read -r line; do
        # Skip blank lines and comments
        [[ -z "$line" || "$line" =~ ^# ]] && continue
        echo "$line"
        swaymsg "$line"
    done < "$DEVICE_MONITOR_CONF"
    exit 0
fi

# --- 2) Fallback: auto-detect and place second monitor to the right ---
echo "Using fallback layout (auto-resolution, right side)"

# Get all active outputs
outputs=($(swaymsg -t get_outputs | jq -r '.[] | select(.active == true).name'))

if [ ${#outputs[@]} -eq 1 ]; then
    # Only 1 monitor → nothing to do
    echo "Only one monitor detected; no layout needed."
    exit 0
fi

# Assume first is primary
PRIMARY="${outputs[0]}"

# Apply auto-res for primary
swaymsg "output $PRIMARY mode current position 0 0"

X_OFFSET=$(swaymsg -t get_outputs | jq -r '.[] | select(.active == true) | .current_mode.width' | head -1)

# Apply auto-res and right positioning to the rest
for OUTPUT in "${outputs[@]:1}"; do
    swaymsg "output $OUTPUT mode current position $X_OFFSET 0"
done
