import QtQuick
import QtQuick.Controls

Column {
    spacing: 20

    Text {
        text: "Select Language"
        font.pixelSize: 24
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Repeater {
        model: ["English", "Spanish", "French", "German"]

        RadioButton {
            text: modelData
            checked: index === 0
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
}
