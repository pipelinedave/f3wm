#!/bin/bash

# Workspace name
workspace_name="1"

# Check if ChatGPT is running in the specified workspace
chatgpt_running=$(i3-msg -t get_tree | jq -r '.. | select(.type? == "con" and .window_properties?.instance? == "crx_adcclpceapdbhchilkbngkehpppaefko") | .workspace.name' | grep -w "$workspace_name")

if [ -z "$chatgpt_running" ]; then
    # Launch ChatGPT if it's not running in the specified workspace
    google-chrome --app-id=crx_adcclpceapdbhchilkbngkehpppaefko
fi

