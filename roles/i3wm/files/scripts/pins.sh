#!/bin/bash

PINS_FILE="$HOME/.config/pins/.pinned_apps"

case $1 in
  pin)
    echo "${@:2}" >> "$PINS_FILE"
    sort -uo "$PINS_FILE" "$PINS_FILE"
    ;;
  unpin)
    grep -vFx "${@:2}" "$PINS_FILE" > "${PINS_FILE}.tmp" && mv "${PINS_FILE}.tmp" "$PINS_FILE"
    ;;
  *)
    cat "$PINS_FILE" | dmenu -l 20 -i -p '[pinned]' -fn 'Source Code Pro-14' -nb '#282828' -nf '#C5C8C6' -sb '#28F028' -sf '#282828' | xargs -r -I{} nohup {} > /dev/null 2>&1 &
    ;;
esac

