#/bin/bash

# GTK 4 dark theme
gsettings set org.gnome.desktop.interface color-scheme prefer-dark

# Root password modal
if [ -f /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 ]; then
    killall polkit-gnome-authentication-agent-1 2>/dev/null || true
    /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &
fi

# Composer
if [ "$XDG_SESSION_TYPE" = "x11" ]; then
    killall picom
    picom --config ~/.config/picom/picom.conf &
fi;


# Notification - dunst
if [ "$(command -v dunst)" ]; then
    killall dunst 2>/dev/null || true
    if [ -f ~/.config/my-wm/theme/generated/dunstrc ]; then
        dunst -config ~/.config/my-wm/theme/generated/dunstrc & > /dev/null
    else
        dunst & > /dev/null
    fi
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

