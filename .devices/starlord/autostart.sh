#!/bin/bash

# Composer
killall picom
picom --config ~/.config/picom/picom.conf &

# Notification - dunts
killall dunst
dunst &

# Clip manager
killall copyq
pgrep -x copyq || copyq &

# Root password modal
/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &


# Autostart apps
if [ "$(command -v megasync)" ]; then
	killall megasync
	megasync & > /dev/null
fi

# RClone to sync OneDrive
# if [ "$(command -v rclone)" ]; then 
	# rclone --vfs-cache-mode writes mount OneDrive:sql-scripts ~/Documents/sql-scripts & > /dev/null
# fi
