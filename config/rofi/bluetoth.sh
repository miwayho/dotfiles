#!/usr/bin/env bash

scan_devices() {
    bluetoothctl scan on &>/dev/null &
    sleep 5
    bluetoothctl scan off &>/dev/null
}

get_device_status() {
    systemctl is-active bluetooth.service
}

list_devices() {
    bluetoothctl devices | tee /tmp/debug_devices.log | awk '{print $2 "|" substr($0, index($0,$3))}'
}


get_paired_devices() {
    bluetoothctl paired-devices | awk '{print $2 "|" substr($0, index($0,$3))}'
}

get_connected_devices() {
    bluetoothctl info | awk '/Device/ {print $2 "|" substr($0, index($0,$3))}'
}

get_device_type_icon() {
    local mac="$1"
    local info=$(bluetoothctl info "$mac")

    if echo "$info" | grep -iq "headset\|audio"; then
        echo "󰋋" # Headphones or audio devices
    elif echo "$info" | grep -iq "phone"; then
        echo "󰄋" # Phones
    elif echo "$info" | grep -iq "mouse"; then
        echo "󰍽" # Mice
    elif echo "$info" | grep -iq "keyboard"; then
        echo "󰌌" # Keyboards
    else
        echo "󰂱" # Default for unknown devices
    fi
}

format_device_list() {
    local connected_devices="$1"
    local paired_devices="$2"
    local available_devices="$3"
    local formatted_connected_list=""
    local formatted_available_list=""

    # Format connected devices
    while IFS= read -r line; do
        local mac=$(echo "$line" | cut -d'|' -f1)
        local name=$(echo "$line" | cut -d'|' -f2)
        local icon=$(get_device_type_icon "$mac")

        formatted_connected_list+="$icon  $name|$mac|$name\n"
    done <<< "$connected_devices"

    # Format available devices for pairing
    while IFS= read -r line; do
        local mac=$(echo "$line" | cut -d'|' -f1)
        local name=$(echo "$line" | cut -d'|' -f2)

        # Skip paired devices
        if echo "$paired_devices" | grep -q "$mac"; then
            continue
        fi

        local icon=$(get_device_type_icon "$mac")
        formatted_available_list+="$icon  $name|$mac|$name\n"
    done <<< "$available_devices"

    echo -e "$formatted_connected_list\n---\n$formatted_available_list"
}

main_menu() {
    local toggle="$1"
    local formatted_device_list="$2"

    echo -e "$toggle\nConnected Devices:\n$(echo -e "$formatted_device_list" | sed '/^---$/q' | awk -F'|' '{print $1}')\n---\nAvailable Devices:\n$(echo -e "$formatted_device_list" | sed -n '/^---$/,$p' | awk -F'|' '{print $1}')"
}

handle_bluetooth_adapter() {
    local choice="$1"

    case "$choice" in
        "Bluetooth Adapter                    ")
            systemctl start bluetooth.service
            return 1 ;;
        "Bluetooth Adapter                    ")
            systemctl stop bluetooth.service
            return 1 ;;
    esac

    return 0
}

handle_device_selection() {
    local chosen_device="$1"
    local formatted_device_list="$2"

    local chosen_entry=$(echo -e "$formatted_device_list" | grep -F "$chosen_device")
    local chosen_mac=$(echo "$chosen_entry" | awk -F'|' '{print $2}')
    local chosen_name=$(echo "$chosen_entry" | awk -F'|' '{print $3}')

    local action=$(echo -e "󰌾  Connect\n󰆴  Remove device\n󰂲  Pair device" | rofi -dmenu -i -p "${chosen_name} Options:")

    case "$action" in
        "󰌾  Connect")
            bluetoothctl connect "$chosen_mac" && notify-send "Connection Established" "Connected to \"$chosen_name\"." ||
                notify-send "Failed to Connect" "Could not connect to \"$chosen_name\"." ;;
        "󰆴  Remove device")
            bluetoothctl remove "$chosen_mac" && notify-send "Device Removed" "Removed \"$chosen_name\"." ||
                notify-send "Failed to Remove Device" "Could not remove \"$chosen_name\"." ;;
        "󰂲  Pair device")
            bluetoothctl pair "$chosen_mac" && notify-send "Device Paired" "Paired with \"$chosen_name\"." ||
                notify-send "Failed to Pair" "Could not pair with \"$chosen_name\"." ;;
    esac
}

main_loop() {
    while :; do
        local device_status=$(get_device_status)
        local toggle="Bluetooth Adapter                    "
        [[ "$device_status" == "active" ]] && toggle="Bluetooth Adapter                    "

        local connected_devices=$(get_connected_devices)
        local paired_devices=$(get_paired_devices)
        local available_devices=$(list_devices)
        local formatted_device_list=$(format_device_list "$connected_devices" "$paired_devices" "$available_devices")

        local chosen_device=$(main_menu "$toggle" "$formatted_device_list" | rofi -dmenu -i -selected-row 1 -p "Bluetooth: " -matching "fuzzy")

        [[ -z "$chosen_device" ]] && exit 0

        if [[ "$chosen_device" == "Available devices                " ]]; then
            scan_devices
            continue
        fi

        if handle_bluetooth_adapter "$chosen_device"; then
            handle_device_selection "$chosen_device" "$formatted_device_list"
        fi
    done
}

main_loop

exit 0
