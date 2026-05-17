#!/bin/bash

[ -f ~/.device/.env ] && source ~/.device/.env

[ -x ~/.device/autostart.sh ] && bash ~/.device/autostart.sh &

[ -x ~/.config/waybar/launch.sh ] && bash ~/.config/waybar/launch.sh &
