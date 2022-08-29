#!/bin/bash

# Tap to click and Natural scrolling
sh ~/.config/scripts/xinput-touchpad-props.sh Touchpad

# Set laptop scale
if [[ $(xrandr -q | grep 'HDMI-0 connected') ]]; then
        xrandr --output DP-4 --scale 1x1 --dpi 110 --primary --output HDMI-0 --dpi 110 --mode 1920x1080 --rotate normal --right-of DP-4 --scale 1x1
else
        xrandr --output DP-4 --scale 1x1 --primary --dpi 102
fi

# Wallpaper
feh --bg-fill $WALLPAPER

# Transparenciy
killall picom
picom --experimental-backends &

# Notification - dunts
killall dunst
dunst &

# Reload nvidia backlight
sh /opt/nvidia-settings/nvidia-brightness-load &

#IBus
ibus-daemon -drxR

# Autostart apps
megasync & > /dev/null

# Redshift
# redshift -P -O 5000
# redshift -x # neutral
