#!/bin/bash

if [ -z "$HOME" ]; then
	echo "Home not setted"
	exit 1
fi

bash $HOME/.local/bin/dot-install
