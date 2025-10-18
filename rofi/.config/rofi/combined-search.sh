#!/bin/bash

# Don't show placeholder message
if [ -z "$1" ]; then
  exit 0
fi

# Applications section - use case-insensitive matching to catch partial inputs
find /usr/share/applications ~/.local/share/applications -name "*.desktop" 2>/dev/null | 
grep -i "$1" | head -n 10 | while read -r app_path; do
  app_name=$(grep -m 1 "^Name=" "$app_path" | cut -d'=' -f2)
  icon=$(grep -m 1 "^Icon=" "$app_path" | cut -d'=' -f2)
  [ -z "$app_name" ] && app_name=$(basename "$app_path" .desktop)
  [ -z "$icon" ] && icon="application-x-executable"
  echo -en "$app_name\0icon\x1f$icon\0info\x1f$app_path\n"
done

# Files section - using locate with case-insensitive matching
locate -i "$1" | grep -i "$1" | head -n 20 | while read -r file; do
  if [[ -f "$file" || -d "$file" ]]; then
    filename=$(basename "$file")
    if [[ -d "$file" ]]; then
      icon="folder"
    elif [[ "$file" == *.jpg || "$file" == *.jpeg || "$file" == *.png ]]; then
      icon="image-x-generic"
    elif [[ "$file" == *.mp4 || "$file" == *.mkv || "$file" == *.avi ]]; then
      icon="video-x-generic"
    elif [[ "$file" == *.pdf ]]; then
      icon="application-pdf"
    elif [[ "$file" == *.doc* || "$file" == *.odt ]]; then
      icon="x-office-document"
    elif [[ "$file" == *.mp3 || "$file" == *.ogg || "$file" == *.flac ]]; then
      icon="audio-x-generic"
    else
      icon="text-x-generic"
    fi
    echo -en "$filename\0icon\x1f$icon\0info\x1f$file\n"
  fi
done
