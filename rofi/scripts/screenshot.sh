#!/usr/bin/env bash

## Rofi | Screenshot Menu
## Hyprland version

# ─────────────────────────────────────────────
# Configuration
# ─────────────────────────────────────────────

dir="$HOME/.config/rofi/"
screenshot_dir="$HOME/Pictures/Screenshots"

# Show notifications after taking screenshots
USE_NOTIFICATIONS=false

# ─────────────────────────────────────────────

mkdir -p "$screenshot_dir"

timestamp="$(date '+%Y-%m-%d_%H-%M-%S')"

# Options
fullscreen='󰹑'
area='󰩭'
window='󰖯'
delayed='󰔛'


notify() {
    if [[ "$USE_NOTIFICATIONS" == true ]]; then
        notify-send "$1" "$2"
    fi
}



rofi_cmd() {
    rofi -dmenu \
        -p "Screenshot" \
        -mesg "󰣇  Screenshot Tool" \
        -theme "${dir}/configs/applet.rasi"
}

run_rofi() {
    echo -e "$fullscreen\n$area\n$window\n$delayed" | rofi_cmd
}


run_cmd() {
    case "$1" in

        --fullscreen)
            file="$screenshot_dir/screenshot_$timestamp.png"

            grim "$file"
            wl-copy < "$file"

            notify "Screenshot" "Saved and copied to clipboard"
            ;;

        --area)
            geometry="$(slurp)" || exit 0

            file="$screenshot_dir/screenshot_$timestamp.png"

            grim -g "$geometry" "$file"
            wl-copy < "$file"

            notify "Screenshot" "Saved and copied to clipboard"
            ;;

        --window)
            geometry="$(
                hyprctl activewindow -j |
                    jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"'
            )"

            file="$screenshot_dir/screenshot_$timestamp.png"

            grim -g "$geometry" "$file"
            wl-copy < "$file"

            notify "Screenshot" "Saved and copied to clipboard"
            ;;

        --delayed)
            notify "Screenshot" "Taking screenshot in 5 seconds..."

            sleep 5

            file="$screenshot_dir/screenshot_$timestamp.png"

            grim "$file"
            wl-copy < "$file"

            notify "Screenshot" "Saved and copied to clipboard"
            ;;

    esac
}

if [[ "$1" == "--fullscreen" ]]; then
    run_cmd --fullscreen
    exit 0
fi

chosen="$(run_rofi)"

case "$chosen" in
    "$fullscreen")
        run_cmd --fullscreen
        ;;

    "$area")
        run_cmd --area
        ;;

    "$window")
        run_cmd --window
        ;;

    "$delayed")
        run_cmd --delayed
        ;;
esac