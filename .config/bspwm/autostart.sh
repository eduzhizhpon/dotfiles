#!/bin/bash

# Tap to click and Natural scrolling
sh ~/.config/scripts/xinput-touchpad-props.sh Touchpad

# Composer
killall picom
#picom --experimental-backends &
picom --config ~/.config/bspwm/config/picom.conf &

# Notification - dunts
killall dunst
dunst &

# Reload nvidia backlight
sh /opt/nvidia-settings/nvidia-brightness-load &

#IBus
ibus-daemon -drxR

# Autostart apps
killall megasync
megasync & > /dev/null

# Redshift
# redshift -P -O 5000
# redshift -x # neutral


#
# GTK 4 dark theme
#
gsettings set org.gnome.desktop.interface color-scheme prefer-dark



/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &
