// CPU / RAM / temperatura / bateria / uptime — jeden `sh` co 2 s (zamiast kilku procesów)
import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

Card {
    id: card
    property real cpu: 0
    property real memUsed: 0
    property real memTotal: 1
    property int temp: 0
    property int battery: -1
    property string batStatus: ""
    property string uptime: ""
    property var lastCpu: null

    Process {
        id: probe
        command: ["sh", "-c", "head -1 /proc/stat; grep -E '^(MemTotal|MemAvailable):' /proc/meminfo; cat /sys/class/thermal/thermal_zone*/temp 2>/dev/null | sort -n | tail -1; cat /sys/class/power_supply/BAT0/capacity /sys/class/power_supply/BAT0/status 2>/dev/null; cut -d. -f1 /proc/uptime"]
        stdout: StdioCollector {
            onStreamFinished: {
                const l = text.trim().split("\n");
                const c = l[0].split(/\s+/).slice(1).map(Number);
                const idle = c[3] + c[4], total = c.reduce((a, b) => a + b, 0);
                if (card.lastCpu)
                    card.cpu = 100 * (1 - (idle - card.lastCpu.idle) / Math.max(1, total - card.lastCpu.total));
                card.lastCpu = { idle, total };
                card.memTotal = parseInt(l[1].split(/\s+/)[1]) / 1048576;
                card.memUsed = card.memTotal - parseInt(l[2].split(/\s+/)[1]) / 1048576;
                card.temp = Math.round(parseInt(l[3]) / 1000);
                const hasBat = l.length >= 7;
                card.battery = hasBat ? parseInt(l[4]) : -1;
                card.batStatus = hasBat ? l[5] : "";
                const up = parseInt(l[l.length - 1]);
                card.uptime = `${Math.floor(up / 3600)}h ${Math.floor(up % 3600 / 60)}m`;
            }
        }
    }
    Timer { interval: 2000; running: true; repeat: true; triggeredOnStart: true; onTriggered: probe.running = true }

    ColumnLayout {
        spacing: 8
        width: 300

        Stat { icon: ""; label: "CPU"; value: `${Math.round(card.cpu)}%`; fraction: card.cpu / 100 }
        Stat { icon: ""; label: "RAM"; value: `${card.memUsed.toFixed(1)} / ${card.memTotal.toFixed(0)} G`; fraction: card.memUsed / card.memTotal }
        Stat { icon: ""; label: "TEMP"; value: `${card.temp}°C`; fraction: Math.min(1, card.temp / 100); hot: card.temp >= 80 }
        Stat {
            visible: card.battery >= 0
            icon: card.batStatus === "Charging" ? "󰂄" : "󰁹"
            label: "BAT"; value: `${card.battery}%`; fraction: card.battery / 100; hot: card.battery <= 15 && card.batStatus !== "Charging"
        }
        Text {
            text: `󰔟  uptime ${card.uptime}`
            color: Colors.textMuted
            font { family: "JetBrainsMono Nerd Font Propo"; pixelSize: 12; weight: Font.Bold }
        }
    }

    component Stat: ColumnLayout {
        property string icon
        property string label
        property string value
        property real fraction
        property bool hot: false
        spacing: 3
        Layout.fillWidth: true

        RowLayout {
            Layout.fillWidth: true
            Text { text: `${icon}  ${label}`; color: Colors.textMuted; font { family: "JetBrainsMono Nerd Font Propo"; pixelSize: 12; weight: Font.Bold } }
            Item { Layout.fillWidth: true }
            Text { text: value; color: hot ? Colors.error : Colors.text; font { family: "JetBrainsMono Nerd Font Propo"; pixelSize: 12; weight: Font.Bold } }
        }
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 4
            radius: 2
            color: Colors.surfaceContainerHighest
            Rectangle {
                width: parent.width * Math.max(0, Math.min(1, fraction))
                height: parent.height
                radius: 2
                color: hot ? Colors.error : Colors.primary
                Behavior on width { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }
            }
        }
    }
}
