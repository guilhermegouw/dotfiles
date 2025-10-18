#!/bin/bash

# Unified Search for Rofi - Apps + Files
# Searches applications first, then files using fd for fast performance

# Configuration
MAX_APPS=15
MAX_FILES=25

# Debug logging
debug_log() {
    echo "$(date): $1" >> /tmp/rofi-unified-debug.log
}

# Function to get icon for file types
get_file_icon() {
    local file="$1"
    local ext="${file##*.}"
    case "${ext,,}" in
        # Documents
        pdf) echo "application-pdf" ;;
        doc|docx|odt) echo "x-office-document" ;;
        xls|xlsx|ods|csv) echo "x-office-spreadsheet" ;;
        ppt|pptx|odp) echo "x-office-presentation" ;;
        txt|md|rst) echo "text-x-generic" ;;

        # Programming
        py|pyc) echo "text-x-python" ;;
        js|jsx|ts|tsx) echo "text-x-javascript" ;;
        html|htm) echo "text-html" ;;
        css|scss|sass) echo "text-css" ;;
        c|cpp|h|hpp) echo "text-x-c++src" ;;
        java) echo "text-x-java" ;;
        sh|bash|zsh) echo "text-x-script" ;;
        json|xml|yaml|yml) echo "text-x-script" ;;

        # Media
        jpg|jpeg|png|gif|webp|bmp) echo "image-x-generic" ;;
        svg) echo "image-svg+xml" ;;
        mp3|ogg|wav|flac|m4a) echo "audio-x-generic" ;;
        mp4|mkv|avi|mov|webm|flv) echo "video-x-generic" ;;

        # Archives
        zip|tar|gz|xz|bz2|7z|rar) echo "package-x-generic" ;;

        # Other
        *) echo "text-x-generic" ;;
    esac
}

# Function to search applications
search_apps() {
    local query="$1"
    local app_count=0

    debug_log "Searching apps for: $query"

    # Create temporary file to collect results
    local temp_file=$(mktemp)

    # Search .desktop files in standard locations
    for dir in "/usr/share/applications" "/usr/local/share/applications" "$HOME/.local/share/applications"; do
        if [ -d "$dir" ]; then
            find "$dir" -name "*.desktop" -type f 2>/dev/null | while read -r desktop_file; do
                # Extract app info
                name=$(grep "^Name=" "$desktop_file" | head -1 | cut -d'=' -f2-)
                comment=$(grep "^Comment=" "$desktop_file" | head -1 | cut -d'=' -f2- 2>/dev/null)
                keywords=$(grep "^Keywords=" "$desktop_file" | head -1 | cut -d'=' -f2- | tr ';' ' ' 2>/dev/null)
                icon=$(grep "^Icon=" "$desktop_file" | head -1 | cut -d'=' -f2- 2>/dev/null)

                # Skip if no name or if hidden
                [ -z "$name" ] && continue
                grep -q "^NoDisplay=true" "$desktop_file" 2>/dev/null && continue
                grep -q "^Hidden=true" "$desktop_file" 2>/dev/null && continue

                # Check if query matches name, comment, or keywords (case insensitive)
                search_text="$name $comment $keywords"
                if echo "$search_text" | grep -qi "$query" 2>/dev/null; then
                    # Default icon if none specified
                    [ -z "$icon" ] && icon="application-x-executable"

                    # Output to temp file
                    printf "%s\0icon\x1f%s\0info\x1fapp:%s\n" "$name" "$icon" "$desktop_file" >> "$temp_file"
                fi
            done
        fi
    done

    # Output results (limited to MAX_APPS)
    head -n $MAX_APPS "$temp_file"
    rm -f "$temp_file"
}

# Function to search files using locate (fallback to find)
search_files() {
    local query="$1"

    debug_log "Searching files for: $query"

    # Create temporary file for results
    local temp_file=$(mktemp)

    # Try locate first (fastest)
    if command -v locate >/dev/null 2>&1; then
        locate -i "*$query*" 2>/dev/null | grep "^$HOME" | while read -r filepath; do
            [ ! -f "$filepath" ] && continue

            # Skip some noisy directories
            case "$filepath" in
                */.git/*|*/.cache/*|*/node_modules/*|*/.npm/*|*/.cargo/*|*/.local/share/Trash/*) continue ;;
            esac

            filename=$(basename "$filepath")
            dirname=$(dirname "$filepath" | sed "s|$HOME|~|")
            icon=$(get_file_icon "$filename")

            # Shorten long directory paths
            if [ ${#dirname} -gt 45 ]; then
                short_dir="...${dirname: -42}"
            else
                short_dir="$dirname"
            fi

            # Output to temp file
            printf "%s\0icon\x1f%s\0info\x1ffile:%s\n" "$filename ($short_dir)" "$icon" "$filepath" >> "$temp_file"
        done
    else
        # Fallback to find if locate isn't available
        find "$HOME" -type f -iname "*$query*" \
            -not -path "*/.git/*" \
            -not -path "*/.cache/*" \
            -not -path "*/node_modules/*" \
            -not -path "*/.npm/*" \
            -not -path "*/.cargo/*" \
            -not -path "*/.local/share/Trash/*" \
            2>/dev/null | while read -r filepath; do

            filename=$(basename "$filepath")
            dirname=$(dirname "$filepath" | sed "s|$HOME|~|")
            icon=$(get_file_icon "$filename")

            # Shorten long directory paths
            if [ ${#dirname} -gt 45 ]; then
                short_dir="...${dirname: -42}"
            else
                short_dir="$dirname"
            fi

            printf "%s\0icon\x1f%s\0info\x1ffile:%s\n" "$filename ($short_dir)" "$icon" "$filepath" >> "$temp_file"
        done
    fi

    # Output results (limited to MAX_FILES)
    head -n $MAX_FILES "$temp_file"
    rm -f "$temp_file"
}

# Handle selection when user presses Enter
if [ "$ROFI_RETV" = "1" ]; then
    debug_log "Selection made: $1"
    debug_log "ROFI_INFO: $ROFI_INFO"

    if [ -n "$ROFI_INFO" ]; then
        case "$ROFI_INFO" in
            app:*)
                # Launch application
                desktop_file="${ROFI_INFO#app:}"
                debug_log "Launching app: $desktop_file"
                gtk-launch "$(basename "$desktop_file" .desktop)" 2>/dev/null &
                ;;
            file:*)
                # Open file
                filepath="${ROFI_INFO#file:}"
                debug_log "Opening file: $filepath"
                xdg-open "$filepath" 2>/dev/null &
                ;;
        esac
    fi
    exit 0
fi

# Main search function
if [ $# -eq 0 ]; then
    # No arguments - show default suggestions
    debug_log "No query provided, showing defaults"

    # Show popular applications first
    printf "Firefox\0icon\x1ffirefox\0info\x1fapp:/usr/share/applications/firefox.desktop\n"
    printf "Files\0icon\x1forg.gnome.Nautilus\0info\x1fapp:/usr/share/applications/org.gnome.Nautilus.desktop\n"
    printf "Terminal\0icon\x1futilities-terminal\0info\x1fapp:/usr/share/applications/org.gnome.Terminal.desktop\n"
    printf "Text Editor\0icon\x1faccessories-text-editor\0info\x1fapp:/usr/share/applications/org.gnome.TextEditor.desktop\n"

    # Show some recent files
    find "$HOME/Downloads" "$HOME/Documents" -type f -printf '%T@ %p\n' 2>/dev/null | \
        sort -nr | head -5 | cut -d' ' -f2- | while read -r filepath; do
        [ -f "$filepath" ] || continue
        filename=$(basename "$filepath")
        dirname=$(dirname "$filepath" | sed "s|$HOME|~|")
        icon=$(get_file_icon "$filename")
        printf "%s\0icon\x1f%s\0info\x1ffile:%s\n" "$filename ($dirname)" "$icon" "$filepath"
    done
else
    # Search mode
    query="$*"
    debug_log "Starting search for: $query"

    # Search apps first (higher priority)
    search_apps "$query"

    # Then search files
    search_files "$query"
fi