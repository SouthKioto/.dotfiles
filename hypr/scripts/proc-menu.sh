#!/bin/bash
# Lista procesów w Rofi, wybór → potwierdzenie → kill

selected=$(ps -eo pid,comm,%cpu,%mem --sort=-%mem --no-headers \
    | awk '{printf "%-6s %-25s CPU:%5s%%  MEM:%5s%%\n", $1, $2, $3, $4}' \
    | rofi -dmenu -i -p "Procesy" -theme ~/.config/rofi/config.rasi)

[ -z "$selected" ] && exit 0

pid=$(echo "$selected" | awk '{print $1}')
name=$(echo "$selected" | awk '{print $2}')

confirm=$(echo -e "Nie\nTak" | rofi -dmenu -p "Zabić $name (PID $pid)?" -theme ~/.config/rofi/config.rasi)

[ "$confirm" = "Tak" ] && kill -9 "$pid"
