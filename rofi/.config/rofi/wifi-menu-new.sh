#!/usr/bin/env bash
#
# Simple Wi-fi menu for i3/Polybar using Rofi
# Based on ericmurphyxyz's rofi-wifi-menu with button enhancements
#

# Add custom buttons to the script
THEME="~/.config/rofi/wifi-menu.rasi"
ROFI_OPTIONS=(-theme ${THEME} -kb-custom-1 "Alt+r" -kb-custom-2 "Alt+t")

# Get a list of available wifi connections and format it nicely
wifi_list=$(nmcli --fields "SSID,SIGNAL,SECURITY" device wifi list | sed 1d | sed 's/  */ /g' | awk '{
    signal=$2
    if (signal >= 70) icon="󰤨"
    else if (signal >= 50) icon="󰤥"
    else if (signal >= 30) icon="󰤢"
    else icon="󰤟"
    
    security=""
    if ($3 != "--") security="󰌆"
    
    # Print SSID with signal icon
    printf "%s %s %s\n", $1, icon, security
}')

# Check if wifi is enabled
connected=$(nmcli -fields WIFI g)
if [[ "$connected" =~ "enabled" ]]; then
    toggle="󰖪  Disable Wi-Fi"
elif [[ "$connected" =~ "disabled" ]]; then
    toggle="󰖩  Enable Wi-Fi"
fi

# Get currently connected network
current_connection=$(nmcli -t -f NAME,TYPE con show --active | grep wireless | cut -d ':' -f1)
if [[ -n "$current_connection" ]]; then
    current="$current_connection 󰂯  Disconnect"
fi

# Generate Rofi configuration with buttons
cat > /tmp/rofi_wifi.rasi << EOF
@import "${THEME}"

button-rescan {
    str: "󰑓  Rescan Networks";
}

button-toggle {
    str: "${toggle}";
}
EOF

# Use rofi to select wifi network with custom theme and buttons
chosen_network=$(echo -e "$current\n$wifi_list" | rofi -dmenu -i -p "Networks" -theme /tmp/rofi_wifi.rasi "${ROFI_OPTIONS[@]}")
exit_code=$?

if [ $exit_code -eq 10 ]; then
    # Alt+r was pressed - Rescan networks
    nmcli device wifi rescan
    sleep 1
    exec "$0"
    exit 0
elif [ $exit_code -eq 11 ]; then
    # Alt+t was pressed - Toggle wifi
    if [[ "$connected" =~ "enabled" ]]; then
        nmcli radio wifi off
    else
        nmcli radio wifi on
        sleep 1
        exec "$0"
    fi
    exit 0
fi

# Get name of connection (extract SSID)
chosen_id=$(echo "$chosen_network" | awk '{print $1}')

if [ "$chosen_network" = "" ]; then
    exit
elif [[ "$chosen_network" =~ "Disconnect" ]]; then
    nmcli con down id "$current_connection"
else
    # Message to show when connection is activated successfully
    success_message="Connected to Wi-Fi network \"$chosen_id\"."
    
    # Get saved connections
    saved_connections=$(nmcli -g NAME connection)
    if [[ $(echo "$saved_connections" | grep -w "$chosen_id") = "$chosen_id" ]]; then
        nmcli connection up id "$chosen_id" | grep "successfully" && notify-send "Connection Established" "$success_message" || true
    else
        # Use a simple password prompt
        wifi_password=$(rofi -dmenu -password -p "Password" -lines 0)
        
        if [ -n "$wifi_password" ]; then
            nmcli device wifi connect "$chosen_id" password "$wifi_password" | grep "successfully" && notify-send "Connection Established" "$success_message" || true
        fi
    fi
fi
