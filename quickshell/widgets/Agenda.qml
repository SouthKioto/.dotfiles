// Najbliższe 7 dni z calcurse + zadania (todo). Odświeżanie co 5 min, klik = calcurse w kitty.
// Najechanie myszą rozwija kafelek: szerszy, wszystkie zadania, pełne nazwy zamiast ucinania.
// Prawy górny róg ekranu, tylko z monitorem LG (shell.qml), bo na samym laptopie brak miejsca.
import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

Card {
    id: card
    property var days: []     // [{ label, items: [{ time, text }] }]
    property var allTodos: [] // [{ prio, text }] posortowane po priorytecie
    readonly property int collapsedTodos: 4
    readonly property int maxTodos: 15   // limit po rozwinięciu, żeby kolumna nie wyszła poza ekran
    property bool expanded: false
    readonly property var todos: allTodos.slice(0, expanded ? maxTodos : collapsedTodos)
    readonly property string font: "JetBrainsMono Nerd Font Propo"

    function dayLabel(mm, dd, yy) {
        const d = new Date(2000 + yy, mm - 1, dd);
        const today = new Date(); today.setHours(0, 0, 0, 0);
        const diff = Math.round((d - today) / 86400000);
        if (diff === 0) return "Dziś";
        if (diff === 1) return "Jutro";
        return d.toLocaleDateString(Qt.locale("pl_PL"), "dddd, d MMM");
    }

    Process {
        id: probe
        command: ["sh", "-c",
            "calcurse -Q --days 7 --filter-type cal"
            + " --format-apt 'A|%S|%m\\n' --format-recur-apt 'A|%S|%m\\n'"
            + " --format-event 'A||%m\\n' --format-recur-event 'A||%m\\n';"
            + " calcurse -Q --filter-type todo --format-todo 'T|%p|%m\\n'"]
        stdout: StdioCollector {
            onStreamFinished: {
                const days = [], todos = [];
                let cur = null;
                for (const line of text.split("\n")) {
                    const h = line.match(/^(\d\d)\/(\d\d)\/(\d\d):$/);   // nagłówek dnia: mm/dd/yy:
                    if (h) {
                        cur = { label: card.dayLabel(+h[1], +h[2], +h[3]), items: [] };
                        days.push(cur);
                        continue;
                    }
                    const p = line.split("|");
                    if (p[0] === "A" && cur) cur.items.push({ time: p[1], text: p.slice(2).join("|") });
                    else if (p[0] === "T") todos.push({ prio: +p[1], text: p.slice(2).join("|") });
                }
                card.days = days;
                card.allTodos = todos.sort((a, b) => (a.prio || 10) - (b.prio || 10));
            }
        }
    }
    Timer { interval: 5 * 60 * 1000; running: true; repeat: true; triggeredOnStart: true; onTriggered: probe.running = true }

    // opóźnienie, żeby przejechanie kursorem po pulpicie nie rozwijało kafelka
    Timer { id: hoverDelay; interval: 250; onTriggered: card.expanded = area.containsMouse }

    MouseArea {
        id: area
        // inner z Card ma rozmiar 0x0, więc obszar liczony z kolumny + padding
        x: -card.padding; y: -card.padding
        width: col.width + card.padding * 2
        height: col.height + card.padding * 2
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onContainsMouseChanged: hoverDelay.restart()
        onClicked: Quickshell.execDetached(["kitty", "-e", "calcurse"])
    }

    ColumnLayout {
        id: col
        spacing: 6
        width: card.expanded ? 440 : 300
        Behavior on width { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

        Text {
            text: `${String.fromCodePoint(0xF00ED)}  Najbliższe 7 dni`
            color: Colors.text
            font { family: card.font; pixelSize: 13; weight: Font.Black }
        }

        Text {
            visible: card.days.length === 0
            text: "brak wydarzeń"
            color: Colors.textMuted
            font { family: card.font; pixelSize: 11; weight: Font.Bold }
        }

        Repeater {
            model: card.days
            delegate: ColumnLayout {
                required property var modelData
                Layout.fillWidth: true
                spacing: 2
                Text {
                    text: modelData.label
                    color: Colors.primary
                    font { family: card.font; pixelSize: 11; weight: Font.Bold; capitalization: Font.Capitalize }
                }
                Repeater {
                    model: modelData.items
                    delegate: Text {
                        required property var modelData
                        Layout.fillWidth: true
                        text: (modelData.time ? modelData.time + "  " : "•  ") + modelData.text
                        elide: Text.ElideRight
                        color: Colors.text
                        font { family: card.font; pixelSize: 11; weight: Font.Bold }
                    }
                }
            }
        }

        Rectangle { visible: card.todos.length > 0; Layout.fillWidth: true; implicitHeight: 1; color: Colors.outlineVariant }

        Text {
            visible: card.allTodos.length > 0
            text: `Zadania (${card.allTodos.length})`
            color: Colors.text
            font { family: card.font; pixelSize: 11; weight: Font.Black }
        }

        Repeater {
            model: card.todos
            delegate: Text {
                required property var modelData
                Layout.fillWidth: true
                text: `${String.fromCodePoint(0xF0131)}  ${modelData.text}`
                elide: card.expanded ? Text.ElideNone : Text.ElideRight
                wrapMode: card.expanded ? Text.WordWrap : Text.NoWrap
                color: modelData.prio > 0 && modelData.prio <= 3 ? Colors.error : Colors.textMuted
                font { family: card.font; pixelSize: 11; weight: Font.Bold }
            }
        }

        Text {
            readonly property int hidden: card.allTodos.length - card.todos.length
            visible: hidden > 0
            text: card.expanded ? `+${hidden} więcej w calcurse` : `+${hidden} więcej (najedź, żeby rozwinąć)`
            color: Colors.textMuted
            font { family: card.font; pixelSize: 10; weight: Font.Bold; italic: true }
        }
    }
}
