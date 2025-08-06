#!/bin/sh

choice=$(printf "Shutdown\nReboot\nLogout\nLock" | wofi --dmenu)

case "$choice" in
    "Shutdown") systemctl poweroff ;;
    "Reboot") systemctl reboot ;;
    "Logout") loginctl terminate-user "$USER" ;;
    "Lock") swaylock ;;
esac
