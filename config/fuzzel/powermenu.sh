#!/bin/sh
choice=$(printf "Shutdown\nReboot\nLogout\nLock" | fuzzel --dmenu --prompt="Power: ")

case "$choice" in
    "Shutdown") systemctl poweroff ;;
    "Reboot") systemctl reboot ;;
    "Logout") loginctl terminate-user $USER ;;
    "Lock") swaylock ;;
esac