#!/bin/bash

# Configuration
CACHE_FILE="$HOME/.cache/rofi-file-search.cache"
PROCESSED_CACHE="$HOME/.cache/rofi-file-search-processed.cache"
CACHE_EXPIRY=3600  # Cache expiry in seconds (1 hour)
MAX_RESULTS=200    # Maximum results to show in Rofi

# Create cache directory if it doesn't exist
mkdir -p "$(dirname "$CACHE_FILE")"

# Function to determine icon based on file extension
get_icon() {
    local ext="${1##*.}"
    case "${ext,,}" in
        # Text and documents
        txt|md|rst)               echo "text-x-generic" ;;
        pdf)                      echo "application-pdf" ;;
        doc|docx|odt)             echo "x-office-document" ;;
        xls|xlsx|ods|csv)         echo "x-office-spreadsheet" ;;
        ppt|pptx|odp)             echo "x-office-presentation" ;;
        epub|azw3|mobi)           echo "application-epub+zip" ;;
        
        # Programming
        py|pyc)                   echo "text-x-python" ;;
        c|cpp|h|hpp)              echo "text-x-c++src" ;;
        java)                     echo "text-x-java" ;;
        js|jsx|ts|tsx)            echo "text-x-javascript" ;;
        html|htm|xhtml)           echo "text-html" ;;
        css|scss|sass)            echo "text-css" ;;
        json|xml|yaml|yml)        echo "text-x-script" ;;
        sh|bash|zsh)              echo "text-x-script" ;;
        
        # Media
        jpg|jpeg|png|gif|webp)    echo "image-x-generic" ;;
        svg)                      echo "image-svg+xml" ;;
        mp3|ogg|wav|flac)         echo "audio-x-generic" ;;
        mp4|mkv|avi|mov|webm)     echo "video-x-generic" ;;
        
        # Archives
        zip|tar|gz|xz|bz2|7z|rar) echo "package-x-generic" ;;
        
        # Executable
        exe|appimage|bin)         echo "application-x-executable" ;;
        
        # Other
        *)                        echo "text-x-generic" ;;
    esac
}

# Function to update the file cache - focused on important files
update_cache() {
    echo "Updating cache..." >&2
    
    # Create temporary file
    local temp_file=$(mktemp)
    
    # Find Python-related PDFs and books in Downloads (high priority)
    find "$HOME/Downloads" -type f \( -name "*python*" -o -name "*Python*" \) \( -name "*.pdf" -o -name "*.epub" \) 2>/dev/null | head -n 500 > "$temp_file"
    
    # Find other PDFs in Downloads (medium priority)
    find "$HOME/Downloads" -type f -name "*.pdf" 2>/dev/null | head -n 500 >> "$temp_file"
    
    # Add other commonly used files
    find "$HOME/Documents" "$HOME/Downloads" -type f \( -name "*.pdf" -o -name "*.docx" -o -name "*.xlsx" \) 2>/dev/null | head -n 500 >> "$temp_file"
    
    # Process the files into the format Rofi expects - this is the key optimization
    > "$PROCESSED_CACHE"
    while read -r file; do
        # Skip if file doesn't exist
        [ ! -e "$file" ] && continue
        
        name=$(basename "$file")
        icon=$(get_icon "$name")
        
        # For PDF files and ebooks, show directory info
        if [[ "$name" == *.pdf ]] || [[ "$name" == *.epub ]]; then
            dir=$(dirname "$file" | sed "s|$HOME|~|")
            printf "%s\0icon\x1f%s\0info\x1f%s\n" "$name ($dir)" "$icon" "$file" >> "$PROCESSED_CACHE"
        else
            printf "%s\0icon\x1f%s\0info\x1f%s\n" "$name" "$icon" "$file" >> "$PROCESSED_CACHE"
        fi
    done < "$temp_file"
    
    # Save the raw file list for selections
    mv "$temp_file" "$CACHE_FILE"
    
    # Update cache timestamp
    touch "$CACHE_FILE"
    touch "$PROCESSED_CACHE"
    echo "Cache updated with $(wc -l < "$CACHE_FILE") files" >&2
}

# Handle rebuild command
if [ "$1" = "rebuild" ]; then
    rm -f "$CACHE_FILE" "$PROCESSED_CACHE"
    update_cache
    echo "Cache rebuilt successfully."
    exit 0
fi

# Check if cache needs updating - do this in the background if stale
if [ ! -f "$PROCESSED_CACHE" ] || [ $(($(date +%s) - $(stat -c %Y "$PROCESSED_CACHE"))) -gt "$CACHE_EXPIRY" ]; then
    if [ ! -f "$PROCESSED_CACHE" ]; then
        # Initial build must be synchronous
        update_cache
    else
        # Update in background if already exists
        (update_cache &) 
    fi
fi

# Handle selection to open file
if [ "$ROFI_RETV" = "1" ]; then
    selection="$1"
    
    if [ -n "$ROFI_INFO" ]; then
        # Use the info field if available
        xdg-open "$ROFI_INFO" &>/dev/null &
    else
        # Try to extract path from the display text (for PDFs with path)
        path=$(echo "$selection" | grep -o "(.*/.*)" | sed 's/^(//' | sed 's/)$//' | sed "s|~|$HOME|")
        
        if [ -e "$path" ]; then
            xdg-open "$path" &>/dev/null &
        else
            # Try to find the file in the cache based on name
            base_name=$(echo "$selection" | sed 's/ (.*//')
            path=$(grep -F "$base_name" "$CACHE_FILE" | head -n 1)
            
            if [ -n "$path" ]; then
                xdg-open "$path" &>/dev/null &
            fi
        fi
    fi
    exit 0
fi

# Just output the preprocessed results - this makes startup much faster
if [ -f "$PROCESSED_CACHE" ]; then
    cat "$PROCESSED_CACHE"
else
    # Fallback if processed cache doesn't exist yet
    echo "Generating file list..."
    update_cache
    cat "$PROCESSED_CACHE"
fi
