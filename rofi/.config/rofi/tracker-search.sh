#!/bin/bash

# Tracker-based Rofi Search
# Provides GNOME-like search experience using tracker3

# Exit if no query provided
if [ -z "$1" ]; then
    exit 0
fi

QUERY="$1"
MAX_RESULTS=20

# Function to get appropriate icon based on file type
get_icon() {
    local file="$1"
    local mime_type=$(file --mime-type -b "$file" 2>/dev/null)

    case "$mime_type" in
        # Applications
        application/x-desktop) echo "application-x-executable" ;;

        # Documents
        application/pdf) echo "application-pdf" ;;
        application/msword|application/vnd.openxmlformats-officedocument.wordprocessingml.document) echo "x-office-document" ;;
        application/vnd.ms-excel|application/vnd.openxmlformats-officedocument.spreadsheetml.sheet) echo "x-office-spreadsheet" ;;
        application/vnd.ms-powerpoint|application/vnd.openxmlformats-officedocument.presentationml.presentation) echo "x-office-presentation" ;;

        # Text files
        text/*) echo "text-x-generic" ;;

        # Images
        image/*) echo "image-x-generic" ;;

        # Audio
        audio/*) echo "audio-x-generic" ;;

        # Video
        video/*) echo "video-x-generic" ;;

        # Archives
        application/zip|application/x-tar|application/x-compressed*) echo "package-x-generic" ;;

        # Directories
        inode/directory) echo "folder" ;;

        # Default
        *) echo "text-x-generic" ;;
    esac
}

# Handle selection when user presses Enter
if [ "$ROFI_RETV" = "1" ]; then
    if [ -n "$ROFI_INFO" ]; then
        case "$ROFI_INFO" in
            app:*)
                # Launch application
                desktop_file="${ROFI_INFO#app:}"
                gtk-launch "$(basename "$desktop_file" .desktop)" 2>/dev/null &
                ;;
            file:*)
                # Open file
                filepath="${ROFI_INFO#file:}"
                xdg-open "$filepath" 2>/dev/null &
                ;;
        esac
    fi
    exit 0
fi

# Search applications first
find /usr/share/applications ~/.local/share/applications -name "*.desktop" 2>/dev/null | while read -r desktop_file; do
    # Extract application info
    name=$(grep "^Name=" "$desktop_file" | head -1 | cut -d'=' -f2-)
    comment=$(grep "^Comment=" "$desktop_file" | head -1 | cut -d'=' -f2- 2>/dev/null)
    icon=$(grep "^Icon=" "$desktop_file" | head -1 | cut -d'=' -f2- 2>/dev/null)

    # Skip hidden applications
    [ -z "$name" ] && continue
    grep -q "^NoDisplay=true" "$desktop_file" 2>/dev/null && continue
    grep -q "^Hidden=true" "$desktop_file" 2>/dev/null && continue

    # Check if query matches
    if echo "$name $comment" | grep -qi "$QUERY" 2>/dev/null; then
        [ -z "$icon" ] && icon="application-x-executable"
        printf "%s\0icon\x1f%s\0info\x1fapp:%s\n" "$name" "$icon" "$desktop_file"
    fi
done | head -n 5

# Search files using localsearch (modern tracker replacement)
if command -v localsearch >/dev/null 2>&1; then
    # Use localsearch - this provides the GNOME-like search experience!
    localsearch search --limit=$MAX_RESULTS --disable-color "$QUERY" 2>/dev/null | awk '
    /^  file:\/\// {
        # Extract file URI and print it
        print $1
    }' | while read -r file_uri; do
        # Convert URI to file path using proper escaping
        filepath=$(python3 -c "import urllib.parse, sys; print(urllib.parse.unquote(sys.argv[1].replace('file://', '')))" "$file_uri")

        # Skip if file doesn't exist
        [ ! -e "$filepath" ] && continue

        # Skip some noisy directories
        case "$filepath" in
            */.git/*|*/.cache/*|*/node_modules/*|*/.npm/*|*/.cargo/*|*/.local/share/Trash/*) continue ;;
        esac

        filename=$(basename "$filepath")
        dirname=$(dirname "$filepath" | sed "s|$HOME|~|")
        icon=$(get_icon "$filepath")

        # Shorten long directory paths
        if [ ${#dirname} -gt 50 ]; then
            short_dir="...${dirname: -47}"
        else
            short_dir="$dirname"
        fi

        printf "%s\0icon\x1f%s\0info\x1ffile:%s\n" "$filename ($short_dir)" "$icon" "$filepath"
    done
else
    # Fallback to locate if localsearch isn't available
    locate -i "*$QUERY*" 2>/dev/null | grep "^$HOME" | head -n $MAX_RESULTS | while read -r filepath; do
        [ ! -f "$filepath" ] && continue

        # Skip noisy directories
        case "$filepath" in
            */.git/*|*/.cache/*|*/node_modules/*|*/.npm/*|*/.cargo/*|*/.local/share/Trash/*) continue ;;
        esac

        filename=$(basename "$filepath")
        dirname=$(dirname "$filepath" | sed "s|$HOME|~|")
        icon=$(get_icon "$filepath")

        if [ ${#dirname} -gt 50 ]; then
            short_dir="...${dirname: -47}"
        else
            short_dir="$dirname"
        fi

        printf "%s\0icon\x1f%s\0info\x1ffile:%s\n" "$filename ($short_dir)" "$icon" "$filepath"
    done
fi