#!/bin/bash
# Podmienia kolory w decorations.lua na podstawie wygenerowanego colors.conf

COLORS_FILE="$HOME/.config/hypr/colors.conf"
DECORATIONS="$HOME/.config/hypr/modules/decorations.lua"

# Odczytaj kolory z colors.conf
get_color() {
    grep "^\$$1 " "$COLORS_FILE" | sed 's/.*rgb(\(.*\))/\1/'
}

PRIMARY=$(get_color "primary")
TERTIARY=$(get_color "tertiary")
SECONDARY_CONTAINER=$(get_color "secondary_container")
SURFACE=$(get_color "surface")
OUTLINE_VARIANT=$(get_color "outline_variant")

sed -i "s/active_border = { colors = { \"rgba([^)]*)\", \"rgba([^)]*)\", \"rgba([^)]*)\" }, angle = 45 }/active_border = { colors = { \"rgba(${PRIMARY}ee)\", \"rgba(${TERTIARY}ee)\", \"rgba(${SECONDARY_CONTAINER}ee)\" }, angle = 45 }/" "$DECORATIONS"

sed -i "s/inactive_border = \"rgba([^)]*)\"/inactive_border = \"rgba(${OUTLINE_VARIANT}44)\"/" "$DECORATIONS"

sed -i "s/color = \"rgba([^)]*ee)\"/color = \"rgba(${SURFACE}ee)\"/" "$DECORATIONS"
sed -i "s/color_inactive = \"rgba([^)]*88)\"/color_inactive = \"rgba(${SURFACE}88)\"/" "$DECORATIONS"

echo "✓ Kolory decorations.lua zaktualizowane"

# Przeładuj Hyprland
hyprctl reload

pkill -9 waybar || true; waybar &disown
