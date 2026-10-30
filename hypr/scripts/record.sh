#!/usr/bin/env bash
# Nagrywanie ekranu (wf-recorder, sprzętowe H.264 przez VA-API na iGPU)
#   region | screen [audio]   start; jeśli już nagrywa → stop
#   menu                      wybór w rofi (SUPER + ALT + SHIFT + R)
#   status                    JSON dla waybara (custom/recording, sygnał 10)
# Pliki: ~/Wideo/Nagrania

PIDFILE="${XDG_RUNTIME_DIR:-/tmp}/record.pid"
DIR="$(xdg-user-dir VIDEOS 2>/dev/null || echo "$HOME/Wideo")/Nagrania"

running() { [[ -f $PIDFILE ]] && kill -0 "$(<"$PIDFILE")" 2>/dev/null; }
refresh() { pkill -RTMIN+10 -x waybar; }

stop() {
    local pid; pid=$(<"$PIDFILE")
    kill -INT "$pid"
    while kill -0 "$pid" 2>/dev/null; do sleep 0.1; done
    local file; file=$(<"$PIDFILE.file")
    rm -f "$PIDFILE" "$PIDFILE.file"
    refresh
    action=$(notify-send -a "Nagrywanie" -i video-x-generic "Zapisano nagranie" "$(basename "$file")" \
        -A open="Otwórz" -A dir="Pokaż w folderze")
    case "$action" in
        open) xdg-open "$file" ;;
        dir) kitty -e yazi "$file" ;;
    esac
}

start() { # $1 = region|screen, $2 = audio (opcjonalnie)
    local args=()
    case "$1" in
        region)
            local geo; geo=$(slurp -d) || exit 0
            args+=(-g "$geo") ;;
        screen)
            args+=(-o "$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .name')") ;;
    esac
    [[ $2 == audio ]] && args+=("--audio=$(pactl get-default-sink).monitor")
    [[ -e /dev/dri/renderD128 ]] && args+=(-c h264_vaapi -d /dev/dri/renderD128)

    mkdir -p "$DIR"
    local file; file="$DIR/nagranie_$(date +%Y-%m-%d_%H-%M-%S).mp4"
    wf-recorder "${args[@]}" -f "$file" >"${XDG_CACHE_HOME:-$HOME/.cache}/wf-recorder.log" 2>&1 &
    echo $! >"$PIDFILE"
    echo "$file" >"$PIDFILE.file"
    sleep 0.3
    if ! running; then
        rm -f "$PIDFILE" "$PIDFILE.file"
        notify-send -a "Nagrywanie" -u critical "Nie udało się nagrywać" "Log: ~/.cache/wf-recorder.log"
        exit 1
    fi
    refresh
}

case "${1:-region}" in
    status)
        if running; then
            printf '{"text":"󰑊 REC","tooltip":"Nagrywanie od %s — klik: stop","class":"recording"}\n' \
                "$(date -r "$PIDFILE" +%H:%M:%S)"
        else
            echo '{"text":""}'
        fi
        ;;
    menu)
        running && { stop; exit; }
        choice=$(printf '%s\n' \
            "󰩭  Obszar" "󰩭  Obszar + dźwięk systemu" \
            "󰍹  Cały ekran" "󰍹  Cały ekran + dźwięk systemu" \
            | rofi -dmenu -i -no-custom -p "" -mesg "Nagrywanie ekranu → ~/Wideo/Nagrania" \
                -theme "$HOME/.config/rofi/menu.rasi" \
                -theme-str 'inputbar { enabled: false; } listview { lines: 4; }')
        case "$choice" in
            *Obszar*dźwięk*) start region audio ;;
            *Obszar*) start region ;;
            *ekran*dźwięk*) start screen audio ;;
            *ekran*) start screen ;;
        esac
        ;;
    region | screen)
        if running; then stop; else start "$1" "$2"; fi
        ;;
    stop)
        running && stop
        ;;
esac
