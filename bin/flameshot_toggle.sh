#!/bin/bash

# Check if Flameshot is running
if pgrep -x "flameshot" > /dev/null; then
    # If running, kill it
    killall flameshot
    notify-send "Flameshot" "Stopped"
else
    # If not running, start it in GUI mode
    flameshot gui &
    notify-send "Flameshot" "Started in GUI mode"
fi
