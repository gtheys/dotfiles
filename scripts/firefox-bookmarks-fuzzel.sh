#!/usr/bin/env bash

# Generate menu entries with titles
selection=$(foxmarks bookmarks | while IFS=";" read -r title url; do
  printf "%s | %s\n" "$title" "$url"
done | fuzzel --dmenu)

# Extract URL from selection and open it
if [[ -n "$selection" ]]; then
  url=$(echo "$selection" | awk -F' | ' '{print $NF}')
  xdg-open "$url"
fi
