// Podgląd workspace'ów (SUPER + TAB) — zamiennik hyprexpo, który wypadł z hyprland-plugins.
// Siatka workspace'ów z fokusowanego monitora z żywymi miniaturami okien.
// Klik w workspace/okno → przejście, 1–9 → workspace, Esc / SUPER + TAB → zamknij.
// Sterowanie: `qs -c widgets ipc call overview toggle`
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick

Scope {
    id: root
    property bool shown: false
    property string monitorName: ""

    function open() {
        Hyprland.refreshWorkspaces()
        Hyprland.refreshToplevels()
        monitorName = Hyprland.focusedMonitor?.name ?? ""
        shown = true
    }

    function go(dispatcher) {
        Hyprland.dispatch(dispatcher)
        shown = false
    }

    IpcHandler {
        target: "overview"
        function toggle(): void { root.shown ? root.shown = false : root.open() }
        function close(): void { root.shown = false }
    }

    LazyLoader {
        active: root.shown

        PanelWindow {
            id: win
            readonly property HyprlandMonitor monitor: Hyprland.monitors.values.find(m => m.name === root.monitorName) ?? null
            readonly property var workspaces: Hyprland.workspaces.values
                .filter(w => w.id > 0 && w.monitor?.name === root.monitorName)
                .sort((a, b) => a.id - b.id)

            // siatka: kolumny ~ pierwiastek, kafelek w proporcjach monitora
            readonly property int cols: Math.max(2, Math.ceil(Math.sqrt(workspaces.length)))
            readonly property int rows: Math.ceil(workspaces.length / cols)
            readonly property real monW: (monitor?.width ?? 1920) / (monitor?.scale ?? 1)
            readonly property real monH: (monitor?.height ?? 1080) / (monitor?.scale ?? 1)
            readonly property real tileScale: Math.min((width * 0.86 - (cols - 1) * 18) / cols / monW,
                                                       (height * 0.82 - (rows - 1) * 18) / rows / monH)

            screen: Quickshell.screens.find(s => s.name === root.monitorName) ?? null
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.namespace: "overview"
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
            exclusionMode: ExclusionMode.Ignore
            anchors { top: true; bottom: true; left: true; right: true }
            color: "transparent"

            Rectangle {
                id: backdrop
                anchors.fill: parent
                color: Qt.alpha(Colors.surface, 0.72)
                opacity: 0
                Component.onCompleted: opacity = 1
                Behavior on opacity { NumberAnimation { duration: 140; easing.type: Easing.OutQuad } }
            }

            MouseArea { // klik w tło zamyka
                anchors.fill: parent
                onClicked: root.shown = false
            }

            Item {
                anchors.fill: parent
                focus: true
                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Escape || event.key === Qt.Key_Tab) {
                        root.shown = false
                    } else if (event.key >= Qt.Key_1 && event.key <= Qt.Key_9) {
                        root.go(`hl.dsp.focus({ workspace = ${event.key - Qt.Key_0} })`)
                    }
                }
            }

            Grid {
                anchors.centerIn: parent
                columns: win.cols
                spacing: 18
                scale: backdrop.opacity * 0.06 + 0.94 // lekki "zoom in" przy otwarciu

                Repeater {
                    model: win.workspaces

                    Rectangle {
                        id: tile
                        required property HyprlandWorkspace modelData
                        readonly property bool current: win.monitor?.activeWorkspace?.id === modelData.id

                        width: win.monW * win.tileScale
                        height: win.monH * win.tileScale
                        radius: 6
                        clip: true
                        color: Colors.surfaceContainer
                        border.width: current ? 3 : (tileMouse.containsMouse ? 2 : 0)
                        border.color: current ? Colors.primary : Colors.outline

                        Image {
                            anchors.fill: parent
                            source: "file://" + Quickshell.env("HOME") + "/Obrazy/curr_wallpaper/curr_wallpaper.png"
                            fillMode: Image.PreserveAspectCrop
                            sourceSize.width: width
                            asynchronous: true
                            opacity: 0.55
                        }

                        MouseArea {
                            id: tileMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: root.go(`hl.dsp.focus({ workspace = ${tile.modelData.id} })`)
                        }

                        // okna: najpierw kafelkowe, pływające na wierzchu
                        Repeater {
                            model: tile.modelData.toplevels.values
                                .filter(t => t.lastIpcObject?.at)
                                .sort((a, b) => (a.lastIpcObject.floating ? 1 : 0) - (b.lastIpcObject.floating ? 1 : 0))

                            Rectangle {
                                id: thumb
                                required property HyprlandToplevel modelData
                                readonly property var ipc: modelData.lastIpcObject

                                x: (ipc.at[0] - (win.monitor?.x ?? 0)) * win.tileScale
                                y: (ipc.at[1] - (win.monitor?.y ?? 0)) * win.tileScale
                                width: ipc.size[0] * win.tileScale
                                height: ipc.size[1] * win.tileScale
                                radius: 4
                                clip: true
                                color: Colors.surfaceContainerHigh
                                border.width: thumbMouse.containsMouse ? 2 : 0
                                border.color: Colors.primary

                                Text { // zastępczo, zanim przyjdzie klatka
                                    anchors.centerIn: parent
                                    width: parent.width - 8
                                    visible: !view.hasContent
                                    text: thumb.ipc.class ?? ""
                                    color: Colors.textMuted
                                    font { family: "JetBrainsMono Nerd Font Propo"; pixelSize: 11 }
                                    horizontalAlignment: Text.AlignHCenter
                                    elide: Text.ElideRight
                                }

                                ScreencopyView {
                                    id: view
                                    anchors.fill: parent
                                    captureSource: thumb.modelData.wayland
                                    live: true
                                    constraintSize: Qt.size(parent.width, parent.height)
                                }

                                MouseArea {
                                    id: thumbMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: root.go(`hl.dsp.focus({ window = "address:${thumb.ipc.address}" })`)
                                }
                            }
                        }

                        Rectangle { // numer workspace'a
                            anchors { left: parent.left; bottom: parent.bottom; margins: 8 }
                            width: 26; height: 26; radius: 13
                            color: tile.current ? Colors.primary : Qt.alpha(Colors.surface, 0.85)

                            Text {
                                anchors.centerIn: parent
                                text: tile.modelData.id
                                color: tile.current ? Colors.textOnPrimary : Colors.text
                                font { family: "JetBrainsMono Nerd Font Propo"; pixelSize: 13; bold: true }
                            }
                        }
                    }
                }
            }
        }
    }
}
