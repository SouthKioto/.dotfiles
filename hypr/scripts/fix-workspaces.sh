#!/usr/bin/env bash
for i in 1 2 3 4 5; do
    echo "dispatch moveworkspacetomonitor $i HDMI-A-2" | socat - "UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket.sock"
done
