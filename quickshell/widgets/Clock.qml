import Quickshell
import QtQuick

Column {
    spacing: -6

    SystemClock { id: clock; precision: SystemClock.Seconds }

    Text {
        text: Qt.formatTime(clock.date, "HH:mm")
        color: Colors.text
        font { family: "JetBrainsMono Nerd Font Propo"; pixelSize: 96; weight: Font.Black }
        style: Text.Raised
        styleColor: Qt.rgba(0, 0, 0, 0.4)
    }
    Text {
        leftPadding: 6
        text: clock.date.toLocaleDateString(Qt.locale("pl_PL"), "dddd, d MMMM")
        color: Colors.primary
        font { family: "JetBrainsMono Nerd Font Propo"; pixelSize: 20; weight: Font.Bold }
        style: Text.Raised
        styleColor: Qt.rgba(0, 0, 0, 0.4)
    }
}
