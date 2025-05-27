#!/bin/bash
WINDOW=$(i3-msg -t get_tree | jq -r '.. | select(.type?) | select(.window_properties?) | select(.window_properties.class == "Alacritty" and .window_properties.instance == "nvim_todo") | .id')
if [ -n "$WINDOW" ]; then
    i3-msg [con_id="$WINDOW"] move container to workspace current, focus
else
    alacritty --class nvim_todo,alacritty -e nvim ~/todo &
fi
