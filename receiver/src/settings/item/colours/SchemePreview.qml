// ColoredTextComponent.qml
import QtQuick 2.15

Rectangle {
    id: root
    // Customizable properties
    required property color textColor
    required property color bgColor
    required property color borderColor
    property string exampleText: "Abc"
    property int borderWidth: 2

    // Visual properties
    color: bgColor               // Background color
    border.color: borderColor        // Border color
    border.width: borderWidth   // Border width

    // Centered text
    Text {
        text: root.exampleText
        color: textColor
        anchors.centerIn: parent
        font.pixelSize: 16
    }

    // Default size (can be overridden)
    implicitWidth: 200
    implicitHeight: 50
}
