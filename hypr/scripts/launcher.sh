#!/usr/bin/env bash
# Toggle launchera: jeśli rofi jest otwarte, zamknij je, w przeciwnym razie uruchom

if pgrep -x rofi >/dev/null; then
    pkill -x rofi
    exit 0
fi

rofi -show drun -no-config -theme "$HOME/.config/rofi/launcher.rasi"
