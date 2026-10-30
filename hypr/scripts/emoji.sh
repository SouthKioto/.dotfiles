#!/usr/bin/env bash
# Emoji w Rofi (SUPER + .): Enter = skopiuj do schowka (plugin rofi-emoji)
pgrep -x rofi >/dev/null && { pkill -x rofi; exit 0; }
rofi -modi emoji -show emoji -emoji-mode copy \
    -theme "$HOME/.config/rofi/menu.rasi" \
    -theme-str 'window { width: 560px; } listview { lines: 10; }' \
    -theme-str 'entry { placeholder: "szukaj emoji (po angielsku)…"; }' \
    || notify-send -a "Emoji" "Brak pluginu rofi-emoji" "Uruchom ~/.config/rice/install.sh"
