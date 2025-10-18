#!/usr/bin/env bash

# Options
lock="  Lock"
restart="  Restart"
sleep="  Sleep"
poweroff="  Power off"

# Rofi command
rofi_command="rofi -theme ~/.config/rofi/powermenu.rasi"

# Show the menu and get user choice
chosen="$(echo -e "$lock\n$restart\n$sleep\n$poweroff" | $rofi_command -dmenu -selected-row 0)"

# Execute based on choice
case $chosen in
    $lock)
        # Replace with your preferred lock command
        i3lock -c 1e1e2e
        ;;
    $restart)
        systemctl reboot
        ;;
    $sleep)
        systemctl suspend
        ;;
    $poweroff)
        systemctl poweroff
        ;;
esac
