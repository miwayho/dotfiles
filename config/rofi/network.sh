#!/usr/bin/env bash

scan_networks() {
    nmcli device wifi rescan
}

get_device_status() {
    nmcli -fields WIFI g | awk '/enabled|disabled/ {print $1}'
}

get_network_list() {
    nmcli --fields "SSID,SIGNAL,SECURITY" -t device wifi list | sed "/--/d"
}

get_active_ssid() {
    nmcli -t -f NAME,TYPE,DEVICE connection show --active | awk -F':' '/802-11-wireless/ {print $1}'
}

format_network_list() {
    local network_list="$1"
    local active_ssid="$2"
    local formatted_list=""

    while IFS= read -r line; do
        IFS=':' read -r ssid signal security <<< "$line"

        [[ -z "$ssid" || ! "$signal" =~ ^[0-9]+$ ]] && continue

        case $signal in
            8[0-9]|9[0-9]|100) icon_signal="󰤪" ;;
            6[0-9]|7[0-9])     icon_signal="󰤧" ;;
            4[0-9]|5[0-9])     icon_signal="󰤤" ;;
            2[0-9]|3[0-9])     icon_signal="󰤡" ;;
            *)                 icon_signal="󰤬" ;;
        esac

        if [[ -z "$security" || "$security" == "--" ]]; then
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

        [[ "$ssid" == "$active_ssid" ]] && icon="$icon  Connected:"

        formatted_list+="$icon  $ssid|$ssid|$security\n"
    done <<< "$network_list"

    echo -e "$formatted_list"
}

get_saved_connections() {
    nmcli -g NAME connection
}

main_menu() {
    local toggle="$1"
    local formatted_network_list="$2"

    echo -e "$toggle\nAvailable networks                \n$(echo -e "$formatted_network_list" | awk -F'|' '{print $1}')"
}

handle_wifi_adapter() {
    local choice="$1"

    case "$choice" in
        "Wifi Adapter                       ")
            nmcli radio wifi on && scan_networks
            return 1 ;;
        "Wifi Adapter                       ")
            nmcli radio wifi off
            return 1 ;;
    esac

    return 0
}

handle_network_selection() {
    local chosen_network="$1"
    local formatted_network_list="$2"
    local active_ssid="$3"
    local saved_connections="$4"

    local chosen_entry=$(echo -e "$formatted_network_list" | grep -F "$chosen_network")
    local chosen_id=$(echo "$chosen_entry" | awk -F'|' '{print $2}')
    local chosen_security=$(echo "$chosen_entry" | awk -F'|' '{print $3}')

    if [[ "$chosen_id" == "$active_ssid" ]]; then
        local action=$(echo -e "󰌾  Disconnect\n󰆴  Forget network" | rofi -dmenu -i -p "${chosen_id} Options:")
        case "$action" in
            "󰌾  Disconnect")
                nmcli connection down id "$chosen_id" && notify-send "Disconnected" "Disconnected from \"$chosen_id\"." ||
                    notify-send "Failed to Disconnect" "Could not disconnect from \"$chosen_id\"." ;;
            "󰆴  Forget network")
                nmcli connection delete id "$chosen_id" && notify-send "Network Deleted" "Removed \"$chosen_id\"." ||
                    notify-send "Failed to Delete Network" "Could not delete \"$chosen_id\"." ;;
        esac
    elif echo "$saved_connections" | grep -qw "$chosen_id"; then
        local action=$(echo -e "  Connect\n󰆴  Forget network" | rofi -dmenu -i -p "${chosen_id} Options:")
        case "$action" in
            "  Connect")
                nmcli connection up id "$chosen_id" && notify-send "Connection Established" "Connected to \"$chosen_id\"." ||
                    notify-send "Failed to Connect" "Could not connect to \"$chosen_id\"." ;;
            "󰆴  Forget network")
                nmcli connection delete id "$chosen_id" && notify-send "Network Deleted" "Removed \"$chosen_id\"." ||
                    notify-send "Failed to Delete Network" "Could not delete \"$chosen_id\"." ;;
        esac
    else
        local wifi_password=""
        if [[ -n "$chosen_security" && "$chosen_security" != "--" ]]; then
            wifi_password=$(rofi -dmenu -p "Password: ")
        fi
        nmcli device wifi connect "$chosen_id" ${wifi_password:+password "$wifi_password"} && \
            notify-send "Connection Established" "Connected to \"$chosen_id\"." ||
            notify-send "Failed to Connect" "Could not connect to \"$chosen_id\"."
    fi
}

main_loop() {
    while :; do
        local device_status=$(get_device_status)
        local toggle="Wifi Adapter                       "
        [[ "$device_status" == "enabled" ]] && toggle="Wifi Adapter                       "

        local network_list=$(get_network_list)
        local active_ssid=$(get_active_ssid)
        local formatted_network_list=$(format_network_list "$network_list" "$active_ssid")
        local saved_connections=$(get_saved_connections)

        local chosen_network=$(main_menu "$toggle" "$formatted_network_list" | rofi -dmenu -i -selected-row 1 -p "Wi-Fi: " -matching "fuzzy")

        [[ -z "$chosen_network" ]] && exit 0

        if [[ "$chosen_network" == "Available networks                " ]]; then
            scan_networks
            continue
        fi

        if handle_wifi_adapter "$chosen_network"; then
            handle_network_selection "$chosen_network" "$formatted_network_list" "$active_ssid" "$saved_connections"
        fi
    done
}

main_loop

exit 0