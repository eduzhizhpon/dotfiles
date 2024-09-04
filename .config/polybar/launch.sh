#!/usr/bin/env sh


LEFT_BARS=("logo" "workspaces" "host-ip")
LEFT_BARS_WIDTHS=(50 220 250)

RIGHT_BARS=("date" "sys-utils" "sys-tray")
RIGHT_BARS_WIDTHS=(170 230 200)


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

screen_width=$(get_screen_width "$MONITOR")

process_bars() {
    local offset=5
    local bars=("${@:3:$2}")
    local widths=("${@:$(($2 + 3))}")
    local is_right=$1

    echo "${bars[@]}"
    echo "${widths[@]}"

    if [ "$is_right" == "true" ]; then
        offset=$(($screen_width - 5))  
    fi
    
    for i in "${!bars[@]}"; do
        bar="${bars[$i]}"
        bar_width="${widths[$i]}"
        
        if [ "$is_right" == true ]; then
            offset=$(($offset - $bar_width))  
        fi

        OFFSET_X=$offset WIDTH=$bar_width polybar "$bar" -c ~/.config/polybar/components.ini  &
        
        if [ "$is_right" == true ]; then
            offset=$(($offset - 5))  
        else
            offset=$(($offset + $bar_width + 5))  
        fi
    done
}

process_bars "false" "${#LEFT_BARS[@]}" "${LEFT_BARS[@]}" "${LEFT_BARS_WIDTHS[@]}"
process_bars "true" "${#RIGHT_BARS[@]}" "${RIGHT_BARS[@]}" "${RIGHT_BARS_WIDTHS[@]}"

## External Monitor
for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
	if [ "$m" != "$MONITOR" ]; then
		echo "Config for monitor=$m"
		# MONITOR=$m polybar logo-external -c ~/.config/polybar/components.ini &
		# MONITOR=$m polybar date-external -c ~/.config/polybar/components.ini &
		MONITOR=$m polybar workspaces-external -c ~/.config/polybar/components.ini &
	fi
done;

exit 0
