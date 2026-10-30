#!/usr/bin/env bash
# Tryb skupienia: bez powiadomień (swaync DND) i bez widżetów na pulpicie
#   toggle   SUPER + D, klik we wskaźnik w waybarze
#   status   JSON dla waybara (custom/focus, sygnał 12)

STATE="${XDG_RUNTIME_DIR:-/tmp}/focus.on"
refresh() { pkill -RTMIN+12 -x waybar; }

case "$1" in
    toggle)
        if [[ -f $STATE ]]; then
            started=$(<"$STATE")
            rm -f "$STATE"
            swaync-client -df >/dev/null
            qs -c widgets ipc call widgets restore >/dev/null 2>&1
            mins=$(( ($(date +%s) - started) / 60 ))
            notify-send -a "Skupienie" -i face-smile "Koniec trybu skupienia" "Trwał ${mins} min"
        else
            date +%s >"$STATE"
            swaync-client -dn >/dev/null
            qs -c widgets ipc call widgets hide >/dev/null 2>&1
        fi
        refresh
        ;;
    status)
        if [[ -f $STATE ]]; then
            mins=$(( ($(date +%s) - $(<"$STATE")) / 60 ))
            printf '{"text":"󰽥 %s min","class":"active","tooltip":"Tryb skupienia: bez powiadomień i widżetów\\nklik / SUPER+D: zakończ"}\n' "$mins"
        else
            echo '{"text":"","class":"inactive"}'
        fi
        ;;
    *) echo "użycie: $0 toggle|status" >&2; exit 2 ;;
esac
