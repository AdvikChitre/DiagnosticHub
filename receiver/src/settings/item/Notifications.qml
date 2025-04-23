import QtQuick
import QtQuick.Controls

Column {
    spacing: 20

    Text {
        text: "Notifications"
        font.pixelSize: 24
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Switch {
        text: "Flashing Light"
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Switch {
        text: "Sound Alert"
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Switch {
        text: "Vibration Alert"
        anchors.horizontalCenter: parent.horizontalCenter
    }
}
