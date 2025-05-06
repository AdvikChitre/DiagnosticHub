// Notifications.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Column {
    spacing: 20
    width: parent.width

    Text {
        text: "Notifications"
        font.pixelSize: 24
        anchors.horizontalCenter: parent.horizontalCenter
    }

    GridLayout {
        columns: 2
        rowSpacing: 25
        columnSpacing: 20
        anchors.horizontalCenter: parent.horizontalCenter
        Layout.fillWidth: true

        // Flash
        Text {
            text: "Flashing Light"
            font.pixelSize: 16
            Layout.alignment: Qt.AlignLeft
        }
        RoundedSwitch {
            checked: appStorage.notifyFlash
            onCheckedChanged: appStorage.notifyFlash = checked
            Layout.alignment: Qt.AlignRight
        }

        // Sound
        Text {
            text: "Sound Alert"
            font.pixelSize: 16
            Layout.alignment: Qt.AlignLeft
        }
        RoundedSwitch {
            checked: appStorage.notifyAudio
            onCheckedChanged: appStorage.notifyAudio = checked
            Layout.alignment: Qt.AlignRight
        }

        // Vibration
        Text {
            text: "Vibration Alert"
            font.pixelSize: 16
            Layout.alignment: Qt.AlignLeft
        }
        RoundedSwitch {
            checked: appStorage.notifyHaptic
            onCheckedChanged: {
                appStorage.notifyHaptic = checked
                console.log(appStorage.notifyHaptic)
            }
            Layout.alignment: Qt.AlignRight
        }
    }
}
