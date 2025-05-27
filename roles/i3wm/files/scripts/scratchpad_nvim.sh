#!/bin/bash
if ! i3-msg -t get_tree | jq -re '.. | select(.type?) | select(.window_properties?) | select(.window_properties.class == "nvim_todo")' > /dev/null; then
    alacritty --class nvim_todo,Alacritty -e nvim ~/todo &
    sleep 0.5 # Give it a moment to breathe, to come alive
fi
i3-msg [class="nvim_todo"] scratchpad show