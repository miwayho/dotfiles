#!/usr/bin/env bash

dir="$HOME/.config/rofi"
theme="horizontal"

options=(
    "󰊓"
    "󰊔"
    "󰖲"
    "󱎫"
)

rofi_cmd() {
    rofi -dmenu -p "Screenshot" -theme "${dir}/${theme}.rasi"
}

run_rofi() {
    printf "%s\n" "${options[@]}" | rofi_cmd
}

run_cmd() {
    timestamp=$(date '+%Y-%m-%d_%H-%M-%S')
    save_path="$HOME/Pictures/Screenshots/screenshot_$timestamp.png"

    case $1 in
        "󰊓")
            sleep 1
            maim | tee "$save_path" | xclip -selection clipboard -t image/png
            notify-send "Screenshot" "Full screen captured and copied to clipboard."
            ;;
        "󰊔")
            sleep 1
            maim --select | tee "$save_path" | xclip -selection clipboard -t image/png
            notify-send "Screenshot" "Selected area captured and copied to clipboard."
            ;;
        "󰖲")
            sleep 1
            maim --window "$(xdotool getactivewindow)" | tee "$save_path" | xclip -selection clipboard -t image/png
            notify-send "Screenshot" "Active window captured and copied to clipboard."
            ;;
        "󱎫")
            sleep 5
            maim | tee "$save_path" | xclip -selection clipboard -t image/png
            notify-send "Screenshot" "Full screen captured with 5-second delay and copied to clipboard."
            ;;
    esac
}

chosen=$(run_rofi)
[[ -n "$chosen" ]] && run_cmd "$chosen"