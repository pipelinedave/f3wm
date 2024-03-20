#!/bin/bash

# Workspace name
workspace_name="1"

# Check if Konsole is running in the specified workspace
konsole_running=$(i3-msg -t get_tree | jq -r '.. | select(.type? == "con" and .window_properties?.class? == "konsole") | .workspace.name' | grep -w "$workspace_name")

if [ -z "$konsole_running" ]; then
    # Launch Konsole if it's not running in the specified workspace
    konsole
fi

