#!/bin/bash

action="$1"

mute_status=$(pactl get-sink-mute @DEFAULT_SINK@ | awk '{print $2}')

if [ "$action" = "toggle" ]; then
    pactl set-sink-mute @DEFAULT_SINK@ toggle

    if pactl get-sink-mute @DEFAULT_SINK@ | grep -q 'yes'; then
        mute_status="Muted"
    else
        mute_status="Unmuted"
    fi

    notify-send -r 9999 "Volume" "$mute_status"
else
    if [ "$mute_status" = "yes" ] && [[ "$action" == +* ]]; then
        pactl set-sink-mute @DEFAULT_SINK@ 0
        mute_status="Unmuted"
    fi

    pactl set-sink-volume @DEFAULT_SINK@ "$action"

    volume=$(pactl get-sink-volume @DEFAULT_SINK@ | awk '/\// {print $5}' | tr -d '%')

    if [ "$volume" -eq 0 ]; then
        pactl set-sink-mute @DEFAULT_SINK@ 1
        mute_status="Muted"
    fi

    if [ "$volume" -gt 100 ]; then
        pactl set-sink-volume @DEFAULT_SINK@ 100%
        volume="100"
    fi

    notify-send -r 9999 "Volume" "Volume: ${volume}%"
fi