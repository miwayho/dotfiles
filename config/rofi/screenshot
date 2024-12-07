#!/usr/bin/env bash

dir="$HOME/.config/rofi"
theme='horizontal'

screenshot_full="󰊓"
screenshot_area="󰊔"
screenshot_window="󰖲"
screenshot_delay="󱎫"

rofi_cmd() {
    rofi -dmenu \
        -theme ${dir}/${theme}.rasi \
        -p "Screenshot"
}

run_rofi() {
    echo -e "$screenshot_full\n$screenshot_area\n$screenshot_window\n$screenshot_delay" | rofi_cmd
}

run_cmd() {
    case $1 in
        "$screenshot_full")
            sleep 1
            maim | tee ~/Pictures/Screenshots/screenshot_$(date '+%Y-%m-%d_%H-%M-%S').png | xclip -selection clipboard -t image/png
            notify-send "Screenshot" "Full screen screencaptured and copied to buffer"
            ;;
        "$screenshot_area")
            sleep 1
            maim --select | tee ~/Pictures/Screenshots/screenshot_$(date '+%Y-%m-%d_%H-%M-%S').png | tee ~/Pictures/Screenshots/screenshot_$(date '+%Y-%m-%d_%H-%M-%S').png | xclip -selection clipboard -t image/png
            notify-send "Screenshot" "The selected area is screenshot and copied to the buffer"
            ;;
        "$screenshot_window")
            sleep 1
            maim --window $(xdotool getactivewindow) | tee ~/Pictures/Screenshots/screenshot_$(date '+%Y-%m-%d_%H-%M-%S').png | xclip -selection clipboard -t image/png
            notify-send "Screenshot" "Active window screenshotted and copied to clipboard"
            ;;
        "$screenshot_delay")
            sleep 5
            maim | tee ~/Pictures/Screenshots/screenshot_$(date '+%Y-%m-%d_%H-%M-%S').png | xclip -selection clipboard -t image/png
            notify-send "Screenshot" "The full screen is screenshotted and copied to the clipboard with a 5-second delay!"
            ;;
    esac
}

chosen="$(run_rofi)"
if [[ -n "$chosen" ]]; then
    run_cmd "$chosen"
fi