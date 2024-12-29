#!/usr/bin/env bash

dir="$HOME/.config/rofi"
theme="horizontal"

options=(
    "󰊓"  # Full screen
    "󰊔"  # Select area
    "󰖲"  # Active window
    "󱎫"  # Full screen with delay
)

check_dependencies() {
    local missing_dependencies=()
    for cmd in rofi import xclip xdotool; do
        if ! command -v "$cmd" &>/dev/null; then
            missing_dependencies+=("$cmd")
        fi
    done

    if [[ ${#missing_dependencies[@]} -gt 0 ]]; then
        notify-send "Screenshot Error" "Missing utilities: ${missing_dependencies[*]}"
        exit 1
    fi

    if [[ ! -d "$HOME/Pictures/Screenshots" ]]; then
        notify-send "Screenshot Error" "The folder '$HOME/Pictures/Screenshots' does not exist. Please create it manually."
        exit 1
    fi
}

rofi_cmd() {
    if [[ ! -f "${dir}/${theme}.rasi" ]]; then
        notify-send "Screenshot Error" "Rofi theme '${theme}.rasi' not found."
        exit 1
    fi
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
            if import -window root "$save_path"; then
                xclip -selection clipboard -t image/png <"$save_path"
                notify-send "Screenshot" "Full screen captured and copied to clipboard."
            else
                notify-send "Screenshot Error" "Failed to capture screen screenshot."
            fi
            ;;
        "󰊔")
            sleep 1
            if import "$save_path"; then
                xclip -selection clipboard -t image/png <"$save_path"
                notify-send "Screenshot" "Selected area captured and copied to clipboard."
            else
                notify-send "Screenshot Error" "Failed to capture selected area."
            fi
            ;;
        "󰖲")
            sleep 1
            active_window=$(xdotool getactivewindow 2>/dev/null)
            if [[ -z "$active_window" ]]; then
                notify-send "Screenshot Error" "Failed to get active window."
                return
            fi
            if import -window "$active_window" "$save_path"; then
                xclip -selection clipboard -t image/png <"$save_path"
                notify-send "Screenshot" "Active window captured and copied to clipboard."
            else
                notify-send "Screenshot Error" "Failed to capture active window."
            fi
            ;;
        "󱎫")
            sleep 5
            if import -window root "$save_path"; then
                xclip -selection clipboard -t image/png <"$save_path"
                notify-send "Screenshot" "Full screen captured with 5-second delay and copied to clipboard."
            else
                notify-send "Screenshot Error" "Failed to capture screen screenshot with delay."
            fi
            ;;
        *)
            notify-send "Screenshot Error" "Unknown action selected."
            ;;
    esac
}

check_dependencies

chosen=$(run_rofi)
if [[ -n "$chosen" ]]; then
    run_cmd "$chosen"
else
    notify-send "Screenshot" "Action cancelled by user."
fi