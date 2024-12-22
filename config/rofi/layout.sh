#!/usr/bin/env bash

dir="$HOME/.config/rofi"
theme="horizontal"

options=(
    "󰖯"
    "󰤼"
    "󰖲"
    "󰊓"
)

rofi_cmd() {
    rofi -dmenu -p "i3layout" -theme "${dir}/${theme}.rasi"
}

run_rofi() {
    printf "%s\n" "${options[@]}" | rofi_cmd
}

run_cmd() {
    case $1 in
        "󰖯") i3-msg layout tabbed ;;
        "󰤼") i3-msg layout toggle split ;;
        "󰖲") i3-msg floating toggle ;;
        "󰊓") i3-msg fullscreen toggle ;;
    esac
}

chosen=$(run_rofi)
[[ -n "$chosen" ]] && run_cmd "$chosen"