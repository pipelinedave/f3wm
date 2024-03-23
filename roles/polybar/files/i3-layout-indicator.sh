#!/bin/bash

# Fetch the entire tree and details of the currently focused item
TREE=$(i3-msg -t get_tree)
FOCUSED_INFO=$(echo "$TREE" | jq '.. | select(.focused? == true)')

# Extract necessary properties
FOCUSED_WINDOW_ID=$(echo "$FOCUSED_INFO" | jq '.window')
FOCUSED_TYPE=$(echo "$FOCUSED_INFO" | jq -r '.type')

# Handle different focus situations
if [ "$FOCUSED_WINDOW_ID" == "null" ] && [ "$FOCUSED_TYPE" == "workspace" ]; then
  # This is an empty workspace
  printf "%-7s" ""
else
  # There is something focused, find out the layout
  # If focused on a container (possibly due to 'focus parent'), use its layout directly
  if [ "$FOCUSED_WINDOW_ID" == "null" ]; then
    PARENT_LAYOUT=$(echo "$FOCUSED_INFO" | jq -r '.layout')
  else
    # Else, we're focusing on a window, find its parent container's layout
    PARENT_LAYOUT=$(echo "$TREE" | jq --argjson window_id "$FOCUSED_WINDOW_ID" '
      recurse(.nodes[]) | 
      select(.nodes[].window == $window_id) | 
      .layout'
    )
  fi

  # Check if layout is valid, set to 'none' if not
  if [ -z "$PARENT_LAYOUT" ] || [ "$PARENT_LAYOUT" == "null" ]; then
    PARENT_LAYOUT=""
  fi

  # Remove quotes and pad the layout text
  printf "%-7s" $(echo $PARENT_LAYOUT | tr -d '"' | xargs)
fi

