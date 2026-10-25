#!/bin/bash
# Pokazuje liczbę procesów obciążających CPU/RAM + top 5 w tooltipie
mapfile -t heavy < <(ps -eo pid,comm,%cpu,%mem --sort=-%cpu --no-headers \
    | awk '$3+0 > 3.0 || $4+0 > 2.0')

count=${#heavy[@]}
tooltip=$(printf '%s\n' "${heavy[@]:0:5}" | awk '{printf "%-6s %-20s CPU:%s%% MEM:%s%%\n", $1, $2, $3, $4}')

if [ -z "$tooltip" ]; then
    tooltip="Brak procesów obciążających system"
fi

printf '{"text":" %s","tooltip":"%s","class":"%s"}\n' \
    "$count" "$tooltip" "$([ "$count" -gt 5 ] && echo warning || echo normal)"
