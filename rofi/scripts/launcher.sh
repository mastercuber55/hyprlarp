hyprctl eval 'hl.layer_rule({ match = { namespace = "rofi" }, animation = "slide bottom" })'

rofi -show drun -theme "$HOME/.config/rofi/configs/launcher.rasi"

hyprctl eval 'hl.layer_rule({ match = { namespace = "rofi" }, animation = "fade" })'