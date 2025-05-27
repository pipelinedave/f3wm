#!/bin/bash
URL="$1"

# YouTube
if [[ "$URL" =~ ^https?://(www\.)?youtube\.com ]] || [[ "$URL" =~ ^https?://youtu\.be ]]; then
  echo "Opening in YouTube"
  ~/.local/bin/youtube "$URL"

# ChatGPT
elif [[ "$URL" =~ chat\.openai\.com ]]; then
  echo "Opening in ChatGPT"
  ~/.local/bin/chatgpt "$URL"

# Google Calendar
elif [[ "$URL" =~ calendar\.google\.com ]]; then
  echo "Opening in Google Calendar"
  ~/.local/bin/gcalendar "$URL"

# Google Drive
elif [[ "$URL" =~ drive\.google\.com ]]; then
  echo "Opening in Google Drive"
  ~/.local/bin/gdrive "$URL"

# GitHub
elif [[ "$URL" =~ github\.com ]]; then
  echo "Opening in GitHub"
  ~/.local/bin/github "$URL"

# Gmail
elif [[ "$URL" =~ mail\.google\.com ]]; then
  echo "Opening in Gmail"
  ~/.local/bin/gmail "$URL"

# Google Maps
elif [[ "$URL" =~ maps\.google\.com ]]; then
  echo "Opening in Google Maps"
  ~/.local/bin/gmaps "$URL"

# Google Photos
elif [[ "$URL" =~ photos\.google\.com ]]; then
  echo "Opening in Google Photos"
  ~/.local/bin/gphotos "$URL"

# WhatsApp
elif [[ "$URL" =~ web\.whatsapp\.com ]]; then
  echo "Opening in WhatsApp"
  ~/.local/bin/whatsapp "$URL"

else
  # Default browser or action
  echo "Opening in browser"
  qutebrowser "$URL"
fi

