#!/bin/bash

battery_percentage=$(cat /sys/class/power_supply/BAT1/capacity)

notify-send "Battery" "$battery_percentage%"