#!/bin/bash

# Check if an elvi (search engine) is provided
if [ -z "$1" ]; then
  echo "Error: No Surfraw elvi specified."
  echo "Usage: $0 <elvi_name> [dmenu_options]"
  exit 1
fi

ELVI=$1
shift # Remove the first argument, leaving any dmenu options.

# Prompt for a search query using dmenu with passed options
QUERY=$(echo | dmenu -p "[$ELVI]" "$@")

# Check if the query is not empty
if [ -n "$QUERY" ]; then
    # Use surfraw (sr) to search with the specified elvi for the query
    sr "$ELVI" "$QUERY"
fi
