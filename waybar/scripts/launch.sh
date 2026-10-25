#!/usr/bin/env bash
# Restart Waybar (pkill zamiast SIGUSR2, żeby tray nie znikał)

pkill -x waybar

# poczekaj aż proces faktycznie się zamknie (max ~2 s)
for _ in $(seq 1 20); do
    pgrep -x waybar >/dev/null || break
    sleep 0.1
done

waybar >/dev/null 2>&1 &
disown
