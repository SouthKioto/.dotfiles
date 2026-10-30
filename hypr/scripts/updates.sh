#!/usr/bin/env bash
# Liczba aktualizacji w waybarze (custom/updates, sygnał 13): repo (checkupdates) + AUR (yay -Qua)
#   status   JSON (co godzinę)
#   run      aktualizacja w kitty, potem odświeżenie licznika

refresh() { pkill -RTMIN+13 -x waybar; }

case "${1:-status}" in
    status)
        repo=$(checkupdates 2>/dev/null)
        aur=$(yay -Qua 2>/dev/null)
        n_repo=$(grep -c . <<<"$repo")
        n_aur=$(grep -c . <<<"$aur")
        total=$((n_repo + n_aur))
        if ((total == 0)); then
            echo '{"text":"","class":"none"}'
            exit 0
        fi
        list=$( { head -15 <<<"$repo"; head -5 <<<"$aur" | sed 's/^/[AUR] /'; } | sed '/^$/d' | jq -Rs .)
        printf '{"text":"󰏗 %d","class":"%s","tooltip":%s}\n' "$total" \
            "$( ((total >= 50)) && echo many || echo some)" \
            "$(jq -n --argjson l "$list" --arg h "Aktualizacje: $n_repo repo + $n_aur AUR" '$h + "\n\n" + $l + "\nklik: yay -Syu"')"
        ;;
    run)
        kitty --class floating-update -e bash -c 'yay -Syu; echo; read -rp "Enter, aby zamknąć…"'
        refresh
        ;;
esac
