#!/bin/sh

choice=$(printf "Shutdown\nReboot\nLogout\nLock" | wofi --dmenu -j --height=160)

case "$choice" in
    "Shutdown") systemctl poweroff ;;
    "Reboot") systemctl reboot ;;
    "Logout") loginctl terminate-user "$USER" ;;
    "Lock") swaylock ;;
esac
