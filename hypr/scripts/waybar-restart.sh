#!/usr/bin/env bash
# Restart Waybar (SUPER + R). pkill zamiast SIGUSR2, żeby tray nie znikał

pkill -x waybar

# poczekaj aż proces faktycznie się zamknie (max ~2 s), potem na twardo
for _ in {1..20}; do
    pgrep -x waybar >/dev/null || break
    sleep 0.1
done
pkill -9 -x waybar 2>/dev/null

setsid -f waybar >"${XDG_CACHE_HOME:-$HOME/.cache}/waybar.log" 2>&1 </dev/null
