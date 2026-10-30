#!/usr/bin/env bash
# Pogoda w waybarze (custom/weather). Dane pobiera widżet Quickshell (Weather.qml) co 15 min
# i zapisuje do $XDG_RUNTIME_DIR/pogoda.json — tu tylko je czytamy, bez drugiego zapytania.
# Pasek: pierwsze miasto z listy w shell.qml; tooltip: wszystkie.

FILE="${XDG_RUNTIME_DIR:-/tmp}/pogoda.json"
# nazwy miast w tej samej kolejności co zapytanie — jedyne źródło: quickshell/widgets/shell.qml
NAMES=$(grep -oP '\{ name: "\K[^"]+' ~/.config/quickshell/widgets/shell.qml | jq -R . | jq -sc .)

[[ -s $FILE ]] || { echo '{"text":"","class":"empty"}'; exit 0; }

jq -c --argjson names "$NAMES" '
  def icon(c; day):
    if c == 0 then (if day == 1 then "󰖙" else "󰖔" end)
    elif c <= 2 then (if day == 1 then "󰖕" else "󰼱" end)
    elif c == 3 then "󰖐"
    elif c == 45 or c == 48 then "󰖑"
    elif c <= 57 then "󰖗"
    elif c <= 67 or (c >= 80 and c <= 82) then "󰖖"
    elif c <= 77 or c == 85 or c == 86 then "󰖘"
    else "󰙾" end;
  (if type == "array" then . else [.] end) as $all
  | $all[0].current as $c
  | {
      text: "\(icon($c.weather_code; $c.is_day)) \($c.temperature_2m | round)°",
      tooltip: ([range(0; $all | length) as $i
                 | $all[$i].current as $x
                 | "\(icon($x.weather_code; $x.is_day))  \($names[$i] // "?"): \($x.temperature_2m | round)° (odczuwalna \($x.apparent_temperature | round)°)"]
                | join("\n")) + "\n\nklik: pokaż/ukryj widżety",
      class: "ok"
    }' "$FILE" 2>/dev/null || echo '{"text":"","class":"empty"}'
