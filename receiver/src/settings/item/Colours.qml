import QtQuick
import QtQuick.Controls

Column {
    spacing: 20
    property ButtonGroup themeGroup: ButtonGroup {}

    Text {
        text: "Select Colour Scheme"
        font.pixelSize: 24
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Repeater {
        model: ["Light", "Dark", "System Default"]

        RadioButton {
            text: modelData
            checked: index === 0
            ButtonGroup.group: parent.themeGroup
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
}
