#!/usr/bin/env bash

scan_networks() {
    sleep 2
    nmcli device wifi rescan
    sleep 1
}

while :; do
    device_status=$(nmcli -fields WIFI g | grep -o "enabled\|disabled")
    if [[ "$device_status" == "enabled" ]]; then
        toggle="  Adapter on"
    else
        toggle="  Adapter off"
    fi

    network_list=$(nmcli --fields "SSID,SIGNAL,SECURITY" -t device wifi list | sed "/--/d")

    formatted_network_list=$(echo "$network_list" | while IFS= read -r line; do
        ssid=$(echo "$line" | awk -F':' '{print $1}')
        signal=$(echo "$line" | awk -F':' '{print $2}')
        security=$(echo "$line" | awk -F':' '{print $3}')

        [[ ! "$signal" =~ ^[0-9]+$ ]] && continue

        case $signal in
            8[0-9]|9[0-9]|100) icon_signal="󰤪" ;;
            6[0-9]|7[0-9])     icon_signal="󰤧" ;;
            4[0-9]|5[0-9])     icon_signal="󰤤" ;;
            2[0-9]|3[0-9])     icon_signal="󰤡" ;;
            *)                 icon_signal="󰤬" ;;
        esac

        if [[ "$security" == "--" || -z "$security" ]]; then
            case $signal in
                8[0-9]|9[0-9]|100) icon="󰤨" ;;
                6[0-9]|7[0-9])     icon="󰤥" ;;
                4[0-9]|5[0-9])     icon="󰤢" ;;
                2[0-9]|3[0-9])     icon="󰤟" ;;
                *)                 icon="󰤯" ;;
            esac
        else
            icon=$icon_signal
        fi

        formatted_line="$icon  $ssid"
        echo "$formatted_line|$ssid|$security"
    done)

    chosen_network=$(echo -e "$toggle\n󰑓  Rescan Networks\nAvailable networks:\n$(echo "$formatted_network_list" | awk -F'|' '{print $1}')" | rofi -dmenu -i -selected-row 1 -p "Wi-Fi SSID: " -matching "fuzzy")
    [[ -z "$chosen_network" ]] && exit

    if [[ "$chosen_network" == "  Adapter off" ]]; then
        nmcli radio wifi on
        scan_networks
        continue
    elif [[ "$chosen_network" == "  Adapter on" ]]; then
        nmcli radio wifi off
        continue
    elif [[ "$chosen_network" == "󰑓  Rescan Networks" ]]; then
        scan_networks
        continue
    fi

    chosen_entry=$(echo "$formatted_network_list" | grep -F "$chosen_network")
    chosen_id=$(echo "$chosen_entry" | awk -F'|' '{print $2}')
    chosen_security=$(echo "$chosen_entry" | awk -F'|' '{print $3}')

    saved_connections=$(nmcli -g NAME connection)
    if [[ $(echo "$saved_connections" | grep -w "$chosen_id") == "$chosen_id" ]]; then
        action=$(echo -e "  Connect\n󰗨 Forget network" | rofi -dmenu -i -p "Saved Network Options:" -mesg "Network: $chosen_id")

        if [[ "$action" == "  Connect" ]]; then
            nmcli connection up id "$chosen_id" && notify-send "Connection Established" "Connected to \"$chosen_id\"."
        elif [[ "$action" == "󰗨 Forget network" ]]; then
            nmcli connection delete id "$chosen_id" && notify-send "Network Deleted" "Removed \"$chosen_id\"."
        fi
    else
        if [[ "$chosen_security" != "--" && -n "$chosen_security" ]]; then
            wifi_password=$(rofi -dmenu -p "Password: ")
        fi
        nmcli device wifi connect "$chosen_id" password "$wifi_password" && notify-send "Connection Established" "Connected to \"$chosen_id\"."
    fi
done
