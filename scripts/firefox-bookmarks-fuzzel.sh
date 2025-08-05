#!/usr/bin/env bash

# Define an icon for Nerd Font users.
ICON=""

# Generate menu entries, run fuzzel, and capture the full selected line.
# The format is "ICON TITLE | URL".
selection=$(foxmarks bookmarks | while IFS=";" read -r title url; do
  # Use the title, but fall back to the URL if the title is empty.
  display_text="${title:-$url}"
  printf "%s %s | %s\n" "$ICON" "$display_text" "$url"
done | fuzzel --dmenu --lines 15 --prompt "Bookmarks > ")

# If a selection was made (i.e., user didn't press Escape)...
if [[ -n "$selection" ]]; then
  # Use awk to extract the URL from the selected line.
  # It treats " | " (space-pipe-space) as the separator and prints the last field ($NF),
  # which is the URL. This is the key part of your working script.
  url=$(echo "$selection" | awk -F ' \\| ' '{print $NF}')

  # Open the cleanly extracted URL.
  xdg-open "$url"
fi
