#!/usr/bin/env bash
# Wywoływany przez gamemoded (~/.config/gamemode.ini) przy starcie / końcu gry.
#   start: bez animacji, bluru i przyciemniania, profil performance, powiadomienia wyciszone
#   end:   przeładuj Hyprlanda (przywraca config), TLP z powrotem na automat, powiadomienia włączone

case "$1" in
    start)
        hyprctl eval 'hl.config({ animations = { enabled = false }, decoration = { blur = { enabled = false }, dim_inactive = false } })' >/dev/null
        tlpctl performance >/dev/null 2>&1
        swaync-client --dnd-on >/dev/null 2>&1
        ;;
    end)
        hyprctl reload >/dev/null
        if [[ $(cat /sys/class/power_supply/AC/online 2>/dev/null) == 1 ]]; then
            tlpctl performance >/dev/null 2>&1
        else
            tlpctl balanced >/dev/null 2>&1
        fi
        swaync-client --dnd-off >/dev/null 2>&1
        ;;
esac
