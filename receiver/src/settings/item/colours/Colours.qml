import QtQuick
import QtQuick.Controls

Column {
    spacing: 20
    property ButtonGroup themeGroup: ButtonGroup {}

    Text {
        text: "Select Colour Scheme"
        font.pixelSize: 32
        font.bold: true
        anchors.horizontalCenter: parent.horizontalCenter
    }

    ListModel {
        id: themeModel
        ListElement {
            name: "Default"
            textColor: "#34495e"
            bgColor: "#dfe6e9"
            borderColor: "#7f8c8d"
        }
        ListElement {
            name: "Light"
            textColor: "#2c3e50"
            bgColor: "#ecf0f1"
            borderColor: "#bdc3c7"
        }
        ListElement {
            name: "Dark"
            textColor: "#ecf0f1"
            bgColor: "#2c3e50"
            borderColor: "#3498db"
        }
    }

    Repeater {
        model: themeModel

        Row {
            spacing: 15
            anchors.horizontalCenter: parent.horizontalCenter
            height: 60

            RadioButton {
                id: radio
                checked: index === 0
                ButtonGroup.group: themeGroup
                anchors.verticalCenter: parent.verticalCenter
            }

            SchemePreview {
                anchors.verticalCenter: parent.verticalCenter
                textColor: model.textColor
                bgColor: model.bgColor
                borderColor: model.borderColor
                exampleText: model.name
                borderWidth: 2
                radius: 5
                width: 250
                height: 60

                // Optional: Add hover effect
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: radio.checked = true
                }
            }
        }
    }
}
