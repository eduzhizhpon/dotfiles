#!/usr/bin/env bash

waybar_path="$HOME/.config/waybar"

exec 200>/tmp/waybar-launch.lock
flock -n 200 || exit 0

killall -q waybar
while pgrep -x waybar >/dev/null; do sleep 0.1; done
sleep 0.5

style_path="$waybar_path/style.css"
modules_path="$waybar_path/modules.json"
primary_config_path="$waybar_path/configs/primary.json"
secondary_config_path="$waybar_path/configs/secondary.json"
generated_config_path="/tmp/waybar-config.jsonc"
primary_monitor_path="$waybar_path/monitors/$DEVICE.json"

# Get monitor info from hyprctl
mapfile -t monitors < <(hyprctl monitors -j | jq -r '.[] | .name')
modules_config=$(cat "$modules_path")
primary_specific_config=$(cat "$primary_config_path")
secondary_specific_config=$(cat "$secondary_config_path")

configs="[]"

base_config=$(jq -s '.[0] * .[1]' <(echo "$modules_config") <(echo "$primary_specific_config"))

if [ -f "$primary_monitor_path" ]; then
  echo "Reading monitor config: $primary_monitor_path"
  primary_monitor_config=$(cat "$primary_monitor_path")
else
  primary_monitor_config="{}"
fi

primary_monitor=$(echo "$primary_monitor_config" | jq -r '.name')

if [ -z "$primary_monitor" ]; then
  echo "Searching primary monitor"
  primary_monitor=$(hyprctl monitors -j | jq -r '.[] | select(.focused == true) | .name')
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