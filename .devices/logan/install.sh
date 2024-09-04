#!/bin/bash

if [ -z "$HOME" ]; then
	echo "Home not setted"
	exit 1
fi

DOTFILES_DIR="$HOME/dotfiles"

DOTFILES=(
	".core_env"
	".core_rc"
	".bash_profile"
	".bashrc"
	".local/bin"
	".config/alacritty"
	".config/bspwm"
	".config/dunst"
	".config/gtk-3.0"
	".config/gtk-4.0"
	".config/nvim"
	".config/polybar"	
	".config/rofi"
	".config/sxhkd"
	".config/systemd"
	".config/wallpapers"
	".config/xorg.conf.d"
)

for file in "${DOTFILES[@]}"; do
	echo $file
	rm ~/$file
	ln -sf "$DOTFILES_DIR/$file" ~/$file
done

bash $HOME/.local/bin/dot-install "$DOTFILES_DIR"
