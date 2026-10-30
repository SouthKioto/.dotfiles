#!/usr/bin/env bash
# Historia schowka w Rofi (SUPER + SHIFT + V), Alt+Delete czyści całą historię

THEME="$HOME/.config/rofi/menu.rasi"

choice=$(cliphist list | rofi -dmenu -i -p "󰅍" \
    -kb-custom-1 "Alt+Delete" \
    -mesg "Enter: kopiuj  |  Alt+Del: wyczyść historię" \
    -theme "$THEME" -theme-str 'window { width: 560px; } listview { lines: 10; }' \
    -theme-str 'entry { placeholder: "szukaj w schowku…"; }')
code=$?

if [[ $code -eq 10 ]]; then
    cliphist wipe && notify-send -a "Schowek" "Wyczyszczono historię"
elif [[ -n "$choice" ]]; then
    cliphist decode <<<"$choice" | wl-copy
fi
