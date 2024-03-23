#!/bin/bash
# Define a function to update the layout display
update_layout() {
    LAYOUT=$(~/.config/polybar/i3-layout-indicator.sh)
    polybar-msg action "#i3-layout.hook.0"
}

# Loop to keep subscribing to i3 events
while true; do
    i3-msg -t subscribe '["workspace","window", "binding"]' | while read -r event; do
        update_layout
    done
    # Optional: sleep for a short time to prevent spamming in case of unexpected rapid exits
    sleep 1
done
