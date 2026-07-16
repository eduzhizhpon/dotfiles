#/bin/bash

# GTK 4 dark theme
gsettings set org.gnome.desktop.interface color-scheme prefer-dark

# Root password modal
/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &

# Composer
if [ "$XDG_SESSION_TYPE" = "x11" ]; then
    killall picom
    picom --config ~/.config/picom/picom.conf &
fi;

# Notification - dunts
if [ "$(command -v dunst)" ]; then
    killall dunst
    dunst & > /dev/null
fi

if [ "$(command -v wl-paste)" ]; then
    killall wl-paste
    wl-paste --watch cliphist store
fi

# RClone to sync OneDrive
# if [ "$(command -v rclone)" ]; then 
	# rclone --vfs-cache-mode writes mount OneDrive:sql-scripts ~/Documents/sql-scripts & > /dev/null
# fi

# Megasync
if [ "$(command -v megasync)" ]; then
	killall megasync
	megasync & > /dev/null
fi

