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

# logo fastfetch: kwadratowy kadr ze środka tapety
mkdir -p "$HOME/.cache/fastfetch"
magick "$WALLPAPER" -gravity center -crop "%[fx:min(w,h)]x%[fx:min(w,h)]+0+0" +repage \
    -resize 512x512 "$HOME/.cache/fastfetch/logo.png" 2>/dev/null || true
