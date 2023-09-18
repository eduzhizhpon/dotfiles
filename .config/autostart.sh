#!/bin/bash

# Tap to click and Natural scrolling
sh ~/.config/scripts/xinput-touchpad-props.sh Touchpad


# Composer
killall picom
picom --config ~/.config/picom/picom.conf &

# Notification - dunts
killall dunst
dunst &

#IBus
ibus-daemon -drxR


#
#	GTK 4 dark theme
#
gsettings set org.gnome.desktop.interface color-scheme prefer-dark


 /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &
