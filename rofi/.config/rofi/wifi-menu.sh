#!/bin/bash
#
# Wi-Fi menu for i3/Polybar using Rofi
# Designed to match the existing minimal style
#

# Use echo for debug instead of notify-send since there's a DBus issue
echo "WiFi Menu started" > /tmp/wifi-menu-debug.log

# Handle Ctrl+C gracefully
trap "exit 0" INT

# Get available Wi-Fi networks - optimized for performance
get_networks() {
    # Cache the networks to improve performance
    if [ ! -f "/tmp/wifi_networks.cache" ] || [ "$(stat -c %Y /tmp/wifi_networks.cache 2>/dev/null || echo 0)" -lt "$(( $(date +%s) - 10 ))" ]; then
        nmcli -t -f SSID,SIGNAL,SECURITY device wifi list | awk -F ':' '{
            sec=""
            if ($3 != "") sec=" 󰌆"
            signal=""
            if ($2 >= 75) signal="󰤨"
            else if ($2 >= 50) signal="󰤥"
            else if ($2 >= 25) signal="󰤢"
            else signal="󰤟"
            # Skip empty SSIDs
            if ($1 != "") print $1 " " signal sec
        }' | sort -u > "/tmp/wifi_networks.cache"
    fi
    
    cat "/tmp/wifi_networks.cache"
}

# Get currently connected network
get_connected() {
    nmcli -t -f NAME,TYPE con show --active | grep wireless | cut -d ':' -f1
}

# Check if a network is in the known connections
is_known() {
    nmcli -t -f NAME con show | grep -q "^$1\$"
    echo "Checking if network '$1' is known, result: $?" >> /tmp/wifi-menu-debug.log
    return $?
}

# Main function
main() {
    connected=$(get_connected)
    
    if [ -n "$connected" ]; then
        # Create special option for current connection with distinct format
        options="$connected (disconnect) 󰂯\n$(get_networks)\n---\nRescan networks 󰑓\nTurn Wi-Fi off 󰖪"
    else
        options="$(get_networks)\n---\nRescan networks 󰑓\nTurn Wi-Fi on 󰖩"
    fi

    # Show the menu with rofi - with optimized parameters
    chosen=$(echo -e "$options" | rofi -dmenu -i -p "Networks" -theme ~/.config/rofi/wifi-menu.rasi -no-fixed-num-lines -markup-rows)

    # Handle the selected option
    case $chosen in
        "Rescan networks")
            nmcli device wifi rescan
            main
            ;;
        "Turn Wi-Fi off")
            nmcli radio wifi off
            echo "Wi-Fi has been turned off" >> /tmp/wifi-menu-debug.log
            ;;
        "Turn Wi-Fi on")
            nmcli radio wifi on
            sleep 1
            echo "Wi-Fi has been turned on" >> /tmp/wifi-menu-debug.log
            main
            ;;
        *"(disconnect)")
            network=$(echo "$chosen" | sed 's/ (disconnect)//')
            nmcli con down id "$network"
            echo "Disconnected from $network" >> /tmp/wifi-menu-debug.log
            ;;
        *)
            if [ -n "$chosen" ]; then
                # Extract network name (remove icons and spaces at the end)
                network=$(echo "$chosen" | sed 's/ 󰤨//g' | sed 's/ 󰤥//g' | sed 's/ 󰤢//g' | sed 's/ 󰤟//g' | sed 's/ 󰌆//g' | sed 's/ 󰂯//g' | awk '{print $1}')
                
                # Debug
                echo "Selected network: '$network'" >> /tmp/wifi-menu-debug.log
                
                # Check if network already exists in known connections
                is_known "$network"
                known_status=$?
                
                if [ $known_status -eq 0 ]; then
                    echo "Network is known, connecting directly" >> /tmp/wifi-menu-debug.log
                    nmcli con up id "$network"
                    notify-send "Wi-Fi" "Connected to $network" || true
                else
                    echo "Network is new, prompting for password" >> /tmp/wifi-menu-debug.log
                    
                    # Simple password prompt that we know works
                    password=$(rofi -dmenu -password -p "Password")
                    
                    echo "Password prompt returned: $?" >> /tmp/wifi-menu-debug.log
                        
                        # Try to connect
                        output=$(nmcli device wifi connect "$network" password "$password" 2>&1)
                        
                        if echo "$output" | grep -q "successfully activated"; then
                            notify-send "Wi-Fi" "Connected to $network" || true
                            echo "Connected to $network" >> /tmp/wifi-menu-debug.log
                        else
                            error_msg=$(echo "$output" | grep -o "Error:.*\." | head -1 || echo "Unknown error")
                            notify-send "Wi-Fi" "Failed to connect: $error_msg" || true
                            echo "Failed to connect: $error_msg" >> /tmp/wifi-menu-debug.log
                            
                            # If connection failed, try again after a short delay
                            sleep 0.5
                            main
                        fi
                    fi
                fi
            fi
            ;;
    esac
}

main
