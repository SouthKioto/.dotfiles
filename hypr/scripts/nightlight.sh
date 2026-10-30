#!/usr/bin/env bash
# Nocne światło (hyprsunset) — ręczne przełączanie ponad harmonogramem z hypr/hyprsunset.conf
#   toggle   normalne kolory ↔ 4000K (SUPER + N, klik w waybarze)
#   status   JSON dla waybara (custom/nightlight, sygnał 11)
# Następna zmiana profilu w harmonogramie nadpisuje ręczny wybór.

STATE="${XDG_RUNTIME_DIR:-/tmp}/nightlight.manual"
refresh() { pkill -RTMIN+11 -x waybar; }

# czy według harmonogramu jest teraz noc (19:00–7:00)
scheduled_night() { local h=$((10#$(date +%H))); (( h >= 19 || h < 7 )); }

is_warm() {
    if [[ -f $STATE ]]; then [[ $(<"$STATE") == warm ]]; else scheduled_night; fi
}

case "$1" in
    toggle)
        if is_warm; then
            hyprctl hyprsunset identity >/dev/null && echo cold >"$STATE"
        else
            hyprctl hyprsunset temperature 4000 >/dev/null && echo warm >"$STATE"
        fi
        refresh
        ;;
    status)
        # ręczny wybór wygasa, gdy harmonogram zrówna się z nim
        if [[ -f $STATE ]] && { [[ $(<"$STATE") == warm ]] && scheduled_night || { [[ $(<"$STATE") == cold ]] && ! scheduled_night; }; }; then
            rm -f "$STATE"
        fi
        if ! pgrep -x hyprsunset >/dev/null; then
            echo '{"text":"","class":"off","tooltip":"hyprsunset nie działa"}'
        elif is_warm; then
            echo '{"text":"󰖔","class":"warm","tooltip":"Nocne światło: włączone\nklik: wyłącz"}'
        else
            echo '{"text":"󰖙","class":"cold","tooltip":"Nocne światło: wyłączone (auto od 19:00)\nklik: włącz"}'
        fi
        ;;
    *) echo "użycie: $0 toggle|status" >&2; exit 2 ;;
esac
