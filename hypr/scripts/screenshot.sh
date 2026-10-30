#!/usr/bin/env bash
# Zrzut ekranu + adnotacje:  region | window | output
# satty (Enter = schowek + zapis w ~/Obrazy, Esc = anuluj); bez satty → swappy jak dawniej
mode="${1:-region}"
if command -v satty >/dev/null; then
    # satty ma własne ikony, a wczytanie motywu Papirus kosztuje GTK4 ~3 s startu →
    # osobny katalog GTK z ikonami Adwaita (gtk.css i fontconfig to symlinki do głównych);
    # no-portals, bo portal i tak podałby Papirus-Dark zamiast settings.ini
    hyprshot -m "$mode" --raw | XDG_CONFIG_HOME="$HOME/.config/satty/gtk" GDK_DEBUG=no-portals \
        satty -c "$HOME/.config/satty/config.toml" --filename -
else
    hyprshot -m "$mode" --raw | swappy -f -
fi
