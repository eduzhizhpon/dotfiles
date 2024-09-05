#!/usr/bin/env sh


LEFT_BARS=("logo" "workspaces" "host-ip")

RIGHT_BARS=("date" "sys-utils" "sys-tray")

EXTERNAL_LEFT_BARS=("logo" "workspaces")

EXTERNAL_RIGHT_BARS=("date")

declare -A WIDTHS=( 
    ["logo"]=53 
    ["workspaces"]=220
    ["host-ip"]=250
    ["date"]=170
    ["sys-utils"]=250
    ["sys-tray"]=200
)


# Terminate already running bar instances
killall -q polybar

## Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

## Launch

get_screen_width() {
    local monitor="$1"
    monitor_width=$(xrandr | grep "^$monitor connected" | awk '{for(i=1;i<NF;i++) if($i ~ /^[0-9]+x[0-9]+\+/) print $i}' | cut -d '+' -f 1 | cut -d 'x' -f 1)
    echo "$monitor_width"
}

process_bars() {
    local offset=5
    local is_right=$1
    local monitor=$2
    local bars=("${@:3}")
    local screen_width=$(get_screen_width "$monitor")

    if [ "$is_right" == "true" ]; then
        offset=$(($screen_width - 5))  
    fi
    
    for i in "${!bars[@]}"; do
        bar="${bars[$i]}"
        bar_width="${WIDTHS[$bar]}"
        
        if [ "$is_right" == true ]; then
            offset=$(($offset - $bar_width))  
        fi

        MONITOR=$monitor OFFSET_X=$offset WIDTH=$bar_width polybar "$bar" -c ~/.config/polybar/components.ini  &
        
        if [ "$is_right" == true ]; then
            offset=$(($offset - 5))  
        else
            offset=$(($offset + $bar_width + 5))  
        fi
    done
}

process_bars "false" "$MONITOR" "${LEFT_BARS[@]}"

process_bars "true" "$MONITOR" "${RIGHT_BARS[@]}"

## External Monitor
for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
	if [ "$m" != "$MONITOR" ]; then
		echo "Config for monitor=$m"
        process_bars "false" "$m" "${EXTERNAL_LEFT_BARS[@]}"
    
        process_bars "true" "$m" "${EXTERNAL_RIGHT_BARS[@]}"
	fi
done;

exit 0
