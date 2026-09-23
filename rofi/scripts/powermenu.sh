#!/usr/bin/env bash

## Rofi | Power Menu
## Hyprland version

# Current Theme
dir="$HOME/.config/rofi/"

# CMDs
uptime="$(uptime -p | sed -e 's/up //g')"
host="$(hostname)"

# Options
shutdown=''
reboot=''
suspend=''
logout=''
yes=''
no=''

# Rofi CMD
rofi_cmd() {
    rofi -dmenu \
        -p "Uptime: $uptime" \
        -mesg "Uptime: $uptime" \
        -theme "${dir}/configs/applet.rasi"
}

# Confirmation CMD
confirm_cmd() {
    rofi -dmenu \
        -p 'Confirmation' \
        -mesg 'Are you Sure?' \
        -theme "${dir}/configs/confirm.rasi"
}

# Ask for confirmation
confirm_exit() {
    echo -e "$yes\n$no" | confirm_cmd
}

# Pass variables to rofi dmenu
run_rofi() {
    echo -e "$suspend\n$logout\n$reboot\n$shutdown" | rofi_cmd
}

# Execute Command
run_cmd() {
    selected="$(confirm_exit)"

    if [[ "$selected" == "$yes" ]]; then
        case "$1" in
            --shutdown)
                systemctl poweroff
                ;;

            --reboot)
                systemctl reboot
                ;;

            --suspend)
                systemctl suspend
                ;;

            --logout)
                hyprctl dispatch "hl.dsp.exit()"
                ;;
        esac
    else
        exit 0
    fi
}

# Actions
chosen="$(run_rofi)"

case "$chosen" in
    "$shutdown")
        run_cmd --shutdown
        ;;

    "$reboot")
        run_cmd --reboot
        ;;

    "$suspend")
        run_cmd --suspend
        ;;

    "$logout")
        run_cmd --logout
        ;;
esac