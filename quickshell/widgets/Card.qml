// Kafelek w stylu waybara: 3px, cień, jaśniejsza krawędź od dołu
import QtQuick

Rectangle {
    default property alias content: inner.data
    property int padding: 14

    implicitWidth: inner.childrenRect.width + padding * 2
    implicitHeight: inner.childrenRect.height + padding * 2
    radius: 3
    color: Qt.alpha(Colors.surface, 0.82)
    border.width: 0

    Rectangle { // dolna krawędź
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
        height: 1
        radius: 3
        color: Qt.rgba(1, 1, 1, 0.2)
    }

    Item {
        id: inner
        x: parent.padding
        y: parent.padding
    }
}
