#!/bin/bash

# BSPWM
sh ~/.config/bspwm/bspwmrc &

# Autostart apps
killall megasync
# megasync & > /dev/null
