#!/bin/bash

# Simple Apps-Only Rofi Script
# Just finds and launches applications - no files

# Exit if no query provided
if [ -z "$1" ]; then
    exit 0
fi

QUERY="$1"

# Handle selection when user presses Enter
if [ "$ROFI_RETV" = "1" ]; then
    if [ -n "$ROFI_INFO" ]; then
        # Launch application
        desktop_file="$ROFI_INFO"
        gtk-launch "$(basename "$desktop_file" .desktop)" 2>/dev/null &
    fi
    exit 0
fi

# Search applications only
find /usr/share/applications ~/.local/share/applications -name "*.desktop" 2>/dev/null | while read -r desktop_file; do
    # Extract application info
    name=$(grep "^Name=" "$desktop_file" | head -1 | cut -d'=' -f2-)
    icon=$(grep "^Icon=" "$desktop_file" | head -1 | cut -d'=' -f2- 2>/dev/null)

    # Skip hidden applications
    [ -z "$name" ] && continue
    grep -q "^NoDisplay=true" "$desktop_file" 2>/dev/null && continue
    grep -q "^Hidden=true" "$desktop_file" 2>/dev/null && continue

    # Check if query matches application name (case insensitive)
    if echo "$name" | grep -qi "$QUERY" 2>/dev/null; then
        [ -z "$icon" ] && icon="application-x-executable"
        printf "%s\0icon\x1f%s\0info\x1f%s\n" "$name" "$icon" "$desktop_file"
    fi
done