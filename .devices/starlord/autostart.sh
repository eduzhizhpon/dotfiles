#!/bin/bash

# Composer
if [ "$XDG_SESSION_TYPE" = "x11" ]; then
    killall picom
    picom --config ~/.config/picom/picom.conf &
fi;

# Notification - dunts
killall dunst
dunst &

# Root password modal
/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &


# RClone to sync OneDrive
# if [ "$(command -v rclone)" ]; then 
	# rclone --vfs-cache-mode writes mount OneDrive:sql-scripts ~/Documents/sql-scripts & > /dev/null
# fi
