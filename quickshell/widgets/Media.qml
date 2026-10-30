// Odtwarzacz (MPRIS): okładka, tytuł, postęp, przyciski. Ukryty, gdy nic nie gra.
import Quickshell
import Quickshell.Services.Mpris
import QtQuick
import QtQuick.Layouts

Card {
    id: card
    // preferuj gracza, który aktualnie gra
    readonly property MprisPlayer player: Mpris.players.values.find(p => p.isPlaying) ?? Mpris.players.values[0] ?? null
    visible: player !== null

    // MPRIS nie wysyła pozycji na bieżąco — odpytujemy co sekundę, gdy gra
    Timer {
        interval: 1000; repeat: true
        running: card.player?.isPlaying ?? false
        onTriggered: card.player.positionChanged()
    }

    RowLayout {
        spacing: 14
        width: 300

        Rectangle {
            implicitWidth: 72; implicitHeight: 72
            radius: 3
            color: Colors.surfaceContainerHigh
            clip: true
            Image {
                anchors.fill: parent
                source: card.player?.trackArtUrl ?? ""
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                sourceSize { width: 144; height: 144 }
            }
            Text {
                anchors.centerIn: parent
                visible: !(card.player?.trackArtUrl)
                text: "󰎆"; color: Colors.primary
                font { family: "JetBrainsMono Nerd Font Propo"; pixelSize: 28 }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4

            Text {
                Layout.fillWidth: true
                text: card.player?.trackTitle || "—"
                elide: Text.ElideRight
                color: Colors.text
                font { family: "JetBrainsMono Nerd Font Propo"; pixelSize: 13; weight: Font.Bold }
            }
            Text {
                Layout.fillWidth: true
                text: card.player?.trackArtist ?? ""
                elide: Text.ElideRight
                color: Colors.textMuted
                font { family: "JetBrainsMono Nerd Font Propo"; pixelSize: 11; weight: Font.Bold }
            }
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 3
                radius: 2
                color: Colors.surfaceContainerHighest
                Rectangle {
                    height: parent.height; radius: 2
                    color: Colors.primary
                    width: card.player && card.player.length > 0 ? parent.width * card.player.position / card.player.length : 0
                }
            }
            RowLayout {
                spacing: 18
                Button { glyph: "󰒮"; onClicked: card.player.previous(); enabled: card.player?.canGoPrevious ?? false }
                Button { glyph: card.player?.isPlaying ? "󰏤" : "󰐊"; onClicked: card.player.togglePlaying(); big: true }
                Button { glyph: "󰒭"; onClicked: card.player.next(); enabled: card.player?.canGoNext ?? false }
            }
        }
    }

    component Button: Text {
        property string glyph
        property bool big: false
        signal clicked
        text: glyph
        color: area.containsMouse ? Colors.primary : Colors.text
        opacity: enabled ? 1 : 0.4
        font { family: "JetBrainsMono Nerd Font Propo"; pixelSize: big ? 22 : 16 }
        MouseArea { id: area; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: parent.clicked() }
    }
}
