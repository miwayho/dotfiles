#!/usr/bin/env bash

trap "echo 'Script interrupted'; exit" SIGINT SIGTERM

scan_networks() {
    nmcli device wifi rescan
    sleep 1
}

get_device_status() {
    nmcli radio wifi
}

get_network_list() {
    nmcli --fields "SSID,SIGNAL,SECURITY" -t device wifi list
}

get_active_ssid() {
    nmcli -t -f NAME,TYPE connection show --active | awk -F':' '/wireless/ {print $1}'
}

format_network_list() {
    local network_list="$1"
    local active_ssid="$2"
    local formatted_list=""

    while IFS= read -r line; do
        IFS=':' read -r ssid signal security <<< "${line//\\:/-}"
        ssid="${ssid//\\\\/-}"

        [[ -z "$ssid" || ! "$signal" =~ ^[0-9]+$ ]] && continue

        local icon=""
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
            icon="$icon_signal"
        fi

        [[ "$ssid" == "$active_ssid" ]] && icon+="  Connected:"
        formatted_list+="$icon  $ssid|$ssid|$security\n"
    done <<< "$network_list"

    echo -ne "$formatted_list"
}

get_saved_connections() {
    nmcli -g NAME connection
}

main_menu() {
    printf "%s\nAvailable networks                \n%s" "$1" "$2"
}

handle_wifi_adapter() {
    case "$1" in
        "Wifi Adapter                       ")
            nmcli radio wifi on && scan_networks ;;
        "Wifi Adapter                       ")
            nmcli radio wifi off ;;
        *) return 1 ;;
    esac
    return 0
}


handle_network_selection() {
    local chosen_network="$1"
    local formatted_list="$2"
    local active_ssid="$3"
    local saved_connections="$4"

    local chosen_entry=$(grep -Fm1 -- "$chosen_network" <<< "$formatted_list")
    IFS='|' read -r _ chosen_id security <<< "$chosen_entry"

    if [[ "$chosen_id" == "$active_ssid" ]]; then
        local action=$(printf "󰌾  Disconnect\n󰆴  Forget network" | fuzzel -d -w 40 -l 2)
        case "$action" in
            "󰌾  Disconnect")
                nmcli connection down "$chosen_id"
                notify-send "${chosen_id}" "Disconnected" ;;
            "󰆴  Forget network")
                nmcli connection delete "$chosen_id"
                notify-send "${chosen_id}" "Network deleted" ;;
        esac
    elif grep -qw "$chosen_id" <<< "$saved_connections"; then
        local action=$(printf "  Connect\n󰆴  Forget network" | fuzzel -d -w 40 -l 2)
        case "$action" in
            "  Connect")
                nmcli connection up "$chosen_id"
                notify-send "${chosen_id}" "Connected" ;;
            "󰆴  Forget network")
                nmcli connection delete "$chosen_id"
                notify-send "${chosen_id}" "Network deleted" ;;
        esac
    else
        local password=""
        if [[ "$security" != "--" && -n "$security" ]]; then
            password=$(fuzzel -d -p "Password: ")
            [[ -z "$password" ]] && return
        fi
        
        if nmcli device wifi connect "$chosen_id" ${password:+password "$password"}; then
            notify-send "${chosen_id}" "Connected successfully"
            sleep 2
        else
            [[ $? -ne 0 && -n "$password" ]] && notify-send "${chosen_id}" "Connection failed"
            sleep 2
        fi
    fi
}

main_loop() {
    while :; do
        local status=$(get_device_status)
        local toggle=$([[ "$status" == "enabled" ]] && \
            echo "Wifi Adapter                       " || \
            echo "Wifi Adapter                       ")

        local networks=$(get_network_list)
        local active_ssid=$(get_active_ssid)
        local formatted_list=$(format_network_list "$networks" "$active_ssid")
        local saved=$(get_saved_connections)
        local display_list=$(awk -F'|' '{print $1}' <<< "$formatted_list")

        local chosen=$(main_menu "$toggle" "$display_list" | fuzzel -d -p "Wi-Fi: " --fuzzy-min-length 1)

        [[ -z "$chosen" ]] && exit 0

        if [[ "$chosen" == "Available networks                " ]]; then
            scan_networks
            continue
        fi

        if [[ "$chosen" == "$toggle" ]]; then
            handle_wifi_adapter "$chosen" >/dev/null
        else
            handle_network_selection "$chosen" "$formatted_list" "$active_ssid" "$saved"
        fi
    done
}

main_loop
exit 0