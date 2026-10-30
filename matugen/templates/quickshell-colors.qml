// Matugen — nie edytuj ręcznie. Quickshell przeładowuje widgety sam po zmianie pliku.
pragma Singleton
import Quickshell
import QtQuick

Singleton {
    readonly property color primary: "#{{colors.primary.default.hex_stripped}}"
    readonly property color textOnPrimary: "#{{colors.on_primary.default.hex_stripped}}"
    readonly property color primaryContainer: "#{{colors.primary_container.default.hex_stripped}}"
    readonly property color secondary: "#{{colors.secondary.default.hex_stripped}}"
    readonly property color tertiary: "#{{colors.tertiary.default.hex_stripped}}"
    readonly property color error: "#{{colors.error.default.hex_stripped}}"
    readonly property color surface: "#{{colors.surface.default.hex_stripped}}"
    readonly property color surfaceContainer: "#{{colors.surface_container.default.hex_stripped}}"
    readonly property color surfaceContainerHigh: "#{{colors.surface_container_high.default.hex_stripped}}"
    readonly property color surfaceContainerHighest: "#{{colors.surface_container_highest.default.hex_stripped}}"
    readonly property color text: "#{{colors.on_surface.default.hex_stripped}}"
    readonly property color textMuted: "#{{colors.on_surface_variant.default.hex_stripped}}"
    readonly property color outline: "#{{colors.outline.default.hex_stripped}}"
    readonly property color outlineVariant: "#{{colors.outline_variant.default.hex_stripped}}"
}
