// Pogoda z Open-Meteo (bez klucza API) dla kilku miejscowości: wybrana w całości
// (teraz + 3 dni), reszta jako lista. Klik w miasto / kółko myszy zmienia wybraną.
// Jedno zapytanie co 15 min. Lista miast w shell.qml: Weather { locations: [{ name, lat, lon }, …] }
import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

Card {
    id: card
    property var locations: []
    property int selected: 0
    property var results: []          // odpowiedź API: jeden obiekt na miasto, w kolejności locations

    readonly property string city: locations[selected]?.name ?? ""
    readonly property var current: results[selected]?.current ?? null
    readonly property var daily: results[selected]?.daily ?? null
    property bool failed: false

    readonly property string font: "JetBrainsMono Nerd Font Propo"

    // kod pogody WMO → [ikona dzień, ikona noc, opis]
    function wmo(code) {
        const g = c => String.fromCodePoint(c);
        if (code === 0) return [g(0xF0599), g(0xF0594), "bezchmurnie"];
        if (code === 1) return [g(0xF0595), g(0xF0F31), "przeważnie pogodnie"];
        if (code === 2) return [g(0xF0595), g(0xF0F31), "częściowe zachmurzenie"];
        if (code === 3) return [g(0xF0590), g(0xF0590), "pochmurno"];
        if (code === 45 || code === 48) return [g(0xF0591), g(0xF0591), "mgła"];
        if (code >= 51 && code <= 57) return [g(0xF0597), g(0xF0597), code >= 56 ? "marznąca mżawka" : "mżawka"];
        if (code >= 61 && code <= 67) return [g(0xF0596), g(0xF0596), code >= 66 ? "marznący deszcz" : code === 65 ? "ulewa" : "deszcz"];
        if (code >= 71 && code <= 77) return [g(0xF0598), g(0xF0598), code === 75 ? "intensywny śnieg" : "śnieg"];
        if (code >= 80 && code <= 82) return [g(0xF0596), g(0xF0596), "przelotne opady"];
        if (code === 85 || code === 86) return [g(0xF0F36), g(0xF0F36), "przelotny śnieg"];
        if (code >= 95) return [g(0xF067E), g(0xF067E), code === 95 ? "burza" : "burza z gradem"];
        return [g(0xF0590), g(0xF0590), "—"];
    }

    function icon(code, day) { return wmo(code)[day ? 0 : 1]; }

    Process {
        id: fetch
        // tee: kopia dla waybara (hypr/scripts/weather.sh czyta $XDG_RUNTIME_DIR/pogoda.json)
        command: ["sh", "-c", 'set -o pipefail; curl -sf -m 15 "$1" | tee "${XDG_RUNTIME_DIR:-/tmp}/pogoda.json"', "sh",
            "https://api.open-meteo.com/v1/forecast"
            + `?latitude=${card.locations.map(l => l.lat).join(",")}`
            + `&longitude=${card.locations.map(l => l.lon).join(",")}`
            + "&current=temperature_2m,apparent_temperature,relative_humidity_2m,weather_code,wind_speed_10m,is_day"
            + "&daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max"
            + "&timezone=auto&forecast_days=4"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const d = JSON.parse(text);
                    card.results = Array.isArray(d) ? d : [d];   // jedno miasto → obiekt, kilka → tablica
                    card.failed = false;
                } catch (e) {
                    card.failed = true;
                }
            }
        }
        onExited: code => {
            if (code !== 0) {
                card.failed = true;
                retry.start();
            }
        }
    }
    Timer { interval: 15 * 60 * 1000; running: true; repeat: true; triggeredOnStart: true; onTriggered: fetch.running = true }
    Timer { id: retry; interval: 2 * 60 * 1000; onTriggered: fetch.running = true } // brak sieci po wybudzeniu

    WheelHandler {
        onWheel: event => {
            const n = card.locations.length;
            if (n > 1)
                card.selected = (card.selected + (event.angleDelta.y < 0 ? 1 : n - 1)) % n;
        }
    }

    ColumnLayout {
        spacing: 10
        width: 300

        // brak danych przy starcie (np. jeszcze bez sieci)
        Text {
            visible: !card.current
            text: card.failed ? `${String.fromCodePoint(0xF0590)}  pogoda: brak połączenia` : `${String.fromCodePoint(0xF0590)}  pobieram pogodę…`
            color: Colors.textMuted
            font { family: card.font; pixelSize: 12; weight: Font.Bold }
        }

        RowLayout {
            visible: !!card.current
            Layout.fillWidth: true
            spacing: 14

            Text {
                text: card.current ? card.icon(card.current.weather_code, card.current.is_day) : ""
                color: Colors.primary
                font { family: card.font; pixelSize: 44 }
            }
            ColumnLayout {
                spacing: 0
                Text {
                    text: card.current ? `${Math.round(card.current.temperature_2m)}°` : ""
                    color: Colors.text
                    font { family: card.font; pixelSize: 30; weight: Font.Black }
                }
                Text {
                    text: card.current ? card.wmo(card.current.weather_code)[2] + (card.failed ? " · offline" : "") : ""
                    color: Colors.textMuted
                    font { family: card.font; pixelSize: 11; weight: Font.Bold }
                }
            }
            Item { Layout.fillWidth: true }
            ColumnLayout {
                spacing: 2
                Text {
                    Layout.alignment: Qt.AlignRight
                    text: `${String.fromCodePoint(0xF034E)} ${card.city}`
                    color: Colors.primary
                    font { family: card.font; pixelSize: 12; weight: Font.Bold }
                }
                Text {
                    Layout.alignment: Qt.AlignRight
                    text: card.current ? `odczuwalna ${Math.round(card.current.apparent_temperature)}°` : ""
                    color: Colors.textMuted
                    font { family: card.font; pixelSize: 11; weight: Font.Bold }
                }
                Text {
                    Layout.alignment: Qt.AlignRight
                    text: card.current
                        ? `${String.fromCodePoint(0xF058E)} ${card.current.relative_humidity_2m}%  ${String.fromCodePoint(0xF059D)} ${Math.round(card.current.wind_speed_10m)} km/h`
                        : ""
                    color: Colors.textMuted
                    font { family: card.font; pixelSize: 11; weight: Font.Bold }
                }
            }
        }

        Rectangle { visible: !!card.daily; Layout.fillWidth: true; implicitHeight: 1; color: Colors.outlineVariant }

        // 3 kolejne dni (indeks 0 = dziś, pomijamy) — równe kolumny po 100 px
        Row {
            visible: !!card.daily
            Layout.preferredWidth: 300

            Repeater {
                model: card.daily ? [1, 2, 3] : []
                delegate: Column {
                    required property int modelData
                    readonly property int i: modelData
                    width: 100
                    spacing: 2

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: new Date(card.daily.time[i] + "T12:00").toLocaleDateString(Qt.locale("pl_PL"), "dddd")
                        color: Colors.textMuted
                        font { family: card.font; pixelSize: 11; weight: Font.Bold; capitalization: Font.Capitalize }
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: card.icon(card.daily.weather_code[i], true)
                        color: Colors.secondary
                        font { family: card.font; pixelSize: 22 }
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: `${Math.round(card.daily.temperature_2m_max[i])}° / ${Math.round(card.daily.temperature_2m_min[i])}°`
                        color: Colors.text
                        font { family: card.font; pixelSize: 11; weight: Font.Bold }
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: `${String.fromCodePoint(0xF058C)} ${card.daily.precipitation_probability_max[i] ?? 0}%`
                        color: Colors.textMuted
                        font { family: card.font; pixelSize: 10; weight: Font.Bold }
                    }
                }
            }
        }

        // wszystkie miasta jako chipy: klik = pokaż szczegóły
        Flow {
            visible: card.locations.length > 1 && card.results.length > 0
            Layout.preferredWidth: 300
            spacing: 4

            Repeater {
                model: card.locations
                delegate: Rectangle {
                    required property var modelData
                    required property int index
                    readonly property var now: card.results[index]?.current ?? null
                    readonly property bool active: index === card.selected
                    implicitWidth: chip.implicitWidth + 12
                    implicitHeight: 20
                    radius: 3
                    color: active ? Colors.surfaceContainerHighest : (chipArea.containsMouse ? Colors.surfaceContainerHigh : "transparent")

                    Text {
                        id: chip
                        anchors.centerIn: parent
                        text: (now ? card.icon(now.weather_code, now.is_day) + " " : "") + modelData.name
                            + (now ? ` ${Math.round(now.temperature_2m)}°` : "")
                        color: active ? Colors.primary : Colors.textMuted
                        font { family: card.font; pixelSize: 11; weight: Font.Bold }
                    }
                    MouseArea {
                        id: chipArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: card.selected = index
                    }
                }
            }
        }
    }
}
