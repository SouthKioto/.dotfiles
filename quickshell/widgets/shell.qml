// Widgety na pulpicie (punkt 20): zegar, statystyki systemu, odtwarzacz, pogoda + ściąga dev (prawy dół).
// Warstwa "bottom" — nad tapetą, pod oknami. Start: `qs -c widgets` (autostart.lua).
// Kolory: Colors.qml z matugena, odświeżane same przy zmianie tapety.
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

ShellRoot {
    id: root
    // główny monitor: LG, a bez docka — ekran laptopa
    readonly property var mainScreen: Quickshell.screens.find(s => s.model.includes("ULTRAGEAR")) ?? Quickshell.screens[0]
    property bool widgetsShown: true

    // tryb skupienia (SUPER + D, hypr/scripts/focus.sh): qs -c widgets ipc call widgets hide|restore
    IpcHandler {
        target: "widgets"
        function hide(): void { root.widgetsShown = false }
        function restore(): void { root.widgetsShown = true }   // nie "show" — koliduje z `qs ipc show`
        function toggle(): void { root.widgetsShown = !root.widgetsShown }
    }

    // Variants: przy odpięciu/podpięciu monitora okna są tworzone od nowa na aktualnym
    // ekranie — PanelWindow przypięty do usuniętego ekranu znikał na stałe
    Variants {
        model: Quickshell.screens.filter(s => s === root.mainScreen)

        Scope {
            required property var modelData

            PanelWindow {
                screen: modelData
                visible: root.widgetsShown
                WlrLayershell.layer: WlrLayer.Bottom
                WlrLayershell.namespace: "desktop-widgets"
                exclusionMode: ExclusionMode.Normal // pod waybarem, nie na nim
                color: "transparent"

                anchors { top: true; left: true }
                margins { top: 28; left: 32 }
                implicitWidth: column.implicitWidth
                implicitHeight: column.implicitHeight

                ColumnLayout {
                    id: column
                    spacing: 14

                    Clock {}
                    SysStats {}
                    Media {}
                    Weather {
                        // pierwsze = domyślnie wybrane; współrzędne z geocoding-api.open-meteo.com
                        locations: [
                            { name: "Podłopień", lat: 49.7366, lon: 20.3187 },
                            { name: "Tymbark", lat: 49.7286, lon: 20.3254 },
                            { name: "Limanowa", lat: 49.7059, lon: 20.4220 },
                            { name: "Kraków", lat: 50.0614, lon: 19.9366 },
                            { name: "Wadowice", lat: 49.8834, lon: 19.4929 },
                        ]
                    }
                }
            }

            // calcurse w prawym górnym rogu: rozwija się w dół po najechaniu, więc nie może być na dole kolumny
            PanelWindow {
                screen: modelData
                visible: root.widgetsShown && Quickshell.screens.some(s => s.model.includes("ULTRAGEAR"))
                WlrLayershell.layer: WlrLayer.Bottom
                WlrLayershell.namespace: "desktop-widgets"
                exclusionMode: ExclusionMode.Normal
                color: "transparent"

                anchors { top: true; right: true }
                margins { top: 28; right: 32 }
                implicitWidth: agenda.implicitWidth
                implicitHeight: agenda.implicitHeight

                Agenda { id: agenda }
            }

            // ściąga narzędzi dev w prawym dolnym rogu
            PanelWindow {
                screen: modelData
                visible: root.widgetsShown
                WlrLayershell.layer: WlrLayer.Bottom
                WlrLayershell.namespace: "desktop-widgets"
                exclusionMode: ExclusionMode.Normal
                color: "transparent"

                anchors { bottom: true; right: true }
                margins { bottom: 28; right: 32 }
                implicitWidth: cheatsheet.implicitWidth
                implicitHeight: cheatsheet.implicitHeight

                DevCheatsheet { id: cheatsheet }
            }
        }
    }

    Overview {} // SUPER + TAB
}
