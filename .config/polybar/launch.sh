#!/usr/bin/env sh

## Add this to your wm startup file.

# Terminate already running bar instances
killall -q polybar

## Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

## Launch

## Right bar
polybar date -c ~/.config/polybar/current.ini &
polybar sys-utils -c ~/.config/polybar/current.ini &
polybar sys-tray -c ~/.config/polybar/current.ini &
#polybar sysmenu -c ~/.config/polybar/current.ini &

## Left bar
polybar logo -c ~/.config/polybar/current.ini &
polybar workspaces -c ~/.config/polybar/workspace.ini &
polybar title -c ~/.config/polybar/workspace.ini &

## Center bar

## External Monitor
if [[ $(xrandr -q | grep 'HDMI-0 connected') ]]; then
	polybar logo-external -c ~/.config/polybar/current.ini &
	polybar date-external -c ~/.config/polybar/current.ini &
	polybar workspaces-external -c ~/.config/polybar/workspace.ini &
fi
