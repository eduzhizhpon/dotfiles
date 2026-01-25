#!/usr/bin/env bash

waybar_path="$HOME/.config/waybar"

exec 200>/tmp/waybar-launch.lock
flock -n 200 || exit 0

systemctl --user import-environment all

killall -q waybar
while pgrep -x waybar >/dev/null; do sleep 0.1; done
sleep 0.5

# Detect WM
if [[ "$XDG_CURRENT_DESKTOP" == *"Hyprland"* ]]; then
  wm="hyprland"
elif [[ "$XDG_CURRENT_DESKTOP" == *"sway"* ]]; then
  wm="sway"
else
  # Fallback detection
  if pgrep -x "hyprland" >/dev/null; then
    wm="hyprland"
  elif pgrep -x "sway" >/dev/null; then
    wm="sway"
  fi
fi

echo "Detected WM: $wm"

style_path="$waybar_path/style.css"
common_modules_path="$waybar_path/modules.json"
wm_config_dir="$waybar_path/configs/$wm"
wm_modules_path="$wm_config_dir/modules.json"
primary_config_path="$wm_config_dir/primary.json"
secondary_config_path="$wm_config_dir/secondary.json"
generated_config_path="/tmp/waybar-config.jsonc"
primary_monitor_path="$waybar_path/monitors/$DEVICE.json"

# Load and merge modules
common_modules="{}"
[ -f "$common_modules_path" ] && common_modules=$(cat "$common_modules_path")

wm_modules="{}"
[ -f "$wm_modules_path" ] && wm_modules=$(cat "$wm_modules_path")

modules_config=$(jq -s '.[0] * .[1]' <(echo "$common_modules") <(echo "$wm_modules"))

# Load layout configs
primary_specific_config="{}"
[ -f "$primary_config_path" ] && primary_specific_config=$(cat "$primary_config_path")

secondary_specific_config="{}"
[ -f "$secondary_config_path" ] && secondary_specific_config=$(cat "$secondary_config_path")

# Get monitor info
monitors=()
detected_primary=""

if [[ "$wm" == "hyprland" ]]; then
  mapfile -t monitors < <(hyprctl monitors -j | jq -r '.[] | .name')
  detected_primary=$(hyprctl monitors -j | jq -r '.[] | select(.focused == true) | .name')
elif [[ "$wm" == "sway" ]]; then
  mapfile -t monitors < <(swaymsg -t get_outputs | jq -r '.[] | .name')
  detected_primary=$(swaymsg -t get_outputs | jq -r '.[] | select(.focused == true) | .name')
fi

configs="[]"

base_config=$(jq -s '.[0] * .[1]' <(echo "$modules_config") <(echo "$primary_specific_config"))

primary_monitor=""
if [ -f "$primary_monitor_path" ]; then
  echo "Reading monitor config: $primary_monitor_path"
  primary_monitor=$(jq -r '.name' "$primary_monitor_path")
fi

if [ -z "$primary_monitor" ] || [ "$primary_monitor" == "null" ]; then
  echo "Using detected primary monitor"
  primary_monitor="$detected_primary"
fi

echo "Primary monitor: $primary_monitor"

for monitor in "${monitors[@]}"; do
  if [[ "$monitor" == "$primary_monitor" ]]; then
    # Add output to the base primary config
    config=$(jq --arg output "$monitor" '. + {output: $output}' <(echo "$base_config"))
  else
    # Merge with secondary config and add output
    config=$(jq -s --arg output "$monitor" '.[0] * .[1] | . + {output: $output}' <(echo "$base_config") <(echo "$secondary_specific_config"))
  fi
  configs=$(echo "$configs" | jq ". + [$config]")
done

configs=$(echo "$configs" | sed "s/\${primary}/$primary_monitor/g")

echo "$configs" > "$generated_config_path"

waybar -c "$generated_config_path" -s "$style_path" &

# Explicitly release the lock (optional) -> flock releases on exit
flock -u 200
exec 200>&-
