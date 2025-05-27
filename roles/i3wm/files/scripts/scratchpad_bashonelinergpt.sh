#!/bin/bash
if ! i3-msg -t get_tree | jq -re '.. | select(.type?) | select(.window_properties?) | select(.window_properties.class == "bashonelinergpt" and .window_properties.instance == "qutebrowser")' > /dev/null; then
    bashonelinergpt &
    sleep 0.5 # Give it a moment to breathe, to come alive
fi
i3-msg [instance="bashonelinergpt"] scratchpad show
