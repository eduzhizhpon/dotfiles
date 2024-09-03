#!/usr/bin/env sh

## Add this to your wm startup file.

# Terminate already running bar instances
killall -q polybar

## Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

## Launch

## Right bar
polybar date -c ~/.config/polybar/components.ini &
polybar sys-utils -c ~/.config/polybar/components.ini &
polybar sys-tray -c ~/.config/polybar/components.ini &

## Left bar
polybar logo -c ~/.config/polybar/components.ini &
polybar workspaces -c ~/.config/polybar/components.ini &
# polybar title -c ~/.config/polybar/components.ini &
polybar host-ip -c ~/.config/polybar/components.ini &

## External Monitor
if type "xrandr"; then
	for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
		if [ "$m" != "$MONITOR" ]; then
			echo "Config for monitor=$m"
			MONITOR=$m polybar logo-external -c ~/.config/polybar/components.ini &
			MONITOR=$m polybar date-external -c ~/.config/polybar/components.ini &
			MONITOR=$m polybar workspaces-external -c ~/.config/polybar/components.ini &
		fi
	done;
fi
exit 0
