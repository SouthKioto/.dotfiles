#!/usr/bin/env bash
# Menu zasilania w Rofi (SUPER + P), styl z ~/.config/rofi/menu.rasi

uptime_str=$(uptime -p | sed 's/^up //')

choice=$(printf '%s\n' \
    "  Zablokuj" \
    "󰤄  Uśpij" \
    "󰍃  Wyloguj" \
    "  Uruchom ponownie" \
    "  Wyłącz" \
    | rofi -dmenu -i -no-custom \
        -p "" \
        -mesg "󰔟  ${uptime_str}" \
        -theme "$HOME/.config/rofi/menu.rasi" \
        -theme-str 'inputbar { enabled: false; } listview { lines: 5; }')

case "$choice" in
    *Zablokuj) loginctl lock-session ;;
    *Uśpij) systemctl suspend ;;
    *Wyloguj) hyprctl dispatch 'hl.dsp.exit()' ;;
    *"Uruchom ponownie") systemctl reboot ;;
    *Wyłącz) systemctl poweroff ;;
esac
