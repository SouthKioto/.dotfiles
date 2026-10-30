#!/usr/bin/env bash
# Profile zasilania (TLP / tlp-pd przez D-Bus net.hadess.PowerProfiles)
#   status  JSON dla modułu waybara custom/power
#   cycle   performance → balanced → power-saver → …   (klik w waybarze)
#   menu    wybór w rofi (SUPER + SHIFT + P)
#   watch   demon z autostartu: przy każdej zmianie profilu (też automatycznej
#           po odpięciu zasilacza) zapisuje stan i przeładowuje Hyprlanda —
#           modules/powersave.lua wyłącza wtedy animacje i blur

STATE="${XDG_RUNTIME_DIR:-/tmp}/power-profile"
PROFILES=(performance balanced power-saver)

current() { tlpctl get 2>/dev/null || echo balanced; }

label() {
    case "$1" in
        performance) echo "󰓅|Wydajność" ;;
        power-saver) echo "󰾆|Oszczędzanie (bez animacji i bluru)" ;;
        *) echo "󰾅|Zrównoważony" ;;
    esac
}

apply() {
    local p; p=$(current)
    [[ $(cat "$STATE" 2>/dev/null) == "$p" ]] && return
    echo "$p" >"$STATE"
    hyprctl reload >/dev/null
    pkill -RTMIN+9 -x waybar
}

case "${1:-status}" in
    status)
        p=$(current); IFS='|' read -r icon name <<<"$(label "$p")"
        printf '{"text":"%s","tooltip":"Profil: %s\\nKlik: następny  |  PPM: menu","class":"%s","alt":"%s"}\n' \
            "$icon" "$name" "$p" "$p"
        ;;
    cycle)
        p=$(current)
        for i in "${!PROFILES[@]}"; do [[ ${PROFILES[$i]} == "$p" ]] && break; done
        tlpctl set "${PROFILES[(i + 1) % 3]}" >/dev/null
        ;;
    menu)
        p=$(current)
        choice=$(for x in "${PROFILES[@]}"; do
                IFS='|' read -r icon name <<<"$(label "$x")"
                printf '%s  %s%s\n' "$icon" "$name" "$([[ $x == "$p" ]] && echo '  ')"
            done | rofi -dmenu -i -no-custom -p "" -mesg "Profil zasilania" \
                -theme "$HOME/.config/rofi/menu.rasi" \
                -theme-str 'inputbar { enabled: false; } listview { lines: 3; }')
        case "$choice" in
            *Wydajność*) tlpctl set performance ;;
            *Zrównoważony*) tlpctl set balanced ;;
            *Oszczędzanie*) tlpctl set power-saver ;;
        esac >/dev/null
        ;;
    watch)
        rm -f "$STATE"
        apply
        dbus-monitor --system "type='signal',interface='org.freedesktop.DBus.Properties',member='PropertiesChanged',path='/net/hadess/PowerProfiles'" 2>/dev/null |
            while read -r line; do
                [[ $line == *ActiveProfile* ]] && apply
            done
        ;;
esac
