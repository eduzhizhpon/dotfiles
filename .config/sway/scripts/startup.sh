#!/bin/bash

[ -f ~/.device/.env ] && source ~/.device/.env

[ -x ~/.config/my-wm/scripts/startup-apps.sh ] && bash ~/.config/my-wm/scripts/startup-apps.sh &

[ -x ~/.device/autostart.sh ] && bash ~/.device/autostart.sh &

[ -x ~/.config/waybar/launch.sh ] && bash ~/.config/waybar/launch.sh &
