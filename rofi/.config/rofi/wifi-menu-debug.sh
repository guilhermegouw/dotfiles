#!/bin/bash
#
# Wi-Fi menu for i3/Polybar using Rofi (Simplified debug version)
#

# Clear the debug log
echo "WiFi Menu started" > /tmp/wifi-menu-debug.log

# Get available Wi-Fi networks
get_networks() {
    nmcli -t -f SSID,SIGNAL device wifi list | awk -F ':' '{
        if ($1 != "") print $1
    }' | sort -u
}

# Get currently connected network
get_connected() {
    nmcli -t -f NAME,TYPE con show --active | grep wireless | cut -d ':' -f1
}

# Check if a network is in the known connections
is_known() {
    nmcli -t -f NAME con show | grep -q "^$1\$"
    return $?
}

# Main function
main() {
    connected=$(get_connected)
    
    # Get available networks
    networks=$(get_networks)
    echo "Available networks: $networks" >> /tmp/wifi-menu-debug.log
    
    if [ -n "$connected" ]; then
        options="$connected (disconnect)\n$networks\nRescan networks\nTurn Wi-Fi off"
    else
        options="$networks\nRescan networks\nTurn Wi-Fi on"
    fi

    # Show the menu with rofi - using the simplest possible options
    chosen=$(echo -e "$options" | rofi -dmenu -p "Networks")
    
    echo "Chosen option: $chosen" >> /tmp/wifi-menu-debug.log

    # Handle the selected option
    case $chosen in
        "Rescan networks")
            nmcli device wifi rescan
            sleep 1
            main
            ;;
        "Turn Wi-Fi off")
            nmcli radio wifi off
            echo "Wi-Fi turned off" >> /tmp/wifi-menu-debug.log
            ;;
        "Turn Wi-Fi on")
            nmcli radio wifi on
            sleep 1
            echo "Wi-Fi turned on" >> /tmp/wifi-menu-debug.log
            main
            ;;
        *"(disconnect)")
            network=$(echo "$chosen" | sed 's/ (disconnect)//')
            nmcli con down id "$network"
            echo "Disconnected from $network" >> /tmp/wifi-menu-debug.log
            ;;
        *)
            if [ -n "$chosen" ]; then
                network="$chosen"
                
                echo "Selected network: $network" >> /tmp/wifi-menu-debug.log
                
                # Check if known
                is_known "$network"
                known_status=$?
                echo "Known status ($known_status): $known_status" >> /tmp/wifi-menu-debug.log
                
                if [ $known_status -eq 0 ]; then
                    echo "Network is known" >> /tmp/wifi-menu-debug.log
                    nmcli con up id "$network"
                else
                    echo "Network is new, prompting for password" >> /tmp/wifi-menu-debug.log
                    
                    # This should be the simplest possible password prompt
                    password=$(rofi -dmenu -password -p "Password")
                    
                    echo "Password prompt returned with status: $?" >> /tmp/wifi-menu-debug.log
                    
                    if [ -n "$password" ]; then
                        echo "Got password, connecting..." >> /tmp/wifi-menu-debug.log
                        nmcli device wifi connect "$network" password "$password"
                        echo "Connection attempt completed" >> /tmp/wifi-menu-debug.log
                    else
                        echo "No password entered" >> /tmp/wifi-menu-debug.log
                    fi
                fi
            fi
            ;;
    esac
}

main
