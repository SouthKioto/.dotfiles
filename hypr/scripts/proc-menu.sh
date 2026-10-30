#!/usr/bin/env bash
# Procesy w Rofi (SUPER + O): wybór → potwierdzenie → zakończ (SIGTERM, a gdy nie pomoże SIGKILL)

THEME="$HOME/.config/rofi/menu.rasi"
MONO='* { font: "JetBrainsMono Nerd Font Mono Bold 10"; } window { width: 620px; } listview { lines: 12; }'

selected=$(ps -u "$USER" -o pid=,pcpu=,rss=,comm= --sort=-pcpu \
    | awk '{ printf "%-7s %-24.24s %6.1f%%  %7.0f MB\n", $1, $4, $2, $3/1024 }' \
    | rofi -dmenu -i -p "" -mesg "PID     NAZWA                       CPU      RAM" \
        -theme "$THEME" -theme-str "$MONO" \
        -theme-str 'entry { placeholder: "szukaj procesu…"; }')

[[ -z "$selected" ]] && exit 0

pid=$(awk '{print $1}' <<<"$selected")
name=$(awk '{print $2}' <<<"$selected")

confirm=$(printf '%s\n' "  Nie" "󰆴  Zakończ $name" \
    | rofi -dmenu -i -no-custom -p "" -mesg "Zakończyć $name (PID $pid)?" \
        -theme "$THEME" -theme-str 'inputbar { enabled: false; } listview { lines: 2; }')

[[ "$confirm" != *Zakończ* ]] && exit 0

kill "$pid" 2>/dev/null
for _ in {1..20}; do
    kill -0 "$pid" 2>/dev/null || { notify-send -a "Procesy" "Zakończono $name"; exit 0; }
    sleep 0.1
done
kill -9 "$pid" 2>/dev/null && notify-send -a "Procesy" "Wymuszono zamknięcie $name"
