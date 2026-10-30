#!/usr/bin/env bash
# Przypomnienie o kopii na GitHubie: repozytoria z niezacommitowanymi / niewypchniętymi zmianami.
#   (bez argumentów)  powiadomienie, jeśli coś czeka (systemd --user: git-check.timer, codziennie 20:00)
#   --report          pełna lista w terminalu
# Lista repo: REPOS + wszystko w ~/Projekty i ~/Nauka.

REPOS=(~/.config ~/.config/nvim ~/.config/fish ~/Dokumenty/obsidian-notes)
for d in ~/Projekty/* ~/Nauka/*; do [[ -d $d/.git ]] && REPOS+=("$d"); done

report=()
for d in "${REPOS[@]}"; do
    [[ -d $d/.git ]] || continue
    cd "$d" || continue
    git fetch -q 2>/dev/null
    name=${d#"$HOME"/}
    branch=$(git branch --show-current)
    dirty=$(git status --porcelain 2>/dev/null | wc -l)
    parts=()
    ((dirty > 0)) && parts+=("$dirty zmian(y) bez commita")
    if git rev-parse -q --verify "refs/remotes/origin/$branch" >/dev/null; then
        ahead=$(git rev-list --count "origin/$branch..HEAD")
        ((ahead > 0)) && parts+=("$ahead commit(ów) do wypchnięcia")
    else
        parts+=("gałąź '$branch' nie istnieje na zdalnym")
    fi
    if ((${#parts[@]})); then
        line="$name: ${parts[0]}"
        ((${#parts[@]} > 1)) && line+="; ${parts[1]}"
        report+=("$line")
    fi
done

if [[ $1 == --report ]]; then
    if ((${#report[@]})); then printf '%s\n' "${report[@]}"; else echo "Wszystko jest na zdalnym ✔"; fi
    exit 0
fi

((${#report[@]})) || exit 0
body=$(printf '• %s\n' "${report[@]:0:6}")
((${#report[@]} > 6)) && body+=$'\n'"…i $(( ${#report[@]} - 6 )) więcej"
action=$(notify-send -a "Kopia" -i git -u normal "Niewypchnięte zmiany: ${#report[@]} repo" "$body" -A show="Pokaż listę")
[[ $action == show ]] && kitty --hold -e "$0" --report
