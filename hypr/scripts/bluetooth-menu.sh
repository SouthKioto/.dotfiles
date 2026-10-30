#!/usr/bin/env bash
# Bluetooth w Rofi (SUPER + SHIFT + B): sparowane urządzenia → połącz/rozłącz,
# włącz/wyłącz kartę. Parowanie nowych → bluetui.

THEME="$HOME/.config/rofi/menu.rasi"
notify() { notify-send -a "Bluetooth" -i bluetooth "$@"; }

powered=$(bluetoothctl show | awk '/Powered:/ {print $2}')

entries=()
declare -A mac_of
if [[ $powered == yes ]]; then
    while read -r _ mac name; do
        if bluetoothctl info "$mac" | grep -q 'Connected: yes'; then
            line="󰂱  $name   połączono"
        else
            line="󰂯  $name"
        fi
        entries+=("$line"); mac_of["$line"]=$mac
    done < <(bluetoothctl devices Paired)
    entries+=("󰂲  Wyłącz Bluetooth")
else
    entries+=("󰂯  Włącz Bluetooth")
fi
entries+=("󰒓  Parowanie / zaawansowane (bluetui)")

choice=$(printf '%s\n' "${entries[@]}" | rofi -dmenu -i -no-custom -p "" -mesg "Bluetooth" \
    -theme "$THEME" -theme-str "window { width: 480px; } listview { lines: ${#entries[@]}; }")
[[ -z $choice ]] && exit 0

case "$choice" in
    *"Wyłącz Bluetooth") bluetoothctl power off >/dev/null && notify "Bluetooth wyłączony" ;;
    *"Włącz Bluetooth") bluetoothctl power on >/dev/null && notify "Bluetooth włączony" ;;
    *bluetui*) kitty -e bluetui ;;
    *) mac=${mac_of[$choice]}
       name=$(sed 's/^.  //; s/   połączono$//' <<<"$choice")
       if [[ $choice == *połączono ]]; then
           bluetoothctl disconnect "$mac" >/dev/null && notify "Rozłączono $name"
       else
           notify "Łączenie z $name…"
           bluetoothctl connect "$mac" >/dev/null && notify "Połączono z $name" || notify -u critical "Nie udało się połączyć z $name"
       fi ;;
esac
