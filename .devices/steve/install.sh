#!/bin/bash

if [ -z "$HOME" ]; then
	echo "Home not setted"
	exit 1
fi

DOTFILES_DIR="$HOME"
DEVICE="$HOSTNAME"

echo "Installing in $DOTFILES_DIR for $DEVICE"

ln -sf  "$DOTFILES_DIR/.devices/$DEVICE/autostart.sh" ~/.config/autostart.sh
echo ".config/autostart.sh"

ln -sf  "$DOTFILES_DIR/.devices/$DEVICE/.device_env" ~/.device_env
echo ".device_env"

bash $HOME/.local/bin/dot-install
