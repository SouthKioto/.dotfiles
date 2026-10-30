#!/usr/bin/env bash
# Odśwież cały rice (SUPER + SHIFT + R): config Hyprlanda, waybar, widgety, swaync.
# Przydatne po podpięciu/odpięciu monitorów, gdy coś zniknie albo się rozjedzie.

scripts="$HOME/.config/hypr/scripts"
log="${XDG_CACHE_HOME:-$HOME/.cache}"

hyprctl reload >/dev/null

"$scripts/waybar-restart.sh"

# widgety Quickshell — restart procesu (sam reload configu nie odtwarza okien)
pkill -f '^qs -c widgets$'
for _ in {1..20}; do
    pgrep -f '^qs -c widgets$' >/dev/null || break
    sleep 0.1
done
setsid -f qs -c widgets >"$log/qs-widgets.log" 2>&1 </dev/null

# swaync: przeładuj config i CSS
swaync-client -R -rs >/dev/null 2>&1

notify-send -a rice -t 2000 "Odświeżono" "Hyprland, waybar, widgety, swaync"
