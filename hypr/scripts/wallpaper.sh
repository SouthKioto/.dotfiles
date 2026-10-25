#!/usr/bin/env bash
set -euo pipefail

WALLPAPER_DIR="$HOME/Obrazy/Wallpapers"
ROFI_DIR="$HOME/.config/rofi"
ROFI_THEME="wallpaper-picker"
THUMB_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/wallpaper-thumbs"
CACHE_SCRIPT="$HOME/.config/hypr/scripts/cache-wallpaper.sh"
WAYBAR_LOG="${XDG_CACHE_HOME:-$HOME/.cache}/waybar.log"

mkdir -p "$THUMB_DIR"

mapfile -t walls < <(
    find "$WALLPAPER_DIR" \
        -type f \
        \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) \
        | sort
)

if [[ ${#walls[@]} -eq 0 ]]; then
    notify-send "Wallpaper Picker" "Brak tapet w $WALLPAPER_DIR"
    exit 1
fi

declare -A wall_map
declare -A thumb_map
display_names=()

for wall in "${walls[@]}"; do
    name=$(basename "$wall")
    thumb="$THUMB_DIR/${name%.*}.png"
    [[ ! -f "$thumb" ]] && magick "$wall" -thumbnail 200x120^ -gravity center -extent 200x120 "$thumb" 2>/dev/null || true
    wall_map["$name"]="$wall"
    thumb_map["$name"]="$thumb"
    display_names+=("$name")
done

rofi_exit=0
choice=$(
    for name in "${display_names[@]}"; do
        printf "%s\0icon\x1f%s\n" "$name" "${thumb_map[$name]}"
    done | rofi \
        -dmenu \
        -p " wallpaper" \
        -theme "${ROFI_DIR}/${ROFI_THEME}.rasi" \
        -show-icons \
        -eh 4 \
        -kb-custom-1 "Alt+r" \
        -mesg "Enter: zastosuj  |  Alt+r: losowa"
) || rofi_exit=$?

if [[ $rofi_exit -eq 10 ]]; then
    choice="${display_names[RANDOM % ${#display_names[@]}]}"
fi

[[ -z "${choice:-}" ]] && exit 0

full_path="${wall_map[$choice]}"

if [[ ! -f "$full_path" ]]; then
    notify-send "Wallpaper Picker" "Nie znaleziono pliku tapety"
    exit 1
fi

restart_waybar() {
    pkill -x waybar 2>/dev/null || true

    # poczekaj max 2 s aż stary proces zniknie
    for _ in {1..20}; do
        pgrep -x waybar >/dev/null || break
        sleep 0.1
    done

    # jeśli nadal żyje, zabij na twardo
    pkill -9 -x waybar 2>/dev/null || true

    setsid -f waybar >"$WAYBAR_LOG" 2>&1 < /dev/null
}

apply_wallpaper() {
    local wall="$1"

    awww img "$wall" \
        --transition-type wipe \
        --transition-angle 30 \
        --transition-duration 0.8 \
        --transition-fps 60 \
        || notify-send "awww" "Nie udało się ustawić tapety"

    if [[ -x "$CACHE_SCRIPT" ]]; then
        "$CACHE_SCRIPT" "$wall" || true
    fi

    if ! matugen image "$wall" --source-color-index 0; then
        notify-send "Matugen" "Nie udało się wygenerować kolorów"
    fi

    if [[ -x "$HOME/.config/hypr/scripts/apply-colors.sh" ]]; then
        "$HOME/.config/hypr/scripts/apply-colors.sh" || true
    fi

    restart_waybar
    swaync-client --reload-config 2>/dev/null || true

    notify-send \
        "Wallpaper" \
        "$(basename "$wall")" \
        --icon "$wall"
}

apply_wallpaper "$full_path"
