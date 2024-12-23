#!/usr/bin/env bash

dir="$HOME/.config/rofi"
theme="horizontal"

options=(
    "󰊓"  # Full screen
    "󰊔"  # Select area
    "󰖲"  # Active window
    "󱎫"  # Full screen with delay
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
            import -window root "$save_path" && xclip -selection clipboard -t image/png < "$save_path"
            notify-send "Screenshot" "Full screen captured and copied to clipboard."
            ;;
        "󰊔")
            sleep 1
            import "$save_path" && xclip -selection clipboard -t image/png < "$save_path"
            notify-send "Screenshot" "Selected area captured and copied to clipboard."
            ;;
        "󰖲")
            sleep 1
            active_window=$(xdotool getactivewindow)
            import -window "$active_window" "$save_path" && xclip -selection clipboard -t image/png < "$save_path"
            notify-send "Screenshot" "Active window captured and copied to clipboard."
            ;;
        "󱎫")
            sleep 5
            import -window root "$save_path" && xclip -selection clipboard -t image/png < "$save_path"
            notify-send "Screenshot" "Full screen captured with 5-second delay and copied to clipboard."
            ;;
    esac
}

chosen=$(run_rofi)
[[ -n "$chosen" ]] && run_cmd "$chosen"
