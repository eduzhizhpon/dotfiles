#!/bin/bash

[ -x ~/.device/autostart.sh ] && bash ~/.device/autostart.sh &

[ -x ~/.config/waybar/launch.sh ] && bash ~/.config/waybar/launch.sh &
