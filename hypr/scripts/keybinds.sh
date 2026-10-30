#!/usr/bin/env bash
# Ściąga skrótów (SUPER + F1) — generowana na żywo z `hyprctl binds`, czyli z opisów
# w modules/binds.lua i scratchpads.lua (nowy bind z description = sam się tu pojawi).
pgrep -x rofi >/dev/null && { pkill -x rofi; exit 0; }

# modmask → nazwy klawiszy (bitmaska Hyprlanda)
binds=$(hyprctl binds -j | jq -r '
    def mods: [ (if . / 64 | floor % 2 == 1 then "SUPER" else empty end),
                (if . / 4  | floor % 2 == 1 then "CTRL"  else empty end),
                (if . / 8  | floor % 2 == 1 then "ALT"   else empty end),
                (if .      % 2 == 1         then "SHIFT" else empty end) ];
    .[] | select(.has_description)
        | ((.modmask | mods) + [.key] | join(" + ")) as $k
        | "\($k)\t\(.description)"' \
    | awk -F'\t' '
        # workspace 1–10 zwijamy do jednej linii, reszta bez zmian
        $2 ~ /^Workspace [0-9]+$/           { if (!w++) print "SUPER + 1…0\tWorkspace 1–10"; next }
        $2 ~ /^Przenieś okno na workspace/  { if (!m++) print "SUPER + SHIFT + 1…0\tPrzenieś okno na workspace 1–10"; next }
        { print }' \
    | sed 's/grave/`/; s/period/./; s/mouse:272/LPM/; s/mouse:273/PPM/; s/mouse_down/scroll ↓/; s/mouse_up/scroll ↑/' \
    | awk -F'\t' '{ printf "%-28s %s\n", $1, $2 }')

rofi -dmenu -i -p "" -no-custom -mesg "Skróty Hyprlanda" \
    -theme "$HOME/.config/rofi/menu.rasi" \
    -theme-str '* { font: "JetBrainsMono Nerd Font Mono Bold 10"; } window { width: 640px; } listview { lines: 16; }' \
    -theme-str 'entry { placeholder: "szukaj skrótu…"; }' <<<"$binds" >/dev/null
