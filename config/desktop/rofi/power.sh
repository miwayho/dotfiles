# Current Theme
dir="$HOME/.config/rofi"
theme='horizontal'

# Options
shutdown='󰐥'
reboot='󰑙'
logout='󰿅'
hibernate='󰤄' 

rofi_cmd() {
	rofi -dmenu \
		-theme ${dir}/${theme}.rasi
}

run_rofi() {
	echo -e "$shutdown\n$hibernate\n$reboot\n$logout" | rofi_cmd
}

run_cmd() {
	if [[ $1 == '--shutdown' ]]; then
		systemctl poweroff
	elif [[ $1 == '--reboot' ]]; then
		systemctl reboot
	elif [[ $1 == '--logout' ]]; then
		i3-msg exit
	elif [[ $1 == '--hibernate' ]]; then
		systemctl suspend
	elif [[ $1 == '--lock' ]];then
		betterlockscreen -l dim
	fi
}

chosen="$(run_rofi)"
case ${chosen} in
    $shutdown)
		run_cmd --shutdown
        ;;
    $reboot)
		run_cmd --reboot
        ;;
    $logout)
		run_cmd --logout
        ;;
    $hibernate)
		run_cmd --hibernate
        ;;
esac