#!/bin/bash

EXTERNAL="HDMI-A-2"
INTERNAL="eDP-1"

move_to_external() {
    sleep 0.8
    for i in 1 2 3 4 5; do
        hyprctl dispatch moveworkspacetomonitor "$i $EXTERNAL"
    done
    hyprctl dispatch workspace 1
}

move_to_internal() {
    for i in 1 2 3 4 5; do
        hyprctl dispatch moveworkspacetomonitor "$i $INTERNAL"
    done
    hyprctl dispatch workspace 6
}

if hyprctl monitors | grep -q "$EXTERNAL"; then
    move_to_external
fi

socat - UNIX-CONNECT:/tmp/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock | \
while read -r line; do
    case "$line" in
        monitoradded\>\>*"$EXTERNAL"*)
            move_to_external ;;
        monitorremoved\>\>*"$EXTERNAL"*)
            move_to_internal ;;
    esac
done
