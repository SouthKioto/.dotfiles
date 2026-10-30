// SDDM: wygląd 1:1 z hyprlockiem (hypr/hyprlock.conf.template)
import QtQuick
import QtQuick.Effects
import QtQuick.Controls

Rectangle {
    id: root
    width: 1920 // SDDM i tak rozciąga do rozmiaru ekranu
    height: 1080
    color: config.surface

    readonly property string font: "Noto Sans"
    readonly property color textColor: Qt.rgba(216 / 255, 222 / 255, 233 / 255, 0.7)
    property int sessionIndex: sessionModel.lastIndex
    // ostatni zalogowany, a gdy go brak (pierwszy start) — pierwszy użytkownik z listy
    property string user: userModel.lastUser || (users.count > 0 ? users.itemAt(0).name : "")
    Repeater { id: users; model: userModel; delegate: Item { required property string name } }

    Connections {
        target: sddm
        function onLoginFailed() {
            password.text = "";
            password.hint = "  Złe hasło";
            shake.start();
        }
    }

    // ── tło: tapeta + blur (blur_passes 3, brightness 0.82, contrast 0.89) ──
    Image {
        id: wallpaper
        anchors.fill: parent
        source: config.background
        fillMode: Image.PreserveAspectCrop
        visible: false
    }
    MultiEffect {
        anchors.fill: parent
        source: wallpaper
        blurEnabled: true
        blur: 1.0
        blurMax: 48
        brightness: -0.18
        contrast: -0.11
        saturation: 0.17
    }

    // ── data i godzina ──
    Text {
        id: date
        anchors { horizontalCenter: parent.horizontalCenter; verticalCenter: parent.verticalCenter; verticalCenterOffset: -350 }
        color: root.textColor
        font { family: root.font; pixelSize: 33; bold: true }
        text: clock.now.toLocaleDateString(Qt.locale(), "dddd, d MMMM")
    }
    Text {
        anchors { horizontalCenter: parent.horizontalCenter; verticalCenter: parent.verticalCenter; verticalCenterOffset: -250 }
        color: root.textColor
        font { family: root.font; pixelSize: 160; bold: true }
        // jak hyprlock: %I:%M (12 h, bez AM/PM)
        text: String((clock.now.getHours() + 11) % 12 + 1).padStart(2, "0") + ":" + String(clock.now.getMinutes()).padStart(2, "0")
    }
    Timer {
        id: clock
        property date now: new Date()
        interval: 1000; running: true; repeat: true
        onTriggered: now = new Date()
    }

    // ── avatar ──
    Item {
        id: avatar
        width: 130; height: 130
        anchors { horizontalCenter: parent.horizontalCenter; verticalCenter: parent.verticalCenter; verticalCenterOffset: -40 }
        Image {
            id: avatarImg
            anchors.fill: parent
            source: config.avatar
            fillMode: Image.PreserveAspectCrop
            visible: false
            layer.enabled: true
        }
        Rectangle { id: avatarMask; anchors.fill: parent; radius: width / 2; visible: false; layer.enabled: true }
        MultiEffect {
            anchors.fill: parent
            source: avatarImg
            maskEnabled: true
            maskSource: avatarMask
        }
    }

    Column {
        id: form
        spacing: 20
        anchors { horizontalCenter: parent.horizontalCenter; verticalCenter: parent.verticalCenter; verticalCenterOffset: 170 }

        // ── użytkownik ──
        Rectangle {
            width: 300; height: 60
            radius: height / 2
            color: Qt.rgba(1, 1, 1, 0.1)
            Text {
                anchors.centerIn: parent
                color: Qt.rgba(216 / 255, 222 / 255, 233 / 255, 0.8)
                font { family: root.font; pixelSize: 24; bold: true }
                text: "    " + root.user
            }
        }

        // ── hasło ──
        TextField {
            id: password
            width: 300; height: 60
            echoMode: TextInput.Password
            passwordCharacter: "●"
            horizontalAlignment: TextInput.AlignHCenter
            color: "#c8c8c8"
            font { family: root.font; pixelSize: 18; bold: true }
            property string hint: "  Enter Pass"
            focus: true
            background: Rectangle {
                radius: height / 2
                color: Qt.rgba(1, 1, 1, 0.1)
                border.width: password.activeFocus ? 2 : 0
                border.color: config.primary
            }
            onTextEdited: hint = "  Enter Pass"
            onAccepted: sddm.login(root.user, text, root.sessionIndex)

            Text { // placeholder widoczny też przy fokusie (jak w hyprlocku)
                anchors.centerIn: parent
                visible: password.text.length === 0
                text: password.hint
                color: Qt.rgba(1, 1, 1, 0.6)
                font { family: root.font; pixelSize: 18; bold: true; italic: true }
            }
            Keys.onEscapePressed: text = ""

            SequentialAnimation {
                id: shake
                loops: 2
                NumberAnimation { target: password; property: "x"; to: 12; duration: 50 }
                NumberAnimation { target: password; property: "x"; to: -12; duration: 50 }
                NumberAnimation { target: password; property: "x"; to: 0; duration: 50 }
            }
        }
    }

    // ── dół: sesja + zasilanie ──
    Row {
        anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom; bottomMargin: 40 }
        spacing: 28

        Text {
            id: session
            color: Qt.rgba(1, 1, 1, 0.6)
            font { family: "JetBrainsMono Nerd Font Propo"; pixelSize: 16; bold: true }
            text: "  " + (sessionNames.itemAt(root.sessionIndex)?.name ?? "")
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.sessionIndex = (root.sessionIndex + 1) % sessionModel.count
            }
            Repeater { id: sessionNames; model: sessionModel; delegate: Item { required property string name } }
        }
        PowerButton { glyph: "󰤄"; visible: sddm.canSuspend; onClicked: sddm.suspend() }
        PowerButton { glyph: ""; visible: sddm.canReboot; onClicked: sddm.reboot() }
        PowerButton { glyph: ""; visible: sddm.canPowerOff; onClicked: sddm.powerOff() }
    }

    component PowerButton: Text {
        property string glyph
        signal clicked
        text: glyph
        color: area.containsMouse ? config.primary : Qt.rgba(1, 1, 1, 0.6)
        font { family: "JetBrainsMono Nerd Font Propo"; pixelSize: 20 }
        MouseArea { id: area; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: parent.clicked() }
    }

    Component.onCompleted: password.forceActiveFocus()
}
