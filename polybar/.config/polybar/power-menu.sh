#!/usr/bin/env bash

# Rofi theme path
THEME_PATH="$HOME/.config/rofi/powermenu.rasi"

# Rofi command with simple prompt parameter (avoid theme-str)
rofi_command="rofi -theme $THEME_PATH -dmenu -i -p"

# Options with icons
lock="󰌾 Lock"
suspend="󰤄 Suspend"
logout="󰗽 Logout"
restart="󰜉 Restart"
poweroff="⏻ Shutdown"

# Create menu options
OPTIONS="$poweroff\n$restart\n$lock\n$suspend\n$logout"

# Show the menu and get user choice
chosen="$(echo -e "$OPTIONS" | $rofi_command '')"

# Execute based on choice
case "$chosen" in
    "$poweroff") 
        systemctl poweroff 
        ;;
    "$restart") 
        systemctl reboot 
        ;;
    "$lock") 
        i3lock -c 000000 
        ;;
    "$suspend") 
        systemctl suspend 
        ;;
    "$logout") 
        i3-msg exit 
        ;;
    *) 
        exit 0
        ;;
esac
