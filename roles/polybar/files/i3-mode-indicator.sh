#!/bin/bash
i3-msg -t subscribe -m '[ "mode" ]' | while read -r line ; do
    mode=$(echo $line | jq -r '.change')
    if [ "$mode" == "default" ]; then
        echo ""
    else
        echo "Mode: $mode"
    fi
done

