#!/bin/bash

# File path: ~/.config/polybar/power-profile-switcher.sh

# Get current power profile
current_profile=$(powerprofilesctl get)

# Get available power profiles
readarray -t profiles <<< "$(powerprofilesctl list | grep -E '^\s+[*]?[a-zA-Z-]+:' | grep -vE '(CpuDriver|Degraded|PlatformDriver)' | awk -F':' '{print $1}' | tr -d ' *')"

# This function updates the Polybar module
update_polybar() {
    echo "%{F#F0C674}${current_profile}%{F-}"
}

# This function cycles through the available power profiles
change_profile() {
    # Find the index of the current profile in the profiles array
    current_index=-1
    for i in "${!profiles[@]}"; do
        if [[ "${profiles[$i]}" == "${current_profile}" ]]; then
            current_index=$i
            break
        fi
    done

    # Calculate the index of the next profile
    if [[ $current_index -ne -1 ]]; then
        next_index=$(( (current_index + 1) % ${#profiles[@]} ))
        new_profile=${profiles[$next_index]}
        
        echo "$new_profile"
        # Set the new profile
        powerprofilesctl set "$new_profile"
        current_profile=$new_profile
    fi

    update_polybar
}

# Main script logic for handling --toggle
case "$1" in
    --toggle)
        change_profile
        ;;
    *)
        update_polybar
        ;;
esac

