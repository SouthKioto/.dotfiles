#!/usr/bin/env bash
# Gałąź + znacznik zmian dla zjstatus; nic nie wypisuje poza repozytorium
branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null) || exit 0
dirty=""
[ -n "$(git status --porcelain --untracked-files=no 2>/dev/null | head -1)" ] && dirty=" ●"
printf ' %s%s │' "$branch" "$dirty"
