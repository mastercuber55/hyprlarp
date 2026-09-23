WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
THUMB_DIR="$HOME/.cache/wallpaper-thumbnails"
ROFI_THEME="$HOME/.config/rofi/configs/wallpaper.rasi"

mkdir -p "$THUMB_DIR"

if [[ ! -d "$WALLPAPER_DIR" ]]; then
    notify-send "Wallpaper Picker" "Directory not found"
    exit 1
fi

# Temporary Rofi input
INPUT=$(mktemp)
trap 'rm -f "$INPUT"' EXIT

while IFS= read -r -d '' wallpaper; do
    filename="$(basename "$wallpaper")"
    name="${filename%.*}"

    # Keep thumbnails separate from originals
    thumb="$THUMB_DIR/${filename%.*}.png"

    if [[ ! -f "$thumb" ]]; then
        magick "$wallpaper" \
            -thumbnail '500x300^' \
            -gravity center \
            -extent 500x300 \
            "$thumb"
    fi

    # Rofi row + icon
    printf '%s\0icon\x1f%s\n' "$name" "$thumb" >> "$INPUT"

done < <(
    find "$WALLPAPER_DIR" -maxdepth 1 -type f \
        \( -iname '*.jpg' \
        -o -iname '*.jpeg' \
        -o -iname '*.png' \
        -o -iname '*.webp' \) \
        -print0
)

if [[ ! -s "$INPUT" ]]; then
    notify-send "Wallpaper Picker" "No wallpapers found"
    exit 1
fi

hyprctl eval 'hl.layer_rule({ match = { namespace = "rofi" }, animation = "slide bottom" })'

selected=$(
    rofi \
        -dmenu \
        -show-icons \
        -i \
        -sync \
        -no-custom \
        -theme "$ROFI_THEME" \
        -p "  Wallpapers" \
        < "$INPUT"
)

hyprctl eval 'hl.layer_rule({ match = { namespace = "rofi" }, animation = "fade" })'

[[ -z "$selected" ]] && exit 0

# Find selected wallpaper and let Noctalia handle it
while IFS= read -r -d '' wallpaper; do
    filename="$(basename "$wallpaper")"
    name="${filename%.*}"

    if [[ "$name" == "$selected" ]]; then
        noctalia msg wallpaper-set "$wallpaper"
        exit 0
    fi
done < <(
    find "$WALLPAPER_DIR" -maxdepth 1 -type f \
        \( -iname '*.jpg' \
        -o -iname '*.jpeg' \
        -o -iname '*.png' \
        -o -iname '*.webp' \) \
        -print0
)
