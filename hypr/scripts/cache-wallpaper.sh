#!/usr/bin/env bash
set -euo pipefail

WALLPAPER="$1"
TARGET_DIR="$HOME/Obrazy/curr_wallpaper"

if [[ -z "$WALLPAPER" ]]; then
    echo "Usage: $0 <path-to-wallpaper>" >&2
    exit 1
fi

mkdir -p "$TARGET_DIR"

shopt -s nullglob
rm -f "$TARGET_DIR"/*
shopt -u nullglob

cp "$WALLPAPER" "$TARGET_DIR/curr_wallpaper.png"
