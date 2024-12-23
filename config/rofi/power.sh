#!/usr/bin/env bash

dir="$HOME/.config/rofi"
theme="power"

battery_percentage=$(cat /sys/class/power_supply/BAT*/capacity)

options=(
    "󰐥"
    "󰑙"
    "󰿅"
    "󰤄"
    "󱧥 ${battery_percentage}%"
)

rofi_cmd() {
    rofi -dmenu -theme "${dir}/${theme}.rasi"
}

run_rofi() {
    printf "%s\n" "${options[@]}" | rofi_cmd
}

run_cmd() {
    case $1 in
        "󰐥") systemctl poweroff ;;
        "󰑙") systemctl reboot ;;
        "󰿅") i3-msg exit ;;
        "󰤄") systemctl suspend ;;
    esac
}

chosen=$(run_rofi)
[[ -n "$chosen" ]] && run_cmd "$chosen"